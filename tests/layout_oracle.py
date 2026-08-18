# layout_oracle.py - Faithful Python port of the Declarative UI measurement and
# distribution math (UIColumn/UIRow/UIExpanded and friends).
#
# This mirrors the B4X code 1:1 so the shared cases in layout_cases.json can be
# checked quickly (pytest / plain CLI) AND on-device (UITestRunner.bas). It is a
# port, not a reimplementation: the B4X source in UIColumn.bas / UIRow.bas stays
# authoritative. When the B4X math changes, update this file and regenerate the
# harness cases.

import math

# Every GetContentSize implementation converts non-positive bounds to this
# sentinel before clamping (see UILabel/UISpace/UIPadding/... .bas).
SAFE = 10000

# B4X semantics mirrored explicitly: '/' between two Ints is INTEGER division,
# and Float -> Int assignment rounds to the nearest integer.


def safe_bounds(max_w, max_h):
    return (max_w if max_w > 0 else SAFE, max_h if max_h > 0 else SAFE)


# ---------------------------------------------------------------------------
# Leaves
# ---------------------------------------------------------------------------

def measure_space(fixed, max_w, max_h):
    sw, sh = safe_bounds(max_w, max_h)
    return (min(fixed, sw), min(fixed, sh))


def measure_divider(max_w, max_h):
    sw, sh = safe_bounds(max_w, max_h)
    return (sw, min(1 + 16, sh))  # dividerHeight + breathing room


def measure_label(text_w, size, max_w, max_h):
    sw, sh = safe_bounds(max_w, max_h)
    lines = 1
    if text_w > sw:
        # text_w is a Float in B4X (Canvas.MeasureStringWidth), so this is a
        # real floating division and Ceil behaves as expected.
        lines = max(1, math.ceil(text_w / max(1, sw)))
    line_height = max(round(size * 1.5) + 6, 22)  # Float -> Int rounds
    h = max(lines * line_height + 4, 28)
    return (min(text_w, sw), min(h, sh))


# ---------------------------------------------------------------------------
# Wrappers
# ---------------------------------------------------------------------------

def measure_padding(child, insets, max_w, max_h):
    l, r, t, b = insets
    sw, sh = safe_bounds(max_w, max_h)
    if child is not None:
        child_max_w = max(0, sw - l - r)
        child_max_h = max(0, sh - t - b)
        cs = measure(child, child_max_w, child_max_h)
        if cs is not None:
            return (min(cs[0] + l + r, sw), min(cs[1] + t + b, sh))
    return (min(l + r, sw), min(t + b, sh))


def measure_visibility(child, visible, max_w, max_h):
    if not visible or child is None:
        return (0, 0)
    cs = measure(child, max_w, max_h)
    return cs if cs is not None else (0, 0)


def measure_center(child, max_w, max_h):
    if child is not None:
        cs = measure(child, max_w, max_h)
        if cs is not None:
            return cs
    return None  # flexible marker (empty list in B4X)


def measure_stack(children, max_w, max_h):
    sw, sh = safe_bounds(max_w, max_h)
    maxw = 0
    maxh = 0
    participants = 0
    natural = 0
    for c in children:
        if c.get("participates", True) is False:
            continue
        cs = measure(c, sw, sh)
        participants += 1
        if cs is not None:
            natural += 1
            maxw = max(maxw, cs[0])
            maxh = max(maxh, cs[1])
    if participants > 0 and natural == 0:
        return None
    return (min(maxw, sw), min(maxh, sh))


# ---------------------------------------------------------------------------
# Containers: measure
# ---------------------------------------------------------------------------

def measure_column(children, spacing, max_w, max_h):
    sw, sh = safe_bounds(max_w, max_h)
    maxw = 0
    totalh = 0
    participants = 0
    all_expanded = True
    for c in children:
        if c.get("participates", True) is False:
            continue  # hidden UIVisibility: no size, no spacing slot
        # UIColumn measures every child with MaxHeight=0 (Render and
        # GetContentSize); leaves translate 0 -> SAFE internally.
        cs = measure(c, sw, 0)
        participants += 1
        if cs is None:
            continue
        all_expanded = False
        maxw = max(maxw, cs[0])
        totalh += cs[1]
    totalh += spacing * max(0, participants - 1)
    if participants > 0 and all_expanded:
        return None
    return (min(maxw, sw), min(totalh, sh))


def measure_row(children, spacing, max_w, max_h):
    sw, sh = safe_bounds(max_w, max_h)
    totalw = 0
    maxh = 0
    participants = 0
    natural = 0
    has_expanded = False
    for c in children:
        if c.get("participates", True) is False:
            continue  # hidden UIVisibility: no size, no spacing slot
        # UIRow measures children with both bounds.
        cs = measure(c, sw, sh)
        participants += 1
        if cs is None:
            has_expanded = True
            continue
        totalw += cs[0]
        maxh = max(maxh, cs[1])
        natural += 1
    totalw += spacing * max(0, participants - 1)
    if participants > 0 and has_expanded and natural == 0:
        return None
    return (min(totalw, sw), min(maxh, sh))


def _align(align, free, participants, base_spacing):
    """Returns (initial_offset, layout_spacing) exactly like the Select Case."""
    offset = 0
    spacing = base_spacing
    if align == "center":
        offset = free // 2
    elif align == "end":
        offset = free
    elif align == "spacebetween":
        if participants > 1:
            spacing = base_spacing + free // (participants - 1)
    elif align == "spacearound":
        if participants > 0:
            spacing = base_spacing + free // participants
            offset = (spacing - base_spacing) // 2
    elif align == "spaceevenly":
        if participants > 0:
            spacing = base_spacing + free // (participants + 1)
            offset = spacing - base_spacing
    return offset, spacing


# ---------------------------------------------------------------------------
# Containers: distribution (the Render second pass)
# ---------------------------------------------------------------------------

def layout_column(specs, spacing, main_axis_size, main_align, cross_align,
                  width, height):
    """Mirrors UIColumn.Render. Returns ((container_w, container_h), rects)."""
    # Pass 1: measure (children get MaxHeight=0, mirroring the B4X call).
    total_natural = 0
    expanded_count = 0
    participants = 0
    for c in specs:
        if c.get("participates", True) is False:
            continue
        participants += 1
        s = measure(c, width, 0)
        if s is None:
            expanded_count += 1
        else:
            total_natural += s[1]
    total_natural += spacing * max(0, participants - 1)

    layout_h = height
    if main_axis_size == "min" and expanded_count == 0:
        layout_h = min(height, total_natural)

    remaining = max(0, layout_h - total_natural)
    expanded_h = 0
    remainder = 0
    if expanded_count > 0:
        expanded_h = remaining // expanded_count
        remainder = remaining % expanded_count

    offset, layout_spacing = 0, spacing
    if expanded_count == 0:
        free = max(0, layout_h - total_natural)
        offset, layout_spacing = _align(main_align, free, participants, spacing)

    rects = []
    y = offset
    for c in specs:
        if c.get("participates", True) is False:
            rects.append((0, y, 0, 0))  # zero-size, no spacing slot
            continue
        s = measure(c, width, 0)
        if s is None:
            ch = expanded_h
            if remainder > 0:
                ch += 1
                remainder -= 1
        else:
            ch = s[1]
        ch = max(0, ch)
        cw = width
        left = 0
        if cross_align != "stretch" and s is not None:
            cw = min(s[0], width)
            if cross_align == "center":
                left = (width - cw) // 2
            elif cross_align == "end":
                left = width - cw
        rects.append((left, y, cw, ch))
        y += ch
        y += layout_spacing
    if participants > 0:  # no trailing gap after the last child
        y -= layout_spacing
    return (width, layout_h), rects


def layout_row(specs, spacing, main_axis_size, main_align, cross_align,
               width, height):
    """Mirrors UIRow.Render. Returns ((container_w, container_h), rects)."""
    total_natural = 0
    max_h = 0
    expanded_count = 0
    participants = 0
    for c in specs:
        if c.get("participates", True) is False:
            continue
        participants += 1
        s = measure(c, width, height)
        if s is None:
            expanded_count += 1
        else:
            total_natural += s[0]
            max_h = max(max_h, s[1])
    total_natural += spacing * max(0, participants - 1)

    layout_w = width
    if main_axis_size == "min" and expanded_count == 0:
        layout_w = min(width, total_natural)

    remaining = max(0, layout_w - total_natural)
    expanded_w = 0
    remainder = 0
    if expanded_count > 0:
        expanded_w = remaining // expanded_count
        remainder = remaining % expanded_count

    offset, layout_spacing = 0, spacing
    if expanded_count == 0:
        free = max(0, layout_w - total_natural)
        offset, layout_spacing = _align(main_align, free, participants, spacing)

    rects = []
    x = offset
    for c in specs:
        if c.get("participates", True) is False:
            rects.append((x, 0, 0, 0))  # zero-size, no spacing slot
            continue
        s = measure(c, width, height)
        if s is None:
            cw = expanded_w
            if remainder > 0:
                cw += 1
                remainder -= 1
        else:
            cw = s[0]
        cw = max(0, cw)
        ch = height
        top = 0
        if cross_align != "stretch" and s is not None:
            ch = min(s[1], height)
            if cross_align == "center":
                top = (height - ch) // 2
            elif cross_align == "end":
                top = height - ch
        rects.append((x, top, cw, ch))
        x += cw
        x += layout_spacing
    if participants > 0:
        x -= layout_spacing
    return (layout_w, height), rects


# ---------------------------------------------------------------------------
# Dispatcher: turns a case widget spec into a measured size / layout rects
# ---------------------------------------------------------------------------

def measure(spec, max_w, max_h):
    t = spec["type"]
    if t == "space":
        return measure_space(spec["size"], max_w, max_h)
    if t == "divider":
        return measure_divider(max_w, max_h)
    if t == "label":
        return measure_label(spec["textWidth"], spec.get("fontSize", 14),
                             max_w, max_h)
    if t == "padding":
        insets = (spec.get("l", 0), spec.get("r", 0),
                  spec.get("t", 0), spec.get("b", 0))
        return measure_padding(spec.get("child"), insets, max_w, max_h)
    if t == "visibility":
        return measure_visibility(spec.get("child"),
                                  spec.get("visible", True), max_w, max_h)
    if t == "center":
        return measure_center(spec.get("child"), max_w, max_h)
    if t == "stack":
        return measure_stack(spec.get("children", []), max_w, max_h)
    if t == "column":
        return measure_column(spec.get("children", []),
                              spec.get("spacing", 0), max_w, max_h)
    if t == "row":
        return measure_row(spec.get("children", []),
                           spec.get("spacing", 0), max_w, max_h)
    if t == "expanded":
        return None
    raise ValueError("unknown widget type: %r" % t)


def layout(spec, width, height, main_axis_size, main_align, cross_align):
    """Runs the Render distribution for a column/row case."""
    children = spec.get("children", [])
    spacing = spec.get("spacing", 0)
    if spec["type"] == "column":
        return layout_column(children, spacing, main_axis_size, main_align,
                             cross_align, width, height)
    if spec["type"] == "row":
        return layout_row(children, spacing, main_axis_size, main_align,
                          cross_align, width, height)
    raise ValueError("layout case must be column or row, got %r" % spec["type"])
