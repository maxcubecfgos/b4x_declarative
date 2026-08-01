B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mChild As Object
	Private mVisible As Boolean
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

' Creates a visible wrapper with no child.
Public Sub Initialize As UIVisibility
	mChild = Null
	mVisible = True
	Return Me
End Sub

' Controls whether the child participates in measurement and rendering.
' The parent container must be rendered after changing visibility so it can reflow siblings.
Public Sub Visible(Value As Boolean) As UIVisibility
	mVisible = Value
	Return Me
End Sub

' Replaces the single child managed by this wrapper.
Public Sub Child(Widget As Object) As UIVisibility
	If mChild <> Null Then
		If xui.SubExists(mChild, "Unmount", 0) Then CallSub(mChild, "Unmount")
	End If
	If mBaseView <> Null Then
		If mBaseView.IsInitialized Then mBaseView.RemoveAllViews
	End If
	mChild = Widget
	Return Me
End Sub

Public Sub SetParent(Parent As B4XView)
	mParent = Parent
End Sub

Public Sub SetPosition(Left As Int, Top As Int)
	mLeft = Left
	mTop = Top
End Sub

Public Sub SetSize(Width As Int, Height As Int)
	mWidth = Max(0, Width)
	mHeight = Max(0, Height)
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
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		mBaseView.Color = Colors.Transparent
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If

	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
	If mVisible = False Then
		If mChild <> Null And xui.SubExists(mChild, "Unmount", 0) Then CallSub(mChild, "Unmount")
		mBaseView.RemoveAllViews
		mBaseView.SetLayoutAnimated(0, mLeft, mTop, 0, 0)
		Return
	End If

	If mChild = Null Then
		mBaseView.RemoveAllViews
		Return
	End If

	CallSub2(mChild, "SetParent", mBaseView)
	CallSub3(mChild, "SetPosition", 0, 0)
	CallSub3(mChild, "SetSize", mWidth, mHeight)
	CallSub(mChild, "Render")
End Sub

Public Sub Unmount
	If mChild <> Null And xui.SubExists(mChild, "Unmount", 0) Then CallSub(mChild, "Unmount")
	If mBaseView <> Null Then
		If mBaseView.IsInitialized Then mBaseView.RemoveAllViews
	End If
	mBaseView = Null
	mParent = Null
End Sub

' Internal layout hook used by Column and Row to avoid spacing around hidden children.
Public Sub ParticipatesInLayout As Boolean
	Return mVisible
End Sub

' Hidden children occupy no layout space. Visible children delegate natural measurement.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	If mVisible = False Or mChild = Null Then
		result.Add(0)
		result.Add(0)
		Return result
	End If
	Return CallSub3(mChild, "GetContentSize", MaxWidth, MaxHeight)
End Sub