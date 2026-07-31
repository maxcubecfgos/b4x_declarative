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
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UIRow
	mChildren.Initialize
	mSpacing = 0
	Return Me
End Sub

Public Sub AddChild(Component As Object) As UIRow
	If Component <> Null Then mChildren.Add(Component)
	Return Me
End Sub

Public Sub Spacing(Value As Int) As UIRow
	mSpacing = Max(0, Value)
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
		mBaseView.Color = Colors.Transparent
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	If mChildren.Size = 0 Then Return
    
	' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
	' PRIMERA PASADA: clasificar y medir hijos
	Dim expandedCount As Int = 0
	Dim totalNaturalWidth As Int = 0
	
	For Each child As Object In mChildren
		Dim size As List = CallSub3(child, "GetContentSize", mWidth, mHeight)
		Dim hasNaturalSize As Boolean = False
		If size <> Null Then
			If size.IsInitialized Then
				If size.Size >= 2 Then hasNaturalSize = True
			End If
		End If
		If hasNaturalSize Then
			totalNaturalWidth = totalNaturalWidth + size.Get(0)
		Else
			' Una lista vacía representa espacio flexible.
			expandedCount = expandedCount + 1
		End If
	Next
	totalNaturalWidth = totalNaturalWidth + mSpacing * Max(0, mChildren.Size - 1)
    
	' Fixed children keep their natural size; overflow is clipped by the parent.
	Dim remainingWidth As Int = Max(0, mWidth - totalNaturalWidth)
	Dim expandedWidth As Int = 0
	Dim expandedRemainder As Int = 0
	If expandedCount > 0 Then
		expandedWidth = remainingWidth / expandedCount
		expandedRemainder = remainingWidth Mod expandedCount
	End If
	
	' SEGUNDA PASADA: posicionar cada hijo
	Dim currentLeft As Int = 0
	Dim childIndex As Int = 0
    
	For Each child As Object In mChildren
		Dim currentWidth As Int = 0
		Dim size As List = CallSub3(child, "GetContentSize", mWidth, mHeight)
		Dim hasNaturalSize As Boolean = False
		If size <> Null Then
			If size.IsInitialized Then
				If size.Size >= 2 Then hasNaturalSize = True
			End If
		End If
		If hasNaturalSize Then
			currentWidth = size.Get(0) ' Ancho natural
		Else
			currentWidth = expandedWidth ' También se expande
			If expandedRemainder > 0 Then
				currentWidth = currentWidth + 1
				expandedRemainder = expandedRemainder - 1
			End If
		End If
        
		If currentWidth < 0 Then currentWidth = 0
        
		If child <> Null Then
			CallSub2(child, "SetParent", mBaseView)
			CallSub3(child, "SetPosition", currentLeft, 0)
			CallSub3(child, "SetSize", currentWidth, mHeight)
			CallSub(child, "Render")
		End If
        
		currentLeft = currentLeft + currentWidth
		childIndex = childIndex + 1
		If childIndex < mChildren.Size Then currentLeft = currentLeft + mSpacing
	Next
End Sub

Public Sub Unmount
	For Each child As Object In mChildren
		If child <> Null And xui.SubExists(child, "Unmount", 0) Then CallSub(child, "Unmount")
	Next
	mBaseView = Null
	mParent = Null
End Sub

' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
' Row: ancho = suma anchos hijos, alto = max alto hijo
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	Dim totalNaturalWidth As Int = 0
	Dim maxChildHeight As Int = 0
	Dim hasExpanded As Boolean = False
	Dim naturalChildCount As Int = 0
	
	For Each child As Object In mChildren
		Dim size As List = CallSub3(child, "GetContentSize", safeMaxWidth, safeMaxHeight)
		Dim hasNaturalSize As Boolean = False
		If size <> Null Then
			If size.IsInitialized Then
				If size.Size >= 2 Then hasNaturalSize = True
			End If
		End If
		If hasNaturalSize Then
			totalNaturalWidth = totalNaturalWidth + size.Get(0)
			maxChildHeight = Max(maxChildHeight, size.Get(1))
			naturalChildCount = naturalChildCount + 1
		Else
			hasExpanded = True
		End If
	Next
	totalNaturalWidth = totalNaturalWidth + mSpacing * Max(0, mChildren.Size - 1)
	
	' Si todos son expandidos, retornar Null (ocupar todo)
	If hasExpanded And naturalChildCount = 0 Then
		Dim flexibleSize As List
		flexibleSize.Initialize
		Return flexibleSize
	End If
	
	' Si hay expandidos: el ancho natural es el mínimo necesario
	' Si no hay expandidos: el ancho natural es la suma total
	result.Add(Min(totalNaturalWidth, safeMaxWidth))
	result.Add(Min(maxChildHeight, safeMaxHeight))
	Return result
End Sub