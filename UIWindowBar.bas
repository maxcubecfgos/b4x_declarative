B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mTitle As String
	Private mTitleState As UIState
	Private mBarColor As Int
	Private mTitleColor As Int
	Private mButtonColor As Int

	Private mTheme As UITheme
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
	Private mBarHeight As Int
	Private mTitleLabel As B4XView
	Private mCloseBtn As B4XView
	Private mMinimizeBtn As B4XView
	Private mMaximizeBtn As B4XView
	Private mForm As Object
	Private mDragOffsetX, mDragOffsetY As Int
	Private mIsMaximized As Boolean
	Private mRestoreLeft, mRestoreTop, mRestoreWidth, mRestoreHeight As Int
End Sub

Public Sub Initialize As UIWindowBar
	mTitle = ""
	Dim defaultTheme As UITheme
	defaultTheme.Initialize
	mTheme = defaultTheme
	mBarColor = mTheme.DashboardBar
	mTitleColor = mTheme.DashboardBarText
	mButtonColor = mTheme.SecondaryText

	mBarHeight = 36dip
	mForm = Null
	mIsMaximized = False
	mRestoreLeft = 0
	mRestoreTop = 0
	mRestoreWidth = 0
	mRestoreHeight = 0
	Return Me
End Sub

Public Sub Title(t As String) As UIWindowBar
	If mTitleState <> Null Then
		If mTitleState.IsInitialized Then mTitleState.Unsubscribe(Me, "TitleState_Changed")
	End If
	mTitleState = Null
	mTitle = t
	Return Me
End Sub

Public Sub BindTitle(State As UIState) As UIWindowBar
	If mTitleState <> Null Then
		If mTitleState.IsInitialized Then mTitleState.Unsubscribe(Me, "TitleState_Changed")
	End If
	mTitleState = State
	If mTitleState <> Null Then
		If mTitleState.IsInitialized Then
			mTitle = "" & mTitleState.GetState
			mTitleState.Subscribe(Me, "TitleState_Changed")
		End If
	End If
	Return Me
End Sub

Public Sub BarColor(Color As Int) As UIWindowBar
	mBarColor = Color
	Return Me
End Sub

Public Sub TitleColor(Color As Int) As UIWindowBar
	mTitleColor = Color
	Return Me
End Sub

Public Sub ButtonColor(Color As Int) As UIWindowBar
	mButtonColor = Color
	Return Me
End Sub

Public Sub BarHeight(h As Int) As UIWindowBar
	mBarHeight = h
	Return Me
End Sub

' Applies theme tokens (bar/title/button colors). Rebuilds the native bar
' when mounted, because the chrome is painted at creation time.
Public Sub ApplyTheme(Theme As UITheme) As UIWindowBar
	If Theme = Null Then Return Me
	If Theme.IsInitialized = False Then Return Me
	mTheme = Theme
	mBarColor = mTheme.DashboardBar
	mTitleColor = mTheme.DashboardBarText
	mButtonColor = mTheme.SecondaryText
	If mBaseView <> Null Then
		If mBaseView.IsInitialized Then
			If mBaseView.Parent <> Null Then mBaseView.RemoveViewFromParent
			mBaseView = Null
			Render
		End If
	End If
	Return Me
End Sub

Public Sub FormTarget(f As Object) As UIWindowBar
	mForm = f
	Return Me
End Sub

' Widget protocol -------------------------------------------------------

Public Sub SetParent(Parent As B4XView)
	mParent = Parent
End Sub

Public Sub SetPosition(Left As Int, Top As Int)
	mLeft = Left
	mTop = Top
End Sub

Public Sub SetSize(Width As Int, Height As Int)
	mWidth = Width
	mHeight = Height
End Sub

Public Sub Render
	If mParent = Null Then Return
	If mParent.IsInitialized = False Then Return

	Dim needsCreate As Boolean = False
	If mBaseView = Null Then
		needsCreate = True
	Else If mBaseView.IsInitialized = False Then
		needsCreate = True
	End If

	If needsCreate Then
		CreateBar
	End If

	If mBaseView.Parent <> mParent Then
		If mBaseView.Parent <> Null Then mBaseView.RemoveViewFromParent
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mBarHeight)
	End If

	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mBarHeight)
	UpdateTitle
End Sub

Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	result.Add(MaxWidth)
	result.Add(mBarHeight)
	Return result
End Sub

Public Sub GetView As B4XView
	If mBaseView = Null Then Return Null
	If mBaseView.IsInitialized = False Then Return Null
	Return mBaseView
End Sub

Public Sub Detach
	If mBaseView <> Null Then
		If mBaseView.IsInitialized Then
			If mBaseView.Parent <> Null Then mBaseView.RemoveViewFromParent
		End If
	End If
	mParent = Null
End Sub

' Internal --------------------------------------------------------------

Private Sub CreateBar
	#If B4J
	' B4J: StackPane root + themed title label, built exclusively through the
	' public B4XView API. No reflection into JavaFX internals (getChildren()
	' resolves to non-exported implementation classes under JPMS).
	Dim rootPaneJO As JavaObject
	rootPaneJO.InitializeNewInstance("javafx.scene.layout.StackPane", Null)
	Dim rootPane As B4XView = rootPaneJO
	mBaseView = rootPane
	mBaseView.Color = mBarColor

	Dim titleLabel As Label
	titleLabel.Initialize("")
	mTitleLabel = titleLabel
	mTitleLabel.Text = mTitle
	mTitleLabel.TextColor = mTitleColor
	mTitleLabel.TextSize = 14
	mTitleLabel.SetTextAlignment("CENTER", "LEFT")
	rootPane.AddView(mTitleLabel, 12dip, 0, Max(0, mWidth - 180dip), mBarHeight)
	#Else
	mBaseView = xui.CreatePanel("")
	mBaseView.Color = mBarColor
	Dim lbl As Label
	lbl.Initialize("")
	mTitleLabel = lbl
	mTitleLabel.Color = mBarColor
	mTitleLabel.TextColor = mTitleColor
	mTitleLabel.Text = mTitle
	mTitleLabel.SetTextAlignment("CENTER", "LEFT")
	mBaseView.AddView(mTitleLabel, 12dip, 0, Max(0, mWidth - 180dip), mBarHeight)
	mParent.AddView(mBaseView, mLeft, mTop, mWidth, mBarHeight)
	#End If
End Sub



Private Sub UpdateTitle
	If mTitleLabel = Null Then Return
	If mTitleLabel.IsInitialized = False Then Return
	mTitleLabel.Text = mTitle
End Sub

Private Sub TitleState_Changed(State As UIState)
	If State = Null Then Return
	If State.IsInitialized = False Then Return
	mTitle = "" & State.GetState
	UpdateTitle
End Sub

' Window button events --------------------------------------------------

Private Sub Close_Click
	CloseWindow
End Sub

Private Sub Minimize_Click
	MinimizeWindow
End Sub

Private Sub Maximize_Click
	ToggleMaximize
End Sub

' B4J mouse events for window buttons -----------------------------------

#If B4J
Private Sub Close_MouseClicked(EventData As MouseEvent)
	CloseWindow
End Sub

Private Sub Minimize_MouseClicked(EventData As MouseEvent)
	MinimizeWindow
End Sub

Private Sub Maximize_MouseClicked(EventData As MouseEvent)
	ToggleMaximize
End Sub
#End If



' B4A touch events for window buttons -----------------------------------

#If B4A
Private Sub Close_Touch(Action As Int, X As Float, Y As Float)
	If Action <> 1 Then Return
	CloseWindow
End Sub

Private Sub Minimize_Touch(Action As Int, X As Float, Y As Float)
	If Action <> 1 Then Return
	MinimizeWindow
End Sub

Private Sub Maximize_Touch(Action As Int, X As Float, Y As Float)
	If Action <> 1 Then Return
	ToggleMaximize
End Sub

Private Sub TitleDragBar_Touch(Action As Int, X As Float, Y As Float)
	HandleDrag(Action, X, Y)
End Sub
#End If

' B4J drag events for title bar -----------------------------------------

#If B4J
Private Sub TitleDragBar_MousePressed(EventData As MouseEvent)
	mDragOffsetX = EventData.X
	mDragOffsetY = EventData.Y
End Sub

Private Sub TitleDragBar_MouseDragged(EventData As MouseEvent)
	HandleDrag(2, EventData.X, EventData.Y)
End Sub

Private Sub TitleDragBar_MouseClicked(EventData As MouseEvent)
	' Double-click detected by JavaFX fires twice rapidly; toggle maximize
End Sub

Private Sub TitleDragBar_OnMouseClicked(EventData As MouseEvent)
	' Handle double-click for maximize toggle
End Sub
#End If

' Window operations (cross-platform) ------------------------------------

Private Sub CloseWindow
	#If B4A
	Dim act As Activity
	act = Act
	act.Finish
	#Else If B4J
	If mForm <> Null Then
		Dim jo As JavaObject = mForm
		Dim scene As JavaObject = jo.RunMethod("getScene", Null)
		Dim win As JavaObject = scene.RunMethod("getWindow", Null)
		win.RunMethod("close", Null)
	End If
	#End If
End Sub

Private Sub MinimizeWindow
	#If B4A
	' Android doesn't have minimize; do nothing
	#Else If B4J
	If mForm <> Null Then
		Dim jo As JavaObject = mForm
		Dim scene As JavaObject = jo.RunMethod("getScene", Null)
		Dim stage As JavaObject = scene.RunMethod("getWindow", Null)
		stage.RunMethod("setIconified", Array(True))
	End If
	#End If
End Sub


Private Sub ToggleMaximize
	#If B4J
	If mForm = Null Then Return
	Dim jo As JavaObject = mForm
	Dim scene As JavaObject = jo.RunMethod("getScene", Null)
	Dim stage As JavaObject = scene.RunMethod("getWindow", Null)
	If mIsMaximized Then
		' Restore
		stage.RunMethod("setX", Array(mRestoreLeft))
		stage.RunMethod("setY", Array(mRestoreTop))
		stage.RunMethod("setWidth", Array(mRestoreWidth))
		stage.RunMethod("setHeight", Array(mRestoreHeight))
		mIsMaximized = False
	Else
		' Save current position
		mRestoreLeft = stage.RunMethod("getX", Null)
		mRestoreTop = stage.RunMethod("getY", Null)
		mRestoreWidth = stage.RunMethod("getWidth", Null)
		mRestoreHeight = stage.RunMethod("getHeight", Null)
		' Maximize to screen bounds
		Dim screen As JavaObject
		screen.InitializeStatic("javafx.stage.Screen")
		Dim screens As JavaObject = screen.RunMethod("getScreensForRectangle", Array(mRestoreLeft, mRestoreTop, 1, 1))
		Dim bounds As JavaObject = screens.RunMethod("getVisualBounds", Null)
		stage.RunMethod("setX", Array(bounds.RunMethod("getMinX", Null)))
		stage.RunMethod("setY", Array(bounds.RunMethod("getMinY", Null)))
		stage.RunMethod("setWidth", Array(bounds.RunMethod("getWidth", Null)))
		stage.RunMethod("setHeight", Array(bounds.RunMethod("getHeight", Null)))
		mIsMaximized = True
	End If
	#End If
End Sub

Private Sub HandleDrag(Action As Int, X As Float, Y As Float)
	#If B4J
	If mForm = Null Then Return
	Dim jo As JavaObject = mForm
	Dim scene As JavaObject = jo.RunMethod("getScene", Null)
	Dim stage As JavaObject = scene.RunMethod("getWindow", Null)
	If Action = 0 Then
		' Pressed: store offset
		mDragOffsetX = X
		mDragOffsetY = Y
	Else If Action = 2 Then
		' Dragged: move window
		Dim currentX As Double = stage.RunMethod("getX", Null)
		Dim currentY As Double = stage.RunMethod("getY", Null)
		stage.RunMethod("setX", Array(currentX + X - mDragOffsetX))
		stage.RunMethod("setY", Array(currentY + Y - mDragOffsetY))
	End If
	#End If
End Sub



