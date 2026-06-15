B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UILabel
Sub Class_Globals
	Private mText As String
	Public mSize As Int
	Private mTextColor As Int
	Private mGravityValue As Int ' <-- Cambiado para evitar conflictos de nombres
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UILabel
	mText = ""
	mSize = 14
	mTextColor = Colors.Black
	' Usamos el objeto global nativo sin problemas aquí
	mGravityValue = Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL)
	Return Me
End Sub

Public Sub Text(t As String) As UILabel
	mText = t
	Return Me
End Sub

Public Sub Size(s As Int) As UILabel
	mSize = s
	Return Me
End Sub

Public Sub Color(c As Int) As UILabel
	mTextColor = c
	Return Me
End Sub

' CORRECCIÓN: Renombramos el método a TextGravity para que no choque con la palabra reservada
Public Sub TextGravity(g As Int) As UILabel
	mGravityValue = g
	Return Me
End Sub

Public Sub Render(Parent As B4XView, Left As Int, Top As Int, Width As Int, Height As Int)
	If mBaseView.IsInitialized = False Then
		Dim lbl As Label
		lbl.Initialize("")
		mBaseView = lbl
		Parent.AddView(mBaseView, Left, Top, Width, Height)
	End If
    
	mBaseView.SetLayoutAnimated(0, Left, Top, Width, Height)
    
	Dim NativeLabel As Label = mBaseView
	NativeLabel.Text = mText
	NativeLabel.TextSize = mSize
	NativeLabel.TextColor = mTextColor
	NativeLabel.Gravity = mGravityValue
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub