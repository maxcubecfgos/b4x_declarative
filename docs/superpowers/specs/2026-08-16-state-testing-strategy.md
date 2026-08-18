# UIState testing strategy (state, listeners, coalescing)

Date: 2026-08-16
Status: Implemented (see tests/ and tests/README.md)

## Context

UIState is the reactive core of the library: every widget binding, screen
rebuild and UINavigator transition depends on its notification semantics. It
is also subtle in exactly the ways that regress silently: value normalization
(Int vs Double), case-insensitive string equality, the bounded second
notification pass, snapshot-vs-live listener lists, and the deferred
coalescing scheduler. After the layout layer got its two-tier test strategy
(2026-08-15), state was the next most valuable pure-logic target.

## Goals

1. Pin the UIState observable contract: who is notified, in what order, with
   which value, and how many times - including reentrancy and coalescing.
2. Reuse the established two-tier pattern: one shared case list executed by a
   fast Python oracle AND an on-device harness against the real classes.
3. Document the B4X semantics the oracle must mirror, so the port does not
   drift from the source.

## Non-goals

- Adding API to UIState for testability (e.g. a ListenerCount accessor). The
  shared cases assert listener-count behavior indirectly through
  who-is-notified, so the library surface stays untouched.
- Testing UIRebuildScheduler in isolation beyond what UIState exercises; its
  delivery order is pinned through the coalescing cases (S23-S30).
- Timing-exact tests: the scheduler's Sleep(0) drain is real async behavior.
  The device harness gives it a margin (5 UI cycles); the oracle models the
  drain as an atomic flush.

## Design

### Tier 1 - Python oracle

`tests/state_oracle.py` ports UIState.bas and UIRebuildScheduler.bas line by
line: NormalizeValue, SetState equality/no-op rules, Subscribe/Unsubscribe
(null handling, case-insensitive event matching, reference target equality),
NotifyListeners (snapshot + membership check + bounded second pass), and the
scheduler (per-target/event coalescing, live-queue drain). Probe behaviors
driven through the notify callback let the oracle exercise reentrancy,
self-unsubscribe, subscribe-during-notification and flush-time re-queueing.

`tests/test_state.py` runs the shared cases plus four oracle-only reference
semantics checks (lists are not normalized; same-reference no-op; different
references notify; booleans untouched). Those four cannot live in the shared
JSON because on-device B4X '=' on two Lists is reference equality, so an
expected literal could never match.

### Tier 2 - On-device harness (authoritative)

`tests/UIStateTestRunner.bas` executes the same cases with the real UIState.
`tests/StateProbe.bas` is a listener target that records every notification
(target, event, value at call time) into a shared log and runs behavior
scripts (set / setNext / subscribe / unsubscribe, or several actions) from
inside callbacks. No native views are involved; Root is accepted only for a
uniform call convention. The flush step (coalesced delivery) sleeps 5 UI
cycles so the scheduler's Sleep(0) drains; this is the only timing-sensitive
part of the harness.

### Shared case list

`tests/state_cases.json` is the single source of truth: 30 cases (S01..S30).

- Normalization and equality (S01-S08): Int/Long -> Double, Float/Double
  unchanged, strings/booleans untouched, numeric equality no-op (2 vs 2.0),
  case-insensitive string equality no-op (HOLA vs hola), Null transitions.
- Subscription (S09-S12): fan-out order, duplicate dedupe, multiple events on
  one target, empty-event / Null-target rejection.
- Notification passes (S13-S18): the bounded second pass, deep reentrancy
  dropped, listener removed before its turn, self-unsubscribe,
  subscribe-during-notification (with and without a pending second pass).
- Unsubscribe (S19-S22): exact pair removal, idempotence, UnsubscribeTarget,
  ClearListeners.
- Coalescing (S23-S30): deferred delivery, latest-value-wins per target/event,
  cancel-on-unsubscribe, cancel-on-disable, flush-time reentrancy, and the
  no-op-set-does-not-enqueue rule.

`tests/generate_state_cases.py` regenerates
`tests/generated/state_cases.bas` from the JSON (one UTF-8 BOM, CRLF), so the
device harness runs the same numbers as the Python suite.

## B4X semantics the oracle must mirror

1. NormalizeValue: Int/Long/Float/Double become Double (Value + 0.0). Booleans
   are NOT numbers in B4X and pass through untouched.
2. '=' on numbers is numeric (2 = 2.0); '=' on strings is CASE-INSENSITIVE
   ("HOLA" = "hola"); '=' on maps/lists is REFERENCE equality; Null = Null.
3. SetState no-ops when the normalized value equals the current value - the
   equality check happens BEFORE the reentrancy check, so an equal-value set
   from a callback does not raise mPendingNotification.
4. NotifyListeners snapshots the listener list and re-checks membership with
   List.IndexOf (reference), so a listener removed earlier in the pass is
   skipped. A state change from a callback defers ONE more full pass
   (mPendingNotification); deeper reentrancy is dropped but the value sticks.
5. The second pass re-notifies everyone still subscribed with the CURRENT
   value, so listeners notified after a mid-pass change see the new value.
6. Coalescing defers every callback to the scheduler, which keeps one queued
   call per target/event pair (latest argument wins) and drains the live queue
   on the next UI cycle, re-queueing anything scheduled during the drain.

## Known deviations between tiers

- None for behavior: the JSON cases were designed so every assertion (value,
  notified sequence) is expressible with the public API and '=' comparisons,
  so the device harness asserts exactly what the oracle asserts.
- The device flush step needs real UI cycles (see above); the oracle's flush
  is atomic.

## Workflow

1. Add or change a case in `tests/state_cases.json`.
2. `python3 tests/test_state.py` (fast check).
3. If UIState/UIRebuildScheduler changed, update `tests/state_oracle.py` to
   mirror it and run `python3 tests/generate_state_cases.py`.
4. Run the on-device harness (see tests/README.md) for the authoritative pass.
5. `python3 check-b4x-source.py tests/` before committing.

## Next steps

- The on-device harness needs the B4A IDE + emulator; run it once to confirm
  the flush sleep margin is sufficient on a real device.
- Consider wiring the state + layout oracles into a `tests/run-all.py` wrapper
  or a CI step (see .github/workflows/ci.yml).
