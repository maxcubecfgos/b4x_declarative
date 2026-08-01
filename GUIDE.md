# Declarative UI for B4A — User Guide

This guide explains how to use the declarative UI classes included in this project and in the preliminary `.b4xlib` package.

> **Stable syntax contract:** Read [SYNTAX.md](SYNTAX.md) before publishing or extending the library. It defines the rules that future releases must preserve.

> **Current status:** this release is B4A-only. It uses native B4A `Panel`, `ScrollView`, `IME`, `Colors` and `B4XView` APIs. It is not yet a cross-platform B4X library for B4i or B4J.

## 1. What this library provides

Declarative UI for B4A is a small code-first layer for composing native Android interfaces as trees of reusable objects.

Instead of manually creating and positioning every native view in the Activity, you compose widgets and containers:

```basic
Dim content As UIColumn
content.Initialize _
    .Spacing(12dip) _
    .AddChild(title) _
    .AddChild(description) _
    .AddChild(actions)
```

The framework then measures children, assigns layout bounds, creates native views and renders the tree.

It is inspired by declarative UI systems such as Flutter, but it is intentionally smaller. It does not attempt to reproduce Flutter's complete widget catalog, renderer or state system.

## 2. Installation

### Using the preliminary `.b4xlib`

1. Copy `DeclarativeUI.b4xlib` to the B4A Additional Libraries folder.
2. Refresh the Libraries Manager in the B4A IDE.
3. Enable the library in the host project.
4. Enable the required B4A libraries:
   - `XUI`
   - `IME`
5. Create or open a B4A Activity project and use the classes from the package.

The package contains only the reusable `.bas` UI classes and `manifest.txt`. Project documentation such as `README.md`, `GUIDE.md` and `SYNTAX.md` remains in the source repository and is not copied into the `.b4xlib`. The package intentionally excludes the NOVA demo Activity and `Starter.bas`.

### Using the source modules

Alternatively, copy the required `.bas` modules into the B4A project. This is useful while developing or debugging the framework.

The host project must include the modules used by its UI tree. For example, a screen using `UIColumn`, `UILabel` and `UIButton` needs those three classes and their dependencies.

## 3. Minimal working example

The following example mounts one declarative label directly into a B4A Activity. It does not require `UINavigator` or `UIScaffold`.

```basic
Sub Activity_Create(FirstTime As Boolean)
    Dim root As B4XView = Activity
    root.Color = 0xFFF4F7FB

    Dim title As UILabel
    title.Initialize _
        .Text("Hello declarative UI") _
        .Size(24) _
        .Color(0xFF132238)

    title.SetParent(root)
    title.SetPosition(24dip, 40dip)
    title.SetSize(root.Width - 48dip, 48dip)
    title.Render
End Sub
```

For a real application, a layout container such as `UIColumn` or `UIPadding` is usually preferable to positioning every root child manually.

## 4. Composing a screen

Widgets are configured first and mounted by a root container:

```basic
Sub Activity_Create(FirstTime As Boolean)
    Dim root As B4XView = Activity

    Dim title As UILabel
    title.Initialize.Text("Control center").Size(26).Color(0xFF132238)

    Dim subtitle As UILabel
    subtitle.Initialize.Text("Everything is operating normally.").Size(14).Color(0xFF6B7B91)

    Dim body As UIColumn
    body.Initialize _
        .Spacing(10dip) _
        .AddChild(title) _
        .AddChild(subtitle)

    Dim padding As UIPadding
    padding.Initialize.All(16dip).Child(body)

    padding.SetParent(root)
    padding.SetPosition(0, 0)
    padding.SetSize(root.Width, root.Height)
    padding.Render
End Sub
```

The important idea is that `body` describes the child tree. The parent is responsible for passing layout information to each child during `Render`.

## 5. Public widget reference

### Text and content widgets

| Widget | Main purpose | Main configuration methods |
| --- | --- | --- |
| `UILabel` | Native label | `Text`, `BindText`, `UnbindText`, `Size`, `Color` |
| `UIButton` | Native clickable button | `Text`, `BindText`, `UnbindText`, `BackgroundColor`, `TextColor`, `CornerRadius`, `Border`, `OnClick` |
| `UIFloatingActionButton` | Compact circular-style native button | `Text`, `BindText`, `UnbindText`, `BackgroundColor`, `OnClick` |
| `UIInput` | Native text input | `Hint`, `Text`, `BindText`, `UnbindText`, `OnTextChanged`, `TextColor`, `BackgroundColor`, `CornerRadius`, `Border`, `GetText` |
| `UIState` | Observable value holder with selective callbacks | `Initialize`, `GetState`, `SetState`, `Subscribe`, `Unsubscribe`, `UnsubscribeTarget`, `ClearListeners` |
| `UIAsyncState` | Observable idle/loading/success/error operation state | `Initialize`, `SetIdle`, `SetLoading`, `SetSuccess`, `SetError`, `Reset`, `GetStatus`, `GetValue`, `GetErrorMessage`, `Subscribe` |
| `UISnackBar` | Transient overlay notification with optional action | `Initialize`, `Message`, `Action`, `Duration`, `AnimationDuration`, `BackgroundColor`, `TextColor`, `ActionColor`, `CornerRadius`, `Margin`, `Show`, `Dismiss` |
| `UIAnimation` | Native bounds animation utility | `TargetView`, `MoveTo`, `SizeTo`, `MoveAndResize`, `Duration`, `OnCompleted`, `Start`, `Cancel` |
| `UIAppBar` | Top application bar | `Title`, `BindTitle`, `UnbindTitle`, `BackgroundColor` |
| `UIDivider` | Horizontal divider | `Color` |
| `UISpace` | Fixed-size spacer | `Size` |

### Container widgets

| Widget | Main purpose | Main configuration methods |
| --- | --- | --- |
| `UIColumn` | Vertical layout | `Spacing`, `MainAxisSize`, `MainAxisAlignment`, `CrossAxisAlignment`, `AddChild` |
| `UIRow` | Horizontal layout | `Spacing`, `MainAxisSize`, `MainAxisAlignment`, `CrossAxisAlignment`, `AddChild` |
| `UIPadding` | Adds configurable padding around one child | `All`, `Horizontal`, `Vertical`, `Only`, `Child` |
| `UIBox` | Padded child container | `Initialize(child, padding)` |
| `UICenter` | Centers one child using natural size | `Child` |
| `UICard` | Rounded surface with border | `BackgroundColor`, `BorderColor`, `CornerRadius`, `Child` |
| `UIExpanded` | Flexible child marker | `Child` |
| `UIVisibility` | Conditionally includes one child in layout | `Visible`, `BindVisible`, `UnbindVisible`, `OnVisibilityChanged`, `Child` |
| `UIStack` | Overlapping children on the Z axis | `AddChild`, `Alignment` |
| `UIScrollView` | Native vertical scroll container | `Child`, `ScrollTo` |
| `UIScaffold` | App bar, body, bottom navigation and optional FABs | `AppBar`, `Body`, `BottomNavigationBar`, `FloatingActionButtonLeft`, `FloatingActionButtonRight` |
| `UIBottomNavigationBar` | Declarative bottom navigation | `AddItem`, `BindSelectedIndex`, `OnSelected`, `ActiveColor`, `InactiveColor`, `IndicatorColor` |
| `UINavigator` | Virtual screens and safe-area host | `AddScreen`, `NavigateTo` |

All widget classes expose the internal layout lifecycle methods described in [Lifecycle and rendering](#9-lifecycle-and-rendering). Application code normally configures the tree and calls `Render` only on its root.

## 6. Rounded controls

`UIButton` and `UIInput` preserve the native Android background unless a custom shape is requested. Use `CornerRadius` for rounded corners and `Border` for an optional outline:

```basic
Dim button As UIButton
button.Initialize _
    .Text("CONTINUE") _
    .BackgroundColor(0xFF6750A4) _
    .TextColor(Colors.White) _
    .CornerRadius(12dip) _
    .Border(1dip, 0xFF4F378B)

Dim input As UIInput
input.Initialize _
    .Hint("Operator name") _
    .CornerRadius(10dip) _
    .Border(1dip, 0xFFD0D7E2)
```

Both methods return the same widget for fluent chaining. `CornerRadius(0)` and `Border(0, color)` leave the control in its default unshaped mode. A custom `UIInput` background receives library-managed internal padding so its text does not touch the border.

## 7. Layout and natural measurement

The layout engine uses a small measurement protocol:

```text
GetContentSize(maxWidth, maxHeight) -> List(width, height)
```

A widget returning two values has a natural size. An empty `List` means that the widget is flexible and wants the space assigned by its parent.

`UIColumn` and `UIRow` measure children before positioning them. This is why labels and cards can use their natural heights instead of relying entirely on hard-coded coordinates.

### UIColumn

```basic
Dim column As UIColumn
column.Initialize _
    .Spacing(8dip) _
    .AddChild(firstLabel) _
    .AddChild(secondLabel) _
    .AddChild(actionButton)
```

`UIColumn` places children vertically and adds the configured spacing between them. Use `MainAxisSize` to choose whether it keeps its natural height or fills the height assigned by its parent:

```basic
Dim compactColumn As UIColumn
compactColumn.Initialize _
    .MainAxisSize("min") _
    .Spacing(8dip) _
    .AddChild(title) _
    .AddChild(subtitle)
```

`MainAxisSize("min")` uses the measured child height plus spacing. An empty column with `MainAxisSize("min")` has zero height. `MainAxisSize("max")` is the default and uses the height assigned by the parent, which is useful for screen roots and columns containing `UIExpanded`. In nested composition, the parent still decides the constraints; `GetContentSize` reports the natural size so the parent can choose how much space to assign. Invalid values fall back to `max`.

Use `MainAxisAlignment` to distribute free space when the children have natural sizes:

```basic
Dim column As UIColumn
column.Initialize _
    .MainAxisSize("max") _
    .MainAxisAlignment("center") _
    .AddChild(title) _
    .AddChild(subtitle)
```

Supported `MainAxisAlignment` values are `start`, `center`, `end`, `spaceBetween`, `spaceAround` and `spaceEvenly`. The default is `start`. If the column contains `UIExpanded`, the flexible-child allocation takes precedence.

### UIRow

```basic
Dim row As UIRow
row.Initialize _
    .Spacing(8dip) _
    .AddChild(leftButton) _
    .AddChild(rightButton)
```

`UIRow` lays out children horizontally and distributes flexible children across the available width. Use `MainAxisSize("min")` when the row should wrap its natural child width instead of occupying all assigned width:

```basic
Dim compactRow As UIRow
compactRow.Initialize _
    .MainAxisSize("min") _
    .Spacing(8dip) _
    .AddChild(firstButton) _
    .AddChild(secondButton)
```

`MainAxisSize("max")` is the default and uses the width assigned by the parent, preserving the original layout behavior. An empty row with `MainAxisSize("min")` has zero width. A row containing `UIExpanded` keeps the assigned width so flexible children can receive the remaining space. In nested composition, `GetContentSize` still reports natural width and the parent decides the final constraint. For naturally sized children, `MainAxisAlignment` supports the same values as `UIColumn`:

```basic
Dim row As UIRow
row.Initialize _
    .MainAxisSize("max") _
    .MainAxisAlignment("spaceEvenly") _
    .AddChild(firstButton) _
    .AddChild(secondButton)
```

The default alignment is `start`. `MainAxisSize` and `MainAxisAlignment` are case-insensitive; invalid size values fall back to `max`.

Both containers also expose `CrossAxisAlignment`. A column aligns children horizontally and a row aligns children vertically:

```basic
Dim column As UIColumn
column.Initialize _
    .CrossAxisAlignment("center") _
    .AddChild(title) _
    .AddChild(subtitle)

Dim row As UIRow
row.Initialize _
    .CrossAxisAlignment("end") _
    .AddChild(firstButton) _
    .AddChild(secondButton)
```

Supported values are `stretch`, `start`, `center` and `end`, and matching is case-insensitive. `stretch` is the default and preserves the previous behavior. Cross-axis alignment affects naturally measured children; flexible children continue to consume their assigned space.

### UIExpanded

Use `UIExpanded` when a child must consume remaining space, especially inside a column that has a fixed header or footer:

```basic
Dim scroll As UIScrollView
scroll.Initialize.Child(eventList)

Dim flexibleScroll As UIExpanded
flexibleScroll.Initialize.Child(scroll)

Dim body As UIColumn
body.Initialize _
    .Spacing(10dip) _
    .AddChild(header) _
    .AddChild(flexibleScroll) _
    .AddChild(footer)
```

Without `UIExpanded`, a flexible child may not receive the remaining height expected by the parent.

### UIVisibility

Use `UIVisibility` when a child should be part of the declarative tree only while a condition is true:

```basic
Dim detailsVisibility As UIVisibility
detailsVisibility.Initialize _
    .Visible(True) _
    .Child(detailsCard)

detailsVisibility.Visible(False)
dashBoardBody.Render

detailsVisibility.Visible(True)
dashBoardBody.Render
```

For a reactive Boolean state, use `BindVisible` and an explicit callback:

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

`Visible(True)` is the default. `BindVisible` reads the current Boolean state and observes later replacements. Calling `Visible(...)` or `UnbindVisible` removes the binding. `OnVisibilityChanged` receives the changed wrapper and lets the host choose whether to render a `UIColumn`, `UIRow`, `UIScrollView` or another affected parent. When hidden, `UIVisibility` reports a natural size of `0, 0`, removes the child's native views and lets containers reflow the remaining children without a gap. The wrapper preserves the declarative child, so it can be mounted again when visibility returns.

The compact examples project uses this pattern to hide and show the gallery details card without rebuilding or navigating the entire screen.

### UIStack

`UIStack` places children on top of one another. It is useful for badges, overlays, layered cards and backgrounds:

```basic
Dim layered As UIStack
layered.Initialize _
    .Alignment("bottomRight") _
    .AddChild(backgroundCard) _
    .AddChild(statusBadge)
```

Supported alignment values are `topLeft`, `topCenter`, `topRight`, `centerLeft`, `center`, `centerRight`, `bottomLeft`, `bottomCenter` and `bottomRight`. Matching is case-insensitive; invalid values fall back to `topLeft`.

The stack measures to the largest participating natural child. A flexible child (one returning an empty `GetContentSize` list) receives the complete stack bounds. Children are rendered in insertion order, so the last child added is visually above earlier children. Hidden `UIVisibility` children do not participate in measurement or rendering.

`UIStack` preserves the declarative child order while rendering and remounting its children. Structural changes still require rendering the affected parent; `Render` does not remount every child, so stateful native controls such as `UIScrollView` can preserve their current state.

### UICenter

```basic
Dim centered As UICenter
centered.Initialize.Child(title)
```

`UICenter` asks its child for a natural size and positions it in the center of its assigned bounds.

### UIPadding and UICard

`UIPadding` follows the same mental model as Flutter's `EdgeInsets` while remaining a normal fluent B4A widget:

```basic
padding.Initialize.All(16dip)
padding.Horizontal(20dip)
padding.Vertical(12dip)
padding.Only(20dip, 12dip, 20dip, 16dip)
```

`All` sets every side, `Horizontal` sets left and right, `Vertical` sets top and bottom, and `Only` sets left, top, right and bottom independently. Each method returns the same `UIPadding` instance, so calls can be chained. Later calls override the sides they address.

```basic
Dim cardBody As UIColumn
cardBody.Initialize.Spacing(6dip).AddChild(title).AddChild(subtitle)

Dim cardPadding As UIPadding
cardPadding.Initialize.Horizontal(16dip).Vertical(12dip).Child(cardBody)

' Use Only when each side needs a different inset.
Dim asymmetricPadding As UIPadding
asymmetricPadding.Initialize.Only(20dip, 12dip, 20dip, 16dip).Child(cardBody)

Dim card As UICard
card.Initialize _
    .BackgroundColor(0xFFFFFFFF) _
    .BorderColor(0xFFE0E0E0) _
    .CornerRadius(16dip) _
    .Child(cardPadding)
```

## 8. UIScrollView

`UIScrollView` wraps the native B4A `ScrollView` and accepts one declarative child, usually a `UIColumn` containing the complete scrollable content.

```basic
Dim events As UIColumn
events.Initialize _
    .Spacing(8dip) _
    .AddChild(eventCardOne) _
    .AddChild(eventCardTwo) _
    .AddChild(eventCardThree)

Dim scroll As UIScrollView
scroll.Initialize.Child(events)
```

When the scroll view shares a column with fixed content, place it inside `UIExpanded`:

```basic
Dim flexibleScroll As UIExpanded
flexibleScroll.Initialize.Child(scroll)

' screenTitle and refreshButton are UILabel/UIButton instances
' initialized before this composition.
Dim body As UIColumn
body.Initialize _
    .Spacing(10dip) _
    .AddChild(screenTitle) _
    .AddChild(flexibleScroll) _
    .AddChild(refreshButton)
```

Available scroll methods:

```basic
scroll.ScrollTo(200dip)
Dim position As Int = scroll.GetScrollPosition
```

The child content is measured and mounted into the native `ScrollView.Panel`. Re-rendering the same child updates its existing tree and preserves scroll position/native state; replacing the child performs structural cleanup. Do not pass the native panel directly to custom code expecting a `B4XView`; the library handles that conversion internally.

## 9. Lifecycle and rendering

Every layout-aware widget follows this lifecycle:

1. `Initialize` creates the declarative object.
2. Fluent methods configure its properties and children.
3. The parent assigns `SetParent`, `SetPosition` and `SetSize`.
4. `Render` creates or updates the native B4A view.
5. `Unmount` releases native references before a remount.

The following methods are part of the internal composition contract:

```basic
SetParent(parent As B4XView)
SetPosition(left As Int, top As Int)
SetSize(width As Int, height As Int)
Render
Unmount
GetContentSize(maxWidth As Int, maxHeight As Int) As List
```

For ordinary application code, configure the root tree and call these methods on the root only:

```basic
rootWidget.SetParent(Activity)
rootWidget.SetPosition(0, 0)
rootWidget.SetSize(Activity.Width, Activity.Height)
rootWidget.Render
```

When a property changes after mounting, call `Render` on the affected widget or rebuild the root tree when the structure itself changes. The current project uses targeted label renders for simple state changes and a controlled remount for navigation and theme changes.

## 10. Events and callbacks

`UIButton` and `UIFloatingActionButton` use a target object and a callback name:

```basic
Dim saveButton As UIButton
saveButton.Initialize _
    .Text("SAVE") _
    .BackgroundColor(0xFF00A896) _
    .TextColor(Colors.White) _
    .OnClick(Me, "Save_Click")
```

The receiving module must contain the callback:

```basic
Sub Save_Click
    ' Update application state or navigate to another screen.
End Sub
```

Use normal B4A event-style names such as `Save_Click`, `Increment_Click` or `NavigateToSettings_Click`. The callback name must match exactly and must be a parameterless sub. Before dispatching, `UIButton` and `UIFloatingActionButton` verify that the target exposes the callback; an empty or invalid callback is ignored safely instead of causing a reflection error.

`UIButton.TriggerClick` is also available when an application needs to dispatch the configured action programmatically. It uses the same safe callback validation.

## 11. UISnackBar

`UISnackBar` is a transient overlay for short feedback messages. It attaches directly to a `B4XView` root, so it stays above the current declarative screen without becoming a permanent layout child.

```basic
Private Snack As UISnackBar

Snack.Initialize _
    .Message("Settings saved") _
    .Action("UNDO", Me, "UndoSettings_Click") _
    .Duration(3000) _
    .Show(Activity)

Sub UndoSettings_Click
    ' Restore the previous settings.
End Sub
```

`Show` replaces the snackbar's current run safely and starts an enter animation. The default duration is 3000 milliseconds; `Duration(0)` keeps it visible until `Dismiss` is called. `Dismiss` animates it out and removes its native view. `AnimationDuration(0)` disables the enter and exit animation. The action callback is a normal parameterless B4A sub and is checked with `xui.SubExists` before dispatch.

The snackbar uses a generation token for delayed work. Calling `Show`, `Dismiss` or `Unmount` invalidates previous delayed callbacks, which prevents an old `Sleep` from removing a newer snackbar. Call `Unmount` when the root is being discarded.

`UISnackBar` is an overlay API rather than a replacement for `UIColumn`, `UIRow` or `UIScaffold`; use the Activity/content root or another non-clipping host view when the notification must appear above the complete screen.

## 12. UIAnimation

`UIAnimation` adds a small, explicit animation layer without changing the composition syntax. It animates the bounds of an already-mounted `B4XView` using the native B4A layout animation:

```basic
Dim animation As UIAnimation
animation.Initialize _
    .TargetView(cardView) _
    .MoveTo(16dip, 96dip) _
    .Duration(240) _
    .OnCompleted(Me, "CardMoved_Completed") _
    .Start

Sub CardMoved_Completed
    ' Optional completion work.
End Sub
```

Use `SizeTo(width, height)` for size-only changes and `MoveAndResize(...)` for both position and size. The current view bounds are used as the starting point, so the host does not need to duplicate the current layout values. `Duration` is expressed in milliseconds and clamps negative values to zero.

`Start` is restartable. Starting a descriptor again invalidates the completion callback from the previous run. `Cancel` stops the native transition at its current position and suppresses the completion callback. Completion callbacks are parameterless normal B4A subs and are ignored safely when the target or callback name is invalid.

Keep animations opt-in and local. The declarative tree still owns layout; after a parent re-render, the next animation should target the resulting native view. `UIAnimation` currently animates bounds only and does not promise automatic interpolation of colors, text, opacity or arbitrary widget properties.

## 13. State and UI updates

`UIState` is an observable value holder for application state. It keeps the value outside widgets and notifies only the callbacks subscribed to that state instance.

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

`BindText` applies the current state value immediately and renders the widget whenever that state changes. The binding remains attached while the widget is temporarily unmounted for navigation or remounting. `UILabel`, `UIButton` and `UIFloatingActionButton` use the same optional `BindText`/`UnbindText` pattern. Calling `Text(...)` after `BindText(...)` replaces the binding and makes the text static. Call `UnbindText` when the widget should stop observing the state.

App bar titles can also bind directly to a state value:

```basic
Private ScreenTitleState As UIState
Private AppBar As UIAppBar

ScreenTitleState.Initialize("Dashboard")
AppBar.Initialize.BindTitle(ScreenTitleState)
ScreenTitleState.SetState("Activity")
```

Call `UnbindTitle` when the title should stop observing the state. Calling `Title(...)` afterwards also replaces the binding and makes the title static. The original callback API remains available for custom or composite updates:

```basic
CounterState.Subscribe(Me, "CounterState_Changed")

Sub CounterState_Changed(State As UIState)
    CounterLabel.Text("" & State.GetState)
    CounterLabel.Render
End Sub

CounterState.Unsubscribe(Me, "CounterState_Changed")
```

`UIState.UnsubscribeTarget` removes every subscription owned by one widget or object. This milestone provides targeted observable updates, not a complete Flutter-style virtual-DOM diff engine: bound widgets update themselves, while structural changes still require updating and rendering the tree. State values are replacement values; mutating an existing `Map` or `List` does not automatically notify listeners.

### UIInput

`UIInput` provides a native B4A `EditText` that participates in the same measure, layout and render protocol as the other widgets:

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

The binding is intentionally one-way. `BindText` applies state values to the native field; `OnTextChanged` reports user edits through the normal B4A callback convention, and the host decides whether to call `SetState`. This avoids hidden two-way updates and makes validation or transformation explicit.

`Text(...)` removes the state binding. `GetText` returns the current text. Programmatic changes do not invoke `OnTextChanged`; the callback represents user edits. The native field is preserved during ordinary `Render` calls so focus and keyboard state are not discarded. The component reports a natural 48dip height and measures its width from the current text or hint.

`SetState` is a replacement operation. It compares the assigned value using B4A's normal equality semantics, which is appropriate for simple values such as numbers and strings. It does not observe mutations made inside an existing `Map` or `List`; assign a new value when you want to notify listeners. A callback may perform one follow-up state change, but callbacks should not continuously mutate the same state or create an update cycle.

The NOVA example demonstrates this with:

- `CounterState` and the two floating action buttons;
- `ActivityRefreshState` and `REFRESH STREAM`;
- `UITheme` for palette state.

Keep state explicit and keep rendering predictable.

## 14. UIAsyncState

`UIAsyncState` represents the lifecycle of an asynchronous operation without executing the operation itself. It is intentionally independent of `HttpJob`, `OkHttpUtils2`, databases and file APIs. The application still uses normal B4A resumable subs and `Wait For`; the state object exposes the result declaratively to the UI.

The four stable statuses are `idle`, `loading`, `success` and `error`:

```basic
Private UsersState As UIAsyncState

UsersState.Initialize
UsersState.SetLoading
UsersState.SetSuccess("response payload")
UsersState.SetError("Network unavailable")
```

Read the current snapshot with `GetStatus`, `GetValue` and `GetErrorMessage`, or use the convenience predicates `IsIdle`, `IsLoading`, `IsSuccess` and `IsError`. Subscribe with the normal B4A callback convention:

```basic
UsersState.Subscribe(Me, "UsersState_Changed")

Sub UsersState_Changed(State As UIAsyncState)
    If State.IsLoading Then
        ' Show a loading indicator.
    Else If State.IsSuccess Then
        ' Read State.GetValue and show the content.
    Else If State.IsError Then
        ' Read State.GetErrorMessage and show retry UI.
    End If
End Sub
```

A request remains ordinary B4A code. `Wait For` suspends the resumable sub without blocking the UI thread:

```basic
Sub LoadUsers
    UsersState.SetLoading

    Dim job As HttpJob
    job.Initialize("", Me)
    job.Download("https://example.com/api/users")

    Wait For (job) JobDone(job As HttpJob)

    If job.Success Then
        UsersState.SetSuccess(job.GetString)
    Else
        UsersState.SetError(job.ErrorMessage)
    End If
    job.Release
End Sub
```

This separation is deliberate: `UIAsyncState` is reusable for HTTP, database, file and authentication operations, while `HttpJob` and `Wait For` remain visible and testable in the application layer. `Reset` is an alias for `SetIdle`; repeated identical snapshots do not notify listeners. Call `Unsubscribe`, `UnsubscribeTarget` or `ClearListeners` when the owner no longer needs updates.

## 15. UITheme

`UITheme` is a reusable palette provider. It does not know which widgets your application owns, but every visual widget exposes `ApplyTheme` and declarative containers forward the theme to their descendants.

```basic
Private AppTheme As UITheme

' Scheme is a seed color from which the semantic palette is derived.
AppTheme.Initialize.Scheme(0xFF00A896)
Dim surface As Int = AppTheme.Surface
Dim primaryText As Int = AppTheme.PrimaryText
Dim accentText As Int = AppTheme.AccentText
```

Switch the palette and apply it to the declarative roots:

```basic
AppTheme.Toggle
ActiveScreen.ApplyTheme(AppTheme)
Navigator.ApplyTheme(AppTheme)
```

Theme defaults are used until the programmer explicitly overrides a property. For example, `button.BackgroundColor(...)`, `label.Color(...)`, and `card.BorderColor(...)` opt out of that property only; other properties continue to follow the theme. `UICard` also themes its nested content. Containers such as `UIColumn`, `UIStack`, `UIPadding` and `UIScrollView` propagate `ApplyTheme` to their children.

Choose a different brand seed without changing the rest of the application:

```basic
AppTheme.Scheme(0xFF6750A4)
```

`Scheme` accepts a normal B4A ARGB `Int`. The same theme object derives `Background`, `Surface`, `SurfaceVariant`, app bars, `Accent`, borders and dividers from that seed. Use `InitializeWithScheme` when you prefer a single initialization call:

```basic
Dim AppTheme As UITheme
AppTheme.InitializeWithScheme(0xFF6750A4)
```

You can select a mode explicitly:

```basic
AppTheme.DarkMode(True)
```

Query the current mode:

```basic
If AppTheme.IsDark Then
    ' Dark palette is active.
End If
```

Available palette properties:

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

The `*Text` properties are contrast-aware foregrounds for their matching semantic action colors. Prefer them over hard-coded `Colors.White` when a button background comes from the theme.

A root-level theme application routine typically looks like this:

```basic
Sub ApplyTheme
    Root.Color = AppTheme.Background
    ActiveScreen.ApplyTheme(AppTheme)
    Navigator.ApplyTheme(AppTheme)
End Sub
```

This keeps palette policy in `UITheme` instead of repeating color literals in every widget builder.

## 16. UINavigator and safe area

`UINavigator` manages virtual screens inside one real B4A Activity:

```basic
Navigator.Initialize _
    .AddScreen("Home", homeScreen) _
    .AddScreen("Settings", settingsScreen)

Dim root As B4XView = Activity
Navigator.SetParent(root)
Navigator.SetPosition(0, 0)
Navigator.SetSize(root.Width, root.Height)
Navigator.Render
```

Navigate between registered screens:

```basic
Navigator.NavigateTo("Settings")
```

The navigator uses the B4A `IME.GetContentRect` information to place the root below the Android status area. This keeps content away from the clock, battery and notification area without requiring every screen to calculate the top inset.

Screens registered with `UINavigator` are virtual widget trees. They are not physical B4A Activities and do not require separate `.bal` layouts.

### UIBottomNavigationBar

Use `UIBottomNavigationBar` when several virtual screens share a persistent navigation surface. Items are data, selection is explicit, and the callback uses a normal B4A signature:

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

Attach it to the scaffold rather than placing it inside the body:

```basic
Dim screen As UIScaffold
screen.Initialize _
    .AppBar(appBar) _
    .Body(body) _
    .BottomNavigationBar(Navigation)
```

The scaffold reserves `64dip` for the bar, so the body and FABs do not overlap it. `AddItem(Id, Icon, Text)` uses a Unicode string for the icon and keeps the component independent from icon-font dependencies. `ShowInactiveLabels(True)` displays all captions; by default only the selected caption is visible. Ordinary selection changes update existing native children and preserve the bar's declarative configuration.

### UIScaffold

A scaffold combines an app bar, body and optional floating action buttons:

```basic
Dim screen As UIScaffold
screen.Initialize _
    .AppBar(appBar) _
    .Body(body) _
    .FloatingActionButtonRight(actionButton)
```

The scaffold reserves space for its app bar and FAB area before rendering the body.

## 17. Common problems

### A text input does not update my state

`UIInput` does not mutate `UIState` automatically. Verify that the callback has the exact one-argument signature and explicitly updates the state:

```basic
Sub Name_Changed(NewText As String)
    NameState.SetState(NewText)
End Sub
```

If the field should remain independent from application state, omit `BindText` and read its value with `GetText` when needed.

### A button appears but does nothing

Check that:

1. `OnClick` receives the correct target object.
2. The callback name matches exactly.
3. The callback exists in the target module.
4. The widget is not covered by another native view.
5. The root tree was rendered after the button was configured.

### Content is clipped or labels are cut off

Prefer natural measurement through `UIColumn`, `UIRow`, `UIPadding`, `UICard` and `UIVisibility`. Avoid assigning arbitrary fixed heights to text widgets. Use `UIExpanded` for content that should consume remaining space.

### A scroll view does not scroll

Make sure:

- the scroll view has a child, normally a `UIColumn`;
- the child content is taller than the viewport;
- the scroll view is inside `UIExpanded` when it shares a column with headers or footers;
- the root has a valid, positive size before `Render` is called.

### A screen overlaps the status bar

Mount the root through `UINavigator`, or ensure the root uses the available content area. Do not make every screen independently guess the status-bar inset.

### A virtual screen does not navigate

Register it before calling `NavigateTo`:

```basic
Navigator.AddScreen("Settings", settingsScreen)
Navigator.NavigateTo("Settings")
```

A virtual screen name must match the registered name exactly.

### The theme changes internally but the UI stays the same

`UITheme` only changes the values returned by its color properties. The host must assign those values to the widgets and call `Render` where needed.

## 18. NOVA Control Center example

The included demo is organized into three virtual screens:

- **Dashboard:** live counter, metrics, cards, navigation buttons and two FABs.
- **Activity:** measured event cards inside a native scroll view and a refresh counter.
- **Settings:** runtime light/dark palette switching.

Suggested demonstration flow:

1. Tap `+` and `-` on Dashboard.
2. Open `VIEW ACTIVITY`.
3. Scroll through the event stream.
4. Tap `REFRESH STREAM`.
5. Return to Dashboard.
6. Open Settings and toggle the theme.
7. Navigate again to verify that state and mounting remain stable.

## 19. Stable syntax and compatibility

The library's public syntax is defined in [SYNTAX.md](SYNTAX.md). Treat that file as the contract for examples, forum releases and future contributions.

The most important compatibility rules are:

- keep normal B4A declarations and optional fluent chaining as the only composition syntax;
- preserve documented public method names, return types and callback signatures;
- preserve `BindText`/`BindTitle` precedence: calling `Text(...)` or `Title(...)` removes the corresponding binding;
- preserve the lifecycle protocol: `SetParent`, `SetPosition`, `SetSize`, `Render`, `Unmount` and `GetContentSize`;
- add features additively whenever possible;
- document any breaking change with a migration note and a contract-version update.

If an implementation idea cannot be explained by these rules, it should not be added to the public API yet.

## 20. Design boundaries and roadmap

The project intentionally keeps its first release small:

- B4A-only native rendering;
- virtual navigation inside one Activity;
- explicit application state through `UIState` or host variables;
- selective observable callbacks, not automatic tree diffing;
- a small widget set;
- natural measurement instead of a complete constraint solver;
- no automatic bidirectional data binding;
- no complete virtual-DOM diff engine;
- no promise that every Flutter layout behavior is supported.

Potential future work includes more robust incremental updates, additional widgets, animation support, better scroll abstractions and a cross-platform implementation. These should be added only when they solve a concrete problem for B4A users and can preserve the syntax contract.
