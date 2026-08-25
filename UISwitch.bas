B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mText As String
	Private mTextState As UIState
	Private mChecked As Boolean
	Private mCheckedState As UIState
	Private mTextColor As Int
	Private mBackgroundColor As Int
	Private mTextSize As Int
	Private mTextColorOverridden As Boolean
	Private mBackgroundColorOverridden As Boolean
	Private mTextSizeOverridden As Boolean
	Private mTheme As UITheme
	Private mTarget As Object
	Private mEventName As String
	Private mBaseView As B4XView
	Private mBasePanel As B4XView
	Private mLabelView As B4XView
	Private mTrackView As B4XView
	Private mThumbView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
	Private mTrackWidth, mTrackHeight, mThumbSize As Int
	Private mMeasureHost As B4XView
	Private mMeasureCanvas As B4XCanvas
End Sub

Public Sub Initialize As UISwitch
	mText = ""
	mTextState = Null
	mChecked = False
	mCheckedState = Null
	Dim defaultTheme As UITheme
	defaultTheme.Initialize
	mTheme = defaultTheme
	mTextColor = mTheme.PrimaryText
	mBackgroundColor = mTheme.SurfaceVariant
	mTextSize = mTheme.BodyLarge
	mTextColorOverridden = False
	mBackgroundColorOverridden = False
	mTextSizeOverridden = False
	mTarget = Null
	mEventName = ""
	mBaseView = Null
	mBasePanel = Null
	mLabelView = Null
	mTrackView = Null
	mThumbView = Null
	mParent = Null
	mTrackWidth = 52dip
	mTrackHeight = 32dip
	mThumbSize = 24dip
	Return Me
End Sub

Public Sub Text(Value As String) As UISwitch
	UnbindText
	mText = Value
	ApplyTextToNative
	Return Me
End Sub

Public Sub BindText(State As UIState) As UISwitch
	UnbindText
	mTextState = State
	If mTextState <> Null Then
		If mTextState.IsInitialized Then
			mText = StateText(mTextState.GetState)
			mTextState.Subscribe(Me, "TextState_Changed")
			ApplyTextToNative
		End If
	End If
	Return Me
End Sub

Public Sub UnbindText As UISwitch
	If mTextState <> Null Then
		If mTextState.IsInitialized Then mTextState.Unsubscribe(Me, "TextState_Changed")
	End If
	mTextState = Null
	Return Me
End Sub

Public Sub Checked(Value As Boolean) As UISwitch
	UnbindChecked
	mChecked = Value
	ApplyVisualState
	Return Me
End Sub

Public Sub IsChecked As Boolean
	Return mChecked
End Sub

Public Sub BindChecked(State As UIState) As UISwitch
	UnbindChecked
	mCheckedState = State
	If mCheckedState <> Null Then
		If mCheckedState.IsInitialized Then
			mChecked = ReadBoolean(mCheckedState.GetState)
			mCheckedState.Subscribe(Me, "CheckedState_Changed")
			ApplyVisualState
		End If
	End If
	Return Me
End Sub

Public Sub UnbindChecked As UISwitch
	If mCheckedState <> Null Then
		If mCheckedState.IsInitialized Then mCheckedState.Unsubscribe(Me, "CheckedState_Changed")
	End If
	mCheckedState = Null
	Return Me
End Sub

' Callback signature: Sub EventName(Checked As Boolean)
Public Sub OnChanged(Target As Object, EventName As String) As UISwitch
	mTarget = Target
	mEventName = EventName
	Return Me
End Sub

Public Sub OnCheckedChanged(Target As Object, EventName As String) As UISwitch
	Return OnChanged(Target, EventName)
End Sub

Public Sub TextColor(Color As Int) As UISwitch
	mTextColor = Color
	mTextColorOverridden = True
	ApplyTextColorToNative
	Return Me
End Sub

Public Sub BackgroundColor(Color As Int) As UISwitch
	mBackgroundColor = Color
	mBackgroundColorOverridden = True
	ApplyVisualState
	Return Me
End Sub

Public Sub TextSize(Size As Int) As UISwitch
	mTextSize = Max(1, Size)
	mTextSizeOverridden = True
	ApplyTextSizeToNative
	Return Me
End Sub

Public Sub ApplyTheme(Theme As UITheme) As UISwitch
	If Theme = Null Then Return Me
	If Theme.IsInitialized = False Then Return Me
	mTheme = Theme
	If mTextColorOverridden = False Then mTextColor = mTheme.PrimaryText
	If mBackgroundColorOverridden = False Then mBackgroundColor = mTheme.SurfaceVariant
	If mTextSizeOverridden = False Then mTextSize = mTheme.BodyLarge
	If mParent <> Null Then
		If mParent.IsInitialized Then Render
	End If
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
	mWidth = Max(0, Width)
	mHeight = Max(0, Height)
End Sub

Public Sub Render
	If mParent = Null Then Return
	If mParent.IsInitialized = False Then Return
	If mTextState <> Null Then
		If mTextState.IsInitialized Then
			mText = StateText(mTextState.GetState)
			mTextState.Subscribe(Me, "TextState_Changed")
		End If
	End If
	If mCheckedState <> Null Then
		If mCheckedState.IsInitialized Then
			mChecked = ReadBoolean(mCheckedState.GetState)
			mCheckedState.Subscribe(Me, "CheckedState_Changed")
		End If
	End If

	Dim needsCreate As Boolean = False
	If mBasePanel = Null Then
		needsCreate = True
	Else If mBasePanel.IsInitialized = False Then
		needsCreate = True
	End If
	If needsCreate Then
		#If B4A
		mBasePanel = xui.CreatePanel("NativeSwitchTrack")
		#Else
		mBasePanel = xui.CreatePanel("")
		#End If
		mBaseView = mBasePanel
		mBaseView.Color = xui.Color_Transparent
		mBaseView.Tag = Me
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)

		Dim label As Label
		#If B4A
		label.Initialize("NativeSwitchTrack")
		#Else
		label.Initialize("")
		#End If
		mLabelView = label
		mBaseView.AddView(mLabelView, 0, 0, 1dip, mHeight)

		#If B4A
		mTrackView = xui.CreatePanel("NativeSwitchTrack")
		#Else
		mTrackView = xui.CreatePanel("")
		#End If
		mBaseView.AddView(mTrackView, 0, 0, mTrackWidth, mTrackHeight)

		#If B4A
		mThumbView = xui.CreatePanel("NativeSwitchTrack")
		#Else
		mThumbView = xui.CreatePanel("")
		#End If
		mTrackView.AddView(mThumbView, 0, 0, mThumbSize, mThumbSize)
	End If
	If mBaseView.Parent <> mParent Then
		If mBaseView.Parent <> Null Then mBaseView.RemoveViewFromParent
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If		mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
		mBaseView.Tag = Me

#If B4J
	' B4J: xui.CreatePanel prefix dispatch doesn't fire mouse events on Pane.
	' Wire explicitly via JavaFX EventHandler.
	Dim baseJO As JavaObject = mBaseView
	Dim handler As Object = baseJO.CreateEvent("javafx.event.EventHandler", "SwitchClick", False)
	baseJO.RunMethod("setOnMouseClicked", Array(handler))
#End If

		LayoutParts
	ApplyTextToNative
	ApplyTextColorToNative
	ApplyTextSizeToNative
	ApplyVisualState
End Sub

Private Sub LayoutParts
	If mBaseView = Null Then Return
	If mBaseView.IsInitialized = False Then Return
	If mLabelView = Null Or mTrackView = Null Then Return
	If mLabelView.IsInitialized = False Or mTrackView.IsInitialized = False Then Return

	Dim trackWidth As Int = Min(mTrackWidth, mWidth)
	Dim labelLeft As Int = trackWidth + 12dip
	Dim labelWidth As Int = Max(0, mWidth - labelLeft)
	If mText.Trim = "" Then labelWidth = 0
	Dim trackTop As Int = Max(0, (mHeight - mTrackHeight) / 2)
	mTrackView.SetLayoutAnimated(0, 0, trackTop, trackWidth, mTrackHeight)
	mLabelView.SetLayoutAnimated(0, labelLeft, 0, labelWidth, mHeight)
	#If B4A
	Dim nativeLabel As Label = mLabelView
	nativeLabel.Gravity = Gravity.CENTER_VERTICAL
	#Else
	mLabelView.SetTextAlignment("CENTER", "CENTER")
	#End If
	Dim thumbLeft As Int = 4dip
	If mChecked Then thumbLeft = Max(0, trackWidth - mThumbSize - 4dip)
	Dim thumbTop As Int = (mTrackHeight - mThumbSize) / 2
	mThumbView.SetLayoutAnimated(0, thumbLeft, thumbTop, mThumbSize, mThumbSize)
End Sub

Private Sub ApplyTextToNative
	If mLabelView = Null Then Return
	If mLabelView.IsInitialized = False Then Return
	mLabelView.Text = mText
End Sub

Private Sub ApplyTextColorToNative
	If mLabelView = Null Then Return
	If mLabelView.IsInitialized = False Then Return
	mLabelView.TextColor = mTextColor
End Sub

Private Sub ApplyTextSizeToNative
	If mLabelView = Null Then Return
	If mLabelView.IsInitialized = False Then Return
	mLabelView.TextSize = mTextSize
End Sub

Private Sub ApplyVisualState
	If mTrackView = Null Or mThumbView = Null Then Return
	If mTrackView.IsInitialized = False Or mThumbView.IsInitialized = False Then Return

	Dim trackColor As Int = mBackgroundColor
	If mChecked Then trackColor = mTheme.Accent
	mTrackView.SetColorAndBorder(trackColor, 0, 0, mTrackHeight / 2)

	Dim thumbColor As Int = xui.Color_White
	If mChecked = False Then thumbColor = mTheme.MutedText
	mThumbView.SetColorAndBorder(thumbColor, 0, 0, mThumbSize / 2)
	LayoutParts
End Sub

Private Sub CheckedState_Changed(State As UIState)
	If State = Null Then Return
	If State.IsInitialized = False Then Return
	mChecked = ReadBoolean(State.GetState)
	ApplyVisualState
End Sub

Private Sub NativeSwitchTrack_Touch(Action As Int, X As Float, Y As Float)
	If Action <> 1 Then Return
	ToggleChecked
End Sub

#If B4J
' B4J: Events wired via JavaObject.CreateEvent (see Render sub)
Private Sub SwitchClick_Event(MethodName As String, Args() As Object) As Object
	ToggleChecked
	Return Null
End Sub
#End If

' Shared flip logic for both platform input paths.
Private Sub ToggleChecked
	mChecked = Not(mChecked)
	If mCheckedState <> Null Then
		If mCheckedState.IsInitialized Then mCheckedState.SetState(mChecked)
	End If
	ApplyVisualState
	If mTarget = Null Then Return
	If mEventName.Trim = "" Then Return
	If SubExists(mTarget, mEventName) Then CallSub2(mTarget, mEventName, mChecked)
End Sub

Private Sub ReadBoolean(Value As Object) As Boolean
	If Value = Null Then Return False
	Dim normalized As String = ("" & Value).Trim.ToLowerCase
	If normalized = "true" Then Return True
	If normalized = "false" Or normalized = "" Then Return False
	If IsNumber(normalized) Then
		Dim numericValue As Double = normalized
		Return numericValue <> 0
	End If
	Return False
End Sub

Private Sub StateText(Value As Object) As String
	If Value = Null Then Return ""
	Return "" & Value
End Sub

Public Sub Detach
	If mBaseView <> Null Then
		If mBaseView.IsInitialized Then
			If mBaseView.Parent <> Null Then mBaseView.RemoveViewFromParent
		End If
	End If
	mParent = Null
End Sub

Public Sub Unmount
	If mTextState <> Null Then
		If mTextState.IsInitialized Then mTextState.Unsubscribe(Me, "TextState_Changed")
	End If
	If mCheckedState <> Null Then
		If mCheckedState.IsInitialized Then mCheckedState.Unsubscribe(Me, "CheckedState_Changed")
	End If
	If mBaseView <> Null Then
		If mBaseView.IsInitialized Then mBaseView.RemoveViewFromParent
	End If
	mBasePanel = Null
	mBaseView = Null
	mLabelView = Null
	mTrackView = Null
	mThumbView = Null
	mParent = Null
End Sub

Public Sub GetView As B4XView
	If mBaseView = Null Then Return Null
	If mBaseView.IsInitialized = False Then Return Null
	Return mBaseView
End Sub

Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	Dim cvs As B4XCanvas = MeasureEngine
	Dim r As B4XRect = cvs.MeasureText(mText, xui.CreateDefaultFont(mTextSize))
	Dim textWidth As Float = r.Width
	Dim naturalWidth As Int = textWidth + 12dip + mTrackWidth
	Dim naturalHeight As Int = Max(mTheme.ControlHeight, mTrackHeight)
	result.Add(Min(naturalWidth, safeMaxWidth))
	result.Add(Min(naturalHeight, safeMaxHeight))
	Return result
End Sub

' Returns the shared measurement engine. The host panel is never mounted,
' so measuring cannot affect any visible view (on B4J Initialize inserts
' the canvas as a child node of the host).
Private Sub MeasureEngine As B4XCanvas
	If mMeasureHost <> Null Then
		If mMeasureHost.IsInitialized Then Return mMeasureCanvas
	End If
	mMeasureHost = xui.CreatePanel("")
	Dim cvs As B4XCanvas
	cvs.Initialize(mMeasureHost)
	mMeasureCanvas = cvs
	Return mMeasureCanvas
End Sub