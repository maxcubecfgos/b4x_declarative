B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mTitle As String
	Private mColor As Int
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIAppBar
	mTitle = ""
	mColor = 0xFF1976D2
	Return Me
End Sub

Public Sub Title(t As String) As UIAppBar
	mTitle = t
	Return Me
End Sub

Public Sub BackgroundColor(c As Int) As UIAppBar
	mColor = c
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
        
		' Lógica básica interna de UIAppBar
		Dim lbl As Label
		lbl.Initialize("")
		Dim xLbl As B4XView = lbl
		xLbl.Text = mTitle
		xLbl.TextColor = Colors.White
		xLbl.TextSize = 18
		mBaseView.AddView(xLbl, 16dip, 0, mWidth - 32dip, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
	mBaseView.Color = mColor
End Sub