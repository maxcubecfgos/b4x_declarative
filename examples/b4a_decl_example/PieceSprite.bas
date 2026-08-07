B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@

' A floating checkers piece rendered on top of the board during moves.
'
' Built exclusively on the declarative API: UINative mounts the native
' button inside the board panel and UIAnimation drives the glide and the
' fade-out with Flutter-style curves. The sprite is reused between moves.
Sub Class_Globals
    Private mUINative As UINative
    Private mView As B4XView
    Private mGlyph As String
    Private mGlyphColor As Int
    Private mCellSize As Int
    Private mGlideDuration As Int
    Private mHasView As Boolean
End Sub

Public Sub Initialize(Glyph As String, GlyphColor As Int) As PieceSprite
    mGlyph = Glyph
    mGlyphColor = GlyphColor
    mCellSize = 0
    mGlideDuration = 260
    mHasView = False
    Return Me
End Sub

' Sets the piece shown by the sprite. Safe to call while mounted.
Public Sub SetGlyph(Glyph As String, GlyphColor As Int) As PieceSprite
    mGlyph = Glyph
    mGlyphColor = GlyphColor
    If mHasView Then
        mView.Text = mGlyph
        mView.TextColor = mGlyphColor
    End If
    Return Me
End Sub

' Sets the glide duration in milliseconds. The default is 260ms, the
' Material 3 medium motion token.
Public Sub GlideDuration(Milliseconds As Int) As PieceSprite
    mGlideDuration = Max(40, Milliseconds)
    Return Me
End Sub

Public Sub GetGlideDuration As Int
    Return mGlideDuration
End Sub

' Mounts the sprite over Parent at the given board cell.
Public Sub ShowAt(Parent As B4XView, CellSize As Int, Row As Int, Col As Int)
    EnsureView
    mCellSize = Max(1, CellSize)
    mUINative.Initialize(mView, mCellSize, mCellSize)
    mUINative.SetParent(Parent)
    mUINative.SetPosition(Col * mCellSize, Row * mCellSize)
    mUINative.SetSize(mCellSize, mCellSize)
    mUINative.Render
    mView.BringToFront
End Sub

' Starts the glide to the given board cell with an easeOutCubic curve.
Public Sub GlideTo(Row As Int, Col As Int)
    If mCellSize <= 0 Then Return
    If mHasView = False Then Return
    Dim animation As UIAnimation
    animation.Initialize.TargetView(mView) _
        .MoveTo(Col * mCellSize, Row * mCellSize) _
        .Duration(mGlideDuration).Easing("easeOutCubic").Start
End Sub

' Fades the sprite out and detaches it when the fade completes.
Public Sub FadeOut(DurationMs As Int) As ResumableSub
    If mHasView = False Then
        Hide
        Return True
    End If
    Dim animation As UIAnimation
    animation.Initialize.TargetView(mView) _
        .FadeOut(Max(0, DurationMs)).Start
    Sleep(Max(0, DurationMs) + 30)
    Hide
    Return True
End Sub

Public Sub FadeIn(DurationMs As Int)
    If mHasView = False Then Return
    Dim animation As UIAnimation
    animation.Initialize.TargetView(mView).FadeIn(Max(0, DurationMs)).Start
End Sub

' Applies an opacity instantly. Used to fade the sprite in from nothing.
Public Sub SetAlpha(Alpha As Float)
    If mHasView = False Then Return
    If False = mView.IsInitialized Then Return
    Dim animation As UIAnimation
    animation.Initialize.TargetView(mView).SetAlpha(Alpha).Start
End Sub

' Detaches the sprite from the board. The native view is preserved so a
' later ShowAt can reuse it.
Public Sub Hide
    mUINative.Unmount
End Sub

Public Sub IsMounted As Boolean
    If mHasView = False Then Return False
    If False = mView.IsInitialized Then Return False
    If mView.Parent = Null Then Return False
    Return mView.Parent.IsInitialized
End Sub

Private Sub EnsureView
    If mHasView Then
        If mView.IsInitialized Then
            mView.Text = mGlyph
            mView.TextColor = mGlyphColor
            Return
        End If
    End If
    Dim button As Button
    button.Initialize("")
    button.Color = Colors.Transparent
    button.Gravity = Gravity.CENTER
    button.Text = mGlyph
    button.TextColor = mGlyphColor
    button.TextSize = 28
    mView = button
    mHasView = True
End Sub
