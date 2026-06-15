B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mChild As Object
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UICenter
	mChild = Null
	Return Me
End Sub

Public Sub Child(c As Object) As UICenter
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
		mBaseView.Color = Colors.Transparent
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	If mChild <> Null Then
		Dim childWidth As Int = mWidth
		Dim childHeight As Int = mHeight
        
		If GetType(mChild).Contains("uirow") Then childHeight = Min(48dip, mHeight)
        
		Dim childLeft As Int = (mWidth - childWidth) / 2
		Dim childTop As Int = (mHeight - childHeight) / 2
        
		CallSub2(mChild, "SetParent", mBaseView)
		CallSub3(mChild, "SetPosition", childLeft, childTop)
		CallSub3(mChild, "SetSize", childWidth, childHeight)
		CallSub(mChild, "Render")
	End If
End Sub