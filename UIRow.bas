B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mChildren As List
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIRow
	mChildren.Initialize
	Return Me
End Sub

Public Sub AddChild(Component As Object) As UIRow
	mChildren.Add(Component)
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
		mBaseView.Color = Colors.Transparent
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	If mChildren.Size = 0 Then Return
    
	Dim expandedCount As Int = 0
	Dim fixedWidthsTotal As Int = 0
	Dim fixedSpaceWidth As Int = 12dip
    
	For Each child As Object In mChildren
		If GetType(child).Contains("uiexpanded") Then
			expandedCount = expandedCount + 1
		Else If GetType(child).Contains("uispace") Then
			fixedWidthsTotal = fixedWidthsTotal + fixedSpaceWidth
		End If
	Next
    
	Dim remainingWidth As Int = mWidth - fixedWidthsTotal
	Dim expandedWidth As Int = 0
	If expandedCount > 0 Then expandedWidth = remainingWidth / expandedCount
    
	Dim currentLeft As Int = 0
    
	For Each child As Object In mChildren
		Dim currentWidth As Int = 0
		Dim targetObject As Object = child
        
		If GetType(child).Contains("uiexpanded") Then
			currentWidth = expandedWidth
			Dim exp As UIExpanded = child
			targetObject = exp.GetChild
		Else If GetType(child).Contains("uispace") Then
			currentWidth = fixedSpaceWidth
		Else
			currentWidth = remainingWidth / Max(1, mChildren.Size)
		End If
        
		If targetObject <> Null Then
			CallSub2(targetObject, "SetParent", mBaseView)
			CallSub3(targetObject, "SetPosition", currentLeft, 0)
			CallSub3(targetObject, "SetSize", currentWidth, mHeight)
			CallSub(targetObject, "Render")
		End If
        
		currentLeft = currentLeft + currentWidth
	Next
End Sub