# Declarative UI for B4A — Changelog

## Lifecycle and widget milestone

1. Added temporary `Detach` lifecycle support while preserving the existing `Unmount` API and custom-widget compatibility fallback.
2. Optimized stable navigator renders and route changes to preserve/reuse widget identity where possible.
3. Improved `UIListView` pooling: bound rows detach for reuse and are unmounted only when the pool is released.
4. Added `UISwitch`, `UIRadioButton` and `UIRadioGroup` documentation and public API coverage.
5. Fixed first-render safety for `UIInput` and kept the project clean at 0 compiler warnings.

## Previous significant changes

1. Added `UIInput.PasswordMode(Enabled As Boolean)`.
2. Added the declarative `UICheckbox` widget.