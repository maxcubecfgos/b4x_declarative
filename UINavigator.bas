B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mScreens As Map
	Private mHistory As List
	Private mCurrentScreen As String
	Private mParent As B4XView
	Private mHost As B4XView
	Private mMountedScreen As Object
	Private mIsMounted As Boolean
	Private mLeft, mTop, mWidth, mHeight As Int
    Private mInsetLeft, mInsetTop, mInsetRight, mInsetBottom As Int
    Private mBoundsLeft, mBoundsTop, mBoundsWidth, mBoundsHeight As Int
    Private mBoundsReady As Boolean
End Sub

Public Sub Initialize As UINavigator
	mScreens.Initialize
    mHistory.Initialize
    mCurrentScreen = ""
    mMountedScreen = Null
    mIsMounted = False
    mBoundsReady = False
    mBoundsLeft = 0
    mBoundsTop = 0
    mBoundsWidth = 0
    mBoundsHeight = 0
    Return Me
End Sub

' Applies the active theme to all registered virtual screens.
' Screens that do not expose ApplyTheme are left untouched.
Public Sub ApplyTheme(Theme As UITheme) As UINavigator
	If Theme = Null Then Return Me
	If Theme.IsInitialized = False Then Return Me
	For Each key As String In mScreens.Keys
		Dim screen As Object = mScreens.Get(key)
		If screen <> Null And SubExists(screen, "ApplyTheme") Then CallSub2(screen, "ApplyTheme", Theme)
	Next
	Return Me
End Sub

Public Sub AddScreen(Name As String, Screen As Object) As UINavigator
	If Name.Trim = "" Or IsWidgetProtocol(Screen) = False Then Return Me
	mScreens.Put(Name, Screen)
	If mCurrentScreen = "" Then
		mCurrentScreen = Name
		mHistory.Add(Name)
	End If
	If mHost <> Null Then
		If mHost.IsInitialized And Name = mCurrentScreen Then Render
	End If
	Return Me
End Sub

Public Sub NavigateTo(Name As String)
	If mScreens.ContainsKey(Name) = False Then
		Return
	End If
	If mHistory.Size = 0 And mCurrentScreen <> "" Then mHistory.Add(mCurrentScreen)
	If mCurrentScreen = Name Then
		If mIsMounted Then Return
		If mHost <> Null Then
			If mHost.IsInitialized Then Render
		End If
		Return
	End If
	mHistory.Add(Name)
	mCurrentScreen = Name
	If mHost <> Null Then
		If mHost.IsInitialized Then Render
	End If
End Sub

' Returns True when a previously visited screen can be restored.
Public Sub CanGoBack As Boolean
	Return mHistory.Size > 1
End Sub

' Pops the current screen and renders the previous one when mounted.
Public Sub GoBack As Boolean
	If CanGoBack = False Then Return False
	mHistory.RemoveAt(mHistory.Size - 1)
	mCurrentScreen = mHistory.Get(mHistory.Size - 1)
	If mHost <> Null Then
		If mHost.IsInitialized Then Render
	End If
	Return True
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
    RememberBounds(contentLeft, contentTop, contentWidth, contentHeight)

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
		If SubExists(mMountedScreen, "Unmount") Then
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
	End If
	mIsMounted = mHost.IsInitialized
End Sub

Private Sub IsWidgetProtocol(Widget As Object) As Boolean
	If Widget = Null Then Return False
	Return SubExists(Widget, "SetParent") And SubExists(Widget, "SetPosition") _
		And SubExists(Widget, "SetSize") And SubExists(Widget, "Render") _
		And SubExists(Widget, "GetContentSize")
End Sub

' Re-measure the safe area and remount only when an inset changes.
Public Sub RefreshInsets
	If mParent = Null Then Return
	If mHost = Null Then Return
	If mParent.IsInitialized = False Then Return
	If mHost.IsInitialized = False Then Return
    Dim previousLeft As Int = mInsetLeft
    Dim previousTop As Int = mInsetTop
    Dim previousRight As Int = mInsetRight
    Dim previousBottom As Int = mInsetBottom
    Dim previousBoundsLeft As Int = mBoundsLeft
    Dim previousBoundsTop As Int = mBoundsTop
    Dim previousBoundsWidth As Int = mBoundsWidth
    Dim previousBoundsHeight As Int = mBoundsHeight
    Dim hadBounds As Boolean = mBoundsReady
    Dim currentBounds As List = GetSafeBounds
    Dim boundsChanged As Boolean = False
    If hadBounds = False Then boundsChanged = True
    If previousBoundsLeft <> currentBounds.Get(0) Then boundsChanged = True
    If previousBoundsTop <> currentBounds.Get(1) Then boundsChanged = True
    If previousBoundsWidth <> currentBounds.Get(2) Then boundsChanged = True
    If previousBoundsHeight <> currentBounds.Get(3) Then boundsChanged = True
    Dim insetsChanged As Boolean = False
    If previousLeft <> mInsetLeft Then insetsChanged = True
    If previousTop <> mInsetTop Then insetsChanged = True
    If previousRight <> mInsetRight Then insetsChanged = True
    If previousBottom <> mInsetBottom Then insetsChanged = True
    If insetsChanged Or boundsChanged Then Render
End Sub

Private Sub GetSafeBounds As List
    Dim result As List
    result.Initialize
    ResetInsets

    ' WindowInsets are measured from the window/decor coordinate space.
    ' Convert the safe rectangle to the local coordinate space of mParent.
    ' This prevents a second offset when B4A has already inset the parent.
    Try
        Dim context As JavaObject
        context.InitializeContext
        Dim window As JavaObject = context.RunMethod("getWindow", Null)
        Dim decor As JavaObject = window.RunMethod("getDecorView", Null)
        Dim rootInsets As JavaObject = decor.RunMethod("getRootWindowInsets", Null)
        If rootInsets.IsInitialized = False Then Return FullBounds(result)

        Dim sdk As JavaObject
        sdk.InitializeStatic("android.os.Build$VERSION")
        Dim sdkInt As Int = sdk.GetField("SDK_INT")
        Dim insetLeft, insetTop, insetRight, insetBottom As Int

        If sdkInt >= 30 Then
            Dim insetTypes As JavaObject
            insetTypes.InitializeStatic("android.view.WindowInsets$Type")
            Dim systemBars As Int = insetTypes.RunMethod("systemBars", Null)
            Dim ime As Int = insetTypes.RunMethod("ime", Null)
            Dim combinedTypes As Int = Bit.Or(systemBars, ime)
            Dim nativeInsets As JavaObject = rootInsets.RunMethodJO("getInsets", Array As Object(combinedTypes))
            If nativeInsets.IsInitialized Then
                insetLeft = nativeInsets.GetField("left")
                insetTop = nativeInsets.GetField("top")
                insetRight = nativeInsets.GetField("right")
                insetBottom = nativeInsets.GetField("bottom")
            End If
        Else If sdkInt >= 20 Then
            insetLeft = rootInsets.RunMethod("getSystemWindowInsetLeft", Null)
            insetTop = rootInsets.RunMethod("getSystemWindowInsetTop", Null)
            insetRight = rootInsets.RunMethod("getSystemWindowInsetRight", Null)
            insetBottom = rootInsets.RunMethod("getSystemWindowInsetBottom", Null)
        Else
            Return FullBounds(result)
        End If

        Dim decorLocation(2) As Int
        Dim parentLocation(2) As Int
        decor.RunMethod("getLocationOnScreen", Array(decorLocation))
        Dim parentView As JavaObject = mParent
        parentView.RunMethod("getLocationOnScreen", Array(parentLocation))

        Dim decorWidth As Int = decor.RunMethod("getWidth", Null)
        Dim decorHeight As Int = decor.RunMethod("getHeight", Null)
        If decorWidth <= 0 Or decorHeight <= 0 Then Return FullBounds(result)

        Dim safeLeft As Int = decorLocation(0) + insetLeft
        Dim safeTop As Int = decorLocation(1) + insetTop
        Dim safeRight As Int = decorLocation(0) + decorWidth - insetRight
        Dim safeBottom As Int = decorLocation(1) + decorHeight - insetBottom

        mInsetLeft = Max(0, safeLeft - parentLocation(0))
        mInsetTop = Max(0, safeTop - parentLocation(1))
        mInsetRight = Max(0, parentLocation(0) + mWidth - safeRight)
        mInsetBottom = Max(0, parentLocation(1) + mHeight - safeBottom)
    Catch
        ResetInsets
    End Try

    result.Add(mLeft + mInsetLeft)
    result.Add(mTop + mInsetTop)
    result.Add(Max(0, mWidth - mInsetLeft - mInsetRight))
    result.Add(Max(0, mHeight - mInsetTop - mInsetBottom))
    Return result
End Sub

Private Sub FullBounds(Result As List) As List
    ResetInsets
    Result.Add(mLeft)
    Result.Add(mTop)
    Result.Add(Max(0, mWidth))
    Result.Add(Max(0, mHeight))
    Return Result
End Sub

Private Sub RememberBounds(Left As Int, Top As Int, Width As Int, Height As Int)
    mBoundsLeft = Left
    mBoundsTop = Top
    mBoundsWidth = Width
    mBoundsHeight = Height
    mBoundsReady = True
End Sub

Private Sub ResetInsets
    mInsetLeft = 0
    mInsetTop = 0
    mInsetRight = 0
    mInsetBottom = 0
End Sub

Public Sub Unmount
	If mMountedScreen <> Null Then
		If SubExists(mMountedScreen, "Unmount") Then CallSub(mMountedScreen, "Unmount")
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
