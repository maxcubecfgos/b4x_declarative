---
name: declarative-ui-b4a
description: Complete operating knowledge of the Declarative UI for B4X library, a Flutter-inspired, code-first declarative UI layer for native B4A (Android) and B4J (Desktop) apps. Use whenever writing, reviewing, refactoring, explaining or debugging B4X code that composes screens with the UI.* factory (UI.Text, UI.Scaffold, UI.Column...), the UI* widget classes, UIState bindings, UITheme, UIScaffold safe area, UINavigator, or the DeclarativeUI b4xlib. Triggers include declarative UI B4X, the UI.* factory, BindText, UIState, UITheme, UIScaffold, UINavigator, UIListView, UISnackBar, safe area, widget lifecycle, natural measurement and DeclarativeUI.b4xlib.
---

# Declarative UI for B4X — library knowledge

This skill is the condensed operating knowledge of the **Declarative UI for B4X**
library. The authoritative documents live in this same repository: `README.md`
(overview), `GUIDE.md` (user guide), `SYNTAX.md` (stable syntax contract,
version 2.1). Read those files when you need the full wording; this skill is the
reference an agent should work from when writing or reviewing application code.

## What this library is

A small, **code-first declarative UI layer** for native B4A Android applications,
inspired by Flutter but deliberately smaller. Application code composes a tree
of widget objects; the library owns native view creation, measurement,
positioning and rendering.

- It is normal B4X/B4A code with optional fluent method chaining.
- It is **not** a new language, a Flutter/Dart/XML clone, a Designer replacement,
  a virtual-DOM diff engine, or a promise of complete Flutter compatibility.
- Native B4A views (`Panel`, `Button`, `Label`, `EditText`, `ScrollView`...) are
  used underneath; `UINative` inserts arbitrary existing native views.

## The UI.* factory (Contract 2.0 — preferred entry point)

`UI.bas` is a static-code module where every function creates, initializes and
returns a widget. Application code should **never** write `Dim x As UIxxx` +
`x.Initialize` for factory-built trees, and should never call
`SetParent/SetPosition/SetSize/Render` manually: `UI.Show` owns the mount.

Canonical patterns:

```basic
' One widget, mounted full-screen:
UI.Show(Activity, UI.Text("Hola").Size(24))

' A tree built with the fluent chain (no Dim/Initialize anywhere):
UI.Show(Activity, UI.Column(Null) _
    .Spacing(12dip) _
    .AddChild(UI.Text("Titulo").Size(20)) _
    .AddChild(UI.Button("Guardar").OnClick(Me, "Save_Click")))

' Data-driven tree from a List:
UI.Show(Activity, UI.Column(MyWidgetsList))
```

Mounting API:
- `UI.Show(Root As B4XView, Widget)` — mounts at full Root bounds and renders.
  `UI.Render(Root, Widget)` is an alias.
- `UI.Mount(Widget, Root, Left, Top, Width, Height)` — explicit bounds.
- `UI.Unmount(Widget)` — terminal release of a mounted tree.
- `UI.Refresh(Widget)` — re-renders a mounted widget.
- `UI.Invalidate(ChangedWidget)` — re-layouts the mounted tree (re-renders the
  `UI.Show` root so every ancestor re-measures).
- Diagnostics: `UI.Diagnostics`, `UI.Errors As List`, `UI.HasErrors`,
  `UI.ClearErrors`, `UI.ReportError(Operation, Message)`.
- Child-owner registry: `UI.RegisterChild`, `UI.UnregisterChild`,
  `UI.ChildOwner` power the self-explanatory `AddChild` diagnostics ("the widget
  already belongs to another container (...); call UI.Unmount or remove it
  first").

Factory catalog (each returns an initialized widget):

| Factory | Returns |
| --- | --- |
| `UI.Text(Value)` | UILabel |
| `UI.Button(Value)` | UIButton |
| `UI.Fab(Value)` | UIFloatingActionButton |
| `UI.Input(Hint)` | UIInput |
| `UI.Icon(Glyph)` / `UI.IconFA(Glyph)` / `UI.IconMaterial(Glyph)` | UIIcon (Unicode / FontAwesome / Material) |
| `UI.ImageAsset(Name)` / `UI.ImageNetwork(Url)` | UIImage |
| `UI.Progress(Percent)` | UIProgressBar |
| `UI.Switch(Label)` / `UI.Checkbox(Label)` / `UI.Radio(Label)` | UISwitch / UICheckbox / UIRadioButton |
| `UI.Space(Size)` / `UI.Divider` | UISpace / UIDivider |
| `UI.Column(Children)` / `UI.Row(Children)` / `UI.Stack(Children)` | UIColumn / UIRow / UIStack — children: a List, one widget, or Null for fluent `AddChild` |
| `UI.Padding(All, Child)` | UIPadding |
| `UI.Card(Child)` / `UI.Center(Child)` / `UI.Expanded(Child)` / `UI.Scroll(Child)` / `UI.Visibility(Child)` | UICard / UICenter / UIExpanded / UIScrollView / UIVisibility |
| `UI.Scaffold(Body)` / `UI.AppBar(Title)` / `UI.BottomNavigationBar` / `UI.Navigator` / `UI.ListView(Data)` | UIScaffold / UIAppBar / UIBottomNavigationBar / UINavigator / UIListView |
| `UI.State(Value)` / `UI.AsyncState` | UIState / UIAsyncState |
| `UI.Theme(UI.THEME_LIGHT|UI.THEME_DARK)` / `UI.ThemeDefault` / `UI.ThemeDark` / `UI.ThemeWithScheme(Seed)` / `UI.ThemeWithSchemeAndMode(Seed, Dark)` | UITheme |
| `UI.Snack(Message)` / `UI.Dialog` / `UI.Animation(Target)` / `UI.Native(View, NaturalWidth, NaturalHeight)` | UISnackBar / UIAlertDialog / UIAnimation / UINative |

Theme mode constants: `UI.THEME_LIGHT` (0), `UI.THEME_DARK` (1).

**Rules of the single-tree standard** (see `examples/b4a_declarative_counter`):
1. Build the whole screen in one expression, mounted with `UI.Show`.
2. Declare only globals that state or events need later (Root, theme, screen
   reference for `UI.Unmount`).
3. Rebuild = `UI.Unmount(Screen)` + `UI.Show(Root, Screen)`. `UI.Show` mounts on
   top and does **not** clear a previous tree.
4. Split into builder functions only when the tree becomes too large to read —
   never per-widget.
5. Bound widgets re-layout automatically (see Bindings below).

## Widget lifecycle / composition protocol

Every layout-aware widget follows the same protocol (Tier B of the contract):

```basic
SetParent(parent As B4XView)
SetPosition(left As Int, top As Int)
SetSize(width As Int, height As Int)
Render
Detach
Unmount
GetContentSize(maxWidth As Int, maxHeight As Int) As List
```

Semantics:
- `Render` creates **or updates** the native view, preserving identity — a
  focused `EditText` is not recreated on re-layout.
- `Detach` is **temporary**: removes the native view while preserving
  declarative config, bindings and reusable native controls (navigation,
  list pooling).
- `Unmount` is **terminal** cleanup: releases native views and subscriptions.
- Custom widgets that omit `Detach` stay compatible — `UIWidgetBridge` falls
  back to `Unmount`.
- Application code calls the protocol only on the root; containers call it on
  their children.

## Natural measurement and layout

`GetContentSize(maxWidth, maxHeight)` returns:
- `List(width, height)` — the child has a natural size;
- an **empty List** — the child is flexible and expects assigned space
  (this is what `UIExpanded` and a root `UIScaffold` report).

`UIColumn` (vertical) and `UIRow` (horizontal):
- `Spacing(Int)` — gap between children.
- `MainAxisAlignment`: `start` (default), `center`, `end`, `spaceBetween`,
  `spaceAround`, `spaceEvenly` (case-insensitive; invalid → `start`).
- `CrossAxisAlignment`: `stretch` (default), `start`, `center`, `end`.
- `MainAxisSize`: `max` (default, uses assigned bounds), `min` (natural size
  when no flexible child needs space). An empty `min` column is 0-height.
- Flexible children (`UIExpanded`) receive the remaining main-axis space,
  distributed evenly (1px remainder spread left to right).
- Two passes: measure + classify, then position + render.

Other containers:
- `UIPadding`: `All(Int)`, `Horizontal(Int)`, `Vertical(Int)`, `Only(Left, Top, Right, Bottom)`, `Child(Object)`.
- `UICenter`: centers one child using its measured natural size.
- `UIStack`: Z-axis container; `AddChild` insertion order = stacking order
  (later children on top). `Alignment` accepts `topLeft` (default), `topCenter`,
  `topRight`, `centerLeft`, `center`, `centerRight`, `bottomLeft`, `bottomCenter`,
  `bottomRight`. Natural size = largest participating child; flexible children
  get the full stack bounds.
- `UIVisibility`: wraps one child. `Visible(Boolean)` (default True),
  `BindVisible(UIState)`, `UnbindVisible`, `OnVisibilityChanged(Target, EventName)`,
  `Child(Object)`. Hidden → reports `List(0, 0)`, detaches the child. After a
  visibility change, **render the affected parent** yourself (the callback owns
  remeasurement; the library does not guess which parent to reflow).
- `UIExpanded`: layout marker that receives remaining main-axis space.
- `UIScrollView`: wraps one child in a native `ScrollView`; `Child`,
  `ScrollTo(Y)`, `GetScrollPosition`. Place inside `UIExpanded` when it shares
  a Column with fixed content.
- `UISpace`: fixed gap. `UIDivider`: themed horizontal separator.

## State and bindings

`UIState` is a small observable value holder (numbers are normalized to Double
so a counter renders `0`, `1`, ... and never `1.0`):

```basic
Dim CounterState As UIState
CounterState.Initialize(0)          ' or UI.State(0)

CounterState.SetState(CounterState.GetState + 1)
Dim v As Object = CounterState.GetState
```

- `Subscribe(Target, EventName)` → callback `Sub EventName(State As UIState)`.
- `Unsubscribe(Target, EventName)`, `UnsubscribeTarget(Target)` (all owned by a
  target), `ClearListeners`.
- `SetState` notifies only on change; a callback that changes the same state is
  bounded to a second notification pass (no infinite loops).
- `CoalesceNotifications(True)` defers/coalesces callbacks to the next UI cycle
  (opt-in; default is synchronous).
- `UIState` does not observe mutations inside an existing Map/List — assign a
  replacement value.

**Bindings are one-way and replaceable.** A binding applies the current value
immediately and updates the widget on change. Calling the static setter cancels
the binding (permanent precedence rule):

| Widget | Binding | Static setter that cancels it |
| --- | --- | --- |
| UILabel | `BindText(UIState)` | `Text(String)` |
| UIButton | `BindText(UIState)` | `Text(String)` |
| UIFloatingActionButton | `BindText(UIState)` | `Text(String)` |
| UIInput | `BindText(UIState)` | `Text(String)` |
| UIAppBar | `BindTitle(UIState)` | `Title(String)` |
| UIVisibility | `BindVisible(UIState)` | `Visible(Boolean)` / `UnbindVisible` |
| UIProgressBar | `BindValue(UIState)` | `Value(Int)` |

`UIBottomNavigationBar.BindSelectedIndex(UIState)` is **not** cancelled by
`SetSelectedIndex(Int)` — `SetSelectedIndex` updates the bar AND writes the new
index back into the bound state (`SetState`), keeping them synchronized. Use
`UnbindSelectedIndex` to remove the binding.

For `UIInput` the binding is one-way: state → field, while user edits arrive
through `OnTextChanged(NewText As String)`; the host calls `SetState` itself.
Two-way form binding is deliberately not part of the contract.

`UIAsyncState` models async operations: statuses `idle`, `loading`, `success`,
`error`. `SetIdle`, `SetLoading`, `SetSuccess(Value)`, `SetError(Message)`,
`Reset`; readers `GetStatus`, `GetValue`, `GetErrorMessage`, `IsIdle`,
`IsLoading`, `IsSuccess`, `IsError`; `Subscribe` → `Sub Name(State As UIAsyncState)`.
It does not make HTTP requests — the host keeps using `Wait For`/`HttpJob`.

## Themes

`UITheme` is a Material 3-like design-token provider (values only — it does not
repaint anything by itself):

```basic
Dim AppTheme As UITheme
AppTheme.Initialize                                  ' light, default seed
' AppTheme.InitializeDark
' AppTheme.InitializeWithScheme(0xFF6750A4)
' AppTheme.InitializeWithSchemeAndMode(0xFF6750A4, True)
AppTheme.Scheme(0xFF6558D3)                          ' change seed, keep mode
AppTheme.Toggle                                      ' light <-> dark
```

Semantic properties: `Background`, `Surface`, `SurfaceVariant`, `PrimaryText`,
`SecondaryText`, `MutedText`, `DashboardBar`, `SecondaryBar`, `HeroSurface`,
`Accent`, `Info`, `Negative`, `Divider`, `Border`, `ButtonText`, `ThemeAction`,
`AccentText`, `InfoText`, `NegativeText`, `ThemeActionText`, `DashboardBarText`,
`RippleColor`. Typography: `DisplayLarge`, `HeadlineSmall`, `TitleLarge`,
`BodyLarge`, `BodyMedium`, `BodySmall`, `LabelLarge`, `ButtonTextSize`,
`InputTextSize`, `NavigationTextSize`, `AppBarTitleSize`, `FabTextSize`.
Shapes: `RadiusSmall/Medium/Large`, `ButtonRadius`, `CardRadius`, `InputRadius`,
`FabRadius`, `SnackbarRadius`. Layout: `AppBarHeight`, `BottomNavigationHeight`,
`FabSize`, `HorizontalPadding`, ... .

**Theme application is root-first and propagates.** Call `.ApplyTheme(Theme)` on
the root scaffold/navigator: `UIScaffold.ApplyTheme` forwards to appBar, body,
FABs and bottom navigation; containers (`UIColumn`, `UIRow`, `UIStack`,
`UIPadding`, `UIBox`, `UICenter`, `UIExpanded`, `UIScrollView`, `UIVisibility`,
`UICard`) forward to their children; `UIAppBar` forwards to its action widget.
**Leaf widgets do not need their own `ApplyTheme` in a root-themed tree.**

Explicit setters (`Color(...)`, `Size(...)`, `BackgroundColor(...)`,
`CornerRadius(...)`, `TextSize(...)`...) mark only that property as overridden;
`ApplyTheme` never replaces an overridden property. In a theme-toggle, rebuild
the tree (`UI.Unmount` + rebuild + `UI.Show`) or call `ApplyTheme` again; the
scaffold re-paints its background from `mBackgroundColor` (theme `Background`).

## Widget catalog

- **UIAppBar**: `Title`, `BindTitle`, `UnbindTitle`, `Action(Widget)` (trailing
  icon/button), `ClearAction`, `BackgroundColor`, `TitleColor`, `TitleSize`,
  `ApplyTheme`. Natural height = theme `AppBarHeight`.
- **UIScaffold**: `AppBar`, `Body`, `FloatingActionButtonLeft/Right`,
  `BottomNavigationBar`, `Clear*` variants, `BackgroundColor`, `ApplyTheme`,
  `RefreshInsets`. Reserves app bar + bottom nav + FAB space before laying out
  the body; applies **safe area automatically** on every `Render` (status bar,
  IME, multi-window via `UIWidgetBridge.GetSafeBounds` reading Android
  `WindowInsets`).
- **UIBottomNavigationBar**: `AddItem(Id As String, Icon As String, Text As String)`
  (Unicode icons, no icon-font dependency), `BindSelectedIndex`,
  `SetSelectedIndex`, `GetSelectedIndex`, `GetSelectedId`, `OnSelected`,
  `ShowInactiveLabels(Boolean)`, `ActiveColor`, `InactiveColor`,
  `IndicatorColor`, `BackgroundColor`, `DividerColor`, `IconSize`, `TextSize`.
  Default height 64dip. Selection updates existing native children (no rebuild
  of native views per tab change).
- **UINavigator**: virtual screens in one Activity. `AddScreen(Name, Widget)`,
  `NavigateTo(Name)`, `GoBack`, `CanGoBack`, `ApplyTheme`, `RefreshInsets`.
  A route change **detaches** the previous screen (restorable by `GoBack`);
  `Unmount` is terminal. Does not apply inset offsets itself (UIScaffold does).
- **UILabel**: `Text`, `BindText`, `UnbindText`, `Size`, `Color`, `ApplyTheme`.
  Natural size measured via `Canvas.MeasureStringWidth` with wrap estimate.
- **UIButton**: `Text`, `BindText`, `UnbindText`, `BackgroundColor`, `TextColor`,
  `TextSize`, `CornerRadius(Int)`, `Border(width As Int, color As Int)`,
  `OnClick`, `TriggerClick`, `ApplyTheme`. Default radius/border 0 = native look.
- **UIFloatingActionButton**: `Text`, `BindText`, `UnbindText`, `BackgroundColor`,
  `TextColor`, `TextSize`, `CornerRadius`, `OnClick`, `ApplyTheme`. Rounded
  ripple via `RippleDrawable` (API 21+).
- **UIInput**: native `EditText`. `Hint`, `Text`, `BindText`, `UnbindText`,
  `OnTextChanged`, `TextColor`, `HintColor`, `BackgroundColor`, `TextSize`,
  `CornerRadius`, `Border`, `PasswordMode(Boolean)`, `GetText`, `ApplyTheme`.
  Natural height 48dip. Custom background restores touch-friendly padding.
- **UIIcon**: `Unicode`, `FontAwesome`, `Material`, `MaterialCode(Int)`,
  `FontAwesomeCode(Int)`, `Size`, `Color`, `Alignment`, `OnClick`.
- **UIImage**: `Asset(Name)`, `Network(Url)`, `PlaceholderAsset`, `Fit`, `Width`,
  `Height`, `OnLoaded`, `OnError`. Requires OkHttpUtils2 for network.
- **UIProgressBar**: `Value(Int)`, `BindValue`, `UnbindValue`, `Indeterminate`,
  `BarHeight`, `CornerRadius`, `ApplyTheme`.
- **UISwitch**: `Text`, `Checked`, `BindChecked`, `OnChanged`.
- **UICheckbox**: `Text`, `Checked`, `BindChecked`, `OnChanged`.
- **UIRadioButton / UIRadioGroup**: `Value`, `Text`, `Selected`, `BindSelected`,
  `AddOption`, `AddButton`, `OnSelected`.
- **UICard**: `Child`, `BackgroundColor`, `BorderColor`, `CornerRadius`,
  `ApplyTheme`, `GetView`.
- **UIBox**: lightweight padded container `Initialize(child, padding)`.
- **UINative**: inserts an existing native B4A view.
  `Initialize(View, NaturalWidth, NaturalHeight)`, `GetView`.
- **UIPlaceholder**: loading/reserved box. `Color`, `StrokeWidth`, `Width`,
  `Height`, `Size`, `ApplyTheme`.

## Events and callbacks (exact signatures)

Callbacks use normal B4A `(Target, EventName)` style. A missing callback is
reported through `UI.Errors` instead of failing silently.

| Widget | Method | Callback signature |
| --- | --- | --- |
| UIButton / UIFloatingActionButton / UIIcon | `OnClick` | `Sub Name` (no params) |
| UIInput | `OnTextChanged` | `Sub Name(NewText As String)` |
| UIBottomNavigationBar | `OnSelected` | `Sub Name(Index As Int, Id As String)` |
| UIVisibility | `OnVisibilityChanged` | `Sub Name(Visibility As UIVisibility)` |
| UISnackBar | `Action` | `Sub Name` (no params) |
| UIAnimation | `OnCompleted` | `Sub Name` (no params) |
| UIListView | `CreateItem` / `BindItem` | `Sub Name(Index As Int) As Object` / `Sub Name(Index As Int, ItemView As Object)` |
| UIState | `Subscribe` | `Sub Name(State As UIState)` |
| UIAsyncState | `Subscribe` | `Sub Name(State As UIAsyncState)` |

## Overlays and effects

- **UISnackBar**: `Message`, `Action(Text, Target, EventName)`, `Duration(ms)`
  (0 = stays until Dismiss), `AnimationDuration(ms)` (0 = no animation),
  colors, `CornerRadius`, `Margin`, `Show(Parent As B4XView)`, `Dismiss`,
  `Unmount`. Overlay, not a tree child; older delayed work is invalidated by
  newer Show/Dismiss/Unmount.
- **UIAlertDialog**: `Title`, `Message`, `Content(Widget)`, `PositiveButton`,
  `NegativeButton`, `DismissOnOutside`, `ButtonColor`, `ButtonTextColor`,
  `CornerRadius`, `ApplyTheme`, `Show(Parent)`, `Dismiss`.
- **UIAnimation**: bounds-only, opt-in. `TargetView(B4XView)`, `MoveTo(L,T)`,
  `SizeTo(W,H)`, `MoveAndResize(L,T,W,H)`, `Duration(ms)`, `OnCompleted`,
  `Start`, `Cancel`, `IsRunning`. Does not replace layout.

## Lists

`UIListView` = fixed-height virtualized vertical list (pooled declarative rows).
`Items(Data As List)`, `ItemCount`, `ItemHeight(Int)`, `Overscan(Int)`,
`CreateItem(Me, "CreateRow")`, `BindItem(Me, "BindRow")`,
`NotifyDataSetChanged`, `GetItem(Index)`, `ScrollTo`, `GetScrollPosition`,
`ApplyTheme`. With `BindItem`, offscreen rows are detached into a pool and reuse
native controls; without it, rows are recreated so stale content cannot
survive a data change. Variable-height rows are not supported — use
`UIScrollView` for small/variable content, `UIListView` for long fixed-height
collections.

## Writing code in this style (rules an agent must follow)

1. **Use the UI.* factory** — never `Dim x As UIxxx` + `x.Initialize` for
   factory-built trees; never call `SetParent/SetPosition/SetSize/Render` in
   application code (`UI.Show` owns it).
2. **Line continuation is ` _`** (space + underscore) at the end of the line.
   Every fluent chain line except the last must end with ` _`. A continuation
   must be followed by a code line (never a blank line or a comment).
3. **Parentheses must balance per statement.** When you remove a call from a
   fluent chain, adjust the trailing parentheses — removing
   `.ApplyTheme(AppTheme)` from `...Color(x).ApplyTheme(AppTheme))))` leaves
   `...Color(x)))` (one close short). Prefer shallow trees; split very large
   screens into builder functions that return widgets.
4. **Don't repeat `ApplyTheme` on leaves** when the root scaffold/navigator
   already applies it (it propagates). Use explicit setters for per-widget
   overrides.
5. **Render after structural changes**: changing the tree (AddChild,
   visibility, theme) requires rendering the affected root —
   `UI.Unmount` + rebuild + `UI.Show`, or `UI.Render`/`UI.Invalidate`.
   Bindings re-layout automatically; ordinary property changes appear after
   the next Render.
6. **Bindings are one-way and cancelled by their static setter**; a binding
   applies the current state immediately.
7. **Safe area is automatic in UIScaffold** — never compute status-bar insets
   in screens. Wrap scroll content in `UIExpanded` when sharing a Column with
   fixed header/footer.
8. After editing any example or app code, run the project verifier (below).

## Verification workflow

1. **`python check-b4x-source.py`** (repository root; Python standard library
   only, no third-party dependencies) — static gate over every `.b4a`/`.bas`
   in the repository (examples, library modules and the host project): paren
   balance per statement, ` _` continuation rules, `Sub/#Region/Type` pairing,
   BOM/`@EndOfDesignText@` header. Accepts explicit files/directories and
   scans the repository when run without arguments, so it keeps working even
   if `examples/` is removed. Runs automatically inside `build-b4xlib.ps1`
   before packaging.
2. **b4x-mcp** (when available, CLI one-shot mode):
   - `b4x-mcp.exe --cli validate_b4x_syntax --project-path <file.b4a>`
   - `b4x-mcp.exe --cli compile_project --project-path <file.b4a>` (real B4ABuilder)
   - `b4x-mcp.exe --cli diagnose_project --project-path <file.b4a>`
   - `b4x-mcp.exe --cli get_codebundle --project-path <file.b4a>`
   If the IDE has the project open, `ide_state.json` may be **stale** after
   editing files on disk: press **Ctrl+R** in the B4A IDE to regenerate.
3. The IDE CodeBundle and `compile_project` output are the authoritative
   "does it compile" sources; `validate_b4x_syntax` is a fast static check.

## Versioning and contract

- Contract version 2.0 (see `SYNTAX.md`): public syntax, fluent return types,
  callback signatures, binding precedence, layout values and the lifecycle
  protocol are stable within a contract major version.
- Tier A = application API (compatibility-sensitive); Tier B = composition
  protocol (custom widgets implement `SetParent/SetPosition/SetSize/Render/
  Detach/Unmount/GetContentSize`); Tier C = internal details (free to change).
- Deliberate boundaries: no virtual-DOM diffing, no two-way form binding, no
  variable-height list rows, no implicit animations, no global app state.
