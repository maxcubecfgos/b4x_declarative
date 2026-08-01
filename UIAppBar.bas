B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mTitle As String
	Private mTitleState As UIState
	Private mColor As Int
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
	Private mTitleLabel As Label ' Persistent reference to the title label.
End Sub

Public Sub Initialize As UIAppBar
	mTitle = ""
	mColor = 0xFF1976D2
	Return Me
End Sub

Public Sub Title(t As String) As UIAppBar
	' An explicit title replaces any previous state binding.
	If mTitleState <> Null Then
		If mTitleState.IsInitialized Then mTitleState.Unsubscribe(Me, "TitleState_Changed")
	End If
	mTitleState = Null
	mTitle = t
	Return Me
End Sub

' Binds the app bar title to an observable UIState.
' The current state value is applied immediately and future changes re-render the title.
Public Sub BindTitle(State As UIState) As UIAppBar
	If mTitleState <> Null Then
		If mTitleState.IsInitialized Then mTitleState.Unsubscribe(Me, "TitleState_Changed")
	End If
	mTitleState = State
	If mTitleState <> Null Then
		If mTitleState.IsInitialized Then
			mTitle = "" & mTitleState.GetState
			mTitleState.Subscribe(Me, "TitleState_Changed")
			If mParent <> Null Then
				If mParent.IsInitialized Then Render
			End If
		End If
	End If
	Return Me
End Sub

' Removes the title binding while preserving the current displayed title.
Public Sub UnbindTitle As UIAppBar
	If mTitleState <> Null Then
		If mTitleState.IsInitialized Then mTitleState.Unsubscribe(Me, "TitleState_Changed")
	End If
	mTitleState = Null
	Return Me
End Sub

Private Sub TitleState_Changed(State As UIState)
	If State = Null Then Return
	If State.IsInitialized = False Then Return
	mTitle = "" & State.GetState
	Render
End Sub

Public Sub BackgroundColor(c As Int) As UIAppBar
	mColor = c
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
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
        
	End If

	Dim titleNeedsCreate As Boolean = needsCreate
	If mTitleLabel = Null Then
		titleNeedsCreate = True
	Else If mTitleLabel.IsInitialized = False Then
		titleNeedsCreate = True
	End If
	If titleNeedsCreate Then
		Dim titleLabel As Label
		titleLabel.Initialize("")
		mTitleLabel = titleLabel
		Dim xLbl As B4XView = mTitleLabel
		xLbl.TextColor = Colors.White
		xLbl.TextSize = 18
		mBaseView.AddView(xLbl, 16dip, 0, mWidth - 32dip, mHeight)
	End If
	
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
	mBaseView.Color = mColor
	
	' Keep the title vertically centered across the whole bar.
	mTitleLabel.Gravity = Gravity.CENTER_VERTICAL
	' Refresh the title on every render, not only during the first mount.
	mTitleLabel.Text = mTitle
End Sub

Public Sub Unmount
	mTitleLabel = Null
	mBaseView = Null
	mParent = Null
End Sub

' Natural measurement used by parent layout containers.
' Use the standard 56dip Material bar height and the full available width.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	result.Add(safeMaxWidth) ' Ancho completo disponible
	result.Add(Min(56dip, safeMaxHeight)) ' Altura fija Material Design
	Return result
End Sub