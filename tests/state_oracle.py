# state_oracle.py - Faithful Python port of the UIState semantics
# (UIState.bas) and the coalescing scheduler (UIRebuildScheduler.bas).
#
# This mirrors the B4X code 1:1 so the shared cases in state_cases.json can be
# checked quickly (pytest / plain CLI) AND on-device (UIStateTestRunner.bas).
# It is a port, not a reimplementation: the B4X source stays authoritative.
# When the B4X code changes, update this file and regenerate the harness cases.
#
# B4X semantics mirrored explicitly:
# - NormalizeValue turns Int/Long/Float/Double into Double (Value + 0.0).
# - '=' on numbers is numeric equality (2 = 2.0).
# - '=' on strings is CASE-INSENSITIVE ("HOLA" = "hola").
# - '=' on maps/lists is REFERENCE equality; Null = Null only.
# - NotifyListeners snapshots the listener list, re-checks membership with
#   List.IndexOf (reference), and runs a bounded second pass when a callback
#   changed the state (mPendingNotification).
# - The scheduler coalesces by target/event (latest argument wins) and drains
#   the live queue on the next UI cycle (flush), like the B4X Do While loop.

import math  # noqa: F401  (kept for parity with layout_oracle imports)


def is_number(value):
    # Python bool is an int subclass; B4X Boolean is NOT Int/Long/Float/Double.
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def normalize(value):
    """UIState.NormalizeValue: numbers become Double, everything else passes
    through untouched (same reference)."""
    if is_number(value):
        return float(value)
    return value


def str_eq(a, b):
    """B4X '=' on two Strings is case-insensitive."""
    return a.lower() == b.lower()


def b4x_equal(a, b):
    """B4X '=' on two Object values: numeric equality for numbers,
    case-insensitive equality for strings, reference equality otherwise
    (maps/lists/booleans are only equal to themselves), Null = Null."""
    if a is None or b is None:
        return a is None and b is None
    if is_number(a) and is_number(b):
        return float(a) == float(b)
    if isinstance(a, str) and isinstance(b, str):
        return str_eq(a, b)
    return a is b


class Scheduler:
    """UIRebuildScheduler port. Delivery is deferred until flush() (the next
    UI cycle in the real app, where RunScheduled resumes after Sleep(0))."""

    def __init__(self):
        self.pending = []  # {Target, EventName, Argument, Cancelled}

    def schedule(self, target, event, argument, has_sub):
        if target is None:
            return
        if event.strip() == "":
            return
        if not has_sub(target, event):
            return
        for call in self.pending:
            # queuedTarget = Target is reference equality; queuedEvent = Event
            # is case-insensitive string equality.
            if call["Target"] is target and str_eq(call["EventName"], event):
                call["Argument"] = argument  # latest argument wins
                return
        self.pending.append({
            "Target": target, "EventName": event,
            "Argument": argument, "Cancelled": False,
        })

    def cancel_target(self, target, event):
        for i in range(len(self.pending) - 1, -1, -1):
            call = self.pending[i]
            if call["Target"] is target:
                if event == "" or str_eq(call["EventName"], event):
                    call["Cancelled"] = True
                    del self.pending[i]

    def cancel(self):
        self.pending = []

    def flush(self, deliver):
        # RunScheduled drains the LIVE queue: a callback that schedules more
        # calls keeps the Do While loop going until nothing is left, because
        # StartIfNeeded no-ops while mScheduled is still set.
        while self.pending:
            call = self.pending.pop(0)
            if call["Cancelled"]:
                continue
            target = call["Target"]
            event = call["EventName"]
            if target is not None and event.strip() != "":
                deliver(target, event, call["Argument"])


class State:
    """UIState port. notify_cb(target, event, state) is invoked exactly where
    B4X would CallSub2, so a case runner can record notifications and drive
    probe behaviors (reentrancy, subscribe/unsubscribe from callbacks)."""

    def __init__(self, initial, notify_cb, has_sub):
        self.value = normalize(initial)
        self.listeners = []  # [{"Target": obj, "EventName": str}]
        self.is_notifying = False
        self.pending_notification = False
        self.coalesce_notifications = False
        self.scheduler = Scheduler()
        self._notify_cb = notify_cb
        self._has_sub = has_sub

    # -- public API -----------------------------------------------------

    def get(self):
        return self.value

    def set(self, new_value):
        normalized = normalize(new_value)
        if self.value is None:
            if normalized is None:
                return
        elif normalized is not None:
            if b4x_equal(self.value, normalized):
                return
        self.value = normalized
        if self.is_notifying:
            self.pending_notification = True
            return
        self.notify()

    def subscribe(self, target, event):
        if target is None or event.strip() == "":
            return
        if not self.has_listener(target, event):
            self.listeners.append({"Target": target, "EventName": event})

    def unsubscribe(self, target, event):
        self.scheduler.cancel_target(target, event)
        for i in range(len(self.listeners) - 1, -1, -1):
            item = self.listeners[i]
            lt, le = item["Target"], item["EventName"]
            same = (lt is None and target is None) or (
                lt is not None and target is not None and lt is target)
            if same and str_eq(le, event):
                del self.listeners[i]

    def unsubscribe_target(self, target):
        self.scheduler.cancel_target(target, "")
        if target is None:
            return
        for i in range(len(self.listeners) - 1, -1, -1):
            lt = self.listeners[i]["Target"]
            if lt is not None and lt is target:
                del self.listeners[i]

    def clear_listeners(self):
        self.scheduler.cancel()
        self.listeners = []

    def coalesce(self, enabled):
        if not enabled:
            self.scheduler.cancel()
        self.coalesce_notifications = enabled

    def flush(self):
        self.scheduler.flush(self._deliver)

    # -- internals ------------------------------------------------------

    def has_listener(self, target, event):
        for item in self.listeners:
            lt, le = item["Target"], item["EventName"]
            same = (lt is None and target is None) or (
                lt is not None and target is not None and lt is target)
            if same and str_eq(le, event):
                return True
        return False

    def notify(self):
        if self.is_notifying:
            return
        self.is_notifying = True
        # Bounded second pass: a state change made from a callback defers one
        # additional notification pass; deeper reentrancy is dropped.
        for _ in range(2):
            self.pending_notification = False
            snapshot = list(self.listeners)
            for item in snapshot:
                # mListeners.IndexOf(item) >= 0 is reference membership, so a
                # listener removed earlier in this pass is skipped.
                if any(item is x for x in self.listeners):
                    target = item["Target"]
                    event = item["EventName"]
                    if self.coalesce_notifications:
                        self.scheduler.schedule(
                            target, event, self, self._has_sub)
                    elif target is not None and event.strip() != "":
                        if self._has_sub(target, event):
                            self._notify_cb(target, event, self)
            if not self.pending_notification:
                break
        self.is_notifying = False
        self.pending_notification = False

    def _deliver(self, target, event, _argument):
        if self._has_sub(target, event):
            self._notify_cb(target, event, self)
