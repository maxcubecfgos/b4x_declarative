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
	' PREVENCIÓN DE ERROR: Nulificamos el objetivo explícitamente
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
	Log("[DBG_UI] UIFloatingActionButton.OnClick text=" & mText & " event=" & mEventName & " targetSet=" & (mTarget <> Null))
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
	Log("[DBG_UI] UIFloatingActionButton.Render text=" & mText & " bounds=" & mLeft & "," & mTop & "," & mWidth & "," & mHeight & " targetSet=" & (mTarget <> Null) & " event=" & mEventName)
	If mParent = Null Then
		Log("[DBG_UI] UIFloatingActionButton.Render skipped: parent is Null")
		Return
	End If
	If mParent.IsInitialized = False Then
		Log("[DBG_UI] UIFloatingActionButton.Render skipped: parent is not initialized")
		Return
	End If

	Dim needsCreate As Boolean = False
	If mBaseView = Null Then
		needsCreate = True
	Else If mBaseView.IsInitialized = False Then
		needsCreate = True
	End If
	If needsCreate Then
		Log("[DBG_UI] UIFloatingActionButton.Render creating native Button eventPrefix=FabBtn")
		' REFACTOR: Mismo patrón que UIButton.
		' mBaseView es el Button directamente (no un Panel conteniendo un Button).
		' Usamos Tag = Me para recuperar la instancia en el evento Click.
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
	Log("[DBG_UI] UIFloatingActionButton.FabBtn_Click entered")
	Dim btn As Button = Sender
	Log("[DBG_UI] UIFloatingActionButton.FabBtn_Click senderTagSet=" & (btn.Tag <> Null))
	Dim instance As UIFloatingActionButton = btn.Tag
	If instance = Null Then
		Log("[DBG_UI] UIFloatingActionButton.FabBtn_Click stopped: Tag is Null")
		Return
	End If
	Log("[DBG_UI] UIFloatingActionButton.FabBtn_Click instanceText=" & instance.mText & " targetSet=" & (instance.mTarget <> Null) & " event=" & instance.mEventName)
	If instance.mTarget <> Null And instance.mEventName <> "" Then
		Log("[DBG_UI] UIFloatingActionButton.FabBtn_Click dispatching CallSub event=" & instance.mEventName)
		CallSub(instance.mTarget, instance.mEventName)
	Else
		Log("[DBG_UI] UIFloatingActionButton.FabBtn_Click stopped: target or event missing")
	End If
End Sub

' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
' FAB: tamaño fijo de 56dip (Material Design spec)
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