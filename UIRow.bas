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
    
	' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
	' PRIMERA PASADA: clasificar y medir hijos
	Dim expandedCount As Int = 0
	Dim totalNaturalWidth As Int = 0
	
	For Each child As Object In mChildren
		If GetType(child).Contains("uiexpanded") Then
			expandedCount = expandedCount + 1
		Else
			Dim size As List = CallSub3(child, "GetContentSize", mWidth, mHeight)
			If size <> Null Then
				totalNaturalWidth = totalNaturalWidth + size.Get(0)
			Else
				' También quiere expandirse
				expandedCount = expandedCount + 1
			End If
		End If
	Next
    
	Dim remainingWidth As Int = Max(0, mWidth - totalNaturalWidth)
	Dim expandedWidth As Int = 0
	If expandedCount > 0 Then expandedWidth = remainingWidth / expandedCount
	
	' SEGUNDA PASADA: posicionar cada hijo
	Dim currentLeft As Int = 0
    
	For Each child As Object In mChildren
		Dim currentWidth As Int = 0
		Dim targetObject As Object = child
        
		If GetType(child).Contains("uiexpanded") Then
			currentWidth = expandedWidth
			Dim exp As UIExpanded = child
			targetObject = exp.GetChild
		Else
			Dim size As List = CallSub3(child, "GetContentSize", mWidth, mHeight)
			If size <> Null Then
				currentWidth = size.Get(0) ' Ancho natural
			Else
				currentWidth = expandedWidth ' También se expande
			End If
		End If
        
		If currentWidth < 0 Then currentWidth = 0
        
		If targetObject <> Null Then
			CallSub2(targetObject, "SetParent", mBaseView)
			CallSub3(targetObject, "SetPosition", currentLeft, 0)
			CallSub3(targetObject, "SetSize", currentWidth, mHeight)
			CallSub(targetObject, "Render")
		End If
        
		currentLeft = currentLeft + currentWidth
	Next
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
	
	For Each child As Object In mChildren
		If GetType(child).Contains("uiexpanded") Then
			hasExpanded = True
		Else
			Dim size As List = CallSub3(child, "GetContentSize", safeMaxWidth, safeMaxHeight)
			If size <> Null Then
				totalNaturalWidth = totalNaturalWidth + size.Get(0)
				maxChildHeight = Max(maxChildHeight, size.Get(1))
			Else
				hasExpanded = True
			End If
		End If
	Next
	
	' Si todos son expandidos, retornar Null (ocupar todo)
	If hasExpanded And totalNaturalWidth = 0 Then
		Return Null
	End If
	
	' Si hay expandidos: el ancho natural es el mínimo necesario
	' Si no hay expandidos: el ancho natural es la suma total
	result.Add(Min(totalNaturalWidth, safeMaxWidth))
	result.Add(Min(maxChildHeight, safeMaxHeight))
	Return result
End Sub