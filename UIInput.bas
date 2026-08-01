B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mText As String
	Private mHint As String
	Private mTextState As UIState
	Private mTextTarget As Object
	Private mTextEventName As String
	Private mTextColor As Int
	Private mBackgroundColor As Int
	Private mEditText As EditText
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
	Private mApplyingState As Boolean
End Sub

' Creates an empty native text input.
Public Sub Initialize As UIInput
	mText = ""
	mHint = ""
	mTextColor = Colors.Black
	mBackgroundColor = Colors.White
	mTextTarget = Null
	mTextEventName = ""
	mApplyingState = False
	Return Me
End Sub

' Sets the text shown when the input is empty.
Public Sub Hint(Value As String) As UIInput
	mHint = Value
	Return Me
End Sub

' Sets a static text value and removes any state binding.
Public Sub Text(Value As String) As UIInput
	UnbindText
	mText = Value
	If mEditText <> Null Then
		If mEditText.IsInitialized Then ApplyTextToNative
	End If
	Return Me
End Sub

' Binds the input text to a UIState.
' The binding is one-way: the host decides whether to update the state from OnTextChanged.
Public Sub BindText(State As UIState) As UIInput
	UnbindText
	mTextState = State
	If mTextState <> Null Then
		If mTextState.IsInitialized Then
			mText = "" & mTextState.GetState
			mTextState.Subscribe(Me, "TextState_Changed")
			If mEditText <> Null Then
				If mEditText.IsInitialized Then ApplyTextToNative
			End If
		End If
	End If
	Return Me
End Sub

' Removes the state binding while preserving the current input text.
Public Sub UnbindText As UIInput
	If mTextState <> Null Then
		If mTextState.IsInitialized Then mTextState.Unsubscribe(Me, "TextState_Changed")
	End If
	mTextState = Null
	Return Me
End Sub

' Registers a normal B4A callback for user edits.
' The callback signature is: Sub EventName(NewText As String)
Public Sub OnTextChanged(Target As Object, EventName As String) As UIInput
	mTextTarget = Target
	mTextEventName = EventName
	Return Me
End Sub

Public Sub TextColor(Color As Int) As UIInput
	mTextColor = Color
	Return Me
End Sub

Public Sub BackgroundColor(Color As Int) As UIInput
	mBackgroundColor = Color
	Return Me
End Sub

' Returns the currently displayed text.
Public Sub GetText As String
	If mEditText <> Null Then
		If mEditText.IsInitialized Then Return mEditText.Text
	End If
	Return mText
End Sub

Public Sub SetParent(Parent As B4XView)
	mParent = Parent
End Sub

Public Sub SetPosition(Left As Int, Top As Int)
	mLeft = Left
	mTop = Top
End Sub

Public Sub SetSize(Width As Int, Height As Int)
	mWidth = Max(0, Width)
	mHeight = Max(0, Height)
End Sub

Public Sub Render
	If mParent = Null Then Return
	If mParent.IsInitialized = False Then Return

	Dim needsCreate As Boolean = False
	If mEditText = Null Then
		needsCreate = True
	Else If mEditText.IsInitialized = False Then
		needsCreate = True
	End If
	If needsCreate Then
		Dim nativeInput As EditText
		nativeInput.Initialize("NativeInput")
		mEditText = nativeInput
		mBaseView = mEditText
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If

	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
	mEditText.TextColor = mTextColor
	mEditText.Color = mBackgroundColor
	mEditText.Hint = mHint
	mEditText.Gravity = Gravity.CENTER_VERTICAL
	ApplyTextToNative
End Sub

Private Sub ApplyTextToNative
	If mEditText = Null Then Return
	If mEditText.IsInitialized = False Then Return
	If mEditText.Text = mText Then Return
	' Programmatic updates must not be reported as user edits.
	mApplyingState = True
	mEditText.Text = mText
	mApplyingState = False
End Sub

Private Sub TextState_Changed(State As UIState)
	If State = Null Then Return
	If State.IsInitialized = False Then Return
	mText = "" & State.GetState
	ApplyTextToNative
End Sub

' Native B4A EditText event. The callback is intentionally not a two-way binding.
Private Sub NativeInput_TextChanged(Old As String, New As String)
	mText = New
	If mApplyingState Then Return
	If mTextTarget = Null Or mTextEventName.Trim = "" Then Return
	If xui.SubExists(mTextTarget, mTextEventName, 1) Then CallSub2(mTextTarget, mTextEventName, New)
End Sub

Public Sub Unmount
	If mBaseView <> Null Then
		If mBaseView.IsInitialized Then mBaseView.RemoveViewFromParent
	End If
	mEditText = Null
	mBaseView = Null
	mParent = Null
End Sub

' Natural measurement used by parent layout containers.
' The input keeps a touch-friendly minimum height and a measured text width.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize

	Dim measureText As String = mText
	If measureText = "" Then measureText = mHint
	Dim bmp As Bitmap
	bmp.InitializeMutable(1dip, 1dip)
	Dim cvs As Canvas
	cvs.Initialize2(bmp)
	Dim textWidth As Float = cvs.MeasureStringWidth(measureText, Typeface.DEFAULT, 16)
	Dim naturalWidth As Int = textWidth + 32dip
	Dim naturalHeight As Int = 48dip

	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	result.Add(Min(naturalWidth, safeMaxWidth))
	result.Add(Min(naturalHeight, safeMaxHeight))
	Return result
End Sub