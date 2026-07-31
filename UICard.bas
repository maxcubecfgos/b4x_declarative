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
	Private mBgColor As Int
	Private mRadius As Int
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UICard
	mBgColor = Colors.White
	mRadius = 12dip
	mChild = Null
	Return Me
End Sub

Public Sub BackgroundColor(c As Int) As UICard
	mBgColor = c
	Return Me
End Sub

Public Sub CornerRadius(r As Int) As UICard
	mRadius = r
	Return Me
End Sub

Public Sub Child(c As Object) As UICard
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
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	Dim NativePanel As Panel = mBaseView
	Dim cd As ColorDrawable
	cd.Initialize2(mBgColor, mRadius, 1dip, 0xFFE0E0E0)
	NativePanel.Background = cd
    
	If mChild <> Null Then
		CallSub2(mChild, "SetParent", mBaseView)
		CallSub3(mChild, "SetPosition", 0, 0)
		CallSub3(mChild, "SetSize", mWidth, mHeight)
		CallSub(mChild, "Render")
	End If
End Sub

Public Sub Unmount
	If mChild <> Null And xui.SubExists(mChild, "Unmount", 0) Then CallSub(mChild, "Unmount")
	mBaseView = Null
	mParent = Null
End Sub

' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
' UICard mide a su hijo y agrega el padding del borde (cornerRadius).
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	If mChild <> Null Then
		' Medir al hijo con el espacio disponible menos bordes de la card
		Dim childMargin As Int = 16dip
		Dim childMaxW As Int = Max(0, safeMaxWidth - 2 * childMargin)
		Dim childMaxH As Int = Max(0, safeMaxHeight - 2 * childMargin)
		
		Dim childSize As List = CallSub3(mChild, "GetContentSize", childMaxW, childMaxH)
		If childSize <> Null Then
			If childSize.IsInitialized Then
				If childSize.Size >= 2 Then
					result.Add(Min(childSize.Get(0) + 2 * childMargin, safeMaxWidth))
					result.Add(Min(childSize.Get(1) + 2 * childMargin, safeMaxHeight))
					Return result
				End If
			End If
		End If
	End If
	
	' Hijo Null o quiere llenar espacio: usar todo el disponible
	result.Add(safeMaxWidth)
	result.Add(safeMaxHeight)
	Return result
End Sub