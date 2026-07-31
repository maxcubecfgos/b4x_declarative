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

Public Sub AddScreen(Name As String, Screen As Object) As UINavigator
	If Name.Trim = "" Or Screen = Null Then Return Me
	mScreens.Put(Name, Screen)
	If mCurrentScreen = "" Then mCurrentScreen = Name
	If mHost <> Null Then
		If mHost.IsInitialized And Name = mCurrentScreen Then Render
	End If
	Return Me
End Sub

Public Sub NavigateTo(Name As String)
	Log("[DBG_UI] UINavigator.NavigateTo requested=" & Name & " current=" & mCurrentScreen & " screenExists=" & mScreens.ContainsKey(Name) & " hostSet=" & (mHost <> Null))
	If mScreens.ContainsKey(Name) = False Then
		Log("[DBG_UI] UINavigator.NavigateTo stopped: screen not found")
		Return
	End If
	If mCurrentScreen = Name And mIsMounted Then
		Log("[DBG_UI] UINavigator.NavigateTo stopped: already mounted")
		Return
	End If
	mCurrentScreen = Name
	If mHost <> Null Then
		If mHost.IsInitialized Then
			Log("[DBG_UI] UINavigator.NavigateTo rendering screen=" & Name)
			Render
		Else
			Log("[DBG_UI] UINavigator.NavigateTo stopped: host not initialized")
		End If
	Else
		Log("[DBG_UI] UINavigator.NavigateTo stopped: host is Null")
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
	Log("[DBG_UI] UINavigator.Render current=" & mCurrentScreen & " bounds=" & mLeft & "," & mTop & "," & mWidth & "," & mHeight & " parentSet=" & (mParent <> Null) & " hostSet=" & (mHost <> Null))
	If mParent = Null Then
		Log("[DBG_UI] UINavigator.Render skipped: parent is Null")
		Return
	End If
	If mParent.IsInitialized = False Then
		Log("[DBG_UI] UINavigator.Render skipped: parent is not initialized")
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
		Log("[DBG_UI] UINavigator.Render mounting screen=" & mCurrentScreen & " contentBounds=" & contentLeft & "," & contentTop & "," & contentWidth & "," & contentHeight)
		CallSub2(Screen, "SetParent", mHost)
		CallSub3(Screen, "SetPosition", 0, 0)
		CallSub3(Screen, "SetSize", contentWidth, contentHeight)
		CallSub(Screen, "Render")
		mMountedScreen = Screen
		Log("[DBG_UI] UINavigator.Render mounted screen=" & mCurrentScreen)
	Else
		Log("[DBG_UI] UINavigator.Render skipped: screen object is Null")
	End If
	mIsMounted = mHost.IsInitialized
End Sub

' Vuelve a medir el área segura y remonta solo si cambió.
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

' --- SISTEMA DE MEDICIÓN ---
' Navigator ocupa todo el espacio disponible (como Scaffold).
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	' Una lista vacía representa un tamaño flexible.
	Dim flexibleSize As List
	flexibleSize.Initialize
	Return flexibleSize
End Sub
