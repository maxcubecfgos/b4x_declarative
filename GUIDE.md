# Declarative UI for B4A — User Guide

This guide explains how to use the declarative UI classes included in this project and in the preliminary `.b4xlib` package.

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

1. Copy `DeclarativeUI-0.1.b4xlib` to the B4A Additional Libraries folder.
2. Refresh the Libraries Manager in the B4A IDE.
3. Enable the library in the host project.
4. Enable the required B4A libraries:
   - `XUI`
   - `IME`
5. Create or open a B4A Activity project and use the classes from the package.

The package contains reusable UI classes only. It intentionally excludes the NOVA demo Activity and `Starter.bas`.

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
| `UILabel` | Native label | `Text`, `Size`, `Color` |
| `UIButton` | Native clickable button | `Text`, `BackgroundColor`, `TextColor`, `OnClick` |
| `UIFloatingActionButton` | Compact circular-style native button | `Text`, `BackgroundColor`, `OnClick` |
| `UIState` | Observable value holder with selective callbacks | `Initialize`, `GetState`, `SetState`, `Subscribe`, `Unsubscribe`, `ClearListeners` |
| `UIAppBar` | Top application bar | `Title`, `BackgroundColor` |
| `UIDivider` | Horizontal divider | `Color` |
| `UISpace` | Fixed-size spacer | `Size` |

### Container widgets

| Widget | Main purpose | Main configuration methods |
| --- | --- | --- |
| `UIColumn` | Vertical layout | `Spacing`, `MainAxisAlignment`, `CrossAxisAlignment`, `AddChild` |
| `UIRow` | Horizontal layout | `Spacing`, `MainAxisAlignment`, `CrossAxisAlignment`, `AddChild` |
| `UIPadding` | Adds configurable padding around one child | `All`, `Horizontal`, `Vertical`, `Only`, `Child` |
| `UIBox` | Padded child container | `Initialize(child, padding)` |
| `UICenter` | Centers one child using natural size | `Child` |
| `UICard` | Rounded surface with border | `BackgroundColor`, `BorderColor`, `CornerRadius`, `Child` |
| `UIExpanded` | Flexible child marker | `Child` |
| `UIScrollView` | Native vertical scroll container | `Child`, `ScrollTo` |
| `UIScaffold` | App bar, body and optional FABs | `AppBar`, `Body`, `FloatingActionButtonLeft`, `FloatingActionButtonRight` |
| `UINavigator` | Virtual screens and safe-area host | `AddScreen`, `NavigateTo` |

All widget classes expose the internal layout lifecycle methods described in [Lifecycle and rendering](#8-lifecycle-and-rendering). Application code normally configures the tree and calls `Render` only on its root.

## 6. Layout and natural measurement

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

`UIColumn` places children vertically and adds the configured spacing between them. Use `MainAxisAlignment` to distribute free space when the children have natural sizes:

```basic
Dim column As UIColumn
column.Initialize _
    .Spacing(8dip) _
    .MainAxisAlignment("center") _
    .AddChild(title) _
    .AddChild(subtitle)
```

Supported values are `start`, `center`, `end`, `spaceBetween`, `spaceAround` and `spaceEvenly`. The default is `start`. If the column contains `UIExpanded`, the flexible-child allocation takes precedence.

### UIRow

```basic
Dim row As UIRow
row.Initialize _
    .Spacing(8dip) _
    .AddChild(leftButton) _
    .AddChild(rightButton)
```

`UIRow` lays out children horizontally and distributes flexible children across the available width. For naturally sized children, `MainAxisAlignment` supports the same values as `UIColumn`:

```basic
Dim row As UIRow
row.Initialize _
    .MainAxisAlignment("spaceEvenly") _
    .AddChild(firstButton) _
    .AddChild(secondButton)
```

The default is `start`, preserving the original layout behavior.

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

## 7. UIScrollView

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

The child content is measured and mounted into the native `ScrollView.Panel`. Do not pass the native panel directly to custom code expecting a `B4XView`; the library handles that conversion internally.

## 8. Lifecycle and rendering

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

## 9. Events and callbacks

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

## 10. State and UI updates

`UIState` is an observable value holder for application state. It keeps the value outside widgets and notifies only the callbacks subscribed to that state instance.

```basic
Private CounterState As UIState

CounterState.Initialize(0).Subscribe(Me, "CounterState_Changed")

Sub Increment_Click
    Dim value As Int = CounterState.GetState
    CounterState.SetState(value + 1)
End Sub

Sub CounterState_Changed(State As UIState)
    CounterLabel.Text("" & State.GetState)
    CounterLabel.Render
End Sub
```

The callback receives the changed `UIState` instance. Use `Unsubscribe` when a long-lived state outlives its screen, or `ClearListeners` when the owner is being destroyed:

```basic
CounterState.Unsubscribe(Me, "CounterState_Changed")
' Or, when the state is no longer needed:
CounterState.ClearListeners
```

This milestone provides selective observable updates; it is not yet a complete Flutter-style virtual-DOM diff engine. The host still decides which widgets depend on a state instance, while `UIState` removes the need to rebuild the root tree for simple value changes. Structural changes still require updating the tree and rendering its root.

`SetState` is a replacement operation. It compares the assigned value using B4A's normal equality semantics, which is appropriate for simple values such as numbers and strings. It does not observe mutations made inside an existing `Map` or `List`; assign a new value when you want to notify listeners. A callback may perform one follow-up state change, but callbacks should not continuously mutate the same state or create an update cycle.

The NOVA example demonstrates this with:

- `CounterState` and the two floating action buttons;
- `ActivityRefreshState` and `REFRESH STREAM`;
- `UITheme` for palette state.

Keep state explicit and keep rendering predictable.

## 11. UITheme

`UITheme` is a reusable palette provider. It does not know which widgets your application owns and it does not repaint them automatically.

```basic
Private AppTheme As UITheme

AppTheme.Initialize
Dim surface As Int = AppTheme.Surface
Dim primaryText As Int = AppTheme.PrimaryText
```

Switch the palette and apply the returned colors in the host:

```basic
AppTheme.Toggle
ApplyTheme
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

A host-side theme application routine typically looks like this:

```basic
Sub ApplyTheme
    ' MainCard, Title, Description and Divider are initialized widgets.
    Root.Color = AppTheme.Background
    MainCard.BackgroundColor(AppTheme.Surface).BorderColor(AppTheme.Border)
    Title.Color(AppTheme.PrimaryText)
    Description.Color(AppTheme.SecondaryText)
    Divider.Color(AppTheme.Divider)
End Sub
```

## 12. UINavigator and safe area

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

## 13. Common problems

### A button appears but does nothing

Check that:

1. `OnClick` receives the correct target object.
2. The callback name matches exactly.
3. The callback exists in the target module.
4. The widget is not covered by another native view.
5. The root tree was rendered after the button was configured.

### Content is clipped or labels are cut off

Prefer natural measurement through `UIColumn`, `UIRow`, `UIPadding` and `UICard`. Avoid assigning arbitrary fixed heights to text widgets. Use `UIExpanded` for content that should consume remaining space.

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

## 14. NOVA Control Center example

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

## 15. Design boundaries and roadmap

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

Potential future work includes more robust incremental updates, additional widgets, animation support, better scroll abstractions and a cross-platform implementation. These should be added only when they solve a concrete problem for B4A users.
