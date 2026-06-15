B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UIColumn
Sub Class_Globals
	Private mChildren As List
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UIColumn
	mChildren.Initialize
	Return Me
End Sub

Public Sub AddChild(Component As Object) As UIColumn
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
    
	' Layout Engine Inteligente: Identifica espacios fijos y distribuye el resto
	Dim spacesCount As Int = 0
	For Each child As Object In mChildren
		If GetType(child).Contains("uispace") Then spacesCount = spacesCount + 1
	Next
    
	Dim currentTop As Int = 0
	Dim fixedSpaceHeight As Int = 24dip ' Tamaño estándar para los objetos UISpace
    
	' El resto del espacio se divide entre los widgets reales
	Dim realWidgetsCount As Int = mChildren.Size - spacesCount
	Dim remainingHeight As Int = Height - (spacesCount * fixedSpaceHeight)
	Dim widgetHeight As Int = remainingHeight / Max(1, realWidgetsCount)
    
	For Each child As Object In mChildren
		Dim currentHeight As Int = widgetHeight
		If GetType(child).Contains("uispace") Then currentHeight = fixedSpaceHeight
        
		Dim dimensions(5) As Object
		dimensions(0) = mBaseView
		dimensions(1) = 0
		dimensions(2) = currentTop
		dimensions(3) = Width
		dimensions(4) = currentHeight
        
		If SubExists(child, "RenderBridge") Then
			CallSub3(child, "RenderBridge", dimensions, Null)
		End If
        
		currentTop = currentTop + currentHeight
	Next
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub