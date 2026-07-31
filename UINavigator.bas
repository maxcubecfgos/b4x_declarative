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
End Sub

Public Sub Initialize As UINavigator
	mScreens.Initialize
	mCurrentScreen = ""
	mMountedScreen = Null
	mIsMounted = False
	Return Me
End Sub

Public Sub AddScreen(Name As String, Screen As Object) As UINavigator
	If Name.Trim = "" Or Screen = Null Then Return Me
	mScreens.Put(Name, Screen)
	If mCurrentScreen = "" Then mCurrentScreen = Name
	If mHost.IsInitialized And Name = mCurrentScreen Then Render
	Return Me
End Sub

Public Sub NavigateTo(Name As String)
	If mScreens.ContainsKey(Name) = False Then Return
	If mCurrentScreen = Name And mIsMounted Then Return
	mCurrentScreen = Name
	If mHost.IsInitialized Then Render
End Sub

Public Sub SetParent(Parent As B4XView)
	If mHost.IsInitialized Then Unmount
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
	If mParent.IsInitialized = False Then Return
	If mHost.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mHost = pnl
		mHost.Color = Colors.Transparent
		mParent.AddView(mHost, mLeft, mTop, mWidth, mHeight)
	Else
		mHost.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
	End If

	If mMountedScreen <> Null Then
		If xui.SubExists(mMountedScreen, "Unmount", 0) = False Then Return
		CallSub(mMountedScreen, "Unmount")
	End If
	mHost.RemoveAllViews
	mMountedScreen = Null

	Dim Screen As Object = mScreens.Get(mCurrentScreen)
	If Screen <> Null Then
		CallSub2(Screen, "SetParent", mHost)
		CallSub3(Screen, "SetPosition", 0, 0)
		CallSub3(Screen, "SetSize", mWidth, mHeight)
		CallSub(Screen, "Render")
		mMountedScreen = Screen
	End If
	mIsMounted = mHost.IsInitialized
End Sub

Public Sub Unmount
	If mMountedScreen <> Null Then
		If xui.SubExists(mMountedScreen, "Unmount", 0) Then CallSub(mMountedScreen, "Unmount")
	End If
	If mHost.IsInitialized Then
		mHost.RemoveAllViews
		mHost.RemoveViewFromParent
	End If
	mHost = Null
	mMountedScreen = Null
	mParent = Null
	mIsMounted = False
End Sub

' --- SISTEMA DE MEDICIÓN ---
' Navigator ocupa todo el espacio disponible (como Scaffold).
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Return Null
End Sub
