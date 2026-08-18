"""Runs the shared UIState cases (tests/state_cases.json) against the oracle.

Works two ways:
    python3 tests/test_state.py          # plain runner, exit code 0/1
    python3 -m pytest tests/test_state.py

The same cases are executed on-device by UIStateTestRunner.bas
(see tests/README.md).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import state_oracle as oracle  # noqa: E402


class Probe:
    """A listener target. `name` is the case-visible identifier; `behavior` is
    the action script run when the probe is notified, mirroring what
    StateProbe.bas does on-device."""

    def __init__(self, name):
        self.name = name
        self.behavior = None

    def __repr__(self):
        return "Probe(%s)" % self.name


def collect_target_names(case):
    """Every probe name referenced by the case: subscribe steps plus the
    subscribe/unsubscribe targets inside behaviors."""
    names = set()
    for step in case["steps"]:
        behavior = step.get("behavior")
        if step["op"] == "subscribe":
            names.add(step["target"])
        if behavior:
            actions = behavior.get("actions") or [behavior]
            for action in actions:
                for key in ("subscribe", "unsubscribe"):
                    if key in action:
                        names.add(action[key]["target"])
    return names


class CaseRun:
    """Executes one case: a fresh UIState plus probes, then walks the steps."""

    def __init__(self, case):
        self.probes = {}
        for name in collect_target_names(case):
            if name not in ("self", "null"):
                self.probes[name] = Probe(name)
        self.notified = []  # [(name, event, value_at_call_time)]
        self.state = oracle.State(case.get("initial"),
                                  self._notify, lambda t, e: True)
        self.case = case

    # -- callback driving (where B4X would CallSub2) ---------------------

    def _notify(self, target, event, state):
        self.notified.append((target.name, event, state.get()))
        self._run_behavior(target, state)

    def _run_behavior(self, target, state):
        behavior = target.behavior
        if not behavior:
            return
        actions = behavior.get("actions") or [behavior]
        for action in actions:
            self._run_action(target, action, state)

    def _run_action(self, target, action, state):
        if "set" in action:
            state.set(action["set"])
        elif action.get("setNext"):
            state.set(state.get() + 1)  # Object arithmetic promotes to Double
        elif "subscribe" in action:
            spec = action["subscribe"]
            state.subscribe(self.resolve(spec["target"], target), spec["event"])
        elif "unsubscribe" in action:
            spec = action["unsubscribe"]
            state.unsubscribe(self.resolve(spec["target"], target), spec["event"])

    def resolve(self, name, notifying_probe):
        if name == "self":
            return notifying_probe
        if name == "null":
            return None
        return self.probes[name]

    # -- step execution -------------------------------------------------

    def run(self):
        for step in self.case["steps"]:
            if not self._step(step):
                return False
        return True

    def _step(self, step):
        op = step["op"]
        if op == "subscribe":
            probe = self.resolve(step["target"], None)
            self.state.subscribe(probe, step["event"])
            if probe is not None:
                probe.behavior = step.get("behavior")
            return True
        if op == "unsubscribe":
            self.state.unsubscribe(self.resolve(step["target"], None),
                                   step["event"])
            return True
        if op == "unsubscribeTarget":
            self.state.unsubscribe_target(self.resolve(step["target"], None))
            return True
        if op == "clear":
            self.state.clear_listeners()
            return True
        if op == "coalesce":
            self.state.coalesce(step["enabled"])
            return True
        if op == "set":
            self.notified = []
            self.state.set(step["value"])
            return self._check_expect(step, check_value=True)
        if op == "flush":
            self.notified = []
            self.state.flush()
            return self._check_expect(step, check_value=True)
        if op == "get":
            expected = step["expect"]
            if not oracle.b4x_equal(self.state.get(), expected):
                raise AssertionError(
                    "get expected %r, got %r" % (expected, self.state.get()))
            return True
        raise AssertionError("unknown op %r" % op)

    def _check_expect(self, step, check_value):
        expect = step.get("expect")
        if expect is None:
            return True
        if check_value and "value" in expect:
            got = self.state.get()
            exp = expect["value"]
            if not oracle.b4x_equal(got, exp):
                raise AssertionError("value expected %r, got %r" % (exp, got))
        if "notified" in expect:
            expected = [tuple(e) for e in expect["notified"]]
            actual = list(self.notified)
            if actual != expected:
                raise AssertionError(
                    "notified expected %r, got %r" % (expected, actual))
        return True


def load_cases():
    with open(os.path.join(HERE, "state_cases.json"), encoding="utf-8") as f:
        return json.load(f)


def check_case(case):
    run = CaseRun(case)
    if not run.run():
        raise AssertionError("case did not complete")


# ---------------------------------------------------------------------------
# Oracle-only checks: reference semantics for non-numeric values. These cannot
# live in the shared JSON because on-device, B4X '=' on two Lists is reference
# equality and the expected value would never equal a literal.
# ---------------------------------------------------------------------------

def test_lists_are_not_normalized():
    lst = [1, 2]
    s = oracle.State(None, lambda t, e, st: None, lambda t, e: True)
    s.set(lst)
    assert s.get() is lst  # same reference preserved


def test_same_list_reference_is_noop():
    calls = []
    target = object()
    s = oracle.State(None, lambda t, e, st: calls.append(1), lambda t, e: True)
    s.subscribe(target, "onChange")
    lst = [1, 2]
    s.set(lst)
    calls.clear()
    s.set(lst)
    assert calls == []  # equal reference -> no notification


def test_different_list_notifies():
    calls = []
    target = object()
    s = oracle.State(None, lambda t, e, st: calls.append(1), lambda t, e: True)
    s.subscribe(target, "onChange")
    s.set([1])
    s.set([2])
    assert len(calls) == 2  # different references are not equal


def test_bool_not_normalized():
    s = oracle.State(True, lambda t, e, st: None, lambda t, e: True)
    assert s.get() is True


# ---------------------------------------------------------------------------
# pytest entry points
# ---------------------------------------------------------------------------

def test_all_state_cases():
    for case in load_cases()["stateCases"]:
        check_case(case)


# ---------------------------------------------------------------------------
# Plain CLI runner (no pytest required)
# ---------------------------------------------------------------------------

def main():
    data = load_cases()
    failures = []

    for case in data["stateCases"]:
        try:
            check_case(case)
            print("PASS  %s (state)" % case["id"])
        except AssertionError as e:
            failures.append((case["id"], str(e)))
            print("FAIL  %s (state): %s" % (case["id"], e))

    extra = [
        ("lists-not-normalized", test_lists_are_not_normalized),
        ("same-list-noop", test_same_list_reference_is_noop),
        ("different-list-notifies", test_different_list_notifies),
        ("bool-not-normalized", test_bool_not_normalized),
    ]
    for name, fn in extra:
        try:
            fn()
            print("PASS  %s (oracle-extra)" % name)
        except AssertionError as e:
            failures.append((name, str(e)))
            print("FAIL  %s (oracle-extra): %s" % (name, e))

    total = len(data["stateCases"]) + len(extra)
    passed = total - len(failures)
    print()
    print("Summary: %d/%d passed (%d failed)" % (passed, total, len(failures)))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
