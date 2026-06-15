B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mChild As Object
	Private mBaseView As B4XView
	Private mBgColor As Int
	Private mRadius As Int
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UICard
	mBgColor = Colors.White
	mRadius = 12dip
	mChild = Null
	Return Me
End Sub

Public Sub BackgroundColor(c As Int) As UICard
	mBgColor = c
	Return Me
End Sub

Public Sub CornerRadius(r As Int) As UICard
	mRadius = r
	Return Me
End Sub

Public Sub Child(c As Object) As UICard
	mChild = c
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
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	Dim NativePanel As Panel = mBaseView
	Dim cd As ColorDrawable
	cd.Initialize2(mBgColor, mRadius, 1dip, 0xFFE0E0E0)
	NativePanel.Background = cd
    
	If mChild <> Null Then
		CallSub2(mChild, "SetParent", mBaseView)
		CallSub3(mChild, "SetPosition", 0, 0)
		CallSub3(mChild, "SetSize", mWidth, mHeight)
		CallSub(mChild, "Render")
	End If
End Sub