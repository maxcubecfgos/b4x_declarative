# Declarative UI for B4A — Changelog

# Declarative UI for B4A — Changelog

## 0.2 — UI.* factory (Contract 2.0)

1. Added `UI.bas`, a static-code factory: every `UI.*` function creates,
   initializes and returns a widget (zero `Dim`/`Initialize` ceremony) and
   `UI.Show`/`UI.Mount` mount the whole tree in one call.
2. Added shared diagnostics: `UI.Diagnostics`, `UI.Errors`, `UI.HasErrors`;
   missing event callbacks are reported instead of failing silently.
3. Added theme presets: `UI.Theme`, `UI.ThemeDark`, `UI.ThemeWithScheme`,
   `UI.ThemeWithSchemeAndMode`.
4. Added `examples/b4a_ui_quickstart`: counter + login + dashboard in one
   navigable shell, written 100% with the factory.
5. Removed all empty `Catch` blocks (4 introduced + 2 pre-existing in
   `UIAnimation.bas`); project stays at 0 compiler warnings.

## Lifecycle and widget milestone


1. Added temporary `Detach` lifecycle support while preserving the existing `Unmount` API and custom-widget compatibility fallback.
2. Optimized stable navigator renders and route changes to preserve/reuse widget identity where possible.
3. Improved `UIListView` pooling: bound rows detach for reuse and are unmounted only when the pool is released.
4. Added `UISwitch`, `UIRadioButton` and `UIRadioGroup` documentation and public API coverage.
5. Fixed first-render safety for `UIInput` and kept the project clean at 0 compiler warnings.

## Previous significant changes

1. Added `UIInput.PasswordMode(Enabled As Boolean)`.
2. Added the declarative `UICheckbox` widget.