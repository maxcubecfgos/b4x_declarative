B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mChildren As List
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIColumn
	mChildren.Initialize
	Return Me
End Sub

Public Sub AddChild(child As Object) As UIColumn
	mChildren.Add(child)
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
	' 1. Inicializar contenedor
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	' 2. Posicionar hijos
	Dim yOffset As Int = 0
	For Each child As Object In mChildren
		CallSub2(child, "SetParent", mBaseView)
		CallSub3(child, "SetPosition", 0, yOffset)
		CallSub3(child, "SetSize", mWidth, 100dip) ' Damos una altura fija para probar
		CallSub(child, "Render")
		yOffset = yOffset + 110dip ' Sumamos altura + margen
	Next
End Sub