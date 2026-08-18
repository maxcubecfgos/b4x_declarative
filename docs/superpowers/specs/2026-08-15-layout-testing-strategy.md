# Layout testing strategy (measurement and distribution)

Date: 2026-08-15
Status: Implemented (see tests/ and tests/README.md)

## Context

The library has no automated tests. The layout layer (GetContentSize natural
measurement plus the Column/Row/Expanded distribution in Render) is the most
algorithmic, most regressible pure logic in the project, and it is where a
wrong integer division or a changed spacing rule breaks every screen. B4X code
cannot run outside the B4A IDE/device, so there is no obvious unit-test host.

Two prior experiments shaped this design:
- `check-b4x-source.py` proves the project is comfortable with Python tooling
  for fast, dependency-free checks.
- `_tmp_main_harness.txt` proved the project's informal on-device harness
  convention (`DeclarativeUI TEST PASS/FAIL ...` log lines) works.

## Goals

1. A single, shared list of cases (source of truth) that both a fast
   host-side checker and the real on-device library execute.
2. Fast feedback without an emulator: layout regressions should be caught in
   seconds by a Python oracle that mirrors the B4X math line by line.
3. Authoritative verification against the real classes: an on-device runner
   that mounts real trees on a panel and asserts the rects the engine assigns.
4. Explicit documentation of the B4X semantics that the oracle must mirror.

## Non-goals

- Replacing the B4X source with a reimplementation. The B4X classes stay
  authoritative; the Python oracle is a *port* and a spec check.
- Testing font metrics (device-dependent by design).
- Testing Android-only paths (safe-area insets, ripple drawables) off-device.
- A full virtual-DOM diff engine or UI automation framework.

## Design

### Tier 1 - Python oracle (fast, host-side, CI-able)

`tests/layout_oracle.py` ports the measurement and distribution math of
UIColumn, UIRow, UIExpanded, UILabel, UIPadding, UIVisibility, UICenter,
UIStack, UIDivider and UISpace. `tests/test_layout.py` runs every shared case
through the oracle and prints `PASS/FAIL` plus a summary; it works as a plain
CLI script and under pytest (exit code 0 only when all cases pass).

### Tier 2 - On-device harness (authoritative)

`tests/UITestRunner.bas` builds the same widget trees with the real UI.*
classes, mounts them on a panel, and asserts:
- natural size via GetContentSize on every measure case;
- the mounted container's native view size after Render (MainAxisSize min/max);
- the exact rect assigned to every child, read back through a recording
  widget (`tests/TestProbe.bas`) that implements the widget protocol but
  creates no native view. In probe mode, `space` and `expanded` leaves become
  probes, so natural and flexible children are both covered.

### Shared case list

`tests/layout_cases.json` is the single source of truth:
- 30 measure cases (M1..M30): leaves, wrappers, containers, clamping, the
  flexible marker, nested containers, and hidden-UIVisibility participation.
- 25 layout cases (L1..L25): every MainAxisAlignment (start/center/end/
  spaceBetween/spaceAround/spaceEvenly), MainAxisSize min/max, cross-axis
  stretch/start/center/end, Expanded remainder distribution, overflow
  clipping, empty containers, nesting and hidden children.

`tests/generate_harness_cases.py` regenerates `tests/generated/harness_cases.bas`
from the JSON, so the device harness always runs the same numbers as the
Python suite. The generator emits a B4X module with exactly one UTF-8 BOM and
CRLF endings, and the output is validated by the repo's own checker
(`python3 check-b4x-source.py tests/`).

## B4X semantics the oracle must mirror

These are the traps that made hand-computed expectations wrong on the first
run, and the reason the oracle is a mirror instead of a reimplementation:

1. Integer division: `/` between two Ints is INTEGER division in B4X (use
   `//` in Python). `remaining / count`, `free / 2`, and every alignment
   formula depend on this.
2. Float -> Int assignment ROUNDS (use `round()`), e.g. the label line-height
   formula.
3. The 10000-dip sentinel: every GetContentSize converts non-positive bounds
   to 10000 before clamping. This is why UIColumn measuring children with
   MaxHeight=0 still yields full natural heights.
4. `Mod` remainder: the extra pixel of an uneven Expanded split goes to the
   FIRST expanded children, in child order.
5. `ParticipatesInLayout`: hidden UIVisibility children are skipped entirely
   - zero size, zero spacing slots - while still being positioned as a
   zero-size rect.
6. Alignment is applied only when there are NO expanded children; spacing
   between participants is added after every child except the last.

## Known deviations between tiers

- UILabel: the oracle takes a synthetic textWidth input; on-device the width
  comes from real font metrics. Label measure cases assert exact numbers in
  Python and structural invariants (w <= maxWidth, h >= 28) on-device.
- Nested layout cases (L23): the probe rect list only aligns with top-level
  children, so the device harness checks container size and logs probe
  geometry for these; the Python oracle asserts the full rect list.

## Workflow

1. Add or change a case in `tests/layout_cases.json`.
2. `python3 tests/test_layout.py` (fast check).
3. If the B4X math changed, update `tests/layout_oracle.py` to mirror it and
   run `python3 tests/generate_harness_cases.py`.
4. Run the on-device harness (see tests/README.md) for the authoritative
   pass against the real classes.
5. `python3 check-b4x-source.py tests/` before committing.

## Next steps

- Wire `tests/test_layout.py` into a CI step (or a `tests/run-all.py` wrapper
  that also runs check-b4x-source.py).
- Extend cases to UIScrollView content-height math and UIListView windowing
  (both are pure math over the same GetContentSize protocol).
- Add render-stability cases (Render twice keeps the same native view) using
  the existing lifecycle harness pattern.
