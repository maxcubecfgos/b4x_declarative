B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UICard
Sub Class_Globals
	Private mChild As Object
	Private mBaseView As B4XView
	Private mBgColor As Int
	Private mRadius As Int
End Sub

Public Sub Initialize As UICard
	mBgColor = Colors.White
	mRadius = 12dip ' Ajustado a 12dip para que haga juego con el nuevo diseño
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

Public Sub Render(Parent As B4XView, Left As Int, Top As Int, Width As Int, Height As Int)
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		Parent.AddView(mBaseView, Left, Top, Width, Height)
	End If
    
	mBaseView.SetLayoutAnimated(0, Left, Top, Width, Height)
    
	' Solución al error de background en B4XView aplicando casteo nativo
	Dim NativePanel As Panel = mBaseView
	Dim cd As ColorDrawable
	cd.Initialize2(mBgColor, mRadius, 1dip, 0xFFE0E0E0) ' Borde gris sutil
	NativePanel.Background = cd
    
	' Renderizamos el hijo único
	If mChild <> Null And SubExists(mChild, "RenderBridge") Then
		Dim dimensions(5) As Object
		dimensions(0) = mBaseView
		dimensions(1) = 0
		dimensions(2) = 0
		dimensions(3) = Width
		dimensions(4) = Height
		CallSub3(mChild, "RenderBridge", dimensions, Null)
	End If
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub