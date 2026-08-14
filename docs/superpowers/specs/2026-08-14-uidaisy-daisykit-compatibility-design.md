# UIDaisy: DaisyKit compatibility adapter + template rewrite

Date: 2026-08-14
Status: Approved (design brainstormed with the author)

## Context

The Declarative UI for B4A library (code-first declarative UI layer, Flutter
inspired) needs to host components from a third-party component kit:

- **B4XDaisyUIKit** ("DaisyKit", by Anele Mbanga / Mashyane; b4xlib
  `B4XDaisyUIKit.b4xlib`, package `com.sithaso.daisyuikit`) — a kit of ~100
  native components (`B4XDaisy*` classes: Button, Card, Text, Input, Toggle,
  Progress, Alert, SweetAlert, Navbar, Fab, ...).
- DaisyKit components are **not** `B4XView`s and do **not** implement the
  Declarative UI widget protocol. They own a lifecycle of their own
  (`Initialize`, `AddToParent`, `RemoveViewFromParent`, setters, events).

Goals (stated by the author):

1. Use DaisyKit components **declaratively** inside Declarative UI trees
   through a dedicated adapter widget named `UIDaisy` (via a `UI.Daisy`
   factory), **without copying or reusing any DaisyKit code** ("no code reuse,
   no reinventing the wheel").
2. **No manual measurements**: the adapter must auto-measure components, like
   the rest of the library (natural size via `GetContentSize`).
3. Rewrite the **template example** (`examples/b4a-template`, "Lumen Home") so
   the visual widgets belong to the UIDaisyKit library, keeping Declarative
   UI's own infrastructure (scaffold, navigation, state, list, mounting).

## Verified facts about DaisyKit components (protocol)

Verified by reading the unpacked `B4XDaisyUIKit.b4xlib` sources
(`C:\Program Files\Anywhere Software\extra\B4XDaisyUIKit.b4xlib`).

Common surface (present in essentially every component):

- `Public mBase As B4XView` — the component's root view (public field).
- `Public Sub Initialize(Callback As Object, EventName As String)` — events
  are raised to the caller with the EventName prefix
  (e.g. `mEventName & "_Click"`), through
  `B4XDaisyVariants.RaiseEventIfSubExists`.
- `Public Sub AddToParent(Parent As B4XView, Left As Int, Top As Int, Width As Int, Height As Int) As B4XView`
  - Resolves margins internally (`Left + mg.l`, `Width - mg.l - mg.r`, ...).
  - **`W <= 0` or `H <= 0` triggers the component's own fit-content
    resolution** (e.g. Button → configured/content width + resolved height;
    Checkbox → `EstimatePreferredWidth/Height`; Input → 200dip default width
    when unset).
  - Creates the view lazily (`If mBase.IsInitialized = False Then ...`) and
    then **unconditionally calls `Parent.AddView(mBase, ...)`** — re-adding to
    the same parent crashes with "The specified child already has a parent",
    so the adapter must `RemoveViewFromParent` before re-adding.
- `Public Sub RemoveViewFromParent`
- `GetComputedHeight` / `getComputedHeight` (naming is inconsistent across
  components; B4X method calls are case-insensitive) — returns `mBase.Height`,
  i.e. **requires the view to exist before it reports anything useful**.
- `CreateView(Width, Height) As B4XView` — offscreen-safe creation in ~60% of
  components; **not universal** (absent in Card, Checkbox, Toggle, Input,
  Label, Select, List, Menu, Accordion, Steps, ...).
- Measurement helpers are not uniform (`GetEstimateContentWidth` only on
  Button; `MeasureTextWidth/Height` only on Text).
- Theming: `B4XDaisyVariants.ApplyThemeToPage(ThemeName, RootView)` cascades
  `UpdateTheme` to Daisy components via `Tag` + `SubExists` duck-typing.

Conclusion: there is **no uniform native measurement API**, but the uniform
`AddToParent(parent, ...)` with `(0, 0)` sizes + `mBase.Width/Height` read-back
after an **offscreen mount** gives a universal auto-measure path that does not
need manual measurements.

## Design

### 1. `UIDaisy` adapter widget (new module `UIDaisy.bas`)

Implements the Declarative UI widget protocol (Tier B) for one DaisyKit
component instance:

```
UI.Daisy(Component As Object)                        ' auto-measure both axes
UI.Daisy(Component As Object, W As Int, H As Int)    ' 0 = auto for that axis
```

- `Initialize(Component As Object, NaturalWidth As Int, NaturalHeight As Int) As UIDaisy`
  — component is **owned by the caller** (like `UINative`), already
  initialized by the user with `Initialize(Me, "event")`.
- **Access without compile-time dependency on DaisyKit** (the library does not
  reference any `B4XDaisy*` type): duck typing via `SubExists` + the official
  Reflection library (`Reflector`):
  - `AddToParent` (5 args) and result-returning reads via
    `r.RunMethod(...)` / `r.GetField("mBase")`.
  - Protocol requirement: the component must expose `AddToParent`,
    `RemoveViewFromParent` and a public `mBase As B4XView` field; otherwise
    `UI.ReportError` is raised through the existing diagnostics system.
- **Auto-measure** (`GetContentSize(MaxWidth, MaxHeight)`):
  1. Keep an internal hidden measuring panel (a `Panel` created in
     `Initialize`, never added to a window — offscreen mounts are safe, this
     is exactly what DaisyKit's own `CreateView` does).
  2. On first measure: offscreen mount `AddToParent(measuringPanel, 0, 0, 0, 0)`
     → the component resolves its own fit-content size → read back
     `mBase.Width`/`mBase.Height` → `RemoveViewFromParent` → cache the natural
     size.
  3. Subsequent `GetContentSize` calls re-mount offscreen and re-read (the
     view already exists, so it is cheap) — config changes made by the user
     before render are always reflected.
  4. Return `List(Min(W, MaxWidth), Min(H, MaxHeight))` with `W`/`H` = the
     explicit override when > 0, else the measured natural size. On failure
     (Try/Catch or protocol violation) return an **empty list** (flexible
     child, matching `UINative` semantics).
- **Render**: with the engine-assigned bounds — if already mounted under a
  parent, `RemoveViewFromParent` first, then
  `AddToParent(Parent, Left, Top, Width, Height)` (avoids the "child already
  has a parent" crash; DaisyKit re-applies its own margin resolution).
- **Detach**: `RemoveViewFromParent`. **Unmount**: `RemoveViewFromParent`;
  the component instance and its event subscriptions stay alive (caller-owned).
- **ApplyTheme** (Theme As UITheme): no-op returning `Me` — DaisyKit manages
  its own look through `Variant`/`Class`/`Size`; identity preserved for theme
  propagation through declarative containers (same pattern as `UINative`).

### 2. Factory in `UI.bas`

- `UI.Daisy(Component As Object) As UIDaisy` — auto-measure default.
- `UI.Daisy(Component As Object, NaturalWidth As Int, NaturalHeight As Int) As UIDaisy`
  — explicit override per axis; `0` means auto for that axis (satisfies "no
  manual measurements" by default while keeping an escape hatch).
- Library project (`Declarative UI.b4a`) header gains `LibraryN=reflection`;
  consumers (and the template) must also reference `reflection` (DaisyKit
  already does).

### 3. Template rewrite (`examples/b4a-template`, Lumen Home)

Infrastructure stays Declarative UI: `UIScaffold`, `UINavigator`,
`UI.AppBar`, `UI.BottomNavigationBar`, `UIListView` (row container),
`UIState`/`UIAsyncState`, safe area, `UI.Show` mounting.

Visual widgets become DaisyKit components wrapped in `UI.Daisy`:

| Current (UI.*) | New (B4XDaisy*) |
| --- | --- |
| `UI.Text` | `B4XDaisyText` |
| `UI.Button` | `B4XDaisyButton` (`Variant="primary"`, `Rounded="full"`) |
| `UI.Card` | `B4XDaisyCard` + `B4XDaisyCardBody` |
| `UI.Input` | `B4XDaisyInput` |
| `UI.Switch` | `B4XDaisyToggle` |
| `UI.Progress` | `B4XDaisyProgress` |
| `UI.IconFA` | `B4XDaisyIconButton` (or `B4XDaisySvgIcon`) |
| `UI.Fab` | `B4XDaisyFab` |
| `UI.Snack` | `B4XDaisyToast` / `B4XDaisyAlert` |
| `UIAlertDialog` (dialogs) | `B4XDaisySweetAlert` / `B4XDaisyModal` |
| Color badge chip | `B4XDaisyBadge` / `B4XDaisyAvatar` |
| `UIDivider` | `B4XDaisyDivider` |

Assumptions agreed with the author:

1. Bindings (`BindText`/`BindChecked`/`BindValue`) do **not** exist on Daisy
   widgets — replaced by direct setters + event handlers; keep component
   references as globals for dynamic updates (the template's `UpdateStats`
   pattern already fits).
2. Dark mode: the toggle calls `B4XDaisyVariants.ApplyThemeToPage(<theme>,
   Root)` (DaisyKit's cascade); `UITheme` remains only for the remaining
   `UI.*` infrastructure (AppBar/BottomNav/list).
3. `UI.AppBar` and `UI.BottomNavigationBar` stay as-is (scaffold reserves
   their space with its own widgets; swapping to `B4XDaisyNavbar`/`Dock`
   complicates layout with no demo benefit).
4. Template libraries: add `b4xdaisyuikit` and `reflection` (it already
   references `core`, `xui`, `javaobject`, `okhttputils2`, `declarativeui`).
5. The Devices screen builds its `UIListView` rows with `UI.Daisy` widgets
   (demonstrates the adapter inside pooled rows).

### 4. Docs

- `README.md`, `GUIDE.md`, `SYNTAX.md`: new `UI.Daisy` / `UIDaisy` entry
  (usage, protocol requirements, measurement semantics, diagnostics).
- `CHANGELOG.md`: new entry.

## Verification

1. `python check-b4x-source.py` — static gate over the whole repo (paren
   balance, continuations, Sub pairing, headers).
2. `build-b4xlib.ps1` — rebuild `DeclarativeUI.b4xlib` (runs the check
   automatically).
3. `b4x-mcp` on the template: `validate_b4x_syntax`, `compile_project`
   (real B4ABuilder); `Declarative UI.b4a` project must also compile with the
   new module + reflection library.
4. Manual/preview check: build the template and inspect the rendered demo
   (auto-measure placement, dark mode toggle, list rows).

## Out of scope

- No copying or adaptation of any DaisyKit source code (the adapter only
  calls the public protocol).
- No per-component factory methods (`UI.DaisyButton`, ...).
- No binding support on Daisy components.
- B4J support (Reflection library exists for B4A/B4i, not B4J); declared
  B4A-first for this feature.