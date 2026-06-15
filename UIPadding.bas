B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UIPadding
Sub Class_Globals
	Private mChild As Object
	Private mBaseView As B4XView
	Private mTop, mBottom, mLeft, mRight As Int
End Sub

Public Sub Initialize As UIPadding
	mTop = 0 : mBottom = 0 : mLeft = 0 : mRight = 0
	mChild = Null
	Return Me
End Sub

' Margen uniforme para los 4 lados
Public Sub All(Value As Int) As UIPadding
	mTop = Value : mBottom = Value : mLeft = Value : mRight = Value
	Return Me
End Sub

' Márgenes simétricos por ejes
Public Sub Symmetric(Horizontal As Int, Vertical As Int) As UIPadding
	mLeft = Horizontal : mRight = Horizontal
	mTop = Vertical : mBottom = Vertical
	Return Me
End Sub

Public Sub Child(c As Object) As UIPadding
	mChild = c
	Return Me
End Sub

Public Sub Render(Parent As B4XView, Left As Int, Top As Int, Width As Int, Height As Int)
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		mBaseView.Color = Colors.Transparent
		Parent.AddView(mBaseView, Left, Top, Width, Height)
	End If
    
	mBaseView.SetLayoutAnimated(0, Left, Top, Width, Height)
    
	If mChild <> Null And SubExists(mChild, "RenderBridge") Then
		Dim childLeft As Int = mLeft
		Dim childTop As Int = mTop
		Dim childWidth As Int = Width - mLeft - mRight
		Dim childHeight As Int = Height - mTop - mBottom
        
		Dim dimensions(5) As Object
		dimensions(0) = mBaseView
		dimensions(1) = Max(0, childLeft)
		dimensions(2) = Max(0, childTop)
		dimensions(3) = Max(0, childWidth)
		dimensions(4) = Max(0, childHeight)
        
		CallSub3(mChild, "RenderBridge", dimensions, Null)
	End If
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub