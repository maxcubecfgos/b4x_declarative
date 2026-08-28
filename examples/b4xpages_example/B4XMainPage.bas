B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\Shared Files" "..\Files"
#End Region

#Macro: Title, Export B4XPages, ide://run?File=%B4X%\Zipper.jar&Args=%PROJECT_NAME%.zip

'PackPal - Travel Checklist
'Demonstrates DeclarativeUI: navigation, forms, progress, themes and
'data-driven screen rebuilds - cross-platform (B4A + B4J).

Sub Class_Globals
	Private Root As B4XView
	Private Nav As UINavigator
	Private Theme As UITheme

	Private Trips As List
	Private CurrentTripIndex As Int

	Private AddTripNameInput As UIInput
	Private AddItemNameInput As UIInput

	' Widget-to-index lookup. Native views are not touched before mount,
	' so the association lives on the declarative widget (used via Sender).
	Private TripIndexByButton As Map
	Private ItemIndexByButton As Map

	Private IsDark As Boolean
	Private WindowBar As UIWindowBar ' desktop chrome (B4J only)
	Private WindowBarHeight As Int
End Sub

Public Sub Initialize
	Theme = UI.Theme(UI.THEME_LIGHT)
	Trips.Initialize
	TripIndexByButton.Initialize
	ItemIndexByButton.Initialize
	IsDark = False
	WindowBarHeight = 36dip
	CurrentTripIndex = -1
	SeedSampleData
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	BuildNavigator
End Sub

' Navigator host pattern (GUIDE §19): explicit bounds so it can be
' re-sized later. On Android the page root may be 0-sized here; the
' B4XPage_Resize handler below fixes the bounds as soon as they exist.
Private Sub BuildNavigator
	UI.Unmount(Nav)
	Nav = UI.Navigator _
		.AddScreen("trips",   BuildTripListScreen) _
		.AddScreen("detail",  BuildTripDetailScreen) _
		.AddScreen("addTrip", BuildAddTripScreen) _
		.AddScreen("addItem", BuildAddItemScreen) _
		.ApplyTheme(Theme)
	Dim topInset As Int = 0
	#If B4J
	BuildWindowBar
	topInset = WindowBarHeight
	#End If
	Nav.SetParent(Root)
	Nav.SetPosition(0, topInset)
	Nav.SetSize(Max(1, Root.Width), Max(1, Root.Height - topInset))
	Nav.Render
End Sub

' Desktop window chrome: title bar with close/minimize/maximize + dragging.
#If B4J
Private Sub BuildWindowBar
	UI.Unmount(WindowBar)
	WindowBar = UI.WindowBar("PackPal - Travel Checklist") _
		.BarColor(Theme.DashboardBar) _
		.TitleColor(Theme.DashboardBarText) _
		.ButtonColor(Theme.DashboardBarText) _
		.FormTarget(B4XPages.GetNativeParent(Me))
	WindowBar.SetParent(Root)
	WindowBar.SetPosition(0, 0)
	WindowBar.SetSize(Max(1, Root.Width), WindowBarHeight)
	WindowBar.Render
End Sub
#End If

' Fires whenever the page content area changes (desktop resizes).
Private Sub B4XPage_Resize (Width As Int, Height As Int)
	If Nav = Null Then Return
	If Nav.IsInitialized = False Then Return
	If Width <= 0 Or Height <= 0 Then Return
	Dim topInset As Int = 0
	#If B4J
	If WindowBar <> Null Then
		If WindowBar.IsInitialized Then
			WindowBar.SetSize(Width, WindowBarHeight)
			WindowBar.Render
			topInset = WindowBarHeight
		End If
	End If
	#End If
	Nav.SetPosition(0, topInset)
	Nav.SetSize(Width, Max(1, Height - topInset))
	Nav.Render
End Sub

' ====================  THEME  ====================

Private Sub OnToggleTheme
	IsDark = Not(IsDark)
	Theme = UI.Theme(IIf(IsDark, UI.THEME_DARK, UI.THEME_LIGHT))
	BuildNavigator
End Sub

Private Sub ThemeGlyph As String
	Return IIf(IsDark, Chr(0x2600), Chr(0x263E)) ' sun / crescent moon
End Sub

' Data changed: re-register the route with a freshly built tree.
' UINavigator.AddScreen replaces the stored widget and re-renders immediately
' when that route is the currently mounted screen.
Private Sub RefreshScreen(Name As String)
	Select Name
		Case "trips"
			Nav.AddScreen("trips", BuildTripListScreen)
		Case "detail"
			Nav.AddScreen("detail", BuildTripDetailScreen)
	End Select
End Sub

' ====================  SCREENS  ====================

Private Sub BuildTripListScreen As UIScaffold
	TripIndexByButton.Clear
	Dim body As UIColumn = UI.Column(Null) _
		.Spacing(12dip) _
		.AddChild(UI.Text("Your travel checklists").Size(14).Color(Theme.MutedText))
	For i = 0 To Trips.Size - 1
		body.AddChild(TripCard(i))
	Next
	Return UI.Scaffold(UI.Padding(16dip, UI.Scroll(body))) _
		.AppBar(UI.AppBar("PackPal") _
		.Action(UI.Icon(ThemeGlyph).Size(20).Color(Theme.DashboardBarText).OnClick(Me, "OnToggleTheme"))) _
		.FloatingActionButtonRight(UI.Fab("+").OnClick(Me, "OnAddTripClick")) _
		.ApplyTheme(Theme)
End Sub

Private Sub TripCard(Index As Int) As UICard
	Dim trip As Map = Trips.Get(Index)
	Dim items As List = trip.Get("items")
	Dim checkedCount As Int = CountChecked(items)
	Dim pct As Int = Round(checkedCount * 100 / Max(1, items.Size))
	Dim openBtn As UIButton = UI.Button(trip.Get("name")) _
		.BackgroundColor(Theme.Surface) _
		.TextColor(Theme.PrimaryText) _
		.TextSize(18) _
		.OnClick(Me, "OnTripClick")
	TripIndexByButton.Put(openBtn, Index)
	Return UI.Card(UI.Column(Null) _
		.Spacing(6dip) _
		.AddChild(openBtn) _
		.AddChild(UI.Progress(pct)) _
		.AddChild(UI.Text(checkedCount & " of " & items.Size & " packed").Size(13).Color(Theme.MutedText))) _
		.BackgroundColor(Theme.Surface) _
		.CornerRadius(Theme.CardRadius)
End Sub

Private Sub BuildTripDetailScreen As UIScaffold
	If CurrentTripIndex < 0 Or CurrentTripIndex >= Trips.Size Then CurrentTripIndex = 0
	ItemIndexByButton.Clear
	Dim trip As Map = Trips.Get(CurrentTripIndex)
	Dim body As UIColumn = UI.Column(Null) _
		.Spacing(8dip) _
		.AddChild(UI.Button(Chr(0x2190) & "  Back") _
			.BackgroundColor(Theme.Background) _
			.TextColor(Theme.Accent) _
			.OnClick(Me, "OnDetailBack"))
	For i = 0 To GetCurrentItems.Size - 1
		body.AddChild(ItemRow(i))
	Next
	Return UI.Scaffold(UI.Padding(16dip, UI.Scroll(body))) _
		.AppBar(UI.AppBar(trip.Get("name")) _
		.Action(UI.Icon(ThemeGlyph).Size(20).Color(Theme.DashboardBarText).OnClick(Me, "OnToggleTheme"))) _
		.FloatingActionButtonRight(UI.Fab("+").OnClick(Me, "OnAddItemClick")) _
		.ApplyTheme(Theme)
End Sub

Private Sub ItemRow(Index As Int) As UIButton
	Dim item As Map = GetCurrentItems.Get(Index)
	Dim isChecked As Boolean = item.GetDefault("checked", False)
	Dim row As UIButton = UI.Button(IIf(isChecked, Chr(0x2611) & "  ", Chr(0x2610) & "  ") & item.Get("name")) _
		.BackgroundColor(IIf(isChecked, Theme.Accent, Theme.Surface)) _
		.TextColor(IIf(isChecked, Theme.AccentText, Theme.PrimaryText)) _
		.CornerRadius(12dip) _
		.OnClick(Me, "OnToggleItem")
	ItemIndexByButton.Put(row, Index)
	Return row
End Sub

Private Sub BuildAddTripScreen As UIScaffold
	AddTripNameInput = UI.Input("Trip name") _
		.BackgroundColor(Theme.Surface) _
		.CornerRadius(12dip)
	Return UI.Scaffold(UI.Padding(16dip, UI.Column(Null) _
		.Spacing(12dip) _
		.AddChild(UI.Button(Chr(0x2190) & "  Back") _
			.BackgroundColor(Theme.Background) _
			.TextColor(Theme.Accent) _
			.OnClick(Me, "OnAddBack")) _
		.AddChild(AddTripNameInput) _
		.AddChild(UI.Space(8dip)) _
		.AddChild(UI.Button("Create Trip") _
			.BackgroundColor(Theme.Accent) _
			.TextColor(Theme.AccentText) _
			.CornerRadius(12dip) _
			.OnClick(Me, "OnCreateTrip")))) _
		.AppBar(UI.AppBar("New Trip") _
		.Action(UI.Icon(ThemeGlyph).Size(20).Color(Theme.DashboardBarText).OnClick(Me, "OnToggleTheme"))) _
		.ApplyTheme(Theme)
End Sub

Private Sub BuildAddItemScreen As UIScaffold
	AddItemNameInput = UI.Input("Item name") _
		.BackgroundColor(Theme.Surface) _
		.CornerRadius(12dip)
	Return UI.Scaffold(UI.Padding(16dip, UI.Column(Null) _
		.Spacing(12dip) _
		.AddChild(UI.Button(Chr(0x2190) & "  Back") _
			.BackgroundColor(Theme.Background) _
			.TextColor(Theme.Accent) _
			.OnClick(Me, "OnAddBack")) _
		.AddChild(AddItemNameInput) _
		.AddChild(UI.Space(8dip)) _
		.AddChild(UI.Button("Add Item") _
			.BackgroundColor(Theme.Accent) _
			.TextColor(Theme.AccentText) _
			.CornerRadius(12dip) _
			.OnClick(Me, "OnCreateItem")))) _
		.AppBar(UI.AppBar("Add Item") _
		.Action(UI.Icon(ThemeGlyph).Size(20).Color(Theme.DashboardBarText).OnClick(Me, "OnToggleTheme"))) _
		.ApplyTheme(Theme)
End Sub

' ====================  CALLBACKS  ====================

Private Sub OnAddTripClick
	Nav.NavigateTo("addTrip")
End Sub

' Consumes the Android hardware back while virtual history exists.
' Called from Main.Activity_KeyPress before the B4XPages delegate.
Public Sub HandleBack As Boolean
	If Nav = Null Then Return False
	If Nav.IsInitialized = False Then Return False
	Return Nav.HandleBack
End Sub

Private Sub OnTripClick
	CurrentTripIndex = TripIndexByButton.Get(Sender)
	RefreshScreen("detail")
	Nav.NavigateTo("detail")
End Sub

Private Sub OnDetailBack
	Nav.GoBack
End Sub

Private Sub OnAddBack
	Nav.GoBack
End Sub

Private Sub OnAddItemClick
	Nav.NavigateTo("addItem")
End Sub

Private Sub OnCreateTrip
	Dim tripName As String = AddTripNameInput.GetText
	If tripName.Trim = "" Then tripName = "Trip " & (Trips.Size + 1)

	Dim newTrip As Map
	newTrip.Initialize
	newTrip.Put("name", tripName)
	Dim emptyList As List
	emptyList.Initialize
	newTrip.Put("items", emptyList)
	Trips.Add(newTrip)
	RefreshScreen("trips")
	Nav.GoBack
	UI.Snack("Trip created") _
		.Duration(2200) _
		.BackgroundColor(Theme.DashboardBar) _
		.TextColor(Theme.DashboardBarText) _
		.Show(Root)
End Sub

Private Sub OnCreateItem
	If CurrentTripIndex < 0 Or CurrentTripIndex >= Trips.Size Then Return
	Dim itemName As String = AddItemNameInput.GetText
	If itemName.Trim = "" Then itemName = "Item " & (GetCurrentItems.Size + 1)

	Dim newItem As Map
	newItem.Initialize
	newItem.Put("name", itemName)
	newItem.Put("checked", False)
	GetCurrentItems.Add(newItem)
	RefreshScreen("detail")
	RefreshScreen("trips")
	Nav.GoBack
	UI.Snack("Item added") _
		.Duration(2200) _
		.BackgroundColor(Theme.DashboardBar) _
		.TextColor(Theme.DashboardBarText) _
		.Show(Root)
End Sub

Private Sub OnToggleItem
	Dim idx As Int = ItemIndexByButton.Get(Sender)
	Dim items As List = GetCurrentItems
	If idx < 0 Or idx >= items.Size Then Return
	Dim item As Map = items.Get(idx)
	Dim newChecked As Boolean = Not(item.Get("checked"))
	item.Put("checked", newChecked)
	RefreshScreen("detail")
	RefreshScreen("trips")
	UI.Snack(IIf(newChecked, "Packed", "Unpacked") & ": " & item.Get("name")) _
		.Duration(1800) _
		.BackgroundColor(Theme.DashboardBar) _
		.TextColor(Theme.DashboardBarText) _
		.Show(Root)
End Sub

' ====================  HELPERS  ====================

Private Sub GetCurrentItems As List
	If CurrentTripIndex < 0 Or CurrentTripIndex >= Trips.Size Then
		Dim empty As List
		empty.Initialize
		Return empty
	End If
	Dim trip As Map = Trips.Get(CurrentTripIndex)
	Return trip.Get("items")
End Sub

Private Sub CountChecked(Items As List) As Int
	Dim count As Int = 0
	For i = 0 To Items.Size - 1
		Dim item As Map = Items.Get(i)
		If item.Get("checked") = True Then count = count + 1
	Next
	Return count
End Sub

Private Sub SeedSampleData
	Dim trip1 As Map
	trip1.Initialize
	trip1.Put("name", "Barcelona Weekend")
	Dim items1 As List
	items1.Initialize
	AddItemToList(items1, "Passport", True)
	AddItemToList(items1, "Phone charger", True)
	AddItemToList(items1, "T-shirts x3", False)
	AddItemToList(items1, "Sunscreen", False)
	AddItemToList(items1, "Guidebook", False)
	trip1.Put("items", items1)
	Trips.Add(trip1)

	Dim trip2 As Map
	trip2.Initialize
	trip2.Put("name", "Tokyo Business")
	Dim items2 As List
	items2.Initialize
	AddItemToList(items2, "Laptop", True)
	AddItemToList(items2, "Business cards", False)
	AddItemToList(items2, "Suit", False)
	AddItemToList(items2, "Toiletry kit", False)
	trip2.Put("items", items2)
	Trips.Add(trip2)

	Dim trip3 As Map
	trip3.Initialize
	trip3.Put("name", "Beach House")
	Dim items3 As List
	items3.Initialize
	AddItemToList(items3, "Swimsuit", False)
	AddItemToList(items3, "Towel", False)
	AddItemToList(items3, "Sunglasses", False)
	AddItemToList(items3, "Book", False)
	trip3.Put("items", items3)
	Trips.Add(trip3)
End Sub

Private Sub AddItemToList(Items As List, ItemName As String, Checked As Boolean)
	Dim item As Map
	item.Initialize
	item.Put("name", ItemName)
	item.Put("checked", Checked)
	Items.Add(item)
End Sub
