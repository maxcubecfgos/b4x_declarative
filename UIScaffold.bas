B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mAppBar As Object
	Private mBody As Object
	Private mFabLeft As Object
	Private mFabRight As Object
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIScaffold
	' Initialize optional slots explicitly to avoid invalid object references.
	mAppBar = Null
	mBody = Null
	mFabLeft = Null
	mFabRight = Null
	Return Me
End Sub

Public Sub AppBar(bar As Object) As UIScaffold
	mAppBar = bar
	Return Me
End Sub

Public Sub Body(b As Object) As UIScaffold
	mBody = b
	Return Me
End Sub

Public Sub FloatingActionButtonLeft(fab As Object) As UIScaffold
	mFabLeft = fab
	Return Me
End Sub

Public Sub FloatingActionButtonRight(fab As Object) As UIScaffold
	mFabRight = fab
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
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	' Calculate offsets for the app bar, body, and floating action buttons.
	Dim topOffset As Int = 0
	Dim bottomOffset As Int = 0
	Dim appBarHeight As Int = 56dip
	Dim fabSpace As Int = 80dip ' Espacio total reservado para la zona de FABs
    
	' Render the app bar first.
	If mAppBar <> Null Then
		CallSub2(mAppBar, "SetParent", mBaseView)
		CallSub3(mAppBar, "SetPosition", 0, 0)
		CallSub3(mAppBar, "SetSize", mWidth, appBarHeight)
		CallSub(mAppBar, "Render")
		topOffset = appBarHeight ' El body empezará debajo de la AppBar
	End If
    
	' Reserve bottom space when one or more floating action buttons are present.
	Dim hasFab As Boolean = (mFabLeft <> Null Or mFabRight <> Null)
	If hasFab Then
		bottomOffset = fabSpace
	End If
    
	' Render the body using the remaining height.
	If mBody <> Null Then
		Dim bodyHeight As Int = mHeight - topOffset - bottomOffset
		If bodyHeight < 0 Then bodyHeight = 0
        
		CallSub2(mBody, "SetParent", mBaseView)
		CallSub3(mBody, "SetPosition", 0, topOffset)
		CallSub3(mBody, "SetSize", mWidth, bodyHeight)
		CallSub(mBody, "Render")
	End If
    
	' Render the floating action buttons above the body layer.
	Dim fabSize As Int = 56dip
	If mFabRight <> Null Then
		CallSub2(mFabRight, "SetParent", mBaseView)
		CallSub3(mFabRight, "SetPosition", mWidth - fabSize - 16dip, mHeight - fabSize - 16dip)
		CallSub3(mFabRight, "SetSize", fabSize, fabSize)
		CallSub(mFabRight, "Render")
	End If
    
	If mFabLeft <> Null Then
		CallSub2(mFabLeft, "SetParent", mBaseView)
		CallSub3(mFabLeft, "SetPosition", 16dip, mHeight - fabSize - 16dip)
		CallSub3(mFabLeft, "SetSize", fabSize, fabSize)
		CallSub(mFabLeft, "Render")
	End If
End Sub

Public Sub Unmount
	If mAppBar <> Null And xui.SubExists(mAppBar, "Unmount", 0) Then CallSub(mAppBar, "Unmount")
	If mBody <> Null And xui.SubExists(mBody, "Unmount", 0) Then CallSub(mBody, "Unmount")
	If mFabLeft <> Null And xui.SubExists(mFabLeft, "Unmount", 0) Then CallSub(mFabLeft, "Unmount")
	If mFabRight <> Null And xui.SubExists(mFabRight, "Unmount", 0) Then CallSub(mFabRight, "Unmount")
	mBaseView = Null
	mParent = Null
End Sub

' Natural measurement used by parent layout containers.
' Scaffold fills all available space as the root layout.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	' An empty list represents a flexible size.
	Dim flexibleSize As List
	flexibleSize.Initialize
	Return flexibleSize
End Sub