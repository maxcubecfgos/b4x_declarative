"""Runs the shared layout cases (tests/layout_cases.json) against the oracle.

Works two ways:
    python3 tests/test_layout.py          # plain runner, exit code 0/1
    python3 -m pytest tests/test_layout.py

The same cases are executed on-device by UITestRunner.bas (see tests/README.md).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import layout_oracle as oracle  # noqa: E402


def load_cases():
    with open(os.path.join(HERE, "layout_cases.json"), encoding="utf-8") as f:
        return json.load(f)


def check_measure_case(case):
    result = oracle.measure(case["widget"], case["maxWidth"], case["maxHeight"])
    if case["flexible"]:
        assert result is None, "expected flexible marker (empty list), got %r" % (result,)
        return
    assert result is not None, "expected a measured size, got flexible marker"
    expected = tuple(case["expect"])
    assert result == expected, "expected %r, got %r" % (expected, result)


def check_layout_case(case):
    widget = case["widget"]
    container, rects = oracle.layout(
        widget,
        case["width"],
        case["height"],
        case["mainAxisSize"],
        case["mainAxisAlignment"],
        case["crossAxisAlignment"],
    )
    assert list(container) == case["expectContainer"], (
        "container %r != expected %r" % (list(container), case["expectContainer"]))
    assert [list(r) for r in rects] == case["expectRects"], (
        "rects %r != expected %r" % ([list(r) for r in rects], case["expectRects"]))


# ---------------------------------------------------------------------------
# pytest entry points
# ---------------------------------------------------------------------------

def test_all_measure_cases():
    for case in load_cases()["measureCases"]:
        check_measure_case(case)


def test_all_layout_cases():
    for case in load_cases()["layoutCases"]:
        check_layout_case(case)


# ---------------------------------------------------------------------------
# Plain CLI runner (no pytest required)
# ---------------------------------------------------------------------------

def main():
    data = load_cases()
    failures = []

    for case in data["measureCases"]:
        try:
            check_measure_case(case)
            print("PASS  %s (measure)" % case["id"])
        except AssertionError as e:
            failures.append((case["id"], "measure", str(e)))
            print("FAIL  %s (measure): %s" % (case["id"], e))

    for case in data["layoutCases"]:
        try:
            check_layout_case(case)
            print("PASS  %s (layout)" % case["id"])
        except AssertionError as e:
            failures.append((case["id"], "layout", str(e)))
            print("FAIL  %s (layout): %s" % (case["id"], e))

    total = len(data["measureCases"]) + len(data["layoutCases"])
    passed = total - len(failures)
    print()
    print("Summary: %d/%d passed (%d failed)" % (passed, total, len(failures)))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
