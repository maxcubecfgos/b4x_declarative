B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mText As String
	Public mSize As Int
	Private mTextColor As Int
	Private mGravityValue As Int
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UILabel
	mText = ""
	mSize = 14
	mTextColor = Colors.Black
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
	If mBaseView.IsInitialized = False Then
		Dim lbl As Label
		lbl.Initialize("")
		mBaseView = lbl
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	Dim NativeLabel As Label = mBaseView
	NativeLabel.Text = mText
	NativeLabel.TextSize = mSize
	NativeLabel.TextColor = mTextColor
	NativeLabel.Gravity = mGravityValue
End Sub

Public Sub Unmount
	mBaseView = Null
	mParent = Null
End Sub

' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
' Retorna el tamaño NATURAL del texto para que Column/Row/Center
' puedan calcular layouts precisos.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	' Medir ancho usando Canvas.MeasureStringWidth (API estándar de B4A)
	Dim bmp As Bitmap
	bmp.InitializeMutable(1dip, 1dip)
	Dim cvs As Canvas
	cvs.Initialize2(bmp)
	Dim textWidth As Float = cvs.MeasureStringWidth(mText, Typeface.DEFAULT, mSize)
	
	' Altura aproximada: fontSize * 1.5 para espacio entre líneas
	Dim textHeight As Int = Max(mSize * 1.5, 20)
	
	' Acotar a los límites máximos disponibles
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	result.Add(Min(textWidth, safeMaxWidth))
	result.Add(Min(textHeight, safeMaxHeight))
	Return result
End Sub