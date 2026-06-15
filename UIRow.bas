B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UIRow (Versión Flex Avanzada)
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
		mBaseView.Color = Colors.Transparent
		Parent.AddView(mBaseView, Left, Top, Width, Height)
	End If
    
	mBaseView.SetLayoutAnimated(0, Left, Top, Width, Height)
    
	If mChildren.Size = 0 Then Return
    
	' Contamos cuántos hijos son de tipo "UIExpanded" y cuántos son fijos (como UISpace)
	Dim expandedCount As Int = 0
	Dim fixedWidthsTotal As Int = 0
	Dim fixedSpaceWidth As Int = 12dip ' Tamaño estándar de un UISpace horizontal
    
	For Each child As Object In mChildren
		If GetType(child).Contains("uiexpanded") Then
			expandedCount = expandedCount + 1
		Else If GetType(child).Contains("uispace") Then
			fixedWidthsTotal = fixedWidthsTotal + fixedSpaceWidth
		End If
	Next
    
	' El espacio sobrante se divide equitativamente solo entre los objetos Expanded
	Dim remainingWidth As Int = Width - fixedWidthsTotal
	Dim expandedWidth As Int = 0
	If expandedCount > 0 Then expandedWidth = remainingWidth / expandedCount
    
	Dim currentLeft As Int = 0
    
	For Each child As Object In mChildren
		Dim currentWidth As Int = 0
		Dim targetObject As Object = child
        
		If GetType(child).Contains("uiexpanded") Then
			currentWidth = expandedWidth
			' Extraemos el hijo real de adentro del envoltorio Expanded
			Dim exp As UIExpanded = child
			targetObject = exp.GetChild
		Else If GetType(child).Contains("uispace") Then
			currentWidth = fixedSpaceWidth
		Else
			' Si no es ni expanded ni space, le damos un tamaño por defecto
			currentWidth = remainingWidth / Max(1, mChildren.Size)
		End If
        
		Dim dimensions(5) As Object
		dimensions(0) = mBaseView
		dimensions(1) = currentLeft
		dimensions(2) = 0
		dimensions(3) = currentWidth
		dimensions(4) = Height
        
		If SubExists(targetObject, "RenderBridge") Then
			CallSub3(targetObject, "RenderBridge", dimensions, Null)
		End If
        
		currentLeft = currentLeft + currentWidth
	Next
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub