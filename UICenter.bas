B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mChild As Object
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UICenter
	mChild = Null
	Return Me
End Sub

Public Sub Child(c As Object) As UICenter
	mChild = c
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
    
	If mChild <> Null Then
		' --- SISTEMA DE MEDICIÓN: Centrado REAL usando GetContentSize ---
		' 1. Preguntar al hijo su tamaño natural
		Dim childSize As List = CallSub3(mChild, "GetContentSize", mWidth, mHeight)
		
		Dim childWidth As Int = mWidth
		Dim childHeight As Int = mHeight
		
		If childSize <> Null Then
			' El hijo tiene un tamaño natural definido -> centrarlo
			childWidth = Min(childSize.Get(0), mWidth)
			childHeight = Min(childSize.Get(1), mHeight)
		End If
		
		' 2. Calcular posición centrada
		' Fórmula: (contenedor - hijo) / 2
		Dim childLeft As Int = Max(0, (mWidth - childWidth) / 2)
		Dim childTop As Int = Max(0, (mHeight - childHeight) / 2)
        
		CallSub2(mChild, "SetParent", mBaseView)
		CallSub3(mChild, "SetPosition", childLeft, childTop)
		CallSub3(mChild, "SetSize", childWidth, childHeight)
		CallSub(mChild, "Render")
	End If
End Sub

Public Sub Unmount
	If mChild <> Null And xui.SubExists(mChild, "Unmount", 0) Then CallSub(mChild, "Unmount")
	mBaseView = Null
	mParent = Null
End Sub

' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
' UICenter: delega al hijo, el centro no afecta el tamaño natural.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	If mChild <> Null Then
		Dim result As Object = CallSub3(mChild, "GetContentSize", MaxWidth, MaxHeight)
		If result <> Null Then Return result
	End If
	Return Null
End Sub