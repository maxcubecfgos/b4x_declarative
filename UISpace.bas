B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
	Private mFixedWidth As Int = 12dip
	Private mFixedHeight As Int = 12dip
End Sub

Public Sub Initialize As UISpace
	mFixedWidth = 12dip
	mFixedHeight = 12dip
	Return Me
End Sub

' Define el mismo tamaño en ambas direcciones
Public Sub Size(s As Int) As UISpace
	mFixedWidth = s
	mFixedHeight = s
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
End Sub

Public Sub Unmount
	mBaseView = Null
	mParent = Null
End Sub

' --- SISTEMA DE MEDICIÓN (MEASURE/LAYOUT) ---
' UISpace retorna su tamaño INTRÍNSECO (mFixedWidth/mFixedHeight).
' NO usa mWidth/mHeight porque SetSize aún no ha sido llamado
' durante la fase de medición (primera pasada del layout).
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	result.Add(Min(mFixedWidth, safeMaxWidth))
	result.Add(Min(mFixedHeight, safeMaxHeight))
	Return result
End Sub