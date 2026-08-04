#!/usr/bin/env python3
"""Build a compact, dependency-free PDF from FORUM_GUIDE.md.

The output intentionally uses only built-in PDF fonts and simple text layout.
No images or font files are embedded, keeping the forum attachment below the
hard 300 KiB limit.
"""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "FORUM_GUIDE.md"
OUTPUT = ROOT / "DeclarativeUI-ForumGuide.pdf"
# The forum limit is interpreted strictly as 300,000 bytes.
MAX_BYTES = 300_000

PAGE_WIDTH = 595
PAGE_HEIGHT = 842
LEFT = 48
RIGHT = 48
TOP = 52
BOTTOM = 48
BODY_SIZE = 9.2
CODE_SIZE = 8.1
LEADING = 12
CODE_LEADING = 10


def pdf_escape(text: str) -> str:
    # The built-in PDF fonts are intentionally used to keep the attachment
    # tiny. Normalize typography explicitly instead of silently emitting '?'
    # for characters that Latin-1 cannot represent.
    replacements = {
        "•": "-",
        "→": "->",
        "←": "<-",
        "—": "-",
        "–": "-",
        "…": "...",
        "“": '"',
        "”": '"',
        "‘": "'",
        "’": "'",
        "©": "(c)",
        " ": " ",
    }
    for source, replacement in replacements.items():
        text = text.replace(source, replacement)
    text = text.replace("\\", "\\\\")
    text = text.replace("(", "\\(").replace(")", "\\)")
    return text.encode("latin-1", "replace").decode("latin-1")


def wrap_text(text: str, width: int):
    if not text:
        return [""]
    words = text.split()
    lines = []
    current = ""
    for word in words:
        candidate = word if not current else current + " " + word
        if len(candidate) <= width:
            current = candidate
        else:
            if current:
                lines.append(current)
            # Keep very long URLs/tokens readable without overflowing the page.
            while len(word) > width:
                lines.append(word[:width])
                word = word[width:]
            current = word
    if current:
        lines.append(current)
    return lines or [""]


def markdown_lines(source: str):
    in_code = False
    for raw in source.splitlines():
        line = raw.rstrip()
        if line.strip().startswith("```"):
            in_code = not in_code
            yield ("blank", "")
            continue
        if in_code:
            yield ("code", line)
            continue
        if not line.strip():
            yield ("blank", "")
            continue
        if line.startswith("### "):
            yield ("h3", line[4:])
        elif line.startswith("## "):
            yield ("h2", line[3:])
        elif line.startswith("# "):
            yield ("h1", line[2:])
        elif line.startswith("- "):
            yield ("bullet", "• " + line[2:])
        elif re.match(r"^\d+\. ", line):
            yield ("body", line)
        elif line.startswith("> "):
            yield ("quote", line[2:])
        elif line.startswith("| ") or line.startswith("---"):
            # Tables are compactly represented as plain text rows.
            if not line.startswith("---"):
                yield ("body", line.replace("|", "  ").strip())
        else:
            # Remove lightweight Markdown emphasis/backticks for a clean PDF.
            clean = re.sub(r"[`*_]", "", line)
            yield ("body", clean)


def make_content(source: str):
    pages = []
    page = []
    y = PAGE_HEIGHT - TOP

    def height(kind):
        if kind == "h1":
            return 28
        if kind == "h2":
            return 22
        if kind == "h3":
            return 17
        if kind == "code":
            return CODE_LEADING
        return LEADING

    def push(kind, text):
        nonlocal page, y
        page.append((kind, text, y))
        y -= height(kind)

    def new_page():
        nonlocal page, y
        if page:
            pages.append(page)
        page = []
        y = PAGE_HEIGHT - TOP

    for kind, text in markdown_lines(source):
        if kind == "blank":
            if page and y < PAGE_HEIGHT - TOP - 4:
                y -= 5
            continue
        width = 88 if kind == "code" else 92
        wrapped = wrap_text(text, width)
        block_height = sum(height(kind) for _ in wrapped)
        if y - block_height < BOTTOM:
            new_page()
        for line in wrapped:
            push(kind, line)

    if page:
        pages.append(page)
    return pages


def stream_for_page(page, number):
    commands = ["q"]
    for kind, text, y in page:
        if kind == "h1":
            font, size, color = "F2", 18, "0.16 0.20 0.28"
        elif kind == "h2":
            font, size, color = "F2", 13, "0.24 0.20 0.50"
        elif kind == "h3":
            font, size, color = "F2", 10.5, "0.16 0.20 0.28"
        elif kind == "code":
            font, size, color = "F3", CODE_SIZE, "0.08 0.08 0.08"
        elif kind == "quote":
            font, size, color = "F1", BODY_SIZE, "0.28 0.28 0.28"
        elif kind == "bullet":
            font, size, color = "F1", BODY_SIZE, "0.08 0.08 0.08"
        else:
            font, size, color = "F1", BODY_SIZE, "0.08 0.08 0.08"
        commands.append(f"BT /{font} {size} Tf {color} rg {LEFT} {y} Td ({pdf_escape(text)}) Tj ET")
    commands.append(f"BT /F1 8 Tf 0.45 0.45 0.45 rg {PAGE_WIDTH - RIGHT - 35} 25 Td ({number}) Tj ET")
    commands.append("Q")
    return "\n".join(commands).encode("latin-1", "replace")


def build_pdf(source: str):
    pages = make_content(source)
    objects = []

    def add(obj: bytes):
        objects.append(obj)
        return len(objects)

    catalog = add(b"")
    pages_obj = add(b"")
    font_regular = add(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")
    font_bold = add(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>")
    font_mono = add(b"<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>")

    page_ids = []
    for number, page in enumerate(pages, 1):
        content = stream_for_page(page, number)
        content_id = add(b"<< /Length " + str(len(content)).encode() + b" >>\nstream\n" + content + b"\nendstream")
        page_id = add(
            f"<< /Type /Page /Parent {pages_obj} 0 R /MediaBox [0 0 {PAGE_WIDTH} {PAGE_HEIGHT}] "
            f"/Resources << /Font << /F1 {font_regular} 0 R /F2 {font_bold} 0 R /F3 {font_mono} 0 R >> >> "
            f"/Contents {content_id} 0 R >>".encode()
        )
        page_ids.append(page_id)

    kids = " ".join(f"{pid} 0 R" for pid in page_ids)
    objects[pages_obj - 1] = f"<< /Type /Pages /Kids [{kids}] /Count {len(page_ids)} >>".encode()
    objects[catalog - 1] = f"<< /Type /Catalog /Pages {pages_obj} 0 R >>".encode()

    output = bytearray(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets = [0]
    for index, obj in enumerate(objects, 1):
        offsets.append(len(output))
        output.extend(f"{index} 0 obj\n".encode())
        output.extend(obj)
        output.extend(b"\nendobj\n")
    xref = len(output)
    output.extend(f"xref\n0 {len(objects) + 1}\n0000000000 65535 f \n".encode())
    for offset in offsets[1:]:
        output.extend(f"{offset:010d} 00000 n \n".encode())
    output.extend(
        f"trailer\n<< /Size {len(objects) + 1} /Root {catalog} 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode()
    )
    return bytes(output), len(pages)


def main():
    if not SOURCE.exists():
        print(f"Missing source: {SOURCE}", file=sys.stderr)
        return 2
    pdf, pages = build_pdf(SOURCE.read_text(encoding="utf-8"))
    OUTPUT.write_bytes(pdf)
    size = OUTPUT.stat().st_size
    print(f"Created: {OUTPUT}")
    print(f"Pages: {pages}")
    print(f"Size: {size} bytes ({size / 1024:.1f} KiB)")
    print(f"Limit: {MAX_BYTES} bytes")
    if size >= MAX_BYTES:
        print("ERROR: PDF exceeds the mandatory 300 KB limit", file=sys.stderr)
        return 1
    print("OK: PDF is below the mandatory 300 KB limit")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
