"""Python port (regression oracle) of the state-to-text and ripple logic.

Mirrors:
  UIStateTextBinding.bas  -> ToTextNumeric / ToTextRaw  (via ToText)
  UIRoundedSurface.bas     -> ApplyRipple border-stroke decision

This is a fast spec check and regression net, NOT the authoritative code.
The B4X source in the library stays authoritative; an on-device harness
would validate the real classes.

Known limitation: B4X stringifies a Double the same way Java's
Double.toString does. For very large doubles B4X may emit scientific
notation while this oracle emits Python's str(). The cases avoid that
ambiguity except where the algorithm boundary itself is under test
(see T09).
"""
import math

MODE_NUMERIC = 0
MODE_RAW = 1


def _is_number(s):
    try:
        float(s)
        return True
    except (TypeError, ValueError):
        return False


def to_text(value, mode):
    """Port of UIStateTextBinding.ToText (value: Object, mode: Int) -> String."""
    if mode == MODE_RAW:
        if value is None:
            return ""
        return str(value)
    # numeric mode
    value_text = "null" if value is None else str(value)
    value_text = value_text.strip()
    if _is_number(value_text):
        number = float(value_text)
        if number == math.floor(number) and abs(number) < 1000000000000:
            # NumberFormat2(number, 0, 12, 0, False) -> integer, no grouping
            return str(int(round(number)))
    return value_text


def to_text_numeric(value):
    """Port of UIStateTextBinding.ToTextNumeric."""
    return to_text(value, MODE_NUMERIC)


def to_text_raw(value):
    """Port of UIStateTextBinding.ToTextRaw."""
    return to_text(value, MODE_RAW)


def apply_ripple(border_width):
    """Port of the border-stroke decision inside UIRoundedSurface.ApplyRipple.

    The only branch that changes the emitted drawable is
    `borderWidth > 0` -> setStroke(borderWidth, borderColor). The descriptor
    captures that decision so a future refactor cannot silently fold the two
    branches (FAB passes borderWidth=0, Button passes borderWidth>0).
    """
    return {
        "hasStroke": border_width > 0,
        "strokeWidth": border_width if border_width > 0 else 0,
    }
