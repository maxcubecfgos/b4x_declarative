B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mText As String
	Private mTextState As UIState
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
	' Clear the callback target so a new instance starts in a predictable state.
	mTarget = Null
	mEventName = ""
	Return Me
End Sub

Public Sub Text(t As String) As UIButton
	' An explicit text replaces any previous state binding.
	If mTextState <> Null Then
		If mTextState.IsInitialized Then mTextState.Unsubscribe(Me, "TextState_Changed")
	End If
	mTextState = Null
	mText = t
	Return Me
End Sub

' Binds the button text to an observable UIState.
Public Sub BindText(State As UIState) As UIButton
	If mTextState <> Null Then
		If mTextState.IsInitialized Then mTextState.Unsubscribe(Me, "TextState_Changed")
	End If
	mTextState = State
	If mTextState <> Null Then
		If mTextState.IsInitialized Then
			mText = "" & mTextState.GetState
			mTextState.Subscribe(Me, "TextState_Changed")
			If mParent <> Null Then
				If mParent.IsInitialized Then Render
			End If
		End If
	End If
	Return Me
End Sub

' Removes the text binding while preserving the current displayed text.
Public Sub UnbindText As UIButton
	If mTextState <> Null Then
		If mTextState.IsInitialized Then mTextState.Unsubscribe(Me, "TextState_Changed")
	End If
	mTextState = Null
	Return Me
End Sub

Private Sub TextState_Changed(State As UIState)
	If State = Null Then Return
	If State.IsInitialized = False Then Return
	mText = "" & State.GetState
	Render
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
	If mParent = Null Then
		Return
	End If
	If mParent.IsInitialized = False Then
		Return
	End If

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
	mBaseView.Tag = Me
	' Keep content buttons above remounted siblings so their touch surface remains available.
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
	Dim btn As Button = Sender
	Dim instance As UIButton = btn.Tag
	If instance = Null Then Return
	instance.DispatchClick
End Sub

' Dispatches the configured callback only when the target exposes it.
Private Sub DispatchClick
	If mTarget = Null Or mEventName.Trim = "" Then Return
	If xui.SubExists(mTarget, mEventName, 0) Then CallSub(mTarget, mEventName)
End Sub

Public Sub TriggerClick
	DispatchClick
End Sub

' Natural measurement used by parent layout containers.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	' Measure the button label with the standard B4A Canvas API.
	Dim bmp As Bitmap
	bmp.InitializeMutable(1dip, 1dip)
	Dim cvs As Canvas
	cvs.Initialize2(bmp)
	Dim textWidth As Float = cvs.MeasureStringWidth(mText, Typeface.DEFAULT, 14)
	
	' Use a Material-style horizontal padding and minimum height.
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