B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mChildren As List
	Private mSpacing As Int
	Private mMainAxisAlignment As String
	Private mCrossAxisAlignment As String
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIColumn
	mChildren.Initialize
	mSpacing = 0
	mMainAxisAlignment = "start"
	mCrossAxisAlignment = "stretch"
	Return Me
End Sub

Public Sub AddChild(child As Object) As UIColumn
	If child <> Null Then mChildren.Add(child)
	Return Me
End Sub

Public Sub Spacing(Value As Int) As UIColumn
	mSpacing = Max(0, Value)
	Return Me
End Sub

' Controls how children are distributed along the vertical axis.
' Accepted values: start, center, end, spaceBetween, spaceAround, spaceEvenly.
Public Sub MainAxisAlignment(Value As String) As UIColumn
	Dim normalized As String = Value.Trim.ToLowerCase
	If normalized = "center" Or normalized = "end" Or normalized = "spacebetween" Or normalized = "spacearound" Or normalized = "spaceevenly" Then
		mMainAxisAlignment = normalized
	Else
		mMainAxisAlignment = "start"
	End If
	Return Me
End Sub

' Controls how children are aligned across the horizontal axis.
' Accepted values: stretch, start, center, end.
Public Sub CrossAxisAlignment(Value As String) As UIColumn
	Dim normalized As String = Value.Trim.ToLowerCase
	If normalized = "start" Or normalized = "center" Or normalized = "end" Or normalized = "stretch" Then
		mCrossAxisAlignment = normalized
	Else
		mCrossAxisAlignment = "stretch"
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
	mWidth = Width
	mHeight = Height
End Sub

Public Sub Render
	If mParent = Null Then Return
	If mParent.IsInitialized = False Then Return

	' Create the native container when needed.
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
    
	If mChildren.Size = 0 Then Return
	
	' First pass: measure children and classify flexible items.
	' Measure every child through GetContentSize.
	Dim totalNaturalHeight As Int = 0
	Dim expandedCount As Int = 0
	
	For Each child As Object In mChildren
		Dim size As List = CallSub3(child, "GetContentSize", mWidth, 0)
		Dim hasNaturalSize As Boolean = False
		If size <> Null Then
			If size.IsInitialized Then
				If size.Size >= 2 Then hasNaturalSize = True
			End If
		End If
		If hasNaturalSize Then
			totalNaturalHeight = totalNaturalHeight + size.Get(1)
		Else
			' An empty list represents flexible space.
			expandedCount = expandedCount + 1
		End If
	Next
	totalNaturalHeight = totalNaturalHeight + mSpacing * Max(0, mChildren.Size - 1)
	
	' Distribute remaining height among flexible children.
	' Fixed children keep their natural size; overflow is clipped by the parent.
	Dim remainingHeight As Int = Max(0, mHeight - totalNaturalHeight)
	Dim expandedHeight As Int = 0
	Dim expandedRemainder As Int = 0
	If expandedCount > 0 Then
		expandedHeight = remainingHeight / expandedCount
		expandedRemainder = remainingHeight Mod expandedCount
	End If
	
	' Second pass: position and render each child.
	Dim initialOffset As Int = 0
	Dim layoutSpacing As Int = mSpacing
	If expandedCount = 0 Then
		Dim freeSpace As Int = Max(0, mHeight - totalNaturalHeight)
		Select Case mMainAxisAlignment
			Case "center"
				initialOffset = freeSpace / 2
			Case "end"
				initialOffset = freeSpace
			Case "spacebetween"
				If mChildren.Size > 1 Then layoutSpacing = mSpacing + freeSpace / (mChildren.Size - 1)
			Case "spacearound"
				layoutSpacing = mSpacing + freeSpace / mChildren.Size
				initialOffset = (layoutSpacing - mSpacing) / 2
			Case "spaceevenly"
				layoutSpacing = mSpacing + freeSpace / (mChildren.Size + 1)
				initialOffset = layoutSpacing - mSpacing
		End Select
	End If
	Dim yOffset As Int = initialOffset
	Dim childIndex As Int = 0
	For Each child As Object In mChildren
		Dim childHeight As Int
		Dim childWidth As Int
		Dim childLeft As Int

		
		Dim size As List = CallSub3(child, "GetContentSize", mWidth, 0)
		Dim hasNaturalSize As Boolean = False
		If size <> Null Then
			If size.IsInitialized Then
				If size.Size >= 2 Then hasNaturalSize = True
			End If
		End If
		If hasNaturalSize Then
			childHeight = size.Get(1) ' Altura natural
		Else
			childHeight = expandedHeight ' Espacio flexible
			If expandedRemainder > 0 Then
				childHeight = childHeight + 1
				expandedRemainder = expandedRemainder - 1
			End If
		End If
		
		If childHeight < 0 Then childHeight = 0
		childWidth = mWidth
		childLeft = 0
		If mCrossAxisAlignment <> "stretch" And hasNaturalSize Then
			childWidth = Min(size.Get(0), mWidth)
			If mCrossAxisAlignment = "center" Then
				childLeft = (mWidth - childWidth) / 2
			Else If mCrossAxisAlignment = "end" Then
				childLeft = mWidth - childWidth
			End If
		End If
		
		CallSub2(child, "SetParent", mBaseView)
		CallSub3(child, "SetPosition", childLeft, yOffset)
		CallSub3(child, "SetSize", childWidth, childHeight)
		CallSub(child, "Render")
		yOffset = yOffset + childHeight
		childIndex = childIndex + 1
		If childIndex < mChildren.Size Then yOffset = yOffset + layoutSpacing
	Next
End Sub

Public Sub Unmount
	For Each child As Object In mChildren
		If child <> Null And xui.SubExists(child, "Unmount", 0) Then CallSub(child, "Unmount")
	Next
	mBaseView = Null
	mParent = Null
End Sub

' Natural measurement used by parent layout containers.
' Column width is the widest child and height is the sum of child heights.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	Dim maxChildWidth As Int = 0
	Dim totalChildHeight As Int = 0
	Dim allExpanded As Boolean = True
	
	For Each child As Object In mChildren
		Dim size As List = CallSub3(child, "GetContentSize", safeMaxWidth, 0)
		Dim hasNaturalSize As Boolean = False
		If size <> Null Then
			If size.IsInitialized Then
				If size.Size >= 2 Then hasNaturalSize = True
			End If
		End If
		If hasNaturalSize Then
			allExpanded = False
			maxChildWidth = Max(maxChildWidth, size.Get(0))
			totalChildHeight = totalChildHeight + size.Get(1)
		End If
	Next
	totalChildHeight = totalChildHeight + mSpacing * Max(0, mChildren.Size - 1)
	
	If mChildren.Size > 0 And allExpanded Then
		Dim flexibleSize As List
		flexibleSize.Initialize
		Return flexibleSize
	End If
	
	result.Add(Min(maxChildWidth, safeMaxWidth))
	result.Add(Min(totalChildHeight, safeMaxHeight))
	Return result
End Sub