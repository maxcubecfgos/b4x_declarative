# Declarative UI for B4A — Syntax and API Contract

**Contract version:** 1.0  
**Library baseline:** 0.1  
**Status:** Stable syntax baseline for the preliminary release

This document defines the syntax and compatibility rules of Declarative UI for B4A. It is a contract for application authors and for future library development.

The goal is simple: a user who learns this API should not have to learn a different language or a different composition model every few months.

## 1. What this library is — and is not

Declarative UI for B4A is a small, code-first composition layer built with normal B4A classes and native Android views.

It is:

- B4X/B4A code with optional fluent method chaining;
- a tree of reusable widget objects;
- a measure, layout, render and unmount protocol;
- explicit state through `UIState`;
- virtual navigation inside one real B4A Activity.

It is not:

- a new programming language;
- a Dart, Flutter or XML syntax clone;
- a replacement for B4A Activities or the B4A Designer;
- a promise of automatic virtual-DOM diffing;
- a promise that every Flutter widget or layout rule exists here.

When ordinary B4A is the clearest solution, application code may use ordinary B4A. The library adds composition; it does not hide the platform.

## 2. License boundary

This project and its `.b4xlib` package are shared under the Public Development Demo Notice. Use the demo freely in personal, educational, client, employer, internal-business, commercial and monetized applications. Source inspection, debugging and local modification are welcome, and resulting applications may be published as the user's own work.

The only community boundary is about source authorship: please do not copy the implementation into another library, framework, toolkit or standalone source project and publish it under your own name. This does not restrict applications, original code built around the API, tutorials, reviews, small credited snippets or local experiments. The complete notice is in [`LICENSE.txt`](LICENSE.txt), which is included inside the `.b4xlib`.

## 3. The canonical composition syntax

The only recommended composition syntax is normal B4A object creation followed by optional fluent configuration:

```basic
Dim title As UILabel
title.Initialize _
    .Text("Control center") _
    .Size(24) _
    .Color(0xFF132238)

Dim body As UIColumn
body.Initialize _
    .Spacing(12dip) _
    .AddChild(title) _
    .AddChild(actionButton)
```

Rules:

1. Declare widgets with normal B4A `Dim` statements.
2. Call `Initialize` before configuration.
3. Use fluent methods only when they improve readability.
4. A fluent method returns the same widget instance and may be chained.
5. The B4A line-continuation character `_` is the only continuation syntax.
6. Do not introduce a second DSL, macros, markup language or special builder syntax.
7. Keep the final tree in named variables when a screen is complex; do not require users to understand hidden generated code.

The equivalent non-chained form is always valid:

```basic
Dim title As UILabel
title.Initialize
title.Text("Control center")
title.Size(24)
title.Color(0xFF132238)
```

The fluent form is a convenience, not a separate language feature.

## 4. Naming rules

These rules apply to all new public API:

- Classes use the `UI` prefix and PascalCase: `UILabel`, `UIColumn`, `UIScrollView`.
- Public methods use PascalCase: `AddChild`, `BackgroundColor`, `BindText`.
- Callback names follow normal B4A event style: `Save_Click`, `Increment_Click`.
- State variables use descriptive PascalCase names: `CounterState`, `ScreenTitleState`.
- Configuration methods return the configured widget when chaining is useful.
- Lifecycle methods use the fixed names `SetParent`, `SetPosition`, `SetSize`, `Render`, `Unmount` and `GetContentSize`.
- New public methods must not silently change the meaning of an existing method.

The library will not introduce lower-case, Dart-style, JavaScript-style or operator-based alternatives to these conventions.

## 5. Public API tiers

Every public method belongs to one of three tiers.

### Tier A — Application configuration API

This is the API application code is expected to use:

- `Initialize`;
- widget configuration such as `Text`, `Color`, `Size`, `Child`, `AddChild`, `Spacing`, `CornerRadius` and `Border`;
- state bindings such as `BindText` and `BindTitle`;
- asynchronous operation state through `UIAsyncState`;
- text input configuration through `Hint`, `Text`, `TextColor`, `BackgroundColor`, `CornerRadius`, `Border` and `GetText`;
- event registration through `OnClick` and `OnTextChanged`;
- navigation methods such as `AddScreen` and `NavigateTo`;
- `ScrollTo` and other explicitly documented control methods;
- `UIListView` data and item callbacks (`Items`, `ItemCount`, `ItemHeight`, `CreateItem`, `BindItem`, `NotifyDataSetChanged`);
- transient feedback through `UISnackBar`;
- opt-in bounds animation through `UIAnimation`.


Tier A is the compatibility-sensitive public surface.

### Tier B — Composition protocol

These methods allow a parent widget to lay out a child:

```basic
SetParent(parent As B4XView)
SetPosition(left As Int, top As Int)
SetSize(width As Int, height As Int)
Render
Unmount
GetContentSize(maxWidth As Int, maxHeight As Int) As List
```

Application code normally calls these methods only on the root widget. Containers call them on their children.

Custom widgets that want to participate in a `UIColumn`, `UIRow`, `UIPadding`, `UICard`, `UICenter`, `UIExpanded`, `UIVisibility`, `UIStack`, `UIScrollView` or `UIScaffold` tree should implement this protocol with the same method names and signatures.

### Tier C — Native implementation details

Native view references, callback dispatch helpers, internal fields and private subs are implementation details. They are not part of the user-facing contract and may change without a syntax migration.

## 6. Widget initialization and configuration

Every widget must be initialized before it is configured or mounted:

```basic
Dim button As UIButton
button.Initialize _
    .Text("SAVE") _
    .OnClick(Me, "Save_Click")
```

The normal order is:

1. `Dim` the widget.
2. Call `Initialize`.
3. Configure properties, children, state bindings and callbacks.
4. Add the widget to its parent tree.
5. Render the root once it has a valid parent and size.

Configuration methods change the declarative object. They do not promise to create a native view immediately. If a widget is already mounted, methods documented as reactive bindings update it immediately; ordinary property changes become visible after the next `Render`.

## 7. Shape configuration

`UIButton` and `UIInput` expose the same optional shape configuration:

```basic
button.Initialize _
    .Text("SAVE") _
    .CornerRadius(12dip) _
    .Border(1dip, 0xFF008577)
```

Rules:

- `CornerRadius(Int)` returns the same widget and clamps negative values to zero.
- `Border(width, color)` returns the same widget and clamps negative widths to zero.
- The default radius and border width are both zero, preserving the native control background.
- A positive radius or border width activates a `ColorDrawable` background using the configured fill and border values.
- `UIInput` restores a touch-friendly internal padding when a custom background is active.
- Custom button backgrounds can replace the platform ripple drawable; this is an explicit trade-off of custom shaping.
- Shape properties affect the next `Render` and do not change event or state-binding behavior.

## 8. Composition and children

A container owns a tree of child objects:

```basic
Dim cardBody As UIColumn
cardBody.Initialize _
    .Spacing(6dip) _
    .AddChild(title) _
    .AddChild(subtitle)

Dim card As UICard
card.Initialize.Child(cardBody)
```

Rules:

- `AddChild` appends one child and returns the parent container.
- `Child` replaces the single child of a single-child container.
- A child is normally mounted by exactly one parent at a time.
- Structural changes are explicit: change the tree, then render the relevant root.
- The library does not infer ownership from global variables.
- `UIExpanded` is a layout marker for remaining space; it is not a general-purpose state or visibility widget.
- `UIVisibility` is the compositional visibility wrapper; it preserves one child while conditionally including it in layout and can bind that condition to `UIState`.
- `UIStack` is the Z-axis container; `AddChild` insertion order defines the visual stacking order.
- `UIBottomNavigationBar` is the declarative navigation surface; `AddItem` defines item data and `OnSelected` handles selection.
- `UIInput` is a native text-editing widget that participates in the same layout protocol.

The current library uses `Object` for child parameters so different widget classes can participate without inheritance. A custom child must satisfy the composition protocol; otherwise the parent cannot measure or render it safely.

## 9. Layout and measurement contract

`GetContentSize(maxWidth, maxHeight)` returns a `List` with two values:

```text
List(width, height)
```

Rules:

- Two values mean that the child has a natural size.
- An empty list means that the child is flexible and expects space from its parent.
- Width and height are B4A pixel values; use `dip` when specifying application constants.
- `UIColumn` lays out children vertically; `UIRow` lays them out horizontally.
- `UIExpanded` receives remaining main-axis space.
- `UIVisibility.Visible(False)` returns the natural size `List(0, 0)` and therefore does not consume layout space.
- `MainAxisSize("min")` requests natural main-axis size when no flexible child requires assigned space.
- `MainAxisSize("max")` is the default and uses the assigned main-axis bounds.
- Alignment values are case-insensitive.
- Invalid alignment or size values fall back to the documented defaults instead of creating a new behavior.

The supported alignment values are fixed for the current contract:

- `MainAxisAlignment`: `start`, `center`, `end`, `spaceBetween`, `spaceAround`, `spaceEvenly`;
- `CrossAxisAlignment`: `stretch`, `start`, `center`, `end`;
- `MainAxisSize`: `min`, `max`.

Future layout features must be additive or explicitly versioned. Existing values must retain their meaning.

### UIStack

`UIStack` provides overlapping composition without introducing another language syntax:

```basic
Dim stack As UIStack
stack.Initialize _
    .Alignment("bottomRight") _
    .AddChild(background) _
    .AddChild(badge)
```

Rules:

- `AddChild(Object)` appends a child and returns the same `UIStack` instance.
- Children are rendered in insertion order; later children appear above earlier children.
- `Alignment(String)` applies to naturally-sized children and defaults to `topLeft`.
- Accepted values are `topLeft`, `topCenter`, `topRight`, `centerLeft`, `center`, `centerRight`, `bottomLeft`, `bottomCenter` and `bottomRight`; matching is case-insensitive.
- Invalid alignment values fall back to `topLeft`.
- `GetContentSize` returns the largest width and height among participating natural children.
- A flexible child receives the complete assigned stack bounds.
- A hidden `UIVisibility` child does not participate in measurement or rendering.
- The stack preserves mounted children during `Render`; full native cleanup occurs only in `Unmount`, so stateful native controls can retain their state.

`UIStack` follows the same lifecycle and composition protocol as the other containers. Structural changes require rendering the affected parent; no implicit tree diff is introduced.

## 10. Rendering and lifecycle

The stable lifecycle is:

```text
Initialize → configure → compose → SetParent/SetPosition/SetSize → Render
                                                                     ↓
                                                                  Unmount
```

Rules:

- Render the root, not every leaf, during normal screen composition.
- `Render` creates native views when necessary and updates their current bounds/properties.
- `Unmount` releases native view references so the same declarative tree can be mounted again.
- Unmounting does not mean that state bindings or declarative configuration are forgotten.
- Navigation and theme changes may remount a virtual screen.
- A property update that affects only one widget should prefer a targeted `Render` or a documented binding.
- A structural change requires rendering the affected root/container; there is no implicit full-tree diff in this release.
- A bound visibility change is a localized structural update: the wrapper changes first and its explicit callback requests the affected parent render.

The library must not change the meaning of `Render` from “create or update the native representation” to “rebuild application state”.

### Conditional composition

`UIVisibility` uses the same fluent composition syntax as other single-child wrappers:

```basic
Dim optionalCard As UIVisibility
optionalCard.Initialize _
    .Visible(True) _
    .Child(card)

optionalCard.Visible(False)
body.Render
```

For state-driven visibility, use an explicit Boolean `UIState` and a normal B4A callback to render the affected parent:

```basic
Dim detailsState As UIState
detailsState.Initialize(True)

Dim details As UIVisibility
details.Initialize _
    .BindVisible(detailsState) _
    .OnVisibilityChanged(Me, "DetailsVisibilityChanged") _
    .Child(detailsCard)

Sub DetailsVisibilityChanged(Visibility As UIVisibility)
    body.Render
End Sub
```

Rules:

- `Visible(True)` is the default.
- `Child(Object)` replaces the single declarative child.
- `BindVisible(UIState)` reads the current Boolean value immediately and observes later replacements.
- `Visible(Boolean)` and `UnbindVisible` remove the visibility binding while preserving the current value.
- `OnVisibilityChanged(Target, EventName)` receives the changed `UIVisibility` instance through a one-argument callback.
- When hidden, the wrapper returns `List(0, 0)`, unmounts the child and removes the child's native views.
- When visible again, the child is mounted from its declarative configuration.
- The binding changes the wrapper immediately, but the callback owns parent remeasurement. Render the containing `UIColumn`, `UIRow`, `UIScrollView` or other affected root so siblings are remeasured and reflowed.
- `UIVisibility` does not guess which parent to render; this keeps ownership explicit and avoids hidden global rendering.

### UIBottomNavigationBar

`UIBottomNavigationBar` defines a persistent navigation surface without introducing a second event language:

```basic
Dim selectedState As UIState
selectedState.Initialize(0)

Dim navigation As UIBottomNavigationBar
navigation.Initialize _
    .AddItem("home", "⌂", "Home") _
    .AddItem("settings", "⚙", "Settings") _
    .BindSelectedIndex(selectedState) _
    .OnSelected(Me, "Navigation_Selected")

Sub Navigation_Selected(Index As Int, Id As String)
    Navigator.NavigateTo(Id)
End Sub
```

Rules:

- `AddItem(Id, Icon, Text)` appends one item and returns the bar.
- `Id` is application data and is returned unchanged by `GetSelectedId` and the callback.
- `Icon` is a displayable Unicode string; icon-font dependencies are not required.
- `BindSelectedIndex(UIState)` expects a number-like state value and keeps the selected index synchronized.
- `SetSelectedIndex(Index)` changes selection and invokes the registered callback.
- `OnSelected(Target, EventName)` expects `Sub EventName(Index As Int, Id As String)`.
- `ActiveColor`, `InactiveColor`, `IndicatorColor`, `BackgroundColor`, `DividerColor`, `IconSize`, `TextSize` and `ShowInactiveLabels` are configuration methods.
- The default layout height is `64dip`; `UIScaffold.BottomNavigationBar` reserves that area before laying out the body.
- Ordinary selection changes update existing native children; changing item count or bar dimensions rebuilds the native item views.
- `UIBottomNavigationBar` follows the same lifecycle protocol and preserves its state binding across temporary `Unmount` calls.

### UISnackBar

`UISnackBar` is the stable API for transient feedback over a supplied `B4XView` root:

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

Rules:

- `Message(String)`, `Action(Text, Target, EventName)`, `Duration(milliseconds)`, `AnimationDuration(milliseconds)`, `BackgroundColor`, `TextColor`, `ActionColor`, `CornerRadius` and `Margin` return the same snackbar instance.
- `Show(Parent)` mounts the overlay directly over the supplied root and brings it to the front.
- `Duration(0)` keeps it visible until `Dismiss` is called.
- `Dismiss` animates out and removes the native overlay.
- `Unmount` removes the overlay and invalidates delayed work.
- The action callback is a parameterless normal B4A sub and is dispatched only when it exists.
- `Show`, `Dismiss` and `Unmount` invalidate older delayed work; an old `Sleep` must not remove a newer snackbar.
- The snackbar is an overlay, not a permanent `UIColumn`/`UIRow` child. Use a non-clipping screen or Activity root when it must appear above the whole screen.

### UIAnimation

`UIAnimation` is the stable opt-in API for animating an existing native view's bounds:

```basic
Dim animation As UIAnimation
animation.Initialize _
    .TargetView(cardView) _
    .MoveAndResize(16dip, 96dip, 280dip, 160dip) _
    .Duration(240) _
    .OnCompleted(Me, "Animation_Completed") _
    .Start

Sub Animation_Completed
    ' Optional completion work.
End Sub
```

Rules:

- `TargetView(B4XView)` selects the already-mounted native view.
- `MoveTo(left, top)` changes only the destination position.
- `SizeTo(width, height)` changes only the destination size and clamps dimensions to zero or greater.
- `MoveAndResize(...)` sets both destination position and size.
- `Duration(milliseconds)` clamps negative values to zero.
- `Start` uses the view's current bounds as the unspecified starting values and restarts the descriptor when called again.
- `OnCompleted(Target, EventName)` expects a parameterless normal B4A callback.
- `Cancel` stops the native transition at its current bounds and suppresses completion.
- A new `Start` or `Cancel` invalidates pending completion work from an earlier run.
- The current release animates bounds only; it does not imply color, opacity, text or arbitrary-property animation.
- Animations are opt-in and do not replace the normal parent layout/render protocol.

## 11. Events and callbacks

Events use normal B4A target-plus-sub-name callbacks:

```basic
Dim saveButton As UIButton
saveButton.Initialize.OnClick(Me, "Save_Click")

Sub Save_Click
    ' Handle the action.
End Sub
```

Rules:

- The callback name is a `String` and must match exactly.
- The callback for `UIButton` and `UIFloatingActionButton` is parameterless.
- The target is the object that owns the callback, normally `Me`.
- Invalid or empty callbacks are ignored safely; they must not cause reflection crashes.
- `TriggerClick` dispatches the same configured callback as a native click.
- Event registration does not create a second event language or require lambdas.

`UIInput.OnTextChanged(Target, EventName)` uses the callback signature `Sub EventName(NewText As String)`. It reports user edits only; programmatic changes through `Text` or `BindText` do not invoke the callback. Future widgets may expose additional callbacks, but they must use normal B4A callback conventions and document their parameter signature explicitly.

## 12. State and bindings

`UIState` is the standard explicit state primitive:

```basic
Dim counterState As UIState
counterState.Initialize(0)

Dim counterLabel As UILabel
counterLabel.Initialize.BindText(counterState)

counterState.SetState(1)
```

Rules:

- `SetState` replaces the value and notifies subscribed listeners when the value changes.
- `GetState` returns the current value.
- `UIState` does not observe mutations inside an existing `Map` or `List`; assign a replacement value to notify listeners.
- `Subscribe` callbacks receive the `UIState` instance as one argument.
- `Unsubscribe` removes one subscription; `UnsubscribeTarget` removes all subscriptions owned by a target.
- Callbacks must not create an unbounded update cycle.
- A widget binding owns its widget subscription and must safely replace or remove it.

The supported binding methods are:

| Widget | Binding | Static method that replaces the binding |
| --- | --- | --- |
| `UILabel` | `BindText(UIState)` | `Text(String)` |
| `UIButton` | `BindText(UIState)` | `Text(String)` |
| `UIFloatingActionButton` | `BindText(UIState)` | `Text(String)` |
| `UIInput` | `BindText(UIState)` | `Text(String)` |
| `UIAppBar` | `BindTitle(UIState)` | `Title(String)` |

A binding applies the current value immediately and updates the target when the state changes. Calling the corresponding static setter explicitly cancels the binding. This precedence rule is permanent for the contract.

Bindings are intentionally one-way. For `UIInput`, the state value is applied to the native field, while user edits are delivered to the host through `OnTextChanged`; the host must call `SetState` explicitly if the edit should become application state. Automatic two-way form binding is not part of the current syntax and must not be implied by future examples until it is formally added.

### UIInput

`UIInput` exposes a native B4A `EditText` through the standard declarative API:

```basic
Dim nameState As UIState
nameState.Initialize("")

Dim nameInput As UIInput
nameInput.Initialize _
    .Hint("Operator name") _
    .BindText(nameState) _
    .OnTextChanged(Me, "Name_Changed")

Sub Name_Changed(NewText As String)
    nameState.SetState(NewText)
End Sub
```

`Text(String)` cancels `BindText(UIState)`. `GetText` returns the current text. The native field is preserved during ordinary `Render` calls so focus and keyboard state are not discarded. `GetContentSize` reports a natural 48dip height and a width based on the current text or hint.

## 13. Async operation state

`UIAsyncState` is the stable state model for operations that complete later. It does not make HTTP requests and does not replace B4A `Wait For` or `ResumableSub`.

```basic
Dim requestState As UIAsyncState
requestState.Initialize
requestState.SetLoading

Sub RequestState_Changed(State As UIAsyncState)
    If State.IsSuccess Then
        Log(State.GetValue)
    Else If State.IsError Then
        Log(State.GetErrorMessage)
    End If
End Sub

requestState.Subscribe(Me, "RequestState_Changed")
```

The public statuses are fixed strings: `idle`, `loading`, `success` and `error`. Use `SetIdle`, `SetLoading`, `SetSuccess(Value)`, `SetError(Message)` and `Reset` to transition the state. `GetStatus`, `GetValue`, `GetErrorMessage`, `IsIdle`, `IsLoading`, `IsSuccess` and `IsError` expose the current snapshot.

A request implementation remains in normal B4A code and may use `HttpJob` from `OkHttpUtils2`:

```basic
Sub LoadData
    requestState.SetLoading

    Dim job As HttpJob
    job.Initialize("", Me)
    job.Download(URL)
    Wait For (job) JobDone(job As HttpJob)

    If job.Success Then
        requestState.SetSuccess(job.GetString)
    Else
        requestState.SetError(job.ErrorMessage)
    End If
    job.Release
End Sub
```

Rules:

- `UIAsyncState` is independent of HTTP, `OkHttpUtils2`, databases and file APIs.
- `Wait For` remains a B4A language feature and is not hidden behind a new DSL.
- Subscribers receive `Sub EventName(State As UIAsyncState)` through the same safe callback pattern as `UIState`.
- Replacing the snapshot with identical status, value and error does not notify listeners.
- A callback may request one follow-up transition; notification passes are bounded like `UIState`.
- `Reset` is an alias for `SetIdle`.

## 14. Themes

`UITheme` is a Material 3-like design-token provider, not a global renderer. It supplies default colors, typography sizes, corner radii and common control metrics:

```basic
Dim theme As UITheme
theme.Initialize
' theme.InitializeDark
' theme.InitializeWithSchemeAndMode(0xFF6750A4, False)
If theme.IsDark Then
    ' Use the dark palette values.
End If
theme.Toggle
```

Rules:

- `Scheme(seedColor)` accepts a normal B4A ARGB `Int` and returns the same `UITheme` instance for fluent composition.
- `InitializeWithScheme(seedColor)` is the equivalent one-call initialization form.
- `Initialize` remains valid and provides complete light defaults with the default teal seed for backward compatibility.
- `InitializeDark` provides complete dark defaults.
- `InitializeWithSchemeAndMode(seedColor, dark)` combines a custom seed and explicit mode.
- A theme derives semantic color values through properties such as `Background`, `Surface`, `PrimaryText` and `Accent`.
- Typography, shape and layout tokens provide defaults for labels, buttons, cards, inputs, navigation, FABs and snackbars.
- Matching foreground properties such as `AccentText`, `InfoText`, `NegativeText` and `ThemeActionText` provide readable button text for the corresponding action colors.
- The host applies those values to its widgets.
- `UITheme` does not discover widgets or repaint the application automatically.
- Theme changes must not silently change application state or navigation.
- New palette values may be added; existing property meanings must remain stable.
- Calling a widget setter such as `Size`, `TextSize`, `CornerRadius`, `BackgroundColor` or `Color` marks only that property as overridden.
- `ApplyTheme` updates all non-overridden properties, so custom widgets can mix theme defaults with local design decisions.

## 15. Navigation and safe area

`UINavigator` manages virtual screens inside one real B4A Activity:

```basic
Navigator.Initialize _
    .AddScreen("Home", homeScreen) _
    .AddScreen("Settings", settingsScreen)

Navigator.NavigateTo("Settings")
```

Rules:

- A screen is a named widget tree, not a physical Activity or `.bal` layout.
- Screen names are application strings and must match exactly.
- Register a screen before navigating to it.
- The navigator owns mounting and unmounting of the active virtual screen.
- The root content area is responsible for staying below the Android status area.
- The current implementation uses one real Activity and the B4A `IME` content rectangle.

A future native multi-Activity integration must be additive and must not redefine virtual screens as Activities.

## 16. Compatibility and versioning

The syntax contract is more important than internal implementation details.

### Library version versus contract version

These are two related but different version numbers:

- **Library version** (`Version=0.1` in `manifest.txt`) identifies the packaged implementation and release.
- **Contract version** (`1.0` at the top of this file) identifies the public syntax/API rules that application authors rely on.

The preliminary package may therefore be library `0.1` while implementing contract `1.0`. This means the syntax baseline is considered defined, not that the implementation is a mature 1.x product.

Rules for changing the numbers:

- Additive features and internal fixes may increment the library minor or patch version while keeping the contract major version.
- A documented API removal, incompatible signature change, or incompatible syntax/layout rule requires a new contract major version and a migration note.
- A contract major-version change must be visible in the release documentation and must not be hidden behind a routine package rebuild.
- The library version may advance without changing the contract version, but a contract-version change must always be called out in the library release notes.

### Compatibility promise

- Documented Tier A methods and their meanings are stable within a contract major version.
- Minor and patch releases should be additive whenever possible.
- Existing fluent methods keep returning the same widget type.
- Existing callback signatures and binding precedence do not change silently.
- Internal fields, private subs and native view implementation may change.

### Changes that require a migration note

A migration note is required before any of the following:

- renaming or removing a documented public method;
- changing a method's parameter or return type;
- changing a callback signature;
- changing whether a method cancels a binding;
- changing measurement semantics or accepted layout values;
- changing virtual navigation or safe-area behavior;
- introducing a new required initialization order.

Breaking changes require a new contract major version and an explicit migration section in `GUIDE.md`. Deprecated methods should remain available for at least one documented release cycle and produce a clear replacement recommendation in the documentation.

### Adding features

New widgets and optional methods may be added without changing existing syntax. Before adding a feature, verify that it:

1. solves a concrete B4A UI problem;
2. can be expressed with normal B4A code;
3. does not duplicate an existing method with a different name;
4. does not require a global state manager or hidden lifecycle;
5. can be documented with a stable compatibility rule.

## 17. Rules for future contributors

Before merging a library change:

1. Decide whether the change is public API, composition protocol or internal implementation.
2. Preserve existing names and method return types whenever possible.
3. Add an example using the canonical syntax.
4. Update this contract if a new public rule is introduced.
5. Update `GUIDE.md` and the public API tables.
6. Add a migration note for any behavior change.
7. Compile the demo with B4A.
8. Regenerate and validate the `.b4xlib`.
9. Test runtime changes through **IDE focus → F5 → Ctrl+R → bundle inspection**.
10. Do not publish a new syntax convention only in an example or in a private implementation comment.

## 18. Current deliberate boundaries

The following are intentionally outside the contract for now:

- automatic virtual-DOM diffing;
- variable-height or full `RecyclerView` semantics in `UIListView`;
- automatic two-way data binding;
- implicit parent rendering for `UIVisibility` (use explicit `BindVisible` and `OnVisibilityChanged` instead);
- automatic animations or positioning transitions for `UIStack` children; `UIAnimation` remains explicit and opt-in;
- implicit global application state;
- inheritance-based widget extension;
- a custom expression language;
- automatic animations for every property;
- cross-platform B4i/B4J behavior;
- a guarantee of complete Flutter compatibility.

Keeping these boundaries explicit is a feature. The library can grow without forcing users to relearn its basic composition model.
