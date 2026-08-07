B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@

' Example-only adapter: a declarative button that remembers its board coordinate.
Sub Class_Globals
    Private mRow, mCol As Int
    Private mText As String
    Private mSquareColor As Int
    Private mPieceColor As Int
    Private mSelected As Boolean
    Private mLastMove As Boolean
    Private mLegalMove As Boolean
    Private mInteractive As Boolean
    Private mTheme As UITheme
    Private mButton As UIButton
    Private mButtonReady As Boolean
    Private mTarget As Object
    Private mTargetReady As Boolean
    Private mEventName As String
    Private mParent As B4XView
    Private mParentReady As Boolean
    Private mLeft, mTop, mWidth, mHeight As Int
    Private mThemeReady As Boolean
End Sub

Public Sub Initialize(Row As Int, Col As Int) As CheckersCell
    mRow = Row
    mCol = Col
    mText = ""
    mSquareColor = Colors.Transparent
    mPieceColor = Colors.White
    mSelected = False
    mLastMove = False
    mLegalMove = False
    mInteractive = True
    Dim defaultTheme As UITheme
    defaultTheme.Initialize
    mTheme = defaultTheme
    mThemeReady = True
    mButtonReady = False
    mTargetReady = False
    mEventName = ""
    mParentReady = False
    Return Me
End Sub

Public Sub Text(Value As String) As CheckersCell
    mText = Value
    Return Me
End Sub

Public Sub SquareStyle(SquareColor As Int, PieceColor As Int) As CheckersCell
    mSquareColor = SquareColor
    mPieceColor = PieceColor
    Return Me
End Sub

Public Sub Selected(Value As Boolean) As CheckersCell
    mSelected = Value
    Return Me
End Sub

Public Sub LastMove(Value As Boolean) As CheckersCell
    mLastMove = Value
    Return Me
End Sub

Public Sub LegalMove(Value As Boolean) As CheckersCell
    mLegalMove = Value
    Return Me
End Sub

Public Sub Interactive(Value As Boolean) As CheckersCell
    mInteractive = Value
    Return Me
End Sub

Public Sub OnTap(Target As Object, EventName As String) As CheckersCell
    mTarget = Target
    mTargetReady = True
    mEventName = EventName
    Return Me
End Sub

Public Sub ApplyTheme(Theme As UITheme) As CheckersCell
    ' The adapter receives a value type class instance from the declarative tree.
    ' Do not compare it with Null: B4A may invoke equals on a null reference.
    If False = Theme.IsInitialized Then Return Me
    mTheme = Theme
    mThemeReady = True
    If mButtonReady Then
        mButton.ApplyTheme(Theme)
        mButton.Render
    End If
    Return Me
End Sub

Public Sub SetParent(Parent As B4XView)
    mParent = Parent
    ' SetParent is called by the layout engine with a mounted parent.
    ' Avoid probing a possibly empty wrapper here; Render validates the mount.
    mParentReady = True
End Sub

Public Sub SetPosition(Left As Int, Top As Int)
    mLeft = Left
    mTop = Top
End Sub

Public Sub SetSize(Width As Int, Height As Int)
    mWidth = Max(0, Width)
    mHeight = Max(0, Height)
End Sub

Public Sub Render
    If mParentReady = False Then Return
    If False = mParent.IsInitialized Then Return
    If mButtonReady = False Then
        Dim button As UIButton
        button.Initialize
        mButton = button
        mButtonReady = True
    End If
    If mThemeReady = False Then Return
    Dim visualColor As Int = mSquareColor
    ' Selection remains the strongest interaction state. Last-move cells use
    ' the accent, never a board surface color, so they remain unambiguous.
    If mSelected Then
        visualColor = mTheme.Info
    Else If mLastMove Then
        visualColor = mTheme.Accent
    Else If mLegalMove Then
        visualColor = mTheme.HeroSurface
    End If
    ' Keep the piece glyph independent from the square highlight.
    mButton.Text(mText).BackgroundColor(visualColor).TextColor(mPieceColor) _
        .TextSize(28).CornerRadius(0).OnClick(Me, "Button_Click").ApplyTheme(mTheme)
    mButton.SetParent(mParent)
    mButton.SetPosition(mLeft, mTop)
    mButton.SetSize(mWidth, mHeight)
    mButton.Render
End Sub

Private Sub Button_Click
    If mInteractive = False Then Return
    If mTargetReady = False Or mEventName.Trim = "" Then Return
    If SubExists(mTarget, mEventName) Then CallSub3(mTarget, mEventName, mRow, mCol)
End Sub

' Returns the mounted native button, or Null before the first Render.
' Enables opt-in animations such as UIAnimation pulses on the cell.
Public Sub GetView As B4XView
    If mButtonReady = False Then Return Null
    If mButton = Null Then Return Null
    If False = mButton.IsInitialized Then Return Null
    Return mButton.GetView
End Sub

Public Sub Unmount
    If mButtonReady Then mButton.Unmount
    mButtonReady = False
    mParentReady = False
End Sub

Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
    ' Every board cell is one square of an 8x8 board.
    Dim size As List
    size.Initialize
    Dim safeWidth As Int = MaxWidth
    If safeWidth <= 0 Then safeWidth = MaxHeight * 8
    Dim side As Int = Max(1, safeWidth / 8)
    size.Add(side)
    size.Add(side)
    Return size
End Sub