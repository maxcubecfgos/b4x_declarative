B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UILabel
Sub Class_Globals
	Private mText As String
	Private mTextSize As Float
	Private mTextColor As Int
	Private mGravity As Int
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UILabel
	mText = ""
	mTextSize = 16
	mTextColor = Colors.Black
	mGravity = Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL)
	Return Me
End Sub

Public Sub Text(t As String) As UILabel
	mText = t
	Return Me
End Sub

Public Sub Size(s As Float) As UILabel
	mTextSize = s
	Return Me
End Sub

Public Sub Color(c As Int) As UILabel
	mTextColor = c
	Return Me
End Sub

Public Sub AlignLeft As UILabel
	mGravity = Bit.Or(Gravity.LEFT, Gravity.CENTER_VERTICAL)
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
    
	If mBaseView.Text <> mText Then mBaseView.Text = mText
    
	' Corrección: Casteo a Label nativo y asignación correcta de gravedad
	Dim nativeLabel As Label = mBaseView
	nativeLabel.Gravity = mGravity
    
	If nativeLabel.TextSize <> mTextSize Then nativeLabel.TextSize = mTextSize
	If nativeLabel.TextColor <> mTextColor Then nativeLabel.TextColor = mTextColor
End Sub

' Añade esto al final de la clase UILabel para habilitar el puente de paso de parámetros
Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub