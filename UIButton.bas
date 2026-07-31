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
	Log("[DBG_UI] UIButton.OnClick text=" & mText & " event=" & mEventName & " targetSet=" & (mTarget <> Null))
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
	Log("[DBG_UI] UIButton.Render text=" & mText & " bounds=" & mLeft & "," & mTop & "," & mWidth & "," & mHeight & " targetSet=" & (mTarget <> Null) & " event=" & mEventName)
	If mParent = Null Then
		Log("[DBG_UI] UIButton.Render skipped: parent is Null")
		Return
	End If
	If mParent.IsInitialized = False Then
		Log("[DBG_UI] UIButton.Render skipped: parent is not initialized")
		Return
	End If

	Dim needsCreate As Boolean = False
	If mBaseView = Null Then
		needsCreate = True
	Else If mBaseView.IsInitialized = False Then
		needsCreate = True
	End If
	If needsCreate Then
		Log("[DBG_UI] UIButton.Render creating native Button eventPrefix=NativeBtn")
		Dim btn As Button
		btn.Initialize("NativeBtn")
		mBaseView = btn
		mBaseView.Tag = Me
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
	mBaseView.Tag = Me
	' Los botones de contenido pueden quedar detrás de otro hijo durante un remount.
	' Asegurar su orden Z mantiene también intacta su superficie táctil.
	mBaseView.BringToFront
    
	If mBaseView.Text <> mText Then mBaseView.Text = mText
	If mBaseView.Color <> mColor Then mBaseView.Color = mColor
	If mBaseView.TextColor <> mTextColor Then mBaseView.TextColor = mTextColor
End Sub

Public Sub Unmount
	mBaseView = Null
	mParent = Null
End Sub

Private Sub NativeBtn_Click
	Log("[DBG_UI] UIButton.NativeBtn_Click entered")
	Dim btn As Button = Sender
	Log("[DBG_UI] UIButton.NativeBtn_Click senderTagSet=" & (btn.Tag <> Null))
	Dim instance As UIButton = btn.Tag
	If instance = Null Then
		Log("[DBG_UI] UIButton.NativeBtn_Click stopped: Tag is Null")
		Return
	End If
	Log("[DBG_UI] UIButton.NativeBtn_Click instanceText=" & instance.mText & " targetSet=" & (instance.mTarget <> Null) & " event=" & instance.mEventName)
	If instance.mTarget <> Null And instance.mEventName <> "" Then
		Log("[DBG_UI] UIButton.NativeBtn_Click dispatching CallSub event=" & instance.mEventName)
		' Usar el mismo dispatch síncrono que UIFloatingActionButton.
		CallSub(instance.mTarget, instance.mEventName)
	Else
		Log("[DBG_UI] UIButton.NativeBtn_Click stopped: target or event missing")
	End If
End Sub

Public Sub TriggerClick
	If mTarget = Null Or mEventName = "" Then Return
	CallSub(mTarget, mEventName)
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