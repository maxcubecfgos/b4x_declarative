B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mChild As Object
	Private mPadding As Int
End Sub

Public Sub Initialize(child As Object, padding As Int) As UIBox
	mChild = child
	mPadding = padding
	Return Me
End Sub

Public Sub RenderBridge(Args() As Object)
	Dim Parent As B4XView = Args(0)
	Dim L As Int = Args(1), T As Int = Args(2), W As Int = Args(3), H As Int = Args(4)
	' Aplicar padding de forma segura
	CallSub3(mChild, "RenderBridge", Array(Parent, L + mPadding, T + mPadding, W - (2 * mPadding), H - (2 * mPadding)), Null)
End Sub