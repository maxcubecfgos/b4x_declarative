# Declarative UI for B4A — Changelog

## 0.6 — FontAwesome icons in UIButton

1. `UIButton` now renders FontAwesome glyphs in its text with the correct
   typeface. Characters in the FontAwesome private use area (U+F000..U+F8FF)
   are applied `Typeface.FONTAWESOME` via `CSBuilder`, while the surrounding
   label keeps the default typeface. Icon+text buttons just work without any
   new API: `UI.Button(Chr(0xF04B) & "  Run")` shows a play icon and the
   label.

## 0.5 — Debug-mode theme fix, automatic re-layout, multi-line labels

1. Theme factories now call `t.Initialize` before `InitializeWithScheme` and
   `InitializeWithSchemeAndMode`. B4A binds the instance BA only on the method
   named exactly `Initialize`; calling the scheme initializers first crashed
   with "Class instance was not initialized" in debug mode (release was
   unaffected). App code still writes only `UI.ThemeWithScheme(...)`.
2. Bound widgets re-layout the mounted tree automatically: `UI.Show` records
   the root and `UI.Invalidate` re-renders it, so a `BindText` label grows
   correctly from "9" to "10" instead of clipping to the first digit.
3. `UILabel.GetContentSize` estimates the wrapped line count from the text
   width versus the available width and returns a multi-line height. Long
   descriptions in narrow containers no longer "wrap but clip" at the bottom.
4. Restored the documented `Show(Root, Widget)` / `Render(Root, Widget)`
   signatures (the earlier fix had been accidentally reverted).
5. Documentation (SYNTAX/GUIDE): added the single-tree standard (one
   `UI.*` expression + `UI.Show`/`UI.Unmount`, zero ceremony) and the
   automatic re-layout behavior of bound widgets.

## 0.4 — Automatic safe area in UIScaffold

1. `UIScaffold` now measures Android `WindowInsets` automatically on every
   `Render` (via `UIWidgetBridge.GetSafeBounds`) and offsets its appBar,
   body, FABs and bottom navigation below the status area. Apps no longer
   need the navigator (or any per-screen inset logic) to respect the
   status bar — this is now the default behavior.
2. `UINavigator` no longer applies inset offsets; it is purely a virtual
   screen host. `RefreshInsets` remains as a compatibility no-op.
3. Documentation (SYNTAX/GUIDE/README/FORUM_GUIDE) updated: safe area is a
   root-layout concern handled automatically by `UIScaffold`.

## 0.3 — Self-explanatory errors, theme constants and canonical examples

1. `AddChild` (UIColumn/UIRow/UIStack) now reports actionable errors through
   the shared diagnostics: Null child, non-widget object, or a widget that
   already belongs to another container ("call UI.Unmount or remove it
   first"). No more silent drops. Children are released on `Unmount`, so
   widgets can be re-added safely.
2. Theme presets with constants: `UI.Theme(UI.THEME_LIGHT)` / `UI.Theme(UI.THEME_DARK)`.
   `UI.ThemeDefault` and `UI.ThemeDark` remain for direct use.
3. Added `UI.Render(Widget, Root)` as an alias of `UI.Show`.
4. Added three canonical copy-paste examples: `examples/b4a_ui_counter`,
   `examples/b4a_ui_login` and `examples/b4a_ui_dashboard` (each standalone,
   100% factory code).

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