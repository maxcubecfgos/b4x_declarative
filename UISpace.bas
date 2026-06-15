B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UISpace
Sub Class_Globals
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UISpace
	Return Me
End Sub

Public Sub Render(Parent As B4XView, Left As Int, Top As Int, Width As Int, Height As Int)
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		' Lo hacemos transparente
		mBaseView.Color = Colors.Transparent
		Parent.AddView(mBaseView, Left, Top, Width, Height)
	End If
	mBaseView.SetLayoutAnimated(0, Left, Top, Width, Height)
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub