B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mScreens As Map
	Private mCurrentScreen As String
	Private mParent As B4XView
	Private mHost As B4XView
	Private mMountedScreen As Object
	Private mIsMounted As Boolean
	Private mLeft, mTop, mWidth, mHeight As Int
	Private mInsetLeft, mInsetTop, mInsetRight, mInsetBottom As Int
	Private mIme As IME
End Sub

Public Sub Initialize As UINavigator
	mScreens.Initialize
	mIme.Initialize("")
	mCurrentScreen = ""
	mMountedScreen = Null
	mIsMounted = False
	Return Me
End Sub

' Applies the active theme to all registered virtual screens.
' Screens that do not expose ApplyTheme are left untouched.
Public Sub ApplyTheme(Theme As UITheme) As UINavigator
	If Theme = Null Then Return Me
	If Theme.IsInitialized = False Then Return Me
	For Each key As String In mScreens.Keys
		Dim screen As Object = mScreens.Get(key)
		If screen <> Null And xui.SubExists(screen, "ApplyTheme", 1) Then CallSub2(screen, "ApplyTheme", Theme)
	Next
	Return Me
End Sub

Public Sub AddScreen(Name As String, Screen As Object) As UINavigator
	If Name.Trim = "" Or IsWidgetProtocol(Screen) = False Then Return Me
	mScreens.Put(Name, Screen)
	If mCurrentScreen = "" Then mCurrentScreen = Name
	If mHost <> Null Then
		If mHost.IsInitialized And Name = mCurrentScreen Then Render
	End If
	Return Me
End Sub

Public Sub NavigateTo(Name As String)
	If mScreens.ContainsKey(Name) = False Then
		Return
	End If
	If mCurrentScreen = Name And mIsMounted Then
		Return
	End If
	mCurrentScreen = Name
	If mHost <> Null Then
		If mHost.IsInitialized Then
			Render
		Else
		End If
	Else
	End If
End Sub

Public Sub SetParent(Parent As B4XView)
	If mHost <> Null Then
		If mHost.IsInitialized Then Unmount
	End If
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
	If mParent = Null Then
		Return
	End If
	If mParent.IsInitialized = False Then
		Return
	End If

	Dim bounds As List = GetSafeBounds
	Dim contentLeft As Int = bounds.Get(0)
	Dim contentTop As Int = bounds.Get(1)
	Dim contentWidth As Int = bounds.Get(2)
	Dim contentHeight As Int = bounds.Get(3)

	Dim needsCreate As Boolean = False
	If mHost = Null Then
		needsCreate = True
	Else If mHost.IsInitialized = False Then
		needsCreate = True
	End If
	If needsCreate Then
		Dim pnl As Panel
		pnl.Initialize("")
		mHost = pnl
		mHost.Color = Colors.Transparent
		mParent.AddView(mHost, contentLeft, contentTop, contentWidth, contentHeight)
	Else
		mHost.SetLayoutAnimated(0, contentLeft, contentTop, contentWidth, contentHeight)
	End If

	If mMountedScreen <> Null Then
		If xui.SubExists(mMountedScreen, "Unmount", 0) Then
			CallSub(mMountedScreen, "Unmount")
		End If
	End If
	mHost.RemoveAllViews
	mMountedScreen = Null

	Dim Screen As Object = mScreens.Get(mCurrentScreen)
	If Screen <> Null Then
		CallSub2(Screen, "SetParent", mHost)
		CallSub3(Screen, "SetPosition", 0, 0)
		CallSub3(Screen, "SetSize", contentWidth, contentHeight)
		CallSub(Screen, "Render")
		mMountedScreen = Screen
	Else
	End If
	mIsMounted = mHost.IsInitialized
End Sub

Private Sub IsWidgetProtocol(Widget As Object) As Boolean
	If Widget = Null Then Return False
	Return xui.SubExists(Widget, "SetParent", 1) And xui.SubExists(Widget, "SetPosition", 2) _
		And xui.SubExists(Widget, "SetSize", 2) And xui.SubExists(Widget, "Render", 0) _
		And xui.SubExists(Widget, "GetContentSize", 2)
End Sub

' Re-measure the safe area and remount only when an inset changes.
Public Sub RefreshInsets
	If mParent = Null Or mHost = Null Then Return
	If mParent.IsInitialized = False Or mHost.IsInitialized = False Then Return
	Dim previousLeft As Int = mInsetLeft
	Dim previousTop As Int = mInsetTop
	Dim previousRight As Int = mInsetRight
	Dim previousBottom As Int = mInsetBottom
	GetSafeBounds
	If previousLeft <> mInsetLeft Or previousTop <> mInsetTop Or previousRight <> mInsetRight Or previousBottom <> mInsetBottom Then
		Render
	End If
End Sub

Private Sub GetSafeBounds As List
	Dim result As List
	result.Initialize
	Dim contentRect As Rect = mIme.GetContentRect
	mInsetLeft = Max(0, contentRect.Left)
	mInsetTop = Max(0, contentRect.Top)
	mInsetRight = Max(0, mWidth - contentRect.Right)
	mInsetBottom = Max(0, mHeight - contentRect.Bottom)
	result.Add(mLeft + mInsetLeft)
	result.Add(mTop + mInsetTop)
	result.Add(Max(0, mWidth - mInsetLeft - mInsetRight))
	result.Add(Max(0, mHeight - mInsetTop - mInsetBottom))
	Return result
End Sub

Public Sub Unmount
	If mMountedScreen <> Null Then
		If xui.SubExists(mMountedScreen, "Unmount", 0) Then CallSub(mMountedScreen, "Unmount")
	End If
	If mHost <> Null Then
		If mHost.IsInitialized Then
			mHost.RemoveAllViews
			mHost.RemoveViewFromParent
		End If
	End If
	mHost = Null
	mMountedScreen = Null
	mParent = Null
	mIsMounted = False
End Sub

' Natural measurement used by parent layout containers.
' The navigator fills the available space, just like the scaffold.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	' An empty list represents a flexible size.
	Dim flexibleSize As List
	flexibleSize.Initialize
	Return flexibleSize
End Sub
