B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mChildren As List
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UIColumn
	mChildren.Initialize
	Return Me
End Sub

Public Sub AddChild(child As Object) As UIColumn
	mChildren.Add(child)
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
    
	Dim currentTop As Int = 0
	Dim childHeight As Int = Height / mChildren.Size ' Distribución proporcional
    
	For Each child As Object In mChildren
		Dim dims(5) As Object = Array(mBaseView, 0, currentTop, Width, childHeight)
		CallSub3(child, "RenderBridge", dims, Null)
		currentTop = currentTop + childHeight
	Next
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub