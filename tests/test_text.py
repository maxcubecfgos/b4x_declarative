"""Runs the shared text cases (tests/text_cases.json) against the oracle.

    python3 tests/test_text.py
    python3 -m pytest tests/test_text.py

The same cases can be executed on-device by a future TextProbe harness;
for now the tier is a Python oracle only (the logic is purely functional,
no canvas or Activity needed).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import text_oracle as oracle  # noqa: E402


def load_cases():
    with open(os.path.join(HERE, "text_cases.json"), encoding="utf-8") as f:
        return json.load(f)


def run_fn(fn, case_input):
    if fn == "numeric":
        return oracle.to_text_numeric(case_input)
    if fn == "raw":
        return oracle.to_text_raw(case_input)
    if fn == "ripple":
        return oracle.apply_ripple(case_input["borderWidth"])
    raise ValueError("unknown fn: %r" % (fn,))


def check_case(case):
    result = run_fn(case["fn"], case["input"])
    expected = case["expect"]
    assert result == expected, "expected %r, got %r" % (expected, result)


# ---------------------------------------------------------------------------
# pytest entry points
# ---------------------------------------------------------------------------

def test_all_text_cases():
    for case in load_cases()["textCases"]:
        check_case(case)


# ---------------------------------------------------------------------------
# Plain CLI runner (no pytest required)
# ---------------------------------------------------------------------------

def main():
    data = load_cases()
    failures = []
    for case in data["textCases"]:
        try:
            check_case(case)
            print("PASS  %s" % case["id"])
        except AssertionError as e:
            failures.append((case["id"], str(e)))
            print("FAIL  %s: %s" % (case["id"], e))

    total = len(data["textCases"])
    passed = total - len(failures)
    print()
    print("Summary: %d/%d passed (%d failed)" % (passed, total, len(failures)))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
