B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mParent As B4XView
	Private mBaseView As B4XView
	Private mMessageLabel As B4XView
	Private mActionButton As B4XView
	Private mMessage As String
	Private mActionText As String
	Private mActionTarget As Object
	Private mActionEventName As String
	Private mDuration As Int
	Private mAnimationDuration As Int
	Private mBackgroundColor As Int
	Private mTextColor As Int
	Private mActionColor As Int
	Private mBackgroundColorOverridden As Boolean
	Private mTextColorOverridden As Boolean
	Private mActionColorOverridden As Boolean
	Private mTheme As UITheme
	Private mCornerRadius As Int
	Private mMargin As Int
	Private mHeight As Int
	Private mRunId As Int
	Private mVisible As Boolean
End Sub

' Creates a reusable transient notification.
Public Sub Initialize As UISnackBar
	mMessage = ""
	mActionText = ""
	mActionTarget = Null
	mActionEventName = ""
	mDuration = 3000
	mAnimationDuration = 180
	Dim defaultTheme As UITheme
	defaultTheme.Initialize
	mTheme = defaultTheme
	mBackgroundColor = mTheme.SnackbarBackground
	mTextColor = mTheme.SnackbarText
	mActionColor = mTheme.SnackbarAction
	mBackgroundColorOverridden = False
	mTextColorOverridden = False
	mActionColorOverridden = False
	mCornerRadius = 10dip
	mMargin = 16dip
	mHeight = 56dip
	mRunId = 0
	mVisible = False
	Return Me
End Sub

' Sets the message shown by the snackbar.
Public Sub Message(Text As String) As UISnackBar
	mMessage = Text
	If mMessageLabel <> Null Then
		If mMessageLabel.IsInitialized Then mMessageLabel.Text = mMessage
	End If
	Return Me
End Sub

' Adds an optional parameterless action callback.
Public Sub Action(Text As String, Target As Object, EventName As String) As UISnackBar
	mActionText = Text
	mActionTarget = Target
	mActionEventName = EventName
	If mVisible Then
		EnsureViews
		LayoutVisible
	End If
	Return Me
End Sub

' Sets the visible duration in milliseconds. Zero keeps the snackbar visible.
Public Sub Duration(Milliseconds As Int) As UISnackBar
	mDuration = Max(0, Milliseconds)
	Return Me
End Sub

' Sets the enter and exit animation duration in milliseconds.
Public Sub AnimationDuration(Milliseconds As Int) As UISnackBar
	mAnimationDuration = Max(0, Milliseconds)
	Return Me
End Sub

Public Sub BackgroundColor(Color As Int) As UISnackBar
	mBackgroundColor = Color
	mBackgroundColorOverridden = True
	ApplyAppearance
	Return Me
End Sub

Public Sub TextColor(Color As Int) As UISnackBar
	mTextColor = Color
	mTextColorOverridden = True
	ApplyAppearance
	Return Me
End Sub

Public Sub ActionColor(Color As Int) As UISnackBar
	mActionColor = Color
	mActionColorOverridden = True
	ApplyAppearance
	Return Me
End Sub

' Applies theme defaults without replacing explicit color overrides.
Public Sub ApplyTheme(Theme As UITheme) As UISnackBar
	If Theme = Null Then Return Me
	If Theme.IsInitialized = False Then Return Me
	mTheme = Theme
	If mBackgroundColorOverridden = False Then mBackgroundColor = mTheme.SnackbarBackground
	If mTextColorOverridden = False Then mTextColor = mTheme.SnackbarText
	If mActionColorOverridden = False Then mActionColor = mTheme.SnackbarAction
	ApplyAppearance
	Return Me
End Sub

Public Sub CornerRadius(Radius As Int) As UISnackBar
	mCornerRadius = Max(0, Radius)
	ApplyAppearance
	Return Me
End Sub

' Sets the horizontal distance from the parent edges.
Public Sub Margin(Value As Int) As UISnackBar
	mMargin = Max(0, Value)
	If mVisible Then LayoutVisible
	Return Me
End Sub

' Shows the snackbar over Parent. Parent is normally the Activity or a screen root.
Public Sub Show(Parent As B4XView) As UISnackBar
	If Parent = Null Then Return Me
	If Parent.IsInitialized = False Then Return Me
	If mParent <> Null And mParent.IsInitialized Then
		If mParent <> Parent Then RemoveNativeView
	End If
	mParent = Parent
	mRunId = mRunId + 1
	Dim currentRun As Int = mRunId
	mVisible = True
	EnsureViews
	Dim visibleTop As Int = Max(0, mParent.Height - mHeight - mMargin)
	LayoutVisible
	mBaseView.BringToFront
	If mAnimationDuration > 0 Then
		mBaseView.SetLayoutAnimated(0, mBaseView.Left, mParent.Height, mBaseView.Width, mBaseView.Height)
		mBaseView.SetLayoutAnimated(mAnimationDuration, mBaseView.Left, visibleTop, mBaseView.Width, mBaseView.Height)
	End If
	If mDuration > 0 Then AutoDismiss(currentRun)
	Return Me
End Sub

' Dismisses the snackbar and removes its native view after the exit animation.
Public Sub Dismiss As UISnackBar
	mRunId = mRunId + 1
	Dim currentRun As Int = mRunId
	If mBaseView = Null Then
		mVisible = False
		Return Me
	End If
	If mBaseView.IsInitialized = False Then
		mBaseView = Null
		mVisible = False
		Return Me
	End If
	mVisible = False
	If mParent <> Null And mParent.IsInitialized And mAnimationDuration > 0 Then
		mBaseView.SetLayoutAnimated(mAnimationDuration, mBaseView.Left, mParent.Height, mBaseView.Width, mBaseView.Height)
		FinishDismiss(currentRun)
	Else
		RemoveNativeView
	End If
	Return Me
End Sub

Public Sub IsVisible As Boolean
	Return mVisible
End Sub

' Removes the native view and cancels pending show/dismiss work.
Public Sub Unmount
	mRunId = mRunId + 1
	mVisible = False
	RemoveNativeView
	mParent = Null
End Sub

Private Sub EnsureViews
	If mBaseView = Null Or mBaseView.IsInitialized = False Then
		Dim panel As Panel
		panel.Initialize("")
		mBaseView = panel
		mParent.AddView(mBaseView, 0, mParent.Height, mParent.Width, mHeight)
	End If
	If mMessageLabel = Null Or mMessageLabel.IsInitialized = False Then
		Dim label As Label
		label.Initialize("")
		mMessageLabel = label
		mBaseView.AddView(mMessageLabel, 0, 0, mBaseView.Width, mBaseView.Height)
	End If
	If mActionText.Trim <> "" Then
		If mActionButton = Null Or mActionButton.IsInitialized = False Then
			Dim button As Button
			button.Initialize("SnackAction")
			mActionButton = button
			mBaseView.AddView(mActionButton, 0, 0, 0, mBaseView.Height)
		End If
	Else If mActionButton <> Null Then
		If mActionButton.IsInitialized Then mActionButton.RemoveViewFromParent
		mActionButton = Null
	End If
	ApplyAppearance
End Sub

Private Sub ApplyAppearance
	If mBaseView = Null Then Return
	If mBaseView.IsInitialized = False Then Return
	Dim panel As Panel = mBaseView
	Dim background As ColorDrawable
	background.Initialize2(mBackgroundColor, mCornerRadius, 0, Colors.Transparent)
	panel.Background = background
	If mMessageLabel <> Null Then
		If mMessageLabel.IsInitialized Then
			Dim nativeLabel As Label = mMessageLabel
			nativeLabel.Text = mMessage
			nativeLabel.TextColor = mTextColor
			nativeLabel.TextSize = 14
			nativeLabel.Gravity = Bit.Or(Gravity.CENTER_VERTICAL, Gravity.LEFT)
		End If
	End If
	If mActionButton <> Null Then
		If mActionButton.IsInitialized Then
			Dim nativeButton As Button = mActionButton
			nativeButton.Text = mActionText
			nativeButton.TextColor = mActionColor
			nativeButton.TextSize = 13
			nativeButton.Gravity = Gravity.CENTER
			nativeButton.Color = Colors.Transparent
			nativeButton.Tag = Me
		End If
	End If
End Sub

Private Sub LayoutVisible
	If mParent = Null Or mBaseView = Null Then Return
	If mParent.IsInitialized = False Or mBaseView.IsInitialized = False Then Return
	Dim width As Int = Max(0, mParent.Width - 2 * mMargin)
	Dim left As Int = mMargin
	Dim top As Int = Max(0, mParent.Height - mHeight - mMargin)
	mBaseView.SetLayoutAnimated(0, left, top, width, mHeight)
	Dim actionWidth As Int = 0
	If mActionButton <> Null Then
		If mActionButton.IsInitialized Then actionWidth = 88dip
	End If
	Dim messageWidth As Int = Max(0, width - 32dip - actionWidth)
	mMessageLabel.SetLayoutAnimated(0, 16dip, 0, messageWidth, mHeight)
	If mActionButton <> Null Then
		If mActionButton.IsInitialized Then mActionButton.SetLayoutAnimated(0, width - actionWidth - 8dip, 0, actionWidth, mHeight)
	End If
End Sub

Private Sub AutoDismiss(RunId As Int)
	Sleep(mDuration)
	If RunId <> mRunId Or mVisible = False Then Return
	Dismiss
End Sub

Private Sub FinishDismiss(RunId As Int)
	Sleep(mAnimationDuration)
	If RunId <> mRunId Then Return
	If mBaseView = Null Then Return
	If mBaseView.IsInitialized = False Then Return
	RemoveNativeView
End Sub

Private Sub RemoveNativeView
	If mBaseView <> Null Then
		If mBaseView.IsInitialized Then mBaseView.RemoveViewFromParent
	End If
	mBaseView = Null
	mMessageLabel = Null
	mActionButton = Null
End Sub

Private Sub SnackAction_Click
	Dim button As Button = Sender
	Dim snack As UISnackBar = button.Tag
	If snack = Null Then Return
	Dim actionTarget As Object = snack.mActionTarget
	Dim actionEventName As String = snack.mActionEventName
	snack.Dismiss
	If actionTarget <> Null And actionEventName.Trim <> "" Then
		If xui.SubExists(actionTarget, actionEventName, 0) Then CallSub(actionTarget, actionEventName)
	End If
End Sub
