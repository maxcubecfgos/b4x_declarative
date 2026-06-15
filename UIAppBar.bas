B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UIAppBar
Sub Class_Globals
	Private mTitle As String
	Private mBgColor As Int
	Private mTextColor As Int
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UIAppBar
	mTitle = ""
	mBgColor = 0xFF1976D2 ' Azul Material estándar
	mTextColor = Colors.White
	Return Me
End Sub

Public Sub Title(t As String) As UIAppBar
	mTitle = t
	Return Me
End Sub

Public Sub BackgroundColor(c As Int) As UIAppBar
	mBgColor = c
	Return Me
End Sub

Public Sub TextColor(c As Int) As UIAppBar
	mTextColor = c
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
	mBaseView.Color = mBgColor
    
	' Agregamos el texto de la barra de forma interna
	Dim lbl As Label
	If mBaseView.NumberOfViews = 0 Then
		lbl.Initialize("")
		Dim xLbl As B4XView = lbl
		mBaseView.AddView(xLbl, 16dip, 0, Width - 32dip, Height)
	Else
		Dim xLbl As B4XView = mBaseView.GetView(0)
		lbl = xLbl
	End If
    
	lbl.Text = mTitle
	lbl.TextColor = mTextColor
	lbl.TextSize = 20
	lbl.Gravity = Bit.Or(Gravity.LEFT, Gravity.CENTER_VERTICAL)
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub