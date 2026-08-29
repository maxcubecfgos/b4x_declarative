# Kitchen Sink Declarative UI — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert `examples/b4x_kitchen_sink` into the reference Declarative UI example: pure-B4A shell, `UINavigator`-only navigation, one class per screen, covering every `UI.*` factory with polished, token-driven visuals.

**Architecture:** Code module `App` owns the global `UITheme`, the single `UINavigator`, route tracking and shared builders (`ScreenScaffold`, `SectionCard`). Each screen is a self-contained class exposing `Build As Object`; screen-local `UIState`/`UIAsyncState` live in the class instance so they survive theme rebuilds. Navigation = `App.Navigate(route)` / hardware-back → `Nav.GoBack`. Theme toggle = full tree rebuild through `App.RebuildNavigator`.

**Tech Stack:** B4A 13.x, DeclarativeUI.b4xlib (Contract 2.0), core, xui, javaobject, okhttputils2.

## Global Constraints

- 100% factories `UI.*`: **never** `Dim x As UIxxx` + `Initialize` in app code. Single documented exception: `UIPlaceholder` has no factory → `Dim p As UIPlaceholder : p.Initialize`.
- Never call protocol Tier B (`SetParent/SetPosition/SetSize/Render`) except `UI.Show` / `UI.Unmount` / `Nav.Render`-equivalents owned by `App`.
- Line continuation is ` _` (space+underscore); parentheses balance per statement.
- No `.bal` layouts, no Designer, no B4XPages.
- All colors/sizes/typography from `App.Theme` tokens (explicit setters allowed only to *assign* a token).
- Events target the owning class (`Me`) except back-navigation which targets `App`.
- Verification gate per task: `python check-b4x-source.py` → `b4x-mcp --cli validate_b4x_syntax` → `b4x-mcp --cli compile_project` (must be 0 errors). Full `get_codebundle` at Task 14.
- Git commits only if the user explicitly asks.
- Working dir for commands: repo root `D:\Projects\Declarative UI`. b4x-mcp CLI path per repo docs; alternatively use MCP tools directly when running in-session.
- Spanish UI copy, English identifiers.

---

### Task 1: Rebase the project shell (drop B4XPages, plain Activity)

**Files:**
- Modify: `examples/b4x_kitchen_sink/B4A/b4x_kitchen_sink.b4a` (header + Main code)
- Delete: `examples/b4x_kitchen_sink/B4XMainPage.bas`
- Delete: any `mainpage.bal` under `Shared Files/`
- Create: `examples/b4x_kitchen_sink/Shared Files/logo.png` (deferred to Task 7 — skip here)

**Interfaces:**
- Produces: `App.Start(Root As B4XView)` called from `Activity_Create`; `App.Nav As UINavigator`; `App.GoBack` consumed by `Activity_KeyPress`. (App module itself arrives in Task 2 — this task ends with a compiling stub.)

- [ ] **Step 1: Rewrite the project header**

Replace the `.b4a` header (above `@EndOfDesignText@`) with:

```
Build1=Default,b4a.kitchensink
Group=Default Group
Library1=core
Library2=xui
Library3=declarativeui
Library4=javaobject
Library5=okhttputils2
ManifestCode='This code will be applied to the manifest file during compilation.~\n~'You do not need to modify it in most cases.~\n~'See this link for for more information: https://www.b4x.com/forum/showthread.php?p=78136~\n~AddManifestText(~\n~<uses-sdk android:minSdkVersion="21" android:targetSdkVersion="36"/>~\n~<supports-screens android:largeScreens="true" ~\n~    android:normalScreens="true" ~\n~    android:smallScreens="true" ~\n~    android:anyDensity="true"/>)~\n~AddPermission(android.permission.INTERNET)~\n~SetApplicationAttribute(android:icon, "@drawable/icon")~\n~SetApplicationAttribute(android:label, "$LABEL$")~\n~CreateResourceFromFile(Macro, Themes.LightTheme)~\n~'End of default text.~\n~
NumberOfFiles=0
NumberOfLibraries=5
NumberOfModules=1
Module1=App
Version=13.7
@EndOfDesignText@
```

Notes: package changed to `b4a.kitchensink`; `B4XPages` reference removed; `App` pre-registered (file created in Task 2 — between Tasks 1 and 2 the project is allowed to fail compile ONLY if executing strictly task-by-task is desired otherwise do Task 1+2 together before first compile; recommended: run first compile at end of Task 2).

- [ ] **Step 2: Rewrite Main body**

```basic
#Region  Project Attributes
    #ApplicationLabel: Declarative UI Kitchen Sink
    #VersionCode: 1
    #VersionName: 1.0
    'SupportedOrientations possible values: unspecified, landscape or portrait.
    #SupportedOrientations: portrait
#End Region

#Region  Activity Attributes
    #FullScreen: False
    #IncludeTitle: False
#End Region

Sub Process_Globals

End Sub

Sub Globals

End Sub

Sub Activity_Create(FirstTime As Boolean)
    App.Start(Activity)
End Sub

'True = let the OS handle it. We consume BACK while the navigator can pop.
Sub Activity_KeyPress (KeyCode As Int) As Boolean
    If KeyCode = KeyCodes.KEYCODE_BACK Then
        Return Not(App.HandleBack)
    End If
    Return False
End Sub
```

- [ ] **Step 3: Delete B4XPages artifacts**

```powershell
Remove-Item -LiteralPath "examples\b4x_kitchen_sink\B4XMainPage.bas"
Get-ChildItem "examples\b4x_kitchen_sink\Shared Files" -Filter *.bal | Remove-Item
```

Also delete `B4J/` and `B4i/` folders from `examples/b4x_kitchen_sink/` (out of scope per spec).

- [ ] **Step 4: Gate**

No compile yet (App missing). Proceed straight to Task 2 and gate there.

---

### Task 2: `App` code module + `HomeScreen` (runnable gallery)

**Files:**
- Create: `examples/b4x_kitchen_sink/B4A/App.bas` (Code Module)
- Create: `examples/b4x_kitchen_sink/B4A/HomeScreen.bas` (Class Module)

**Interfaces:**
- Produces (consumed by ALL later screen tasks):
  - `App.Theme As UITheme` · `App.Nav As UINavigator` · `App.CurrentRoute As String`
  - `App.Start(Root As B4XView)` · `App.Navigate(RouteName As String)` · `App.HandleBack As Boolean` · `App.ToggleTheme` · `App.RebuildNavigator`
  - `App.RegisterScreen(RouteName As String, Widget As Object, IconGlyph As String, TitleText As String, Desc As String)` — one call per screen; feeds both the navigator AND the home gallery automatically.
  - `App.ScreenScaffold(TitleText As String, Body As Object) As UIScaffold` — themed scaffold with back-arrow AppBar action.
  - `App.SectionCard(TitleText As String, Child As Object) As UICard`
  - `App.Tile(Glyph As String, TitleText As String, Desc As String, HandlerEventName As String) As UICard` — gallery card; click goes through a per-tile event sub defined in HomeScreen.
  - `App.Snack(Parent As B4XView, MessageText As String)` — themed feedback everywhere.
- Produces (HomeScreen): `Build As Object` + eleven `XxxTile_Click` subs added in later tasks.

- [ ] **Step 1: Write `App.bas`**

```basic
Sub Process_Globals
    Public Theme As UITheme
    Public Nav As UINavigator
    Public CurrentRoute As String
    Public Tiles As List
    Public Home As HomeScreen
    Private mRoot As B4XView
End Sub

Public Sub Start(Root1 As B4XView)
    mRoot = Root1
    Theme = UI.ThemeWithScheme(0xFF6558D3)
    Tiles.Initialize
    Home.Initialize
    RebuildNavigator
End Sub

'Registers a route in the navigator and its gallery tile in one call.
'Call order defines gallery order; "home" must be registered first.
Public Sub RegisterScreen(RouteName As String, Widget As Object, _
    Glyph As String, TitleText As String, Desc As String)
    Nav.AddScreen(RouteName, Widget)
    If RouteName <> "home" Then
        Tiles.Add(Array(RouteName, Glyph, TitleText, Desc))
    End If
End Sub

Public Sub Navigate(RouteName As String)
    CurrentRoute = RouteName
    Nav.NavigateTo(RouteName)
End Sub

'Called from Activity_KeyPress. True = back was consumed by the navigator.
Public Sub HandleBack As Boolean
    If Nav.CanGoBack Then
        Nav.GoBack
        Dim hist As List = Nav.HistorySnapshot 'see Step 2 note
        CurrentRoute = hist.Get(hist.Size - 1)
        Return True
    End If
    Return False
End Sub

Public Sub NavBack_Click
    HandleBack
End Sub

Public Sub ToggleTheme
    Theme.Toggle
    RebuildNavigator
End Sub

'Theme change = full declarative rebuild: fresh trees, fresh mount,
'same screen instances (their UIState survives in Class_Globals).
Public Sub RebuildNavigator
    If Nav.IsInitialized Then UI.Unmount(Nav)
    Tiles.Clear
    Nav.Initialize
    Home.Build 'placeholder replaced in RegisterScreens below
    Nav.AddScreen("home", Home.Build)
    CurrentRoute = "home"
    RegisterRoutes
    UI.Show(mRoot, Nav)
End Sub

Private Sub RegisterRoutes
    'One line per screen, appended by later tasks:
    'App.RegisterScreen("text", App.TextScr.Build, Chr(0xF031), "Texto", "...") 
End Sub
```

**Correction before writing the file:** `UINavigator` has no `HistorySnapshot`; keep the route stack in `App` instead. Final `App.bas` replaces the two spots above with:

```basic
    Public History As List 'Process_Globals; Initialize in Start
...
Public Sub Navigate(RouteName As String)
    If History.IsInitialized = False Then History.Initialize
    History.Add(RouteName)
    CurrentRoute = RouteName
    Nav.NavigateTo(RouteName)
End Sub

Public Sub HandleBack As Boolean
    If Nav.CanGoBack Then
        Nav.GoBack
        History.RemoveAt(History.Size - 1)
        CurrentRoute = History.Get(History.Size - 1)
        Return True
    End If
    Return False
End Sub
...
Public Sub RebuildNavigator
    If Nav.IsInitialized Then UI.Unmount(Nav)
    Tiles.Clear
    Nav.Initialize
    If History.IsInitialized = False Then History.Initialize Else History.Clear
    Nav.AddScreen("home", Home.Build)
    History.Add("home")
    CurrentRoute = "home"
    RegisterRoutes
    If RegisterRoutesRestored <> "" Then 'restores deep route after theme toggle
        Navigate(RegisterRoutesRestored)
    End If
    UI.Show(mRoot, Nav)
    #If Debug
    If UI.HasErrors Then Log("DeclarativeUI: " & UI.Errors)
    #End If
End Sub
```

…and `ToggleTheme` captures the route first:

```basic
Public Sub ToggleTheme
    Dim restoredRoute As String = CurrentRoute
    Theme.Toggle
    RegisterRoutesRestored = restoredRoute 'Private in Process_Globals
    RebuildNavigator
    RegisterRoutesRestored = ""
End Sub
```

Shared builders appended to `App.bas` (uses only factories + tokens):

```basic
'Standard screen frame: themed scaffold + back arrow in the AppBar.
Public Sub ScreenScaffold(TitleText As String, Body As Object) As UIScaffold
    Return UI.Scaffold(Body) _
        .AppBar(UI.AppBar(TitleText) _
            .Action(UI.IconFA(Chr(0xF060)).Size(18) _
                .Color(Theme.DashboardBarText).OnClick(Me, "NavBack_Click"))) _
        .ApplyTheme(Theme)
End Sub

'Demo group: titled card wrapper used by every screen.
Public Sub SectionCard(TitleText As String, Child As Object) As UICard
    Return UI.Card(UI.Column(Null) _
        .Spacing(10dip) _
        .AddChild(UI.Text(TitleText).Size(Theme.TitleMedium).Color(Theme.SecondaryText)) _
        .AddChild(Child))
End Sub

'Gallery tile for HomeScreen (click handled by per-tile event in HomeScreen).
Public Sub Tile(Glyph As String, TitleText As String, Desc As String, _
    HandlerEventName As String) As UICard
    Return UI.Card(UI.Column(Null) _
        .Spacing(4dip) _
        .AddChild(UI.Row(Null).Spacing(12dip).CrossAxisAlignment("center") _
            .AddChild(UI.IconFA(Glyph).Size(22).Color(Theme.Accent)) _
            .AddChild(UI.Expanded(UI.Text(TitleText) _
                .Size(Theme.TitleMedium).Color(Theme.PrimaryText))) _
            .AddChild(UI.IconFA(Chr(0xF054)).Size(16).Color(Theme.MutedText))) _
        .AddChild(UI.Text(Desc).Size(Theme.BodySmall).Color(Theme.SecondaryText)))
    'NOTE: UICard has no OnClick; the tappable surface is added by HomeScreen
    'as a full-width transparent-styled button UNDER the card content — see
    'HomeScreen.BuildOverlayTile in Step 2.
End Sub

'Uniform themed snackbar feedback.
Public Sub Snack(ParentView As B4XView, MessageText As String)
    Dim s As UISnackBar = UI.Snack(MessageText).Duration(1800)
    s.ApplyTheme(Theme)
    s.Show(ParentView)
End Sub
```

**Second correction:** `UI.Snack(...)` already returns `UISnackBar`; the local `Dim s` form above is valid B4A (factory assigned to typed local). Keep it — needed to call `ApplyTheme` fluently-chained types. Same pattern allowed nowhere else.

- [ ] **Step 2: Write `HomeScreen.bas`**

```basic
Sub Class_Globals
    Private HeroState As UIState
End Sub

Public Sub Initialize
    HeroState = UI.State("")
End Sub

'Root route: hero header + one tile per registered category.
Public Sub Build As Object
    Dim gallery As UIColumn = UI.Column(Null).Spacing(12dip)
    For i = 0 To App.Tiles.Size - 1
        Dim meta() As Object = App.Tiles.Get(i)
        gallery.AddChild(BuildTile(meta(0), meta(1), meta(2), meta(3), i))
    Next
    Dim body As UIScrollView = UI.Scroll(UI.Padding(16dip, UI.Column(Null) _
        .Spacing(20dip) _
        .AddChild(BuildHero) _
        .AddChild(gallery)))
    Return App.ScreenScaffold("Kitchen Sink", body)
End Sub

Private Sub BuildHero As UICard
    App.HeroState.SetState("Demuestra todos los componentes de la librería" & CRLF & _
        "con navegación 100% UINavigator.")
    Return UI.Card(UI.Column(Null).Spacing(6dip) _
        .AddChild(UI.Text("Declarative UI").Size(Theme.DisplayLarge) _
            .Color(Theme.PrimaryText)) _
        .AddChild(UI.Text("").BindText(App.HeroState) _
            .Size(Theme.BodyLarge).Color(Theme.SecondaryText))) _
        .BackgroundColor(App.Theme.HeroSurface)
End Sub

'Card content + invisible-ish tap surface (styled Button) stacked in a UIStack
'so the WHOLE tile reacts. HandlerEventName selects one of the explicit subs below.
Private Sub BuildTile(RouteName As String, Glyph As String, TitleText As String, _
    Desc As String, Index As Int) As UIStack
    Dim handlerName As String = HandlerFor(Index)
    Dim content As UICard = App.Tile(Glyph, TitleText, Desc, "")
    Dim tap As UIButton = UI.Button("").BackgroundColor(Colors.Transparent) _
        .OnClick(Me, handlerName)
    Return UI.Stack(Null).AddChild(content).AddChild(tap)
End Sub

'Map index -> explicit event sub (B4A has no closures).
Private Sub HandlerFor(Index As Int) As String
    Select Case Index
        Case 0 : Return "Tile0_Click"
        Case 1 : Return "Tile1_Click"
        Case 2 : Return "Tile2_Click"
        Case 3 : Return "Tile3_Click"
        Case 4 : Return "Tile4_Click"
        Case 5 : Return "Tile5_Click"
        Case 6 : Return "Tile6_Click"
        Case 7 : Return "Tile7_Click"
        Case 8 : Return "Tile8_Click"
        Case 9 : Return "Tile9_Click"
        Case Else : Return "Tile10_Click"
    End Select
End Sub

Private Sub Tile0_Click : App.NavigateByIndex(0) : End Sub
Private Sub Tile1_Click : App.NavigateByIndex(1) : End Sub
Private Sub Tile2_Click : App.NavigateByIndex(2) : End Sub
Private Sub Tile3_Click : App.NavigateByIndex(3) : End Sub
Private Sub Tile4_Click : App.NavigateByIndex(4) : End Sub
Private Sub Tile5_Click : App.NavigateByIndex(5) : End Sub
Private Sub Tile6_Click : App.NavigateByIndex(6) : End Sub
Private Sub Tile7_Click : App.NavigateByIndex(7) : End Sub
Private Sub Tile8_Click : AppNavigateByIndexGuard(8) : End Sub 'typo guard: see correction
Private Sub Tile9_Click : App.NavigateByIndex(9) : End Sub
Private Sub Tile10_Click : App.NavigateByIndex(10) : End Sub
```

**Corrections before writing the file:**
1. Fix the typo: `Tile8_Click` must call `App.NavigateByIndex(8)`.
2. Add to `App.bas`:

```basic
'Routes by gallery position (HomeScreen tiles have no closures).
Public Sub NavigateByIndex(Index As Int)
    If Index < 0 Or Index >= Tiles.Size Then Return
    Dim meta() As Object = Tiles.Get(Index)
    Navigate(meta(0))
End Sub
```

3. `BuildHero` reads `App.Theme` directly (helper `Theme` shorthand only exists inside `App`); replace both occurrences accordingly (`App.Theme.DisplayLarge`, `App.Theme.PrimaryText`, `App.Theme.BodyLarge`, `App.Theme.SecondaryText`, `App.Theme.HeroSurface`).
4. The empty-text `UIButton` renders a visible default background on some skins even with `Colors.Transparent`; if the spot-check screenshot shows it, swap `Colors.Transparent` for `App.Theme.Surface` and rely on Card being underneath (visual no-op).

- [ ] **Step 3: Verify (first real gate)**

```powershell
python check-b4x-source.py examples/b4x_kitchen_sink
b4x-mcp --cli validate_b4x_syntax --project-path examples/b4x_kitchen_sink/B4A/b4x_kitchen_sink.b4a
b4x-mcp --cli compile_project --project-path examples/b4x_kitchen_sink/B4A/b4x_kitchen_sink.b4a
```

Expected: 0 errors. App launches showing hero + empty gallery (no tiles yet).

---

### Task 3: `TextScreen` — typography + BindText

**Files:** Create `examples/b4x_kitchen_sink/B4A/TextScreen.bas`; edit `App.bas` (instance + route).

**Interfaces:** Consumes `App.ScreenScaffold/SectionCard/Snack`, `App.RegisterScreen`. Produces nothing downstream.

- [ ] **Step 1: Write `TextScreen.bas`**

```basic
Sub Class_Globals
    Private LiveState As UIState
End Sub

Public Sub Initialize
    LiveState = UI.State("Edita arriba y mira este texto cambiar")
End Sub

Public Sub Build As Object
    Dim typeCard As UICard = App.SectionCard("Escala tipográfica", _
        UI.Column(Null).Spacing(8dip) _
            .AddChild(Sample("DisplayLarge", App.Theme.DisplayLarge)) _
            .AddChild(Sample("HeadlineSmall", App.Theme.HeadlineSmall)) _
            .AddChild(Sample("TitleLarge", App.Theme.TitleLarge)) _
            .AddChild(Sample("BodyLarge", App.Theme.BodyLarge)) _
            .AddChild(Sample("BodyMedium", App.Theme.BodyMedium)) _
            .AddChild(Sample("BodySmall", App.Theme.BodySmall)) _
            .AddChild(Sample("LabelLarge", App.Theme.LabelLarge)))
    Dim bindCard As UICard = App.SectionCard("BindText en vivo", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.Input("Escribe algo...") _
                .OnChanged(Me, "Live_TextChanged")) _
            .AddChild(UI.Text("").BindText(LiveState) _
                .Size(App.Theme.BodyLarge).Color(App.Theme.Accent)))
    Return App.ScreenScaffold("Texto", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip).AddChild(typeCard).AddChild(bindCard))))
End Sub

Private Sub Sample(NameText As String, SizeToken As Int) As UILabel
    Return UI.Text(NameText).Size(SizeToken).Color(App.Theme.PrimaryText)
End Sub

Private Sub Live_TextChanged(NewText As String)
    If NewText = "" Then
        LiveState.SetState("Edita arriba y mira este texto cambiar")
    Else
        LiveState.SetState(NewText)
    End If
End Sub
```

- [ ] **Step 2: Wire into `App`**

In `Process_Globals` add `Public TextScr As TextScreen`. In `Start` add `TextScr.Initialize`. In `RegisterRoutes` add:

```basic
    RegisterScreen("text", TextScr.Build, Chr(0xF031), "Texto", _
        "Escala tipográfica y bindings de texto en vivo")
```

- [ ] **Step 3: Verify** — same three commands as Task 2 Step 3. Expected: 0 errors; home shows 1 tile; route works; typing updates bound label instantly.

---

### Task 4: `ButtonsScreen` — variants, Fab, clickable icons

**Files:** Create `ButtonsScreen.bas`; edit `App.bas`.

- [ ] **Step 1: Write `ButtonsScreen.bas`**

```basic
Sub Class_Globals

End Sub

Public Sub Initialize

End Sub

Public Sub Build As Object
    Dim variants As UICard = App.SectionCard("Variantes de botón", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.Button("Primario").BackgroundColor(App.Theme.Accent) _
                .TextColor(App.Theme.AccentText) _
                .CornerRadius(App.Theme.ButtonRadius) _
                .OnClick(Me, "Primary_Click")) _
            .AddChild(UI.Button("Contorno").BackgroundColor(App.Theme.Surface) _
                .TextColor(App.Theme.Accent).CornerRadius(App.Theme.ButtonRadius) _
                .Border(App.Theme.BorderWidth, App.Theme.Border) _
                .OnClick(Me, "Outlined_Click")) _
            .AddChild(UI.Button("Esquinas suaves").BackgroundColor( _
                App.Theme.SurfaceVariant).TextColor(App.Theme.PrimaryText) _
                .CornerRadius(App.Theme.RadiusExtraLarge) _
                .OnClick(Me, "Pill_Click")))
    Dim icons As UICard = App.SectionCard("Iconos accionables", _
        UI.Row(Null).Spacing(24dip).MainAxisAlignment("center") _
            .AddChild(UI.IconFA(Chr(0xF043)).Size(24).Color(App.Theme.Info) _
                .OnClick(Me, "Icon1_Click")) _
            .AddChild(UI.IconMaterial(Chr(0xE88A)).Size(24) _
                .Color(App.Theme.Negative).OnClick(Me, "Icon2_Click")) _
            .AddChild(UI.Icon(Chr(9733))).Size(24).Color(App.Theme.Accent) _
                .OnClick(Me, "Icon3_Click")))
    Return App.ScreenScaffold("Botones", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip) _
            .AddChild(variants) _
            .AddChild(icons) _
            .AddChild(UI.Fab("+").OnClick(Me, "Fab_Click")))))
End Sub

Private Sub Primary_Click : App.Feedback("Primario") : End Sub
Private Sub Outlined_Click : App.Feedback("Contorno") : End Sub
Private Sub Pill_Click : App.Feedback("Pill") : End Sub
Private Sub Icon1_Click : App.Feedback("Gotero") : End Sub
Private Sub Icon2_Click : App.Feedback("Material favorito") : End Sub
Private Sub Icon3_Click : App.Feedback("Estrella unicode") : End Sub
Private Sub Fab_Click : App.Feedback("FAB pulsado") : End Sub
```

**Correction:** paren balance bug in `icons` — third child closes wrongly. Correct block:

```basic
            .AddChild(UI.Icon(Chr(9733)).Size(24).Color(App.Theme.Accent) _
                .OnClick(Me, "Icon3_Click")))
```

Add to `App.bas`:

```basic
'Feedback helper used by demo handlers (snackbar over the app root).
Public Sub Feedback(MessageText As String)
    Snack(mRoot, MessageText)
End Sub
```

- [ ] **Step 2: Wire into `App`** — `Public BtnScr As ButtonsScreen`; `BtnScr.Initialize` in `Start`; in `RegisterRoutes`:

```basic
    RegisterScreen("buttons", BtnScr.Build, Chr(0xF25A), "Botones", _
        "Botones, FAB e iconos con acciones")
```

- [ ] **Step 3: Verify** — 3 commands, 0 errors, tile #2 navigates, every control snacks.

---

### Task 5: `InputsScreen` — Input, Switch, Checkbox, Radio

**Files:** Create `InputsScreen.bas`; edit `App.bas`.

- [ ] **Step 1: Write `InputsScreen.bas`**

```basic
Sub Class_Globals
    Private CountState As UIState      'chars typed
    Private SwitchState As UIState     'switch checked
    Private ChecksState As UIState     'checkbox summary
    Private Check1, Check2 As Boolean
    Private RadioState As UIState      'selected radio value
End Sub

Public Sub Initialize
    CountState = UI.State("0 caracteres")
    SwitchState = UI.State(False)
    ChecksState = UI.State("Nada marcado")
    RadioState = UI.State("email")
End Sub

Public Sub Build As Object
    Dim inputs As UICard = App.SectionCard("Entrada de texto", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.Input("Nombre de usuario") _
                .OnChanged(Me, "User_TextChanged")) _
            .AddChild(UI.Input("Contraseña").PasswordMode(True)) _
            .AddChild(UI.Text("").BindText(CountState) _
                .Size(App.Theme.LabelLarge).Color(App.Theme.MutedText)))
    Dim toggles As UICard = App.SectionCard("Interruptores", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.Switch("Modo oscuro automático") _
                .BindChecked(SwitchState).OnChanged(Me, "Switch_Changed")) _
            .AddChild(UI.Checkbox("Aceptar términos") _
                .OnChanged(Me, "Check1_Changed")) _
            .AddChild(UI.Checkbox("Recibir novedades") _
                .OnChanged(Me, "Check2_Changed")) _
            .AddChild(UI.Text("").BindText(ChecksState) _
                .Size(App.Theme.BodySmall).Color(App.Theme.SecondaryText)))
    Dim radios As UICard = App.SectionCard("Grupo de radio", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(RadioButtons) _
            .AddChild(UI.Text("").BindText(RadioState) _
                .Size(App.Theme.BodySmall).Color(App.Theme.Accent)))
    Return App.ScreenScaffold("Entradas", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip) _
            .AddChild(inputs).AddChild(toggles).AddChild(radios))))
End Sub

Private Sub RadioButtons As UIRadioGroup
    Dim g As UIRadioGroup = NewRadioGroup
    g.AddOption("email", "Correo electrónico")
    g.AddOption("sms", "Mensaje SMS")
    g.AddOption("push", "Notificación push")
    g.Selected("email")
    g.OnSelected(Me, "Radio_Selected")
    Return g
End Sub

'Documented exception: UIRadioGroup has no factory.
Private Sub NewRadioGroup As UIRadioGroup
    Dim g As UIRadioGroup
    g.Initialize
    Return g
End Sub

Private Sub User_TextChanged(NewText As String)
    CountState.SetState(NewText.Length & " caracteres")
End Sub

Private Sub Switch_Changed(Checked As Boolean)
    SwitchState.SetState(Checked)
End Sub

Private Sub Check1_Changed(Checked As Boolean)
    Check1 = Checked
    RefreshChecks
End Sub

Private Sub Check2_Changed(Checked As Boolean)
    Check2 = Checked
    RefreshChecks
End Sub

Private Sub RefreshChecks
    Dim n As Int = 0
    If Check1 Then n = n + 1
    If Check2 Then n = n + 1
    If n = 0 Then
        ChecksState.SetState("Nada marcado")
    Else
        ChecksState.SetState(n & " de 2 marcados")
    End If
End Sub

Private Sub Radio_Selected(SelectedValue As String)
    RadioState.SetState("Canal: " & SelectedValue)
End Sub
```

- [ ] **Step 2: Wire into `App`** — `Public InputsScr As InputsScreen`; init; route:

```basic
    RegisterScreen("inputs", InputsScr.Build, Chr(0xF11C), "Entradas", _
        "Input, Switch, Checkbox y grupos de radio")
```

- [ ] **Step 3: Verify** — 0 errors; counters/binds react live; radio prints selection.

---

### Task 6: `LayoutScreen` — containers showcase

**Files:** Create `LayoutScreen.bas`; edit `App.bas`.

- [ ] **Step 1: Write `LayoutScreen.bas`**

```basic
Sub Class_Globals
    Private ExtraVisible As UIState
    Private ShowingExtra As Boolean
End Sub

Public Sub Initialize
    ExtraVisible = UI.State(True)
    ShowingExtra = True
End Sub

Public Sub Build As Object
    Dim aligns As UICard = App.SectionCard("Alineaciones", _
        UI.Column(Null).Spacing(8dip) _
            .AddChild(BoxRow("spaceBetween")) _
            .AddChild(BoxRow("spaceEvenly")) _
            .AddChild(BoxRow("center")))
    Dim stack As UICard = App.SectionCard("Stack (eje Z)", _
        UI.Stack(Null).AddChild(Swatch(200dip, App.Theme.SurfaceVariant)) _
            .AddChild(SwatchAt(140dip, App.Theme.SecondaryBar)) _
            .AddChild(SwatchAt(80dip, App.Theme.Accent)))
    Dim flow As UICard = App.SectionCard("Flujo con Expanded + Scroll", _
        UI.Column(Null).Spacing(8dip) _
            .AddChild(UI.Text("Cabecera fija").Size(App.Theme.TitleLarge) _
                .Color(App.Theme.PrimaryText)) _
            .AddChild(UI.Expanded(UI.Scroll(UI.Column(FillerRows)))) _
            .AddChild(UI.Divider) _
            .AddChild(UI.Text("Pie fijo").Size(App.Theme.LabelLarge) _
                .Color(App.Theme.MutedText)))
    Dim vis As UICard = App.SectionCard("Visibilidad reactiva", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.Button("Alternar bloque extra") _
                .BackgroundColor(App.Theme.SecondaryBar) _
                .TextColor(App.Theme.DashboardBarText) _
                .CornerRadius(App.Theme.ButtonRadius) _
                .OnClick(Me, "ToggleExtra_Click")) _
            .AddChild(UI.Visibility(Swatch(56dip, App.Theme.Info)) _
                .BindVisible(ExtraVisible)) _
            .AddChild(UI.Space(4dip)) _
            .AddChild(UI.Divider) _
            .AddChild(UI.Padding(Only0, Swatch(24dip, App.Theme.Negative))))
    Return App.ScreenScaffold("Layout", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip) _
            .AddChild(aligns).AddChild(stack).AddChild(flow).AddChild(vis))))
End Sub

'UIPadding has no Only0 constant — see correction.
Private Sub BoxRow(AxisAlign As String) As UIRow
    Return UI.Row(Null).MainAxisAlignment(AxisAlign).Spacing(8dip) _
        .AddChild(Swatch(48dip, App.Theme.Accent)) _
        .AddChild(Swatch(48dip, App.Theme.Info)) _
        .AddChild(Swatch(48dip, App.Theme.Negative))
End Sub

Private Sub FillerRows As List
    Dim l As List
    l.Initialize
    For i = 1 To 12
        l.Add(UI.Text("Elemento de scroll " & i) _
            .Size(App.Theme.BodyMedium).Color(App.Theme.SecondaryText))
    Next
    Return l
End Sub

Private Sub Swatch(SizeDim As Int, FillColor As Int) As UIPlaceholder
    Dim p As UIPlaceholder
    p.Initialize
    p.FallbackSize(SizeDim, SizeDim).Color(FillColor) _
        .StrokeWidth(0).ApplyTheme(App.Theme)
    Return p
End Sub

Private Sub SwatchAt(SizeDim As Int, FillColor As Int) As UIPlaceholder
    Return Swatch(SizeDim, FillColor)
End Sub

Private Sub ToggleExtra_Click
    ShowingExtra = Not(ShowingExtra)
    ExtraVisible.SetState(ShowingExtra)
End Sub
```

**Corrections before writing:**
1. Remove the invalid `UI.Padding(Only0, ...)` line and its comment entirely (padding demo not needed).
2. `Swatch` must NOT call `.ApplyTheme` after setting an explicit `Color` (override precedence makes it harmless but noisy); final version drops `.ApplyTheme(App.Theme)`:
   `p.FallbackSize(SizeDim, SizeDim).Color(FillColor).StrokeWidth(0)`
3. `FallbackWidth/FallbackHeight` exist; `FallbackSize(W,H)` confirmed via b4x-mcp — keep.

- [ ] **Step 2: Wire into `App`** — `Public LayoutScr As LayoutScreen`; init; route:

```basic
    RegisterScreen("layout", LayoutScr.Build, Chr(0xF009), "Layout", _
        "Columnas, filas, stack, scroll y visibilidad")
```

- [ ] **Step 3: Verify** — 0 errors; alignments visibly differ; toggle hides/shows swatch; scroll flows under fixed header/footer.

---

### Task 7: `MediaScreen` — images, progress, native views, placeholder

**Files:** Create `MediaScreen.bas`; create asset `examples/b4x_kitchen_sink/Shared Files/logo.png`; edit `App.bas`.

- [ ] **Step 1: Create the asset**

```powershell
$b64 = "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAJUlEQVR42mNkYPhfz0BEYBxVOKpwVOGowlGFowpHFY4qHFVIfYUAyMwF0T4KZ2QAAAAASUVORK5CYII="
[IO.File]::WriteAllBytes("$PWD\examples\b4x_kitchen_sink\Shared Files\logo.png", [Convert]::FromBase64String($b64))
```

(8×8 purple PNG placeholder — enough to prove the asset pipeline.)

- [ ] **Step 2: Write `MediaScreen.bas`**

```basic
Sub Class_Globals
    Private BarState As UIState
    Private NetImg As UIImage
    Private Mover As B4XView
End Sub

Public Sub Initialize
    BarState = UI.State(30)
End Sub

Public Sub Build As Object
    Dim imgs As UICard = App.SectionCard("Imágenes", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.ImageAsset("logo.png").Width(64).Height(64).Fit("center")) _
            .AddChild(NetworkImage) _
            .AddChild(UI.Text("Imagen de red con callbacks OnLoaded/OnError", _
                ).Size(App.Theme.BodySmall).Color(App.Theme.MutedText)))
    Dim bars As UICard = App.SectionCard("Progreso", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.Progress(30).BindValue(BarState)) _
            .AddChild(UI.Progress(0).Indeterminate(True)) _
            .AddChild(UI.Row(Null).Spacing(8dip) _
                .AddChild(UI.Button("-10").OnClick(Me, "Minus_Click")) _
                .AddChild(UI.Button("+10").OnClick(Me, "Plus_Click"))))
    Dim native As UICard = App.SectionCard("Vista nativa envuelta", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(NativeSeekBar) _
            .AddChild(NativeMover))
    Dim ph As UICard = App.SectionCard("Placeholder", PlaceholderSwatch)
    Return App.ScreenScaffold("Medios", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip) _
            .AddChild(imgs).AddChild(bars).AddChild(native).AddChild(ph))))
End Sub

Private Sub NetworkImage As UIImage
    NetImg = UI.ImageNetwork("https://picsum.photos/240/120") _
        .Width(240).Height(120).Fit("center") _
        .OnLoaded(Me, "Net_Loaded").OnError(Me, "Net_Error")
    Return NetImg
End Sub

'SeekBar nativa envuelta con UINative (tamaño natural explícito).
Private Sub NativeSeekBar As UINative
    Dim sb As SeekBar
    sb.Initialize("sb")
    sb.Value = 30
    Return UI.Native(sb, 200dip, 30dip)
End Sub

'Caja nativa que luego anima OverlaysScreen-style demos aquí mismo.
Private Sub NativeMover As UINative
    Dim pnl As Panel
    pnl.Initialize("mover")
    pnl.Color = App.Theme.Accent
    Mover = pnl
    Return UI.Native(pnl, 80dip, 24dip)
End Sub

Private Sub PlaceholderSwatch As UIPlaceholder
    Dim p As UIPlaceholder
    p.Initialize
    p.FallbackSize(200dip, 48dip).Color(App.Theme.SurfaceVariant) _
        .StrokeWidth(2)
    Return p
End Sub

Private Sub Minus_Click
    BarState.SetState(Max(0, BarState.GetState - 10))
End Sub

Private Sub Plus_Click
    BarState.SetState(Min(100, BarState.GetState + 10))
End Sub

Private Sub Net_Loaded
    App.Feedback("Imagen cargada")
End Sub

Private Sub Net_Error
    App.Feedback("Error cargando imagen")
End Sub

Private Sub sb_ValueChanged (Value As Int, UserChanged As Boolean)
    If UserChanged Then BarState.SetState(Value)
End Sub
```

**Corrections before writing:**
1. First `AddChild` in `imgs` has stray comma: `UI.Text("...",` → fix to single-string call.
2. `Max/Min` are B4A keywords — valid.
3. `sb_ValueChanged` signature is the native SeekBar event (delegated through UINative's raw view) — keep; if compile complains about undeclared event prefix, rename sub to match `"sb"` exactly as written (it does).

- [ ] **Step 3: Wire into `App`** — `Public MediaScr As MediaScreen`; init; route:

```basic
    RegisterScreen("media", MediaScr.Build, Chr(0xF03E), "Medios", _
        "Imágenes, progreso, vistas nativas y placeholders")
```

- [ ] **Step 4: Verify** — 0 errors; asset + network image render; seekbar drives bound bar; +/- buttons work.

---

### Task 8: `ListScreen` — virtualized UIListView

**Files:** Create `ListScreen.bas`; edit `App.bas`.

- [ ] **Step 1: Write `ListScreen.bas`**

```basic
Sub Class_Globals
    Private Data As List
End Sub

Public Sub Initialize
    Data.Initialize
    For i = 1 To 200
        Data.Add("Contacto " & i)
    Next
End Sub

Public Sub Build As Object
    Dim lst As UIListView = UI.ListView(Data) _
        .ItemHeight(52dip).Overscan(4) _
        .CreateItem(Me, "CreateRow").BindItem(Me, "BindRow")
    Dim controls As UICard = App.SectionCard("Controles de lista", _
        UI.Row(Null).Spacing(8dip) _
            .AddChild(UI.Button("Arriba").OnClick(Me, "Top_Click")) _
            .AddChild(UI.Button("Abajo").OnClick(Me, "Bottom_Click")) _
            .AddChild(UI.Button("Renombrar #1").OnClick(Me, "Rename_Click")))
    Return App.ScreenScaffold("Lista virtualizada", UI.Padding(16dip, _
        UI.Column(Null).Spacing(12dip) _
            .AddChild(controls) _
            .AddChild(UI.Expanded(lst))))
End Sub

'CreateItem callback: build ONE pooled row (called per recycled row).
Private Sub CreateRow (Index As Int) As Object
    Return UI.Row(Null).Spacing(12dip).CrossAxisAlignment("center") _
        .AddChild(UI.IconFA(Chr(0xF007)).Size(16).Color(App.Theme.Accent)) _
        .AddChild(UI.Text("").Size(App.Theme.BodyLarge) _
            .Color(App.Theme.PrimaryText))
End Sub

'BindItem callback: fill the pooled row for Index.
Private Sub BindRow (Index As Int, ItemView As Object)
    Dim row As UIRow = ItemView
    Dim lbl As UILabel = row.GetChildAt(1)
    lbl.SetText(Data.Get(Index))
End Sub

Private Sub Top_Click : App.Feedback("ScrollTo(0)") : End Sub 'impl below
Private Sub Bottom_Click : App.Feedback("final") : End Sub

Private Sub Rename_Click
    Data.Set(0, "Contacto ACTUALIZADO")
    NotifyChanged
    App.Feedback("Item 1 renombrado")
End Sub
```

**Corrections before writing:**
1. `UIListView` API (b4x-mcp) exposes `ScrollTo(Position)`/`NotifyDataSetChanged()` as **instance methods**, so the list must survive `Build`. Move creation to `Class_Globals`-adjacent lifecycle: add field `Private lst As UIListView`; create it in `Initialize`; `Build` reuses `lst` (fresh `Items(Data)` chain each build). Final relevant parts:

```basic
Sub Class_Globals
    Private Data As List
    Private lst As UIListView
End Sub

Public Sub Initialize
    Data.Initialize
    For i = 1 To 200
        Data.Add("Contacto " & i)
    Next
    lst = UI.ListView(Data).ItemHeight(52dip).Overscan(4) _
        .CreateItem(Me, "CreateRow").BindItem(Me, "BindRow")
End Sub
```

…and inside `Build`, replace the local creation with `UI.Expanded(lst)` plus a first-run guard not needed (factory assignment in Initialize happens once per instance; instances live in `App` forever).

2. `row.GetChildAt(1)` / `lbl.SetText` are NOT in the verified API. Verified alternative from b4x-mcp: `UILabel.BindText` + `UIState` per row is heavy; correct pooling-friendly path: store the label via `GetView` is equally unverified. **Safe final approach:** rows carry their OWN binding — `CreateRow` returns a row whose label binds a per-index state kept in a `Map` of states; `BindRow` writes `Data.Get(Index)` into that state. Replace `CreateRow/BindRow` with:

```basic
Private States As Map 'Class_Globals: Private States As Map

'in Initialize: States.Initialize

Private Sub StateFor(Index As Int) As UIState
    If States.ContainsKey(Index) = False Then
        States.Put(Index, UI.State(Data.Get(Index)))
    End If
    Return States.Get(Index)
End Sub

Private Sub CreateRow (Index As Int) As Object
    Return UI.Row(Null).Spacing(12dip).CrossAxisAlignment("center") _
        .AddChild(UI.IconFA(Chr(0xF007)).Size(16).Color(App.Theme.Accent)) _
        .AddChild(UI.Text("").BindText(StateFor(Index)) _
            .Size(App.Theme.BodyLarge).Color(App.Theme.PrimaryText))
End Sub

Private Sub BindRow (Index As Int, ItemView As Object)
    StateFor(Index).SetState(Data.Get(Index))
End Sub

Private Sub Top_Click
    lst.ScrollTo(0)
End Sub

Private Sub Rename_Click
    Data.Set(0, "Contacto ACTUALIZADO")
    StateFor(0).SetState(Data.Get(0))
    NotifyDataSetChangedSafe
    App.Feedback("Item 1 renombrado")
End Sub

Private Sub NotifyDataSetChangedSafe
    lst.NotifyDataSetChanged
End Sub

Private Sub Bottom_Click
    lst.ScrollTo(200 * 52dip)
End Sub
```

(`BindRow` keeps its signature — required by the pool contract even though states do the work.)

- [ ] **Step 2: Wire into `App`** — `Public ListScr As ListScreen`; init; route:

```basic
    RegisterScreen("list", ListScr.Build, Chr(0xF03A), "Lista", _
        "ListView virtualizada con pooling de filas")
```

- [ ] **Step 3: Verify** — smooth 200-item scroll, reuse without flicker, rename + scrollTo work.

---

### Task 9: `StateScreen` — one state, many widgets

**Files:** Create `StateScreen.bas`; edit `App.bas`.

- [ ] **Step 1: Write `StateScreen.bas`**

```basic
Sub Class_Globals
    Private Counter As UIState
End Sub

Public Sub Initialize
    Counter = UI.State(0)
End Sub

Public Sub Build As Object
    Dim card As UICard = App.SectionCard("Un estado, tres widgets", _
        UI.Column(Null).Spacing(14dip) _
            .AddChild(UI.Text("").BindText(Counter) _
                .Size(64).Color(App.Theme.PrimaryText)) _
            .AddChild(UI.Progress(0).BindValue(Counter)) _
            .AddChild(UI.Button("Valor desde estado: ver etiqueta") _
                .BindText(Counter) _ 
                .BackgroundColor(App.Theme.SecondaryBar) _
                .TextColor(App.Theme.DashboardBarText) _
                .CornerRadius(App.Theme.ButtonRadius)))
    Dim actions As UIRow = UI.Row(Null).Spacing(12dip).MainAxisAlignment("center") _
        .AddChild(UI.Button("−").OnClick(Me, "Dec_Click")) _
        .AddChild(UI.Button("+").OnClick(Me, "Inc_Click")) _
        .AddChild(UI.Button("Reset").OnClick(Me, "Reset_Click"))
    Return App.ScreenScaffold("Estado", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip).AddChild(card).AddChild(actions))))
End Sub

Private Sub Inc_Click
    Counter.SetState(Min(100, Counter.GetState + 1))
End Sub

Private Sub Dec_Click
    Counter.SetState(Max(0, Counter.GetState - 1))
End Sub

Private Sub Reset_Click
    Counter.SetState(0)
End Sub
```

**Correction:** trailing `_ ` after `.BindText(Counter)` followed by property setters is legal chaining BUT the stray space before end-of-comment marker in plan text must not reach the file; ensure line reads `...BindText(Counter) _`. Also numbers normalize to Double → label shows `0`,`1`… never `1.0` (library guarantee).

- [ ] **Step 2: Wire into `App`** — `Public StateScr As StateScreen`; init; route:

```basic
    RegisterScreen("state", StateScr.Build, Chr(0xF0C7), "Estado", _
        "UIState compartido entre varios widgets")
```

- [ ] **Step 3: Verify** — label/button/progress move together; persists across theme toggle (instance survives).

---

### Task 10: `AsyncScreen` — UIAsyncState machine

**Files:** Create `AsyncScreen.bas`; edit `App.bas`.

- [ ] **Step 1: Write `AsyncScreen.bas`**

```basic
Sub Class_Globals
    Private Fetch As UIAsyncState
    Private LoadingVis, ContentVis, ErrorVis As UIState
    Private ResultState As UIState
End Sub

Public Sub Initialize
    Fetch.Initialize
    Fetch.Subscribe(Me, "Fetch_StateChanged")
    LoadingVis = UI.State(False)
    ContentVis = UI.State(False)
    ErrorVis = UI.State(False)
    ResultState = UI.State("")
End Sub

Public Sub Build As Object
    Dim card As UICard = App.SectionCard("Operación asíncrona simulada", _
        UI.Column(Null).Spacing(12dip) _
            .AddChild(UI.Visibility(UI.Column(Null) _
                    .AddChild(UI.Progress(0).Indeterminate(True)) _
                    .AddChild(UI.Text("Cargando...") _
                        .Size(App.Theme.BodyMedium).Color(App.Theme.MutedText))) _
                .BindVisible(LoadingVis)) _
            .AddChild(UI.Visibility(UI.Column(Null).Spacing(6dip) _
                    .AddChild(UI.Text("").BindText(ResultState) _
                        .Size(App.Theme.BodyLarge).Color(App.Theme.Info))) _) _
                .BindVisible(ContentVis)) _
            .AddChild(UI.Visibility(UI.Column(Null).Spacing(6dip) _
                    .AddChild(UI.Text("Algo falló. Inténtalo de nuevo.") _
                        .Size(App.Theme.BodyLarge).Color(App.Theme.Negative)) _
                    .AddChild(UI.Button("Reintentar").OnClick(Me, "Retry_Click"))) _
                .BindVisible(ErrorVis)) _
            .AddChild(UI.Row(Null).Spacing(8dip) _
                .AddChild(UI.Button("Cargar (éxito)").OnClick(Me, "LoadOk_Click")) _
                .AddChild(UI.Button("Cargar (error)").OnClick(Me, "LoadFail_Click"))))
    Return App.ScreenScaffold("Async", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip).AddChild(card))))
End Sub

Private Sub LoadOk_Click
    Fetch.Reset
    Fetch.SetLoading
    Sleep(1200)
    Fetch.SetSuccess("Datos recibidos a las " & DateTime.Time(DateTime.Now))
End Sub

Private Sub LoadFail_Click
    Fetch.Reset
    Fetch.SetLoading
    Sleep(900)
    Fetch.SetError("HTTP 500 simulado")
End Sub

Private Sub Retry_Click
    LoadOk_Click
End Sub

'Single subscriber drives all three visibility states (unidirectional).
Private Sub Fetch_StateChanged(State As UIAsyncState)
    LoadingVis.SetState(State.IsLoading)
    ErrorVis.SetState(State.IsError)
    If State.IsSuccess Then
        ResultState.SetState(State.GetValue)
    End If
    ContentVis.SetState(State.IsSuccess)
End Sub
```

**Correction:** stray `_)` in the Content branch — the correct fragment is:

```basic
            .AddChild(UI.Visibility(UI.Column(Null).Spacing(6dip) _
                    .AddChild(UI.Text("").BindText(ResultState) _
                        .Size(App.Theme.BodyLarge).Color(App.Theme.Info))) _
                .BindVisible(ContentVis)) _
```

- [ ] **Step 2: Wire into `App`** — `Public AsyncScr As AsyncScreen`; init; route:

```basic
    RegisterScreen("async", AsyncScr.Build, Chr(0xF021), "Async", _
        "Estados loading/success/error con UIAsyncState")
```

- [ ] **Step 3: Verify** — success path shows result, failure path shows error+retry, retry recovers.

---

### Task 11: `OverlaysScreen` — SnackBar, Dialog, Animation

**Files:** Create `OverlaysScreen.bas`; edit `App.bas`.

- [ ] **Step 1: Write `OverlaysScreen.bas`**

```basic
Sub Class_Globals
    Private DemoBox As UINative
    Private Dialog As UIAlertDialog
    Private DialogChoice As UIState
End Sub

Public Sub Initialize
    DialogChoice = UI.State("(sin elegir)")
End Sub

Public Sub Build As Object
    Dim snackCard As UICard = App.SectionCard("SnackBar", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.Button("Snack simple").OnClick(Me, "SimpleSnack_Click")) _
            .AddChild(UI.Button("Snack con acción").OnClick(Me, "ActionSnack_Click")))
    Dim dialogCard As UICard = App.SectionCard("Diálogo con contenido", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.Button("Abrir diálogo").OnClick(Me, "Dialog_Click")) _
            .AddChild(UI.Text("").BindText(DialogChoice) _
                .Size(App.Theme.BodySmall).Color(App.Theme.SecondaryText)))
    Dim animCard As UICard = App.SectionCard("Animación acotada", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(BuildDemoBox) _
            .AddChild(UI.Button("Animar caja").OnClick(Me, "Animate_Click")))
    Return App.ScreenScaffold("Overlays", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip) _
            .AddChild(snackCard).AddChild(dialogCard).AddChild(animCard))))
End Sub

Private Sub BuildDemoBox As UINative
    Dim pnl As Panel
    pnl.Initialize("")
    pnl.Color = App.Theme.Info
    DemoBox = UI.Native(pnl, 120dip, 32dip)
    Return DemoBox
End Sub

Private Sub SimpleSnack_Click
    App.Feedback("Esto es un snackbar")
End Sub

Private Sub ActionSnack_Click
    Dim s As UISnackBar = UI.Snack("Registro eliminado") _
        .Action("DESHACER", Me, "Undo_Click").Duration(2500)
    s.ApplyTheme(App.Theme)
    s.Show(App.RootView)
End Sub

Private Sub Undo_Click
    App.Feedback("Deshecho")
End Sub

Private Sub Dialog_Click
    Dialog = UI.Dialog _
        .Title("Confirmar suscripción") _
        .Message("Elige cómo continuar. Este diálogo incluye un widget declarativo.") _
        .Content(UI.Checkbox("No volver a preguntar")) _
        .PositiveButton("Aceptar", Me, "DialogAccept_Click") _
        .NegativeButton("Cancelar", Me, "DialogCancel_Click") _
        .DismissOnOutside(True)
    Dialog.ApplyTheme(App.Theme)
    Dialog.Show(App.RootView)
End Sub

Private Sub DialogAccept_Click
    DialogChoice.SetState("Elegiste Aceptar")
    App.Feedback("Diálogo aceptado")
End Sub

Private Sub DialogCancel_Click
    DialogChoice.SetState("Elegiste Cancelar")
End Sub

Private Sub Animate_Click
    Dim v As B4XView = DemoBox.GetView
    Dim a As UIAnimation = UI.Animation(v) _
        .MoveAndResize(0dip, 0dip, 200dip, 48dip) _
        .Duration(600).Easing("decelerate") _
        .OnCompleted(Me, "Anim_Done")
    a.Start
End Sub

Private Sub Anim_Done
    App.Feedback("Animación completada")
End Sub
```

**Corrections before writing:**
1. `UI.Dialog` factory **CONFIRMED** via `UI.bas:346` — `Public Sub Dialog As UIAlertDialog`, no parameters. The chained usage above is final; no fallback needed.
2. `App.RootView` — expose it: add to `App.bas`:

```basic
'Raised overlays (snacks with actions, dialogs) anchor to the app root.
Public Sub RootView As B4XView
    Return mRoot
End Sub
```

3. `UIAnimation.MoveAndResize` offsets are relative to the demo box's PARENT panel (the native wrapper), so `0dip,0dip` start is correct; sizes in dip literals are fine.

- [ ] **Step 2: Wire into `App`** — `Public OverlayScr As OverlaysScreen`; init; route:

```basic
    RegisterScreen("overlays", OverlayScr.Build, Chr(0xF08D), "Overlays", _
        "SnackBars, diálogos y animaciones")
```

- [ ] **Step 3: Verify** — all three overlay families behave; animation completes callback fires.

---

### Task 12: `NavigationScreen` — scaffold anatomy + bottom navigation

**Files:** Create `NavigationScreen.bas`; edit `App.bas`.

**Interfaces:** Consumes `UIBottomNavigationBar.AddItem/BindSelectedIndex/OnSelected`, scaffold `FloatingActionButtonLeft/Right`. Documents the GLOBAL `UINavigator` behavior (history/back) via live status card.

- [ ] **Step 1: Write `NavigationScreen.bas`**

```basic
Sub Class_Globals
    Private TabIndex As UIState
    Private TabLabel As UIState
End Sub

Public Sub Initialize
    TabIndex = UI.State(0)
    TabLabel = UI.State("Tab activo: inicio")
End Sub

Public Sub Build As Object
    Dim navCard As UICard = App.SectionCard("BottomNavigation bindeada", _
        UI.Column(Null).Spacing(10dip) _
            .AddChild(UI.Text("").BindText(TabLabel) _
                .Size(App.Theme.BodyMedium).Color(App.Theme.Accent)) _
            .AddChild(BottomTabs))
    Dim statusCard As UICard = App.SectionCard("UINavigator global (esta app)", _
        UI.Column(Null).Spacing(8dip) _
            .AddChild(UI.Text("Ruta actual: " & App.CurrentRoute) _
                .Size(App.Theme.BodyMedium).Color(App.Theme.SecondaryText)) _
            .AddChild(UI.Text("¿Se puede volver? " & App.Nav.CanGoBack) _
                .Size(App.Theme.BodySmall).Color(App.Theme.MutedText)) _
            .AddChild(UI.Button("Volver").OnClick(Me, "GoBack_Click")))
    Return App.ScreenScaffold("Navegación", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip) _
            .AddChild(statusCard) _
            .AddChild(navCard) _
            .AddChild(UI.Space(72dip)))) _
        .FloatingActionButtonLeft(UI.Fab(Chr(0xF00D)).OnClick(Me, "FabL_Click")) _
        .FloatingActionButtonRight(UI.Fab(Chr(0xF00B)).OnClick(Me, "FabR_Click")))
End Sub

Private Sub BottomTabs As UIBottomNavigationBar
    Dim bar As UIBottomNavigationBar = NewBottomBar
    bar.AddItem("inicio", Chr(0xF015), "Inicio")
    bar.AddItem("buscar", Chr(0xF002), "Buscar")
    bar.AddItem("perfil", Chr(0xF007), "Perfil")
    bar.BindSelectedIndex(TabIndex)
    bar.OnSelected(Me, "Tabs_Selected")
    bar.ShowInactiveLabels(True)
    bar.ApplyTheme(App.Theme)
    Return bar
End Sub

'UIBottomNavigationBar has no factory — documented exception #2.
Private Sub NewBottomBar As UIBottomNavigationBar
    Dim b As UIBottomNavigationBar
    b.Initialize
    Return b
End Sub

Private Sub Tabs_Selected(Index As Int, Id As String)
    TabLabel.SetState("Tab activo: " & Id & " (#" & Index & ")")
End Sub

Private Sub GoBack_Click
    App.HandleBack
End Sub

Private Sub FabL_Click : App.Feedback("FAB izquierdo") : End Sub
Private Sub FabR_Click : App.Feedback("FAB derecho") : End Sub
```

- [ ] **Step 2: Wire into `App`** — `Public NavScr As NavigationScreen`; init; route:

```basic
    RegisterScreen("navigation", NavScr.Build, Chr(0xF0AC), "Navegación", _
        "Scaffold completo, bottom navigation y estado del navigator")
```

- [ ] **Step 3: Verify** — tab taps update bound label WITHOUT rebuilding native views; both FABs visible over scroll; status reflects real route/back state.

---

### Task 13: `ThemeScreen` — seeds, mode toggle, token gallery

**Files:** Create `ThemeScreen.bas`; edit `App.bas`.

- [ ] **Step 1: Write `ThemeScreen.bas`**

```basic
Sub Class_Globals

End Sub

Public Sub Initialize

End Sub

Public Sub Build As Object
    Dim seeds As UICard = App.SectionCard("Semilla de esquema", SeedRow)
    Dim mode As UICard = App.SectionCard("Modo", _
        UI.Row(Null).Spacing(8dip) _
            .AddChild(UI.Button(IIf(App.Theme.IsDark, "Modo actual: oscuro", _
                "Modo actual: claro")).OnClick(Me, "Mode_Click")))
    Dim tokens As UICard = App.SectionCard("Tokens de color", TokenGrid)
    Return App.ScreenScaffold("Tema", UI.Scroll(UI.Padding(16dip, _
        UI.Column(Null).Spacing(16dip) _
            .AddChild(seeds).AddChild(mode).AddChild(tokens))))
End Sub

Private Sub SeedRow As UIRow
    Dim r As UIRow = UI.Row(Null).Spacing(8dip)
    r.AddChild(SeedButton(0xFF6558D3, "Violeta"))
    r.AddChild(SeedButton(0xFF00696E, "Teal"))
    r.AddChild(SeedButton(0xFF984061, "Rosa"))
    r.AddChild(SeedButton(0xFF6B5900? , "")) 'REMOVED — see correction
    Return r
End Sub
```

**Correction — final `SeedRow` (3 seeds, valid hex, per-seed handler via index-free explicit subs is impossible → use ONE sub + tag-free approach):** buttons cannot carry payload; give EACH seed its own event sub:

```basic
Private Sub SeedRow As UIRow
    Return UI.Row(Null).Spacing(8dip) _
        .AddChild(SeedButton(0xFF6558D3, "Violeta", "Seed1_Click")) _
        .AddChild(SeedButton(0xFF00696E, "Teal", "Seed2_Click")) _
        .AddChild(SeedButton(0xFF984061, "Rosa", "Seed3_Click"))
End Sub

Private Sub SeedButton(FillColor As Int, NameText As String, _
    Handler As String) As UIButton
    Return UI.Button(NameText).BackgroundColor(FillColor) _
        .TextColor(Colors.White).CornerRadius(App.Theme.RadiusSmall) _
        .OnClick(Me, Handler)
End Sub

Private Sub Seed1_Click : Recolor(0xFF6558D3) : End Sub
Private Sub Seed2_Click : Recolor(0xFF00696E) : End Sub
Private Sub Seed3_Click : Recolor(0xFF984061) : End Sub

Private Sub Recolor(SeedColor As Int)
    App.Theme.Scheme(SeedColor)
    App.RebuildNavigator
End Sub

Private Sub Mode_Click
    App.ToggleTheme
End Sub

Private Sub TokenGrid As UIColumn
    Return UI.Column(Null).Spacing(6dip) _
        .AddChild(TokenRow("Background", App.Theme.Background)) _
        .AddChild(TokenRow("Surface", App.Theme.Surface)) _
        .AddChild(TokenRow("SurfaceVariant", App.Theme.SurfaceVariant)) _
        .AddChild(TokenRow("HeroSurface", App.Theme.HeroSurface)) _
        .AddChild(TokenRow("Accent", App.Theme.Accent)) _
        .AddChild(TokenRow("Info", App.Theme.Info)) _
        .AddChild(TokenRow("Negative", App.Theme.Negative)) _
        .AddChild(TokenRow("SecondaryBar", App.Theme.SecondaryBar)) _
        .AddChild(TokenRow("DashboardBar", App.Theme.DashboardBar))
End Sub

Private Sub TokenRow(NameText As String, TokenColor As Int) As UIRow
    Return UI.Row(Null).Spacing(10dip).CrossAxisAlignment("center") _
        .AddChild(TokenSwatch(TokenColor)) _
        .AddChild(UI.Text(NameText).Size(App.Theme.BodySmall) _
            .Color(App.Theme.SecondaryText))
End Sub

'Token swatch = UIPlaceholder exception (#1) with themed border.
Private Sub TokenSwatch(TokenColor As Int) As UIPlaceholder
    Dim p As UIPlaceholder
    p.Initialize
    p.FallbackSize(44dip, 22dip).Color(TokenColor).StrokeWidth(1)
    Return p
End Sub
```

- [ ] **Step 2: Wire into `App`** — `Public ThemeScr As ThemeScreen`; init; route:

```basic
    RegisterScreen("theme", ThemeScr.Build, Chr(0xF042), "Tema", _
        "Semillas, modo claro/oscuro y tokens en vivo")
```

- [ ] **Step 3: Verify** — seed clicks recolor EVERYTHING (via RebuildNavigator), toggle flips mode, swatches always legible in both modes.

---

### Task 14: Final verification & polish sweep

**Files:** Read-only sweep + fixes across all modules.

- [ ] **Step 1: Static gate (repo-wide)**

```powershell
python check-b4x-source.py
```

Expected: 0 findings.

- [ ] **Step 2: Full bundle truth**

```powershell
b4x-mcp --cli get_codebundle --project-path examples/b4x_kitchen_sink/B4A/b4x_kitchen_sink.b4a
```

Review `warnings` + `errors` + `logs`; fix everything found (warnings allowed only if benign and noted).

- [ ] **Step 3: Dark-mode audit** — walk every screen mentally against token rules: no hard-coded `Colors.White/Black` outside `SeedButton` text; every explicit color comes from `App.Theme.*`. Fix violations.

- [ ] **Step 4: Optional device smoke test**

```powershell
b4x-mcp --cli run_b4a_on_device --project-path examples/b4x_kitchen_sink/B4A/b4x_kitchen_sink.b4a
```

Read `logcat` for runtime exceptions; confirm home → each route → back → theme toggle → revisit route keeps state.

- [ ] **Step 5: Update spec status** — mark open items resolved in `docs/superpowers/specs/2026-08-22-b4x-kitchen-sink-design.md` (UIPlaceholder = no factory, exception confirmed; UINavigator re-registration semantics documented from source).
