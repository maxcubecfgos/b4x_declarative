# Declarative UI for B4A

A small, code-first declarative UI layer for native B4A applications.

> **Documentation:** See [GUIDE.md](GUIDE.md) for installation, examples, widget APIs, lifecycle, layout, events, themes, navigation and troubleshooting.

This project explores a Flutter-inspired way to compose Android interfaces in B4A while keeping the result native, lightweight, and understandable. It does not try to recreate Flutter internally. Instead, it provides a focused set of composable widgets with a predictable mount, measure, layout, render, and unmount lifecycle.

The included **NOVA Control Center** is a demonstration application designed to show the framework's capabilities in a practical interface:

- Declarative screen composition
- Natural child measurement
- Vertical and horizontal layout
- Flexible children through `UIExpanded`
- A native `ScrollView` wrapped as `UIScrollView`
- Virtual navigation inside one real B4A Activity
- Automatic safe-area handling below the Android status area
- Observable runtime state updates for counters and activity refreshes
- Reusable light and dark palettes through `UITheme`
- Native B4A buttons and floating action buttons with declarative callbacks

## Project structure

| File | Responsibility |
| --- | --- |
| `Declarative UI.b4a` | NOVA demo Activity and screen composition |
| `UITheme.bas` | Reusable light/dark color palette |
| `UIState.bas` | Observable state holder with selective callbacks |
| `UIScrollView.bas` | Declarative wrapper around the native B4A `ScrollView` |
| `UINavigator.bas` | Virtual screen registration, navigation, and safe-area host |
| `UIScaffold.bas` | App bar, body, and optional floating action button layout |
| `UIColumn.bas` | Vertical child layout with natural measurement and axis alignment |
| `UIRow.bas` | Horizontal child layout with natural measurement and axis alignment |
| `UIExpanded.bas` | Flexible space marker for Column and Row |
| `UIPadding.bas` | Flutter-inspired padding around a child (`All`, `Horizontal`, `Vertical`, `Only`) |
| `UICard.bas` | Rounded surface with background and border colors |
| `UIBox.bas` | Lightweight padded child container |
| `UICenter.bas` | Centers a child using its measured natural size |
| `UILabel.bas` | Native label wrapper |
| `UIButton.bas` | Native button wrapper with safe callback dispatch |
| `UIFloatingActionButton.bas` | Compact native floating action button with safe callback dispatch |
| `UIAppBar.bas` | App bar with a persistent, vertically centered title |
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

Dim screen As UIScaffold
screen.Initialize _
    .AppBar(appBar) _
    .Body(padded)
```

The application describes the tree. The framework handles native view creation and positioning during `Render`.

## Widget lifecycle

Every layout-aware widget follows the same basic contract:

1. `Initialize` creates the declarative object.
2. Fluent methods configure text, colors, children, spacing, and callbacks.
3. `SetParent`, `SetPosition`, and `SetSize` receive layout information.
4. `GetContentSize` reports the natural size when the widget has one.
5. `Render` creates or updates the native B4A view.
6. `Unmount` releases native references before a remount.

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

An empty list represents a flexible child. `UIColumn` and `UIRow` first measure natural children, then distribute the remaining space among flexible children such as `UIExpanded`. When all children have natural sizes, `MainAxisAlignment` can place them at the start, center, end, or distribute the free space evenly. `CrossAxisAlignment` controls the perpendicular axis and supports `stretch`, `start`, `center`, and `end`. The default remains `stretch`.

This avoids hard-coding every label height and prevents common clipping problems caused by positioning text using arbitrary constants.

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
- Remounts the child safely after navigation, layout changes, or theme changes.
- Exposes `ScrollTo` and `GetScrollPosition` for programmatic control.

A scroll view is normally placed inside `UIExpanded` when it shares a `UIColumn` with a fixed header or footer:

```basic
ActivityBody.Initialize.Spacing(10dip) _
    .AddChild(header) _
    .AddChild(UIExpanded.Initialize.Child(scroll)) _
    .AddChild(refreshButton)
```

## UIState

`UIState` is a small observable value holder for application state. It keeps state outside widgets and notifies only the callbacks subscribed to that value.

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

This is selective notification, not a full virtual-DOM diff engine. The host still decides which widget belongs to the state callback, while `UIState` removes the need to manually call a root rebuild for simple value changes.

## UITheme

`UITheme` centralizes palette decisions without coupling the framework widgets to one application:

```basic
Private AppTheme As UITheme

AppTheme.Initialize
Dim background As Int = AppTheme.Background
Dim cardSurface As Int = AppTheme.Surface
Dim primaryText As Int = AppTheme.PrimaryText
```

Switch palettes at runtime:

```basic
AppTheme.Toggle
ApplyTheme
```

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

The demo's `ApplyTheme` method injects these colors into the existing widget instances and then remounts the active virtual screen. The palette remains reusable because `UITheme` only provides values; it does not know about NOVA screens or controls.

## Navigation and safe area

`UINavigator` provides virtual screens inside one real native B4A Activity:

```basic
Navigator.Initialize _
    .AddScreen("Dashboard", DashboardScreen) _
    .AddScreen("Activity", ActivityScreen) _
    .AddScreen("Settings", SettingsScreen)

Navigator.NavigateTo("Activity")
```

The host uses the available content rectangle reported by the B4A `IME` API. This keeps the declarative root below the Android status area, including the battery and clock region, without requiring every screen to calculate top insets independently.

This is intentionally a single-Activity navigation model. It avoids pretending that a virtual declarative screen is a physical B4A Activity or layout file. Native Activity behavior can still be added later when a real Activity is genuinely required.

## NOVA Control Center demo

The example contains three virtual screens:

### Dashboard

- Live counter controlled by the two floating action buttons
- Hero status card
- Active-user and uptime metrics
- Navigation buttons for Activity and Settings

### Activity

- A six-item event stream
- Natural card measurement
- A real scrollable content area
- Refresh state updated at runtime
- Navigation back to Dashboard

### Settings

- Runtime theme switch
- Explicit light/dark status text
- Theme-aware cards, bars, labels, borders, dividers, and buttons
- Navigation back to Dashboard

## Building

1. Open `Declarative UI.b4a` in the B4A IDE.
2. Confirm that all project modules are included, especially:
   - `UIScrollView`
   - `UITheme`
3. Compile the project with B4A.
4. Run it from the IDE on a device or emulator.

The project currently uses the following B4A libraries:

- `core`
- `ime`
- `xui`

## Suggested demonstration flow

For a forum presentation, use this sequence:

1. Start on the Dashboard and tap `+` to show state-driven updates.
2. Open `VIEW ACTIVITY` and scroll through the event stream.
3. Tap `REFRESH STREAM` and show the refresh counter changing.
4. Return to Dashboard and open `SETTINGS`.
5. Toggle the theme and show the complete palette transition.
6. Return to Dashboard and verify that navigation and state remain intact.

The most important comparison with imperative UI code is that the demo describes a reusable tree of widgets. Native views are still used underneath, but screen composition, measurement, and mounting are handled consistently by the declarative layer.

## Design principles

- Prefer a small, explicit API over a complete Flutter clone.
- Keep widgets independent from application-specific state and colors.
- Reuse native B4A controls where they are appropriate.
- Measure content before assigning layout bounds.
- Keep virtual navigation separate from native Activity lifecycle.
- Treat safe-area handling as a root-layout concern.
- Keep runtime diagnostics out of production code.
- Add complexity only when a concrete UI problem requires it.
