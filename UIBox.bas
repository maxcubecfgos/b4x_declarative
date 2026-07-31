B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mChild As Object
	Private mPadding As Int
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize(child As Object, padding As Int) As UIBox
	mChild = child
	mPadding = padding
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
	mWidth = Width
	mHeight = Height
End Sub

Public Sub Render
	If mParent = Null Then Return
	If mParent.IsInitialized = False Then Return

	If mChild <> Null Then
		CallSub2(mChild, "SetParent", mParent)
		CallSub3(mChild, "SetPosition", mLeft + mPadding, mTop + mPadding)
		CallSub3(mChild, "SetSize", mWidth - (2 * mPadding), mHeight - (2 * mPadding))
		CallSub(mChild, "Render")
	End If
End Sub

Public Sub Unmount
	If mChild <> Null And xui.SubExists(mChild, "Unmount", 0) Then CallSub(mChild, "Unmount")
	mParent = Null
End Sub

' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
' UIBox mide al hijo y agrega el padding igual que UIPadding.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	If mChild <> Null Then
		Dim childMaxW As Int = Max(0, safeMaxWidth - 2 * mPadding)
		Dim childMaxH As Int = Max(0, safeMaxHeight - 2 * mPadding)
		
		Dim childSize As List = CallSub3(mChild, "GetContentSize", childMaxW, childMaxH)
		If childSize <> Null Then
			result.Add(Min(childSize.Get(0) + 2 * mPadding, safeMaxWidth))
			result.Add(Min(childSize.Get(1) + 2 * mPadding, safeMaxHeight))
			Return result
		End If
	End If
	
	result.Add(safeMaxWidth)
	result.Add(safeMaxHeight)
	Return result
End Sub