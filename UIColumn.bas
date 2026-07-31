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

Public Sub Initialize As UIColumn
	mChildren.Initialize
	mSpacing = 0
	Return Me
End Sub

Public Sub AddChild(child As Object) As UIColumn
	mChildren.Add(child)
	Return Me
End Sub

Public Sub Spacing(Value As Int) As UIColumn
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
	' 1. Inicializar contenedor
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	If mChildren.Size = 0 Then Return
	
	' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
	' PRIMERA PASADA: medir todos los hijos con GetContentSize
	Dim totalNaturalHeight As Int = 0
	Dim expandedCount As Int = 0
	
	For Each child As Object In mChildren
		Dim size As List = CallSub3(child, "GetContentSize", mWidth, 0)
		If size <> Null Then
			totalNaturalHeight = totalNaturalHeight + size.Get(1)
		Else
			' Retorna Null = hijo quiere espacio flexible (como Expanded)
			expandedCount = expandedCount + 1
		End If
	Next
	totalNaturalHeight = totalNaturalHeight + mSpacing * Max(0, mChildren.Size - 1)
	
	' Espacio restante para hijos "expandidos"
	' Fixed children keep their natural size; overflow is clipped by the parent.
	Dim remainingHeight As Int = Max(0, mHeight - totalNaturalHeight)
	Dim expandedHeight As Int = 0
	Dim expandedRemainder As Int = 0
	If expandedCount > 0 Then
		expandedHeight = remainingHeight / expandedCount
		expandedRemainder = remainingHeight Mod expandedCount
	End If
	
	' SEGUNDA PASADA: posicionar cada hijo
	Dim yOffset As Int = 0
	Dim childIndex As Int = 0
	For Each child As Object In mChildren
		Dim childHeight As Int
		
		Dim size As List = CallSub3(child, "GetContentSize", mWidth, 0)
		If size <> Null Then
			childHeight = size.Get(1) ' Altura natural
		Else
			childHeight = expandedHeight ' Espacio flexible
			If expandedRemainder > 0 Then
				childHeight = childHeight + 1
				expandedRemainder = expandedRemainder - 1
			End If
		End If
		
		If childHeight < 0 Then childHeight = 0
		
		CallSub2(child, "SetParent", mBaseView)
		CallSub3(child, "SetPosition", 0, yOffset)
		CallSub3(child, "SetSize", mWidth, childHeight)
		CallSub(child, "Render")
		yOffset = yOffset + childHeight
		childIndex = childIndex + 1
		If childIndex < mChildren.Size Then yOffset = yOffset + mSpacing
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
' Column: ancho = max ancho hijo, alto = suma altos hijos
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
		If size <> Null Then
			allExpanded = False
			maxChildWidth = Max(maxChildWidth, size.Get(0))
			totalChildHeight = totalChildHeight + size.Get(1)
		End If
	Next
	totalChildHeight = totalChildHeight + mSpacing * Max(0, mChildren.Size - 1)
	
	If mChildren.Size > 0 And allExpanded Then
		Return Null ' Los hijos flexibles ocupan todo el espacio
	End If
	
	result.Add(Min(maxChildWidth, safeMaxWidth))
	result.Add(Min(totalChildHeight, safeMaxHeight))
	Return result
End Sub