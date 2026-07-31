B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mText As String
	Private mColor As Int
	Private mTextColor As Int
	Private mTarget As Object
	Private mEventName As String
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIButton
	mText = ""
	mColor = Colors.LightGray
	mTextColor = Colors.Black
	' PREVENCIÓN DE ERROR: Nulificamos el objetivo explícitamente
	mTarget = Null
	mEventName = ""
	Return Me
End Sub

Public Sub Text(t As String) As UIButton
	mText = t
	Return Me
End Sub

Public Sub BackgroundColor(c As Int) As UIButton
	mColor = c
	Return Me
End Sub

Public Sub TextColor(c As Int) As UIButton
	mTextColor = c
	Return Me
End Sub

Public Sub OnClick(Target As Object, EventName As String) As UIButton
	mTarget = Target
	mEventName = EventName
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
	If mParent = Null Then Return
	If mParent.IsInitialized = False Then Return

	Dim needsCreate As Boolean = False
	If mBaseView = Null Then
		needsCreate = True
	Else If mBaseView.IsInitialized = False Then
		needsCreate = True
	End If
	If needsCreate Then
		Dim btn As Button
		btn.Initialize("NativeBtn")
		mBaseView = btn
		mBaseView.Tag = Me
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	If mBaseView.Text <> mText Then mBaseView.Text = mText
	If mBaseView.Color <> mColor Then mBaseView.Color = mColor
	If mBaseView.TextColor <> mTextColor Then mBaseView.TextColor = mTextColor
End Sub

Public Sub Unmount
	mBaseView = Null
	mParent = Null
End Sub

Private Sub NativeBtn_Click
	Dim btn As Button = Sender
	Dim instance As UIButton = btn.Tag
	instance.TriggerClick
End Sub

Public Sub TriggerClick
	If mTarget <> Null And mEventName <> "" Then
		' Diferir el callback evita reentrar en el árbol de vistas mientras
		' Android todavía está procesando el evento Click.
		CallSubDelayed(mTarget, mEventName)
	End If
End Sub

' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	' Medir el texto del botón usando Canvas.MeasureStringWidth (API estándar B4A)
	Dim bmp As Bitmap
	bmp.InitializeMutable(1dip, 1dip)
	Dim cvs As Canvas
	cvs.Initialize2(bmp)
	Dim textWidth As Float = cvs.MeasureStringWidth(mText, Typeface.DEFAULT, 14)
	
	' Botón Material Design: padding horizontal ~32dip, altura ~48dip
	Dim btnPadding As Int = 32dip
	Dim naturalWidth As Int = textWidth + btnPadding
	Dim naturalHeight As Int = 48dip
	
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	result.Add(Min(naturalWidth, safeMaxWidth))
	result.Add(Min(naturalHeight, safeMaxHeight))
	Return result
End Sub