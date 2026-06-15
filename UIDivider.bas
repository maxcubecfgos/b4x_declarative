B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Clase: UIDivider
Sub Class_Globals
	Private mBaseView As B4XView
	Private mColor As Int = 0xFFE0E0E0
End Sub

Public Sub Initialize As UIDivider
	Return Me
End Sub

Public Sub Render(Parent As B4XView, Left As Int, Top As Int, Width As Int, Height As Int)
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		Parent.AddView(mBaseView, Left, Top, Width, Height)
	End If
	mBaseView.SetLayoutAnimated(0, Left, Top + 8dip, Width, 1dip)
	mBaseView.Color = mColor
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub