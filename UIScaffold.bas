B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UIScaffold
Sub Class_Globals
	Private mAppBar As Object
	Private mBody As Object
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UIScaffold
	mAppBar = Null
	mBody = Null
	Return Me
End Sub

Public Sub AppBar(bar As Object) As UIScaffold
	mAppBar = bar
	Return Me
End Sub

Public Sub Body(b As Object) As UIScaffold
	mBody = b
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
    
	Dim appBarHeight As Int = 0
    
	' 1. Si hay AppBar, la dibujamos fija arriba (56dip es el estándar de Android)
	If mAppBar <> Null And SubExists(mAppBar, "RenderBridge") Then
		appBarHeight = 56dip
		Dim barDims(5) As Object
		barDims(0) = mBaseView
		barDims(1) = 0
		barDims(2) = 0
		barDims(3) = Width
		barDims(4) = appBarHeight
		CallSub3(mAppBar, "RenderBridge", barDims, Null)
	End If
    
	' 2. El cuerpo ocupa todo el espacio restante de la pantalla
	If mBody <> Null And SubExists(mBody, "RenderBridge") Then
		Dim bodyDims(5) As Object
		bodyDims(0) = mBaseView
		bodyDims(1) = 0
		bodyDims(2) = appBarHeight
		bodyDims(3) = Width
		bodyDims(4) = Height - appBarHeight
		CallSub3(mBody, "RenderBridge", bodyDims, Null)
	End If
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub