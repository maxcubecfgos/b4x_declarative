B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UICenter
Sub Class_Globals
	Private mChild As Object
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UICenter
	mChild = Null
	Return Me
End Sub

Public Sub Child(c As Object) As UICenter
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
		' Le damos al hijo un tamaño fijo o proporcional más controlado para evitar deformaciones
		' En el caso de filas/botones, limitamos la altura para que no actúe como un bloque gigante
		Dim childWidth As Int = Width
		Dim childHeight As Int = Height
        
		' Si el hijo es un contenedor como una Fila, limitamos su altura a un estándar de botón (48dip)
		If GetType(mChild).Contains("uirow") Then childHeight = Min(48dip, Height)
        
		Dim childLeft As Int = (Width - childWidth) / 2
		Dim childTop As Int = (Height - childHeight) / 2
        
		Dim dimensions(5) As Object
		dimensions(0) = mBaseView
		dimensions(1) = childLeft
		dimensions(2) = childTop
		dimensions(3) = childWidth
		dimensions(4) = childHeight
        
		CallSub3(mChild, "RenderBridge", dimensions, Null)
	End If
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub