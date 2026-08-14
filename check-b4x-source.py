#!/usr/bin/env python3
"""Static verification for B4X source files (B4A projects and modules).

A general-purpose, dependency-free (Python standard library only) tool that
catches the structural mistakes which break the B4A/B4J compiler before they
reach the IDE, especially the classic AI mistake of editing a fluent chain and
leaving a parenthesis out of balance.

It validates every B4X source file it can find (.b4a and .bas), so it keeps
working even if the examples/ folder is deleted or a project is moved. Pass
explicit files or directories to check a subset.

Checks performed on every scanned file:

1. Header sanity
   - at most one UTF-8 BOM, and only at the very start of the file;
   - exactly one '@EndOfDesignText@' marker.

2. Statement-level parenthesis balance
   A B4X statement is one line, extended by trailing ' _' continuations.
   Parentheses inside strings ("...") and comments (') are ignored, so text
   such as "Total (USD)" or 'see note (1)' cannot cause false positives.

3. Continuation '_' rules
   - a continuation must be a trailing '_' outside strings and comments;
   - project style is ' _' (space before the underscore) - a missing space
     is reported as a warning;
   - a continuation must be followed by a code line, not a blank line and
     not a comment-only line.

4. Structural pairing (in the code section, after '@EndOfDesignText@')
   - '#Region' ... '#End Region'
   - 'Sub' ... 'End Sub'
   - 'Type' ... 'End Type'

Exit code 0 = no errors; 1 = at least one error. Warnings never fail by
themselves (call with --strict to make them fatal). A missing file, an
unreadable file or an empty scan result also exits 1.

Usage:
    python check-b4x-source.py [files-or-dirs...] [--strict]
    With no arguments, scans the repository that contains this script for
    *.b4a and *.bas files (skipping VCS/build/cache directories).
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BOM = b"\xef\xbb\xbf"
END_OF_DESIGN_TEXT = "@EndOfDesignText@"
SUPPORTED_SUFFIXES = {".b4a", ".bas"}

# Directories never scanned during a recursive scan. Stored lowercase so the
# comparison is case-insensitive (Windows/macOS filesystems are not).
IGNORED_DIRS = {
    ".git",
    ".hg",
    ".svn",
    ".agents",
    ".vscode",
    "objects",
    "autobackups",
    "build",
    "dist",
    "node_modules",
    "__pycache__",
    ".pytest_cache",
    ".mypy_cache",
}

ERROR = "ERROR"
WARN = "WARN"


class Line:
    """One source line with a precomputed view of its code (comments stripped,
    strings kept) and continuation facts."""

    __slots__ = ("number", "code", "is_continuation", "space_before_underscore")

    def __init__(self, number: int, code: str, is_continuation: bool,
                 space_before_underscore: bool):
        self.number = number
        self.code = code
        self.is_continuation = is_continuation
        self.space_before_underscore = space_before_underscore


def split_code_comment(line: str) -> str:
    """Return the code part of a B4X line: everything before a ' that starts a
    comment. Strings ("...") are tracked so an apostrophe inside a string is
    not treated as a comment marker. B4X strings never span lines."""
    code: list[str] = []
    in_string = False
    i = 0
    n = len(line)
    while i < n:
        ch = line[i]
        if in_string:
            code.append(ch)
            if ch == '"':
                in_string = False
            i += 1
        elif ch == '"':
            in_string = True
            code.append(ch)
            i += 1
        elif ch == "'":
            break  # rest of the line is a comment
        else:
            code.append(ch)
            i += 1
    return "".join(code)


def count_parens(code: str) -> tuple[int, int]:
    """Count '(' and ')' in code, ignoring strings and comments (comments are
    already stripped; strings must still be skipped)."""
    opens = 0
    closes = 0
    in_string = False
    i = 0
    n = len(code)
    while i < n:
        ch = code[i]
        if in_string:
            if ch == '"':
                in_string = False
            i += 1
        elif ch == '"':
            in_string = True
            i += 1
        elif ch == "(":
            opens += 1
            i += 1
        elif ch == ")":
            closes += 1
            i += 1
        else:
            i += 1
    return opens, closes


def continuation_facts(line: str) -> tuple[bool, bool]:
    """Return (is_continuation, space_before_underscore) for a raw line.

    A continuation is a trailing '_' that sits outside strings and comments.
    space_before_underscore is True when the '_' is preceded by whitespace or
    is the first character of the line."""
    in_string = False
    i = 0
    n = len(line)
    last_significant = -1
    while i < n:
        ch = line[i]
        if in_string:
            if ch == '"':
                in_string = False
            i += 1
        elif ch == '"':
            in_string = True
            i += 1
        elif ch == "'":
            break  # comment to end of line
        elif not ch.isspace():
            last_significant = i
            i += 1
        else:
            i += 1
    if last_significant < 0 or line[last_significant] != "_":
        return False, False
    space_before = last_significant == 0 or line[last_significant - 1].isspace()
    return True, space_before


def is_blank_or_comment(line: str) -> bool:
    stripped = line.strip()
    return stripped == "" or stripped.startswith("'")


def check_header(raw: bytes, text: str, path: str) -> list[tuple[str, int, str, str]]:
    issues: list[tuple[str, int, str, str]] = []

    # BOM: exactly one, only at position 0. A doubled BOM at the start has
    # historically broken B4A header parsing.
    if raw.startswith(BOM + BOM):
        issues.append((ERROR, 1, "double UTF-8 BOM at the start of the file; exactly one is allowed", path))
    elif not raw.startswith(BOM):
        issues.append((WARN, 1, "missing UTF-8 BOM (B4X writes one; add it to avoid header parse issues)", path))
    if raw[1:].find(BOM) >= 0:
        issues.append((WARN, 1, "UTF-8 BOM found after the start of the file; it may break header parsing", path))

    marker_count = text.count(END_OF_DESIGN_TEXT)
    if marker_count != 1:
        issues.append((ERROR, 1, f"expected exactly one '{END_OF_DESIGN_TEXT}' marker, found {marker_count}", path))

    return issues


def check_file(path: Path) -> list[tuple[str, int, str, str]]:
    """Validate one B4X source file. Returns (severity, line, message, path)."""
    issues: list[tuple[str, int, str, str]] = []
    path_text = str(path)

    try:
        raw = path.read_bytes()
    except OSError as exc:
        issues.append((ERROR, 1, f"cannot read file: {exc}", path_text))
        return issues

    text = raw.decode("utf-8-sig", errors="replace")
    issues.extend(check_header(raw, text, path_text))

    # Only the code section (after the design-text marker) is analyzed.
    # Without the marker, the whole file is analyzed as code; check_header
    # already reports the missing marker as an error.
    marker_index = text.find(END_OF_DESIGN_TEXT)
    marker_line = text[:marker_index].count("\n") if marker_index >= 0 else -1

    all_lines = text.splitlines()
    code_lines: list[Line] = []
    for number, raw_line in enumerate(all_lines, start=1):
        if marker_line >= 0 and number <= marker_line + 1:
            continue  # header region, includes the marker line itself
        code = split_code_comment(raw_line)
        is_cont, space_before = continuation_facts(raw_line)
        code_lines.append(Line(number, code, is_cont, space_before))

    # ---- Statement grouping + parenthesis balance ---------------------------
    statement_parts: list[tuple[int, str]] = []

    def flush_statement() -> None:
        if not statement_parts:
            return
        opens = closes = 0
        for _, part in statement_parts:
            o, c = count_parens(part)
            opens += o
            closes += c
        if opens != closes:
            balance = opens - closes
            issues.append((
                ERROR,
                statement_parts[-1][0],
                f"parenthesis balance is {balance:+d} (opens={opens}, closes={closes}); "
                f"statement starts on line {statement_parts[0][0]}",
                path_text,
            ))
        statement_parts.clear()

    for line in code_lines:
        statement_parts.append((line.number, line.code))
        if not line.is_continuation:
            flush_statement()
    flush_statement()  # the final statement, even when the file ends with ' _'

    # ---- Continuation rules -------------------------------------------------
    for i, line in enumerate(code_lines):
        if not line.is_continuation:
            continue
        if not line.space_before_underscore:
            issues.append((
                WARN,
                line.number,
                "continuation '_' is not preceded by a space (project style is ' _')",
                path_text,
            ))
        if i + 1 >= len(code_lines):
            issues.append((ERROR, line.number, "line ends with ' _' but is the last line of the file", path_text))
        else:
            nxt = all_lines[code_lines[i + 1].number - 1]
            if is_blank_or_comment(nxt):
                issues.append((
                    ERROR,
                    line.number,
                    "line ends with ' _' but the next line is blank or a comment; "
                    "a continuation must be followed by code",
                    path_text,
                ))

    # ---- Structural pairing -------------------------------------------------
    region_stack: list[int] = []
    type_stack: list[int] = []
    sub_stack: list[int] = []
    for line in code_lines:
        s = line.code.strip()
        if re.match(r"^#Region\b", s):
            region_stack.append(line.number)
        elif re.match(r"^#End Region\b", s):
            if region_stack:
                region_stack.pop()
            else:
                issues.append((ERROR, line.number, "'#End Region' without a matching '#Region'", path_text))
        elif re.match(r"^End\s+Type\s*$", s):
            if type_stack:
                type_stack.pop()
            else:
                issues.append((ERROR, line.number, "'End Type' without a matching 'Type'", path_text))
        elif re.match(r"^(Public\s+|Private\s+)?Type\s+", s):
            type_stack.append(line.number)
        elif re.match(r"^End\s+Sub\s*$", s):
            if sub_stack:
                sub_stack.pop()
            else:
                issues.append((ERROR, line.number, "'End Sub' without a matching 'Sub'", path_text))
        elif re.match(r"^(Public\s+|Private\s+)?Sub\b", s):
            sub_stack.append(line.number)

    for opened in region_stack:
        issues.append((ERROR, opened, "'#Region' without a matching '#End Region'", path_text))
    for opened in type_stack:
        issues.append((ERROR, opened, "'Type' without a matching 'End Type'", path_text))
    for opened in sub_stack:
        issues.append((ERROR, opened, "'Sub' without a matching 'End Sub'", path_text))

    return issues


def collect_targets(args: list[str], default_root: Path) -> list[Path]:
    """Resolve the files to check. With no arguments, scan the directory that
    contains this script for *.b4a and *.bas, skipping VCS/build/cache dirs."""
    if args:
        targets: list[Path] = []
        for raw in args:
            p = Path(raw)
            if p.is_dir():
                for suffix in SUPPORTED_SUFFIXES:
                    targets.extend(_rglob_skipping(p, suffix))
            elif p.is_file():
                if p.suffix.lower() in SUPPORTED_SUFFIXES:
                    targets.append(p)
                else:
                    print(f"check-b4x-source: skipping unsupported file {p} "
                          f"(supported: {', '.join(sorted(SUPPORTED_SUFFIXES))})", file=sys.stderr)
            else:
                print(f"check-b4x-source: no such file or directory: {p}", file=sys.stderr)
        return _unique_sorted(targets)

    targets = []
    for suffix in SUPPORTED_SUFFIXES:
        targets.extend(_rglob_skipping(default_root, suffix))
    return _unique_sorted(targets)


def _rglob_skipping(root: Path, suffix: str) -> list[Path]:
    result: list[Path] = []
    for path in root.rglob(f"*{suffix}"):
        # Case-insensitive match: filesystems like Windows/macOS are
        # case-insensitive, so 'Build' or 'OBJECTS' must be ignored too.
        if any(part.lower() in IGNORED_DIRS for part in path.parts):
            continue
        result.append(path)
    return result


def _unique_sorted(paths: list[Path]) -> list[Path]:
    seen: set[str] = set()
    unique: list[Path] = []
    for p in sorted(paths):
        key = str(p).lower() if sys.platform == "win32" else str(p)
        if key not in seen:
            seen.add(key)
            unique.append(p)
    return unique


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate B4X source files (.b4a/.bas): parenthesis balance, "
        "' _' continuations and structural pairing. No third-party dependencies."
    )
    parser.add_argument("paths", nargs="*", help="files or directories to check (default: scan this repository)")
    parser.add_argument("--strict", action="store_true", help="treat warnings as errors")
    args = parser.parse_args()

    default_root = Path(__file__).resolve().parent
    targets = collect_targets(args.paths, default_root)
    if not targets:
        print("check-b4x-source: no .b4a/.bas files found", file=sys.stderr)
        return 1

    all_issues: list[tuple[str, int, str, str]] = []
    for target in targets:
        all_issues.extend(check_file(target))

    # Deterministic order: path, line.
    all_issues.sort(key=lambda item: (item[3], item[1]))

    error_count = 0
    warning_count = 0
    for severity, line_number, message, path in all_issues:
        print(f"{path}:{line_number}: {severity}: {message}")
        if severity == ERROR:
            error_count += 1
        else:
            warning_count += 1

    print(f"\nChecked {len(targets)} file(s): {error_count} error(s), {warning_count} warning(s).")
    if error_count > 0:
        return 1
    if args.strict and warning_count > 0:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
