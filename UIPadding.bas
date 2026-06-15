B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mChild As Object
	Private mBaseView As B4XView
	Private mTop, mBottom, mLeftPad, mRightPad As Int
	Private mParent As B4XView
	Private mLeft, mTopCoord, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIPadding
	mTop = 0 : mBottom = 0 : mLeftPad = 0 : mRightPad = 0
	mChild = Null
	Return Me
End Sub

Public Sub All(Value As Int) As UIPadding
	mTop = Value : mBottom = Value : mLeftPad = Value : mRightPad = Value
	Return Me
End Sub

Public Sub Symmetric(Horizontal As Int, Vertical As Int) As UIPadding
	mLeftPad = Horizontal : mRightPad = Horizontal
	mTop = Vertical : mBottom = Vertical
	Return Me
End Sub

Public Sub Child(c As Object) As UIPadding
	mChild = c
	Return Me
End Sub

Public Sub SetParent(Parent As B4XView)
	mParent = Parent
End Sub

Public Sub SetPosition(Left As Int, Top As Int)
	mLeft = Left
	mTopCoord = Top
End Sub

Public Sub SetSize(Width As Int, Height As Int)
	mWidth = Width
	mHeight = Height
End Sub

Public Sub Render
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		mBaseView.Color = Colors.Transparent
		mParent.AddView(mBaseView, mLeft, mTopCoord, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTopCoord, mWidth, mHeight)
    
	If mChild <> Null Then
		Dim childLeft As Int = mLeftPad
		Dim childTop As Int = mTop
		Dim childWidth As Int = mWidth - mLeftPad - mRightPad
		Dim childHeight As Int = mHeight - mTop - mBottom
        
		CallSub2(mChild, "SetParent", mBaseView)
		CallSub3(mChild, "SetPosition", Max(0, childLeft), Max(0, childTop))
		CallSub3(mChild, "SetSize", Max(0, childWidth), Max(0, childHeight))
		CallSub(mChild, "Render")
	End If
End Sub