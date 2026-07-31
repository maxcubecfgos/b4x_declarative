B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mText As String
	Private mBgColor As Int
	Private mTextColor As Int
	Private mTarget As Object
	Private mEventName As String
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIFloatingActionButton
	mText = "+"
	mBgColor = 0xFF00C853
	mTextColor = Colors.White
	' Clear the callback target so a new instance starts in a predictable state.
	mTarget = Null
	mEventName = ""
	Return Me
End Sub

Public Sub Text(t As String) As UIFloatingActionButton
	mText = t
	Return Me
End Sub

Public Sub BackgroundColor(c As Int) As UIFloatingActionButton
	mBgColor = c
	Return Me
End Sub

Public Sub OnClick(Target As Object, EventName As String) As UIFloatingActionButton
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
		' Keep the native Button directly in mBaseView and use Tag to recover this instance.
		Dim btn As Button
		btn.Initialize("FabBtn")
		mBaseView = btn
		mBaseView.Tag = Me
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	Dim btn As Button = mBaseView
	btn.Text = mText
	btn.TextSize = 24
	btn.TextColor = mTextColor
    
	Dim cd As ColorDrawable
	cd.Initialize2(mBgColor, mWidth / 2, 0, 0)
	btn.Background = cd
End Sub

Public Sub Unmount
	mBaseView = Null
	mParent = Null
End Sub

Private Sub FabBtn_Click
	Dim btn As Button = Sender
	Dim instance As UIFloatingActionButton = btn.Tag
	If instance = Null Then
		Return
	End If
	If instance.mTarget <> Null And instance.mEventName <> "" Then
		CallSub(instance.mTarget, instance.mEventName)
	Else
	End If
End Sub

' Natural measurement used by parent layout containers.
' Use the Material Design 56dip floating action button size.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	Dim fabSize As Int = 56dip
	
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	result.Add(Min(fabSize, safeMaxWidth))
	result.Add(Min(fabSize, safeMaxHeight))
	Return result
End Sub