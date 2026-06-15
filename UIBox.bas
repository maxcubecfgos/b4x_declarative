B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
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
	If mChild <> Null Then
		CallSub2(mChild, "SetParent", mParent)
		CallSub3(mChild, "SetPosition", mLeft + mPadding, mTop + mPadding)
		CallSub3(mChild, "SetSize", mWidth - (2 * mPadding), mHeight - (2 * mPadding))
		CallSub(mChild, "Render")
	End If
End Sub