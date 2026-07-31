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
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UINavigator
	mScreens.Initialize
	Return Me
End Sub

Public Sub NavigateTo(Name As String)
	mCurrentScreen = Name
End Sub

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
	Dim Screen As Object = mScreens.Get(mCurrentScreen)
	If Screen <> Null Then
		CallSub2(Screen, "SetParent", mParent)
		CallSub3(Screen, "SetPosition", mLeft, mTop)
		CallSub3(Screen, "SetSize", mWidth, mHeight)
		CallSub(Screen, "Render")
	End If
End Sub

Public Sub Unmount
	For Each Screen As Object In mScreens.Values
		If Screen <> Null And xui.SubExists(Screen, "Unmount", 0) Then CallSub(Screen, "Unmount")
	Next
	mParent = Null
End Sub

' --- SISTEMA DE MEDICIÓN ---
' Navigator ocupa todo el espacio disponible (como Scaffold).
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Return Null
End Sub