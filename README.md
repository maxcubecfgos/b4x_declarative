# Declarative UI for B4A

A small, code-first declarative UI layer for native B4A applications.

> **Documentation:** See [GUIDE.md](GUIDE.md) for installation, examples, widget APIs, lifecycle, layout, events, themes, navigation and troubleshooting. See [SYNTAX.md](SYNTAX.md) for the stable syntax and API compatibility contract.

This project explores a Flutter-inspired way to compose Android interfaces in B4A while keeping the result native, lightweight, and understandable. It does not try to recreate Flutter internally. Instead, it provides a focused set of composable widgets with a predictable mount, measure, layout, render, and unmount lifecycle.

The included example is intentionally a **minimal Flutter-style counter** designed to make the core benefit readable at a glance:

- one real B4A Activity;
- one `UIState` bound to a `UILabel`;
- one `UIAppBar` theme action;
- one `UIFloatingActionButton` increment action;
- native views composed through declarative widgets and natural layout.

The repository documentation also covers the complete widget set, including natural measurement, `UIExpanded`, `UIVisibility`, `UIStack`, `UIScrollView`, virtual navigation, safe-area handling, themes, snackbars, animations, native inputs, bottom navigation and asynchronous state. Those capabilities are documented separately so the minimal example remains a credible code-size demonstration.

## Project structure

| File | Responsibility |
| --- | --- |
| `examples/example.b4a` | Minimal counter demonstration Activity |
| `UITheme.bas` | Reusable light/dark seed-color scheme and semantic palette |
| `UIState.bas` | Observable state holder with selective callbacks |
| `UIAsyncState.bas` | Observable idle/loading/success/error state for asynchronous operations |
| `UISnackBar.bas` | Transient overlay notification with optional action callback |
| `UIAnimation.bas` | Small opt-in native bounds animation utility with cancellation and completion callbacks |
| `UIScrollView.bas` | Declarative wrapper around the native B4A `ScrollView` |
| `UIListView.bas` | Fixed-height virtualized list with pooled declarative item widgets |
| `UINavigator.bas` | Virtual screen registration, navigation, and safe-area host |
| `UIScaffold.bas` | App bar, body, bottom navigation, and optional floating action button layout |
| `UIBottomNavigationBar.bas` | Declarative bottom navigation with items, selection state, indicator and callbacks |
| `UIColumn.bas` | Vertical child layout with natural measurement, axis sizing and alignment |
| `UIRow.bas` | Horizontal child layout with natural measurement, axis sizing and alignment |
| `UIExpanded.bas` | Flexible space marker for Column and Row |
| `UIVisibility.bas` | Conditionally includes or removes one child from layout |
| `UIStack.bas` | Overlapping children with natural measurement and alignment |
| `UIPadding.bas` | Flutter-inspired padding around a child (`All`, `Horizontal`, `Vertical`, `Only`) |
| `UICard.bas` | Rounded surface with background and border colors |
| `UIBox.bas` | Lightweight padded child container |
| `UICenter.bas` | Centers a child using its measured natural size |
| `UILabel.bas` | Native label wrapper with optional `UIState` text binding |
| `UIButton.bas` | Native button wrapper with safe callbacks, optional state binding and configurable corners/borders |
| `UIFloatingActionButton.bas` | Compact native floating action button with safe callbacks and optional `UIState` text binding |
| `UIInput.bas` | Native text input with natural measurement, optional state binding, safe callbacks and configurable corners/borders |
| `UISwitch.bas` | Declarative switch with explicit checked state and label |
| `UIRadioButton.bas` / `UIRadioGroup.bas` | Radio options with exclusive selection and optional state binding |
| `UIAppBar.bas` | App bar with a persistent title and optional `UIState` binding |
| `UIDivider.bas` | Themed horizontal divider |
| `UISpace.bas` | Fixed-size layout spacer |

## Declarative composition

Widgets are composed as objects and then mounted by their parent:

```basic
Dim content As UIColumn
content.Initialize _
    .Spacing(12dip) _
    .AddChild(title) _
    .AddChild(description) _
    .AddChild(actions)

Dim padded As UIPadding
padded.Initialize.Horizontal(16dip).Vertical(10dip).Child(content)

Dim navigation As UIBottomNavigationBar
navigation.Initialize _
    .AddItem("home", "⌂", "Home") _
    .AddItem("settings", "⚙", "Settings") _
    .OnSelected(Me, "Navigation_Selected")

Dim screen As UIScaffold
screen.Initialize _
    .AppBar(appBar) _
    .Body(padded) _
    .BottomNavigationBar(navigation)
```

The application describes the tree. The framework handles native view creation and positioning during `Render`.

## Widget lifecycle

Every layout-aware widget follows the same basic contract:

1. `Initialize` creates the declarative object.
2. Fluent methods configure text, colors, children, spacing, and callbacks.
3. `SetParent`, `SetPosition`, and `SetSize` receive layout information.
4. `GetContentSize` reports the natural size when the widget has one.
5. `Render` creates or updates the native B4A view; repeated renders preserve the widget instance and its native view whenever possible.
6. `Detach` temporarily removes the native view from its parent while keeping declarative state, bindings and reusable native controls.
7. `Unmount` is terminal cleanup: it removes native references and subscriptions before the widget is discarded or permanently rebuilt.

This distinction follows the practical Flutter principle that rebuilds must not equal disposal. Containers, `UINavigator` and `UIListView` use `Detach` for temporary moves/recycling and `Unmount` only for structural destruction. Existing custom widgets that expose only `Unmount` remain compatible through the bridge fallback.

This convention keeps containers reusable and lets `UIColumn`, `UIRow`, `UICenter`, and `UIScrollView` work with different child types through the same small protocol.

## Natural measurement

A child can return a two-item `List` from `GetContentSize`:

```basic
Dim result As List
result.Initialize
result.Add(naturalWidth)
result.Add(naturalHeight)
Return result
```

An empty list represents a flexible child. `UIColumn` and `UIRow` first measure natural children, then distribute the remaining space among flexible children such as `UIExpanded`. When all children have natural sizes, `MainAxisAlignment` can place them at the start, center, end, or distribute the free space evenly. `MainAxisSize` controls whether the container keeps its natural size (`min`) or uses all assigned space (`max`, the default). An empty container with `MainAxisSize("min")` has zero size on its main axis. The visible difference is greatest when the parent assigns more space than the children naturally need; nested parents still determine the constraints passed to each child. `CrossAxisAlignment` controls the perpendicular axis and supports `stretch`, `start`, `center`, and `end`. The default remains `stretch`.

This avoids hard-coding every label height and prevents common clipping problems caused by positioning text using arbitrary constants.

`UIVisibility` can conditionally include a child in the measured tree:

```basic
Dim detailsVisibility As UIVisibility
detailsVisibility.Initialize _
    .Visible(True) _
    .Child(detailsCard)

' After changing visibility, render the parent container to reflow siblings.
detailsVisibility.Visible(False)
dashBoardBody.Render
```

For reactive visibility, bind a Boolean `UIState` and explicitly render the affected parent:

```basic
Dim detailsState As UIState
detailsState.Initialize(True)

detailsVisibility.Initialize _
    .BindVisible(detailsState) _
    .OnVisibilityChanged(Me, "DetailsVisibilityChanged") _
    .Child(detailsCard)

Sub DetailsVisibilityChanged(Visibility As UIVisibility)
    dashBoardBody.Render
End Sub
```

`BindVisible` updates the wrapper immediately and notifies the callback when the state changes. The explicit callback keeps ownership clear: the library does not guess which parent should be remeasured. When hidden, the wrapper reports a natural size of `0, 0`, detaches the child's native view and allows `UIColumn` or `UIRow` to place the remaining children without a gap.

`UIStack` provides Flutter-like Z-axis composition:

```basic
Dim layered As UIStack
layered.Initialize _
    .Alignment("bottomRight") _
    .AddChild(backgroundCard) _
    .AddChild(statusBadge)
```

The stack measures to the largest participating natural child. Flexible children receive the full stack bounds. Children are rendered in insertion order, so later children appear above earlier children.

## UIScrollView

`UIScrollView` wraps the native B4A `ScrollView` while keeping the child declarative:

```basic
Dim events As UIColumn
 events.Initialize.Spacing(8dip) _
    .AddChild(eventCardOne) _
    .AddChild(eventCardTwo) _
    .AddChild(eventCardThree)

Dim scroll As UIScrollView
scroll.Initialize.Child(events)
```

The wrapper:

- Creates the native `ScrollView` only when mounted.
- Uses the native `ScrollView.Panel` as the content parent.
- Measures the child with a large content-height limit.
- Sets the panel height to the child's natural height or the viewport height, whichever is larger.
- Keeps the same child mounted during ordinary layout/state updates, preserving scroll position and native state; structural child replacement is cleaned up safely.
- Exposes `ScrollTo` and `GetScrollPosition` for programmatic control.

A scroll view is normally placed inside `UIExpanded` when it shares a `UIColumn` with a fixed header or footer:

```basic
ActivityBody.Initialize.Spacing(10dip) _
    .AddChild(header) _
    .AddChild(UIExpanded.Initialize.Child(scroll)) _
    .AddChild(refreshButton)
```

## UISnackBar

`UISnackBar` provides short-lived feedback without becoming a permanent child of the declarative layout tree:

```basic
Dim snack As UISnackBar
snack.Initialize _
    .Message("Settings saved") _
    .Action("UNDO", Me, "Undo_Click") _
    .Duration(3000) _
    .Show(Activity)

Sub Undo_Click
    ' Restore the previous value.
End Sub
```

`Show` mounts the overlay over the supplied `B4XView`, `Dismiss` removes it, and `Duration(0)` keeps it visible until dismissed. `AnimationDuration(0)` disables the entrance and exit animation. Calling `Show`, `Dismiss` or `Unmount` invalidates older delayed work so an earlier snackbar cannot remove a newer one.

## UIListView

`UIListView` is the efficient option for long, homogeneous vertical datasets. It keeps a small visible window mounted instead of creating one native tree per item:

```basic
Private NewsItems As List
Private NewsList As UIListView

Sub BuildNewsList As UIListView
    NewsItems.Initialize
    For i = 1 To 5000
        NewsItems.Add("News item " & i)
    Next

    NewsList.Initialize _
        .Items(NewsItems) _
        .ItemHeight(72dip) _
        .Overscan(2) _
        .CreateItem(Me, "CreateNewsItem") _
        .BindItem(Me, "BindNewsItem")
    Return NewsList
End Sub

Sub CreateNewsItem(Index As Int) As Object
    Dim title As UILabel
    title.Initialize.Size(16dip)
    Return title
End Sub

Sub BindNewsItem(Index As Int, ItemView As Object)
    Dim title As UILabel = ItemView
    title.Text("" & NewsList.GetItem(Index))
End Sub
```

The list requires a fixed `ItemHeight`. `CreateItem` must return an initialized widget implementing the normal composition protocol, and `BindItem` must update that widget for the current index before it is rendered. `BindItem` is required for safe pooling when rows display changing data. Call `NotifyDataSetChanged` after changing the external data source or the contents of an item.

`UIListView` recycles declarative widget instances and keeps only visible plus overscanned rows mounted. With `BindItem`, rows leaving the viewport are detached into the pool and can reuse their native controls; when the pool is permanently released, rows are unmounted. Without `BindItem`, rows are recreated rather than pooled so stale content cannot survive a data change. It currently does not implement variable-height rows or a platform `RecyclerView`; use `UIScrollView` for small, variable-height content and `UIListView` for long, fixed-height collections.

## UIAnimation

`UIAnimation` is an opt-in utility for animating the bounds of an existing native `B4XView`. It does not replace the layout protocol, rebuild widgets or introduce a second language:

```basic
Dim entrance As UIAnimation
entrance.Initialize _
    .TargetView(cardView) _
    .MoveAndResize(16dip, 80dip, Root.Width - 32dip, 160dip) _
    .Duration(280) _
    .OnCompleted(Me, "CardEntrance_Completed") _
    .Start

Sub CardEntrance_Completed
    ' The native bounds animation has finished.
End Sub
```

The animation starts from the view's current bounds unless a destination is omitted. Use `MoveTo` for position-only transitions, `SizeTo` for size-only transitions, or `MoveAndResize` for both. `Duration(0)` applies the destination immediately and still invokes the completion callback through the same asynchronous-safe path as longer animations. Calling `Start` again restarts the descriptor and invalidates the previous completion callback. `Cancel` invalidates the pending completion callback and requests synchronization of the native view at its current bounds; the exact visual interpolation point remains controlled by Android.

`UIAnimation` is intentionally limited to bounds. The framework keeps ownership of widget configuration and layout; application code can animate a native view after its declarative parent has assigned the current layout. Future animation features should remain additive and preserve this opt-in behavior.

## UIState

`UIState` is a small observable value holder for application state. It keeps state outside widgets and notifies only the callbacks subscribed to that value.

For a label, the widget can own the subscription declaratively:

```basic
Private CounterState As UIState
Private CounterLabel As UILabel

CounterState.Initialize(0)
CounterLabel.Initialize.BindText(CounterState).Size(48)

Sub Increment_Click
    Dim value As Int = CounterState.GetState
    CounterState.SetState(value + 1)
End Sub
```

`BindText` applies the current value immediately and renders the label when the state changes. Use `UnbindText` when the binding should be removed. `UIButton` and `UIFloatingActionButton` expose the same optional `BindText`/`UnbindText` pattern for reactive captions. Calling `Text(...)` afterwards replaces the binding and makes the caption static. App bar titles support the same optional pattern:

```basic
Private ScreenTitleState As UIState
Private AppBar As UIAppBar

ScreenTitleState.Initialize("Dashboard")
AppBar.Initialize.BindTitle(ScreenTitleState)

ScreenTitleState.SetState("Activity")
```

Use `UnbindTitle` to stop observing the title state. The existing callback API remains available for custom or composite updates:

```basic
CounterState.Subscribe(Me, "CounterState_Changed")

Sub CounterState_Changed(State As UIState)
    CounterLabel.Text("" & State.GetState)
    CounterLabel.Render
End Sub
```

`UIState.UnsubscribeTarget` removes every subscription owned by one widget or object. This is selective notification, not a full virtual-DOM diff engine: bindings update their target widget, while structural changes still require updating and rendering the tree. For state that changes several times in one synchronous operation, opt into Flutter-like coalescing with `State.CoalesceNotifications(True)`; listeners then receive one callback on the next UI cycle with the final value. Existing states remain synchronous by default.

### UIInput

`UIInput` wraps a native B4A `EditText` while keeping it inside the same declarative layout protocol:

```basic
Private NameState As UIState
Private NameInput As UIInput

NameState.Initialize("")
NameInput.Initialize _
    .Hint("Operator name") _
    .BindText(NameState) _
    .OnTextChanged(Me, "Name_Changed")

Sub Name_Changed(NewText As String)
    NameState.SetState(NewText)
End Sub
```

`BindText` is one-way: it applies state values to the input, but the input does not mutate the state automatically. The callback receives the user's new text so the host can validate, transform, or store it explicitly. `Text(...)` removes the state binding, and `GetText` returns the current text. Programmatic updates do not invoke `OnTextChanged`; the callback represents user edits only.

The input preserves its native `EditText` during normal renders, so a focused keyboard field is not recreated just because its parent recalculates bounds. `UIColumn`, `UIRow`, `UIPadding` and `UICenter` can use its natural 48dip height and measured width.

## Rounded buttons and inputs

Buttons and text inputs keep their native appearance by default. Rounded corners are opt-in and use the same fluent B4A composition style:

```basic
Dim saveButton As UIButton
saveButton.Initialize _
    .Text("SAVE") _
    .BackgroundColor(0xFF00A896) _
    .TextColor(Colors.White) _
    .CornerRadius(12dip) _
    .Border(1dip, 0xFF008577) _
    .OnClick(Me, "Save_Click")

Dim emailInput As UIInput
emailInput.Initialize _
    .Hint("Email address") _
    .BackgroundColor(0xFFF4F7FB) _
    .TextColor(0xFF132238) _
    .CornerRadius(10dip) _
    .Border(1dip, 0xFFD0D7E2)
```

`CornerRadius(0)` is the default and preserves the native background. `Border(width, color)` is optional; a width of `0` disables the custom border. When a custom input background is used, the library restores internal padding so text remains comfortably inset. A custom button background may not preserve the platform ripple exactly; use the default background when native button feedback is more important than custom shape.

## UITheme

`UITheme` centralizes palette decisions without coupling the framework widgets to one application. It provides Material 3-like light/dark defaults for colors, typography, shapes and common control metrics. Visual widgets read these semantic defaults through `ApplyTheme`; container widgets forward the same theme to their descendants:

```basic
Private AppTheme As UITheme

' Complete light defaults: colors, typography, shapes and control metrics.
AppTheme.Initialize

' Other initialization options:
' AppTheme.InitializeDark
' AppTheme.InitializeWithSchemeAndMode(0xFF6750A4, False)
' AppTheme.Initialize.Scheme(0xFF00A896)
Dim background As Int = AppTheme.Background
Dim cardSurface As Int = AppTheme.Surface
Dim primaryText As Int = AppTheme.PrimaryText
Dim buttonText As Int = AppTheme.AccentText
```

Switch palettes at runtime:

```basic
AppTheme.Toggle
Screen.ApplyTheme(AppTheme)
Navigator.ApplyTheme(AppTheme)
```

`ApplyTheme` updates only values that still use theme defaults. An explicit call such as `button.BackgroundColor(...)`, `label.Color(...)` or `card.BorderColor(...)` remains a deliberate per-widget override. `UICard`, `UIColumn`, `UIRow`, `UIStack`, `UIPadding`, `UIBox`, `UICenter`, `UIExpanded`, `UIScrollView` and `UIVisibility` forward the theme to nested children, so a root scaffold can theme a complete declarative tree.

Available palette groups include:

- `Background`
- `Surface`
- `SurfaceVariant`
- `PrimaryText`
- `SecondaryText`
- `MutedText`
- `DashboardBar`
- `SecondaryBar`
- `HeroSurface`
- `Accent`
- `Info`
- `Negative`
- `Divider`
- `Border`
- `ButtonText`
- `ThemeAction`
- `AccentText`
- `InfoText`
- `NegativeText`
- `ThemeActionText`

`Scheme(seedColor)` changes the seed while keeping the same semantic property names. `InitializeWithScheme(seedColor)` is the one-call light initialization form, while `InitializeDark` and `InitializeWithSchemeAndMode(seedColor, dark)` provide explicit dark initialization. Foreground properties such as `AccentText` and `ThemeActionText` choose a readable light or dark text color for their corresponding background.

Typography tokens include `DisplayLarge`, `HeadlineSmall`, `TitleLarge`, `BodyLarge`, `BodyMedium`, `BodySmall`, `LabelLarge`, `ButtonTextSize`, `InputTextSize` and `NavigationTextSize`. Shape tokens include `RadiusSmall`, `RadiusMedium`, `RadiusLarge`, `ButtonRadius`, `CardRadius`, `InputRadius`, `FabRadius` and `SnackbarRadius`. Layout tokens include app-bar, navigation, FAB, input and touch-target metrics.

A widget uses these defaults automatically. Explicit properties remain possible and override only that property:

```basic
Dim primary As UIButton
primary.Initialize.Text("Continue")

' Only these two properties stop following the theme:
primary.CornerRadius(6dip).TextSize(16)

' Other values still come from UITheme when ApplyTheme is called.
primary.ApplyTheme(AppTheme)
```

The demo applies the theme to the scaffold and navigator. The palette remains reusable because `UITheme` only provides values; it does not know about screens or controls. Widgets use semantic defaults until the host intentionally overrides one of them.

## Navigation and safe area

`UINavigator` provides virtual screens inside one real native B4A Activity:

```basic
Navigator.Initialize _
    .AddScreen("Dashboard", DashboardScreen) _
    .AddScreen("Activity", ActivityScreen) _
    .AddScreen("Settings", SettingsScreen)

Navigator.NavigateTo("Activity")
```

The host uses the available content rectangle calculated from Android `WindowInsets` through `JavaObject`. This keeps the declarative root below the Android status area, including the battery and clock region, without requiring every screen to calculate top insets independently.

This is intentionally a single-Activity navigation model. It avoids pretending that a virtual declarative screen is a physical B4A Activity or layout file. A route change detaches the previous screen so its declarative/native identity can be restored by `GoBack`; `Unmount` is reserved for terminal cleanup. Native Activity behavior can still be added later when a real Activity is genuinely required.

## Bottom navigation

`UIBottomNavigationBar` defines navigation items as data and can bind its selected index to `UIState`:

```basic
Private SelectedTabState As UIState
Private Navigation As UIBottomNavigationBar

SelectedTabState.Initialize(0)
Navigation.Initialize _
    .AddItem("home", "⌂", "Home") _
    .AddItem("activity", "◉", "Activity") _
    .AddItem("settings", "⚙", "Settings") _
    .BindSelectedIndex(SelectedTabState) _
    .OnSelected(Me, "Navigation_Selected")

Dim screen As UIScaffold
screen.Initialize.BottomNavigationBar(Navigation).Body(body)

Sub Navigation_Selected(Index As Int, Id As String)
    Select Case Id
        Case "home"
            Navigator.NavigateTo("Home")
        Case "activity"
            Navigator.NavigateTo("Activity")
        Case "settings"
            Navigator.NavigateTo("Settings")
    End Select
End Sub
```

`UIScaffold` reserves the bottom-navigation area before measuring the body. Selection changes update only the existing native labels and indicator; the bar does not rebuild its native children for ordinary tab changes. `ShowInactiveLabels(True)` displays every caption, while the default shows the active caption and keeps the inactive tabs compact. Use Unicode strings for icons so the component does not require an extra icon-font dependency.

## Minimal counter demonstration

The example contains one intentionally small screen:

- `UIState` drives the counter value;
- `UILabel.BindText` updates the displayed value;
- `UIAppBar` exposes the theme action through a direct FontAwesome glyph;
- `UIFloatingActionButton` increments state through a normal B4A callback;
- `UITheme` changes the palette without resetting the counter;
- `UIScaffold`, `UICenter` and the safe-area-aware root keep composition concise.

The remaining widgets are documented in `GUIDE.md` and can be explored without making the public counter example carry showcase-only navigation and business logic.

## Building

1. Open `Declarative UI.b4a` in the B4A IDE.
2. Confirm that all project modules are included, especially:
   - `UIScrollView`
   - `UITheme`
3. Compile the project with B4A.
4. Run it from the IDE on a device or emulator.

The project currently uses the following B4A libraries:

- `core`
- `XUI`
- `JavaObject`
- `OkHttpUtils2` (required by `UIImage.Network`)

## Suggested demonstration flow

For a forum presentation, use this sequence:

1. Run the example and observe the initial counter.
2. Tap `+` and show that `UIState` updates the bound label.
3. Tap the app-bar theme icon and show that the palette changes without resetting state.
4. Open `examples/example.b4a` and compare the small declarative tree with an equivalent manual `AddView` implementation.
5. Use `GUIDE.md` as the extended API tour for scroll views, snackbars, animations, themes, inputs and other widgets.

The most important comparison with imperative UI code is that the demo describes a reusable tree of widgets. Native views are still used underneath, but screen composition, measurement, and mounting are handled consistently by the declarative layer.

## Stable syntax contract

The public syntax and compatibility rules are maintained in [SYNTAX.md](SYNTAX.md). New releases should preserve the documented fluent API, callback conventions, state-binding precedence, layout values and lifecycle protocol. If a future change breaks one of those rules, it must include a migration note and a contract-version update.

## License and usage

This project is shared under the friendly public development/demo notice in [`LICENSE.txt`](LICENSE.txt). It is open for testing and feedback: use it freely in personal, client, employer, internal-business, commercial and monetized applications; inspect and modify the source while developing; and publish applications built with it as your own work.

The only community boundary is about source authorship: please do not copy the implementation into another library, framework, toolkit or standalone source project and publish it under your own name. This does not restrict applications, original code built around the API, tutorials, reviews, small credited snippets or local experiments. A future Pro version may have separate terms, but those terms do not retroactively restrict this demo. The copyright holder and contact are listed in `LICENSE.txt`.

## Design principles

- Prefer a small, explicit API over a complete Flutter clone.
- Keep widgets independent from application-specific state and colors.
- Reuse native B4A controls where they are appropriate.
- Measure content before assigning layout bounds.
- Keep virtual navigation separate from native Activity lifecycle.
- Treat safe-area handling as a root-layout concern.
- Keep runtime diagnostics out of production code.
- Add complexity only when a concrete UI problem requires it.
