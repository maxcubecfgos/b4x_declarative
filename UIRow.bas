B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UIRow
Sub Class_Globals
	Private mChildren As List
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UIRow
	mChildren.Initialize
	Return Me
End Sub

Public Sub AddChild(Component As Object) As UIRow
	mChildren.Add(Component)
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
    
	If mChildren.Size = 0 Then Return
    
	Dim currentLeft As Int = 0
	Dim childWidth As Int = Width / mChildren.Size
    
	For Each child As Object In mChildren
		Dim dimensions(5) As Object
		dimensions(0) = mBaseView
		dimensions(1) = currentLeft
		dimensions(2) = 0
		dimensions(3) = childWidth
		dimensions(4) = Height
        
		' SOLUCIÓN: Verificación explícita de firmas dinámicas
		If SubExists(child, "RenderBridge") Then
			CallSub3(child, "RenderBridge", dimensions, Null)
		Else
			Log("Error crítico: El objeto " & GetType(child) & " no tiene implementado RenderBridge")
		End If
        
		currentLeft = currentLeft + childWidth
	Next
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub