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
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	Dim btn As Button
	If mBaseView.NumberOfViews = 0 Then
		btn.Initialize("btn")
		Dim xBtn As B4XView = btn
		mBaseView.AddView(xBtn, 0, 0, mWidth, mHeight)
	Else
		Dim xBtn As B4XView = mBaseView.GetView(0)
		btn = xBtn
	End If
    
	btn.Text = mText
	btn.TextSize = 24
	btn.TextColor = mTextColor
    
	Dim cd As ColorDrawable
	cd.Initialize2(mBgColor, mWidth / 2, 0, 0)
	btn.Background = cd
End Sub

Private Sub btn_Click
	If mTarget <> Null And mEventName <> "" Then
		CallSub(mTarget, mEventName)
	End If
End Sub