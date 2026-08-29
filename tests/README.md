# Declarative UI - tests

Two-tier unit-test strategy for the pure logic of the library. Each tier runs
the SAME shared cases: a fast Python oracle (no Android needed) and an
on-device B4A harness against the real classes.

- Layout: measurement (`GetContentSize`) and distribution (`Render` math of
  Column/Row/Expanded).
- State: `UIState` notification semantics and the coalescing scheduler.

## Files

| File | Purpose |
| --- | --- |
| `layout_cases.json` | Shared layout cases (single source of truth). 30 measure (M1..M30) + 25 layout (L1..L25). |
| `layout_oracle.py` | Python port of the layout math (UIColumn/UIRow/UIExpanded/UILabel/UIPadding/UIVisibility/UIStack/UICenter/UIDivider/UISpace + Render second pass). |
| `test_layout.py` | Runs every layout case against the oracle. CLI and pytest. |
| `generate_harness_cases.py` | Regenerates `generated/harness_cases.bas` from the layout JSON. |
| `UITestRunner.bas` + `TestProbe.bas` | On-device layout harness (real UI.* classes, rect assertions via recording probes). |
| `state_cases.json` | Shared UIState cases (single source of truth). 30 cases (S01..S30). |
| `state_oracle.py` | Python port of UIState.bas + UIRebuildScheduler.bas. |
| `test_state.py` | Runs every state case against the oracle, plus 4 oracle-only reference-semantics checks. CLI and pytest. |
| `text_cases.json` | Shared text/ripple cases (single source of truth). |
| `text_oracle.py` | Python port of UIStateTextBinding.bas (ToTextNumeric/ToTextRaw) + the border-stroke decision of UIRoundedSurface.ApplyRipple. |
| `test_text.py` | Runs every text case against the oracle. CLI and pytest. |
| `generate_state_cases.py` | Regenerates `generated/state_cases.bas` from the state JSON. |
| `UIStateTestRunner.bas` + `StateProbe.bas` | On-device state harness (real UIState, behavior-driven probes). |
| `generated/harness_cases.bas`, `generated/state_cases.bas` | Generated modules (StaticCode) exposing `GetMeasureCases`/`GetLayoutCases`/`GetStateCases`. Do not edit by hand. |

## Fast feedback (no Android needed)

    python3 tests/test_layout.py
    python3 tests/test_state.py
    python3 tests/test_text.py
    python3 -m pytest tests/test_layout.py tests/test_state.py tests/test_text.py -q

All exit 0 only when every case passes (55 layout + 30 state + 4 extra + 11 text).
The Python side is an *oracle port*, not the real code: it is the fast spec
check and regression net. The B4X source in the library stays authoritative.

## Authoritative check (on-device)

1. `python3 tests/generate_harness_cases.py` and
   `python3 tests/generate_state_cases.py` (after editing cases or oracles).
2. Create a B4A project that references the DeclarativeUI b4xlib (the
   `examples/b4a-template` project works).
3. Copy `UITestRunner.bas`, `TestProbe.bas`, `UIStateTestRunner.bas`,
   `StateProbe.bas` and both `generated/*.bas` modules into the project
   folder and add them to the project.
4. Call `UITestRunner.Run(Activity)` and `UIStateTestRunner.Run(Activity)`
   once from `Activity_Create`.
5. Read the Log output. Green means every line is `DeclarativeUI TEST PASS`
   and both summaries say `failed=0`.

Notes:

- `UIStateTestRunner.Run` is a ResumableSub: its flush step sleeps a few UI
  cycles so the scheduler drains. It runs to completion asynchronously; the
  summary line appears last.
- The state probes implement the event names used by the cases (`onChange`,
  `onCustom`). Adding a new event name to `state_cases.json` requires adding
  the matching sub to `StateProbe.bas`.

## What is asserted

Layout:

- Measure: exact (width, height) for deterministic leaves and containers;
  flexible marker (empty list) for all-expanded containers; the 10000-dip
  sentinel convention; hidden UIVisibility does not participate.
- Layout: container size after Render; exact child rects for every
  MainAxisAlignment, MainAxisSize min/max, cross-axis alignment, Expanded
  remainder distribution, overflow clipping, nesting and hidden children.
- UILabel measure cases assert only structural invariants on-device
  (w <= maxWidth, h >= 28); the Python suite asserts exact numbers.

State:

- Normalization (Int/Long -> Double, strings/booleans untouched), equality
  no-ops (2 vs 2.0, case-insensitive "HOLA" vs "hola"), Null transitions.
- Subscription: fan-out order, dedupe, multiple events per target, rejection
  of empty events / Null targets.
- Notification passes: the bounded second pass, deep reentrancy dropped,
  listener removed before its turn, self-unsubscribe, subscribe-during-
  notification.
- Unsubscribe: exact pair removal, idempotence, UnsubscribeTarget,
  ClearListeners.
- Coalescing: deferred delivery, latest-value-wins, cancel on unsubscribe or
  disable, flush-time reentrancy, no-op-set-does-not-enqueue.

Text:

- `ToTextNumeric` vs `ToTextRaw` preserve the two original variants that the
  deduplication merged: `30.0` -> `"30"` (numeric) but `"30.0"` (raw);
  `Null` -> `"null"` (numeric) but `""` (raw). These distinctions are exactly
  what a careless future refactor would collapse.
- Non-whole numbers and non-numbers pass through in both modes (no silent
  re-formatting).
- The `Abs(number) < 1000000000000` boundary in numeric mode is exclusive; at
  the limit the raw text is returned (T09 pins this algorithm boundary).
- `ApplyRipple` border-stroke decision: `borderWidth > 0` emits a stroke
  (Button), `borderWidth = 0` does not (FAB). The two cases come from the
  actual call sites, so this guards against folding the branches.

## CI

`.github/workflows/ci.yml` runs on every push and pull request:

1. All oracle suites as plain CLI scripts (no dependencies).
2. All suites under pytest.
3. `python3 check-b4x-source.py --strict .` over the whole repo.
4. A freshness guard: regenerating the harness modules must produce no diff,
   so editing a JSON without regenerating fails CI.

## Not covered (yet)

- Font metrics (device-dependent by design).
- UIScrollView / UIListView virtualization math.
- Safe-area insets and other Android-only paths (need a device).
- The UIDaisy adapter (out of scope for the layout/state layers).
- The text/ripple tier currently has a Python oracle only; there is no
  on-device TextProbe harness yet (the logic is purely functional).

## Maintenance rules

1. `layout_cases.json`, `state_cases.json` and `text_cases.json` are the
   sources of truth: add cases there, not in code.
2. When the B4X math or state code changes, update the matching oracle to
   mirror it and regenerate the harness modules
   (`python3 tests/generate_harness_cases.py`,
   `python3 tests/generate_state_cases.py`).
3. Keep the oracles line-by-line mirrors: B4X `/` on two Ints is integer
   division, Float->Int assignment rounds, string '=' is case-insensitive,
   list/map '=' is reference equality, notify passes are bounded at two.
4. Run `python3 check-b4x-source.py tests/` after touching any .bas here.
5. Full local gate before pushing: the CI steps above.
