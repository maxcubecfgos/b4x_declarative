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

## 2. The canonical composition syntax

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

## 3. Naming rules

These rules apply to all new public API:

- Classes use the `UI` prefix and PascalCase: `UILabel`, `UIColumn`, `UIScrollView`.
- Public methods use PascalCase: `AddChild`, `BackgroundColor`, `BindText`.
- Callback names follow normal B4A event style: `Save_Click`, `Increment_Click`.
- State variables use descriptive PascalCase names: `CounterState`, `ScreenTitleState`.
- Configuration methods return the configured widget when chaining is useful.
- Lifecycle methods use the fixed names `SetParent`, `SetPosition`, `SetSize`, `Render`, `Unmount` and `GetContentSize`.
- New public methods must not silently change the meaning of an existing method.

The library will not introduce lower-case, Dart-style, JavaScript-style or operator-based alternatives to these conventions.

## 4. Public API tiers

Every public method belongs to one of three tiers.

### Tier A — Application configuration API

This is the API application code is expected to use:

- `Initialize`;
- widget configuration such as `Text`, `Color`, `Size`, `Child`, `AddChild` and `Spacing`;
- state bindings such as `BindText` and `BindTitle`;
- text input configuration through `Hint`, `Text`, `TextColor`, `BackgroundColor` and `GetText`;
- event registration through `OnClick` and `OnTextChanged`;
- navigation methods such as `AddScreen` and `NavigateTo`;
- `ScrollTo` and other explicitly documented control methods.

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

## 5. Widget initialization and configuration

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

## 6. Composition and children

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
- `UIVisibility` is the compositional visibility wrapper; it preserves one child while conditionally including it in layout.
- `UIStack` is the Z-axis container; `AddChild` insertion order defines the visual stacking order.
- `UIInput` is a native text-editing widget that participates in the same layout protocol.

The current library uses `Object` for child parameters so different widget classes can participate without inheritance. A custom child must satisfy the composition protocol; otherwise the parent cannot measure or render it safely.

## 7. Layout and measurement contract

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

## 8. Rendering and lifecycle

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

Rules:

- `Visible(True)` is the default.
- `Child(Object)` replaces the single declarative child.
- When hidden, the wrapper returns `List(0, 0)`, unmounts the child and removes the child's native views.
- When visible again, the child is mounted from its declarative configuration.
- Changing visibility is a structural layout update; render the containing `UIColumn`, `UIRow` or other affected root afterward so siblings are remeasured and reflowed.
- `UIVisibility` does not implicitly subscribe to `UIState` in this contract. A future reactive visibility binding must define how parent remeasurement is triggered before it is added.

## 9. Events and callbacks

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

## 10. State and bindings

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

## 11. Themes

`UITheme` is a palette value provider, not a global renderer:

```basic
Dim theme As UITheme
theme.Initialize.Scheme(0xFF6750A4)
If theme.IsDark Then
    ' Use the dark palette values.
End If
theme.Toggle
```

Rules:

- `Scheme(seedColor)` accepts a normal B4A ARGB `Int` and returns the same `UITheme` instance for fluent composition.
- `InitializeWithScheme(seedColor)` is the equivalent one-call initialization form.
- `Initialize` remains valid and uses the default teal seed for backward compatibility.
- A theme derives semantic color values through properties such as `Background`, `Surface`, `PrimaryText` and `Accent`.
- Matching foreground properties such as `AccentText`, `InfoText`, `NegativeText` and `ThemeActionText` provide readable button text for the corresponding action colors.
- The host applies those values to its widgets.
- `UITheme` does not discover widgets or repaint the application automatically.
- Theme changes must not silently change application state or navigation.
- New palette values may be added; existing property meanings must remain stable.

## 12. Navigation and safe area

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

## 13. Compatibility and versioning

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

## 14. Rules for future contributors

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

## 15. Current deliberate boundaries

The following are intentionally outside the contract for now:

- automatic virtual-DOM diffing;
- automatic two-way data binding;
- implicit `UIState` binding for `UIVisibility`;
- automatic animations or positioning transitions for `UIStack` children;
- implicit global application state;
- inheritance-based widget extension;
- a custom expression language;
- automatic animations for every property;
- cross-platform B4i/B4J behavior;
- a guarantee of complete Flutter compatibility.

Keeping these boundaries explicit is a feature. The library can grow without forcing users to relearn its basic composition model.
