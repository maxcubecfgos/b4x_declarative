B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mText As String
	Private mColor As Int
	Private mTarget As Object
	Private mEventName As String
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIButton
	mText = ""
	mColor = Colors.LightGray
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
	If mBaseView.IsInitialized = False Then
		Dim btn As Button
		btn.Initialize("NativeBtn")
		mBaseView = btn
		mBaseView.Tag = Me
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	If mBaseView.Text <> mText Then mBaseView.Text = mText
	If mBaseView.Color <> mColor Then mBaseView.Color = mColor
End Sub

Private Sub NativeBtn_Click
	Dim btn As Button = Sender
	Dim instance As UIButton = btn.Tag
	instance.TriggerClick
End Sub

Public Sub TriggerClick
	If mTarget <> Null And mEventName <> "" Then
		CallSub(mTarget, mEventName)
	End If
End Sub