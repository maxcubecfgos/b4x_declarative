B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private mText As String
	Public mSize As Int
	Private mTextColor As Int
	Private mGravityValue As Int
	Private mBaseView As B4XView
	Private mParent As B4XView
	Private mLeft, mTop, mWidth, mHeight As Int
End Sub

Public Sub Initialize As UILabel
	mText = ""
	mSize = 14
	mTextColor = Colors.Black
	mGravityValue = Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL)
	Return Me
End Sub

Public Sub Text(t As String) As UILabel
	mText = t
	Return Me
End Sub

Public Sub Size(s As Int) As UILabel
	mSize = s
	Return Me
End Sub

Public Sub Color(c As Int) As UILabel
	mTextColor = c
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
		Dim lbl As Label
		lbl.Initialize("")
		mBaseView = lbl
		mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
	End If
	mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    
	Dim NativeLabel As Label = mBaseView
	NativeLabel.Text = mText
	NativeLabel.TextSize = mSize
	NativeLabel.TextColor = mTextColor
	NativeLabel.Gravity = mGravityValue
End Sub

Public Sub Unmount
	mBaseView = Null
	mParent = Null
End Sub

' Natural measurement used by parent layout containers.
' Return the natural text size so Column, Row, and Center can calculate precise layouts.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	
	' Measure text width through the standard B4A Canvas API.
	Dim bmp As Bitmap
	bmp.InitializeMutable(1dip, 1dip)
	Dim cvs As Canvas
	cvs.Initialize2(bmp)
	Dim textWidth As Float = cvs.MeasureStringWidth(mText, Typeface.DEFAULT, mSize)
	
	' Android needs extra room for descenders and TextView padding.
	' The minimum height prevents the lower part of labels from being clipped.
	Dim textHeight As Int = Max(mSize * 1.6 + 10dip, 28dip)
	
	' Clamp the result to the available maximum bounds.
	Dim safeMaxWidth As Int = MaxWidth
	Dim safeMaxHeight As Int = MaxHeight
	If safeMaxWidth <= 0 Then safeMaxWidth = 10000
	If safeMaxHeight <= 0 Then safeMaxHeight = 10000
	
	result.Add(Min(textWidth, safeMaxWidth))
	result.Add(Min(textHeight, safeMaxHeight))
	Return result
End Sub