B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' TestProbe - records the rect that the layout engine assigned to it.
' Used by UITestRunner.bas to assert distribution without native-view
' introspection: it implements the widget protocol but creates no view.
Sub Class_Globals
    Private mParent As B4XView
    Private mLeft, mTop, mWidth, mHeight As Int
    Private mSize As Int = 10
End Sub

Public Sub Initialize(Size As Int) As TestProbe
    mSize = Max(0, Size)
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
    ' No native view: the probe only records the assigned geometry.
End Sub

' Natural size is the configured square, clamped like UISpace.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
    Dim result As List
    result.Initialize
    Dim sw As Int = MaxWidth
    Dim sh As Int = MaxHeight
    If sw <= 0 Then sw = 10000
    If sh <= 0 Then sh = 10000
    result.Add(Min(mSize, sw))
    result.Add(Min(mSize, sh))
    Return result
End Sub

Public Sub Unmount
    mParent = Null
End Sub

Public Sub RectLeft As Int
    Return mLeft
End Sub

Public Sub RectTop As Int
    Return mTop
End Sub

Public Sub RectWidth As Int
    Return mWidth
End Sub

Public Sub RectHeight As Int
    Return mHeight
End Sub
