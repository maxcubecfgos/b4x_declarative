B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@

' Self-contained declarative checkers board.
'
' The board owns the persistent 8x8 cell grid, the floating piece sprite
' and the capture ghost sprite. The game host feeds the visual state
' through SetCell/CommitUpdate, which renders only the cells that changed,
' and drives the Material-style motion through the animation primitives.
' All motion runs on the declarative API: UIAnimation animates bounds and
' opacity with Flutter-style curves.
Sub Class_Globals
    Private mBridge As UIWidgetBridge
    Private mBaseView As B4XView
    Private mParent As B4XView
    Private mLeft, mTop, mWidth, mHeight As Int
    Private mTree As UIColumn
    Private mTreeReady As Boolean
    Private mTheme As UITheme
    Private mThemeReady As Boolean
    Private mCells(8, 8) As CheckersCell
    Private mGlyph(8, 8) As String
    Private mSquareColor(8, 8) As Int
    Private mPieceColor(8, 8) As Int
    Private mSelected(8, 8) As Boolean
    Private mLastMove(8, 8) As Boolean
    Private mLegal(8, 8) As Boolean
    Private mDirty(8, 8) As Boolean
    Private mCellSize As Int
    Private mSprite As PieceSprite
    Private mGhost As PieceSprite
    Private mSpriteReady As Boolean
    Private mGhostReady As Boolean
    Private mBusy As Boolean
    Private mTarget As Object
    Private mTargetReady As Boolean
    Private mEventName As String
End Sub

Public Sub Initialize As CheckersBoard
    mBridge.Initialize
    mTargetReady = False
    mEventName = ""
    mBusy = False
    mSpriteReady = False
    mGhostReady = False
    mTreeReady = False
    mThemeReady = False
    Return Me
End Sub

' Registers the cell-tap callback. The callback signature is
' Sub EventName(Row As Int, Col As Int).
Public Sub OnTap(Target As Object, EventName As String) As CheckersBoard
    mTarget = Target
    mTargetReady = True
    mEventName = EventName
    Return Me
End Sub

' Propagates the active theme to the cell grid.
Public Sub ApplyTheme(Theme As UITheme) As CheckersBoard
    If Theme = Null Then Return Me
    If False = Theme.IsInitialized Then Return Me
    mTheme = Theme
    mThemeReady = True
    If mTreeReady Then
        If SubExists(mTree, "ApplyTheme") Then CallSub2(mTree, "ApplyTheme", Theme)
    End If
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
    If False = mParent.IsInitialized Then Return
    Dim needsCreate As Boolean = False
    If mBaseView = Null Then
        needsCreate = True
    Else If False = mBaseView.IsInitialized Then
        needsCreate = True
    End If
    If needsCreate Then
        Dim pnl As Panel
        pnl.Initialize("")
        mBaseView = pnl
        mBaseView.Color = Colors.Transparent
        mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
    End If
    If mBaseView.Parent <> mParent Then
        If mBaseView.Parent <> Null Then mBaseView.RemoveViewFromParent
        mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
    End If
    mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    If mTreeReady = False Then
        BuildTree
        If mThemeReady Then
            If SubExists(mTree, "ApplyTheme") Then CallSub2(mTree, "ApplyTheme", mTheme)
        End If
        mTreeReady = True
    End If
    mBridge.SetParent(mTree, mBaseView)
    mBridge.SetPosition(mTree, 0, 0)
    mBridge.SetSize(mTree, mWidth, mHeight)
    mBridge.Render(mTree)
    mCellSize = Max(1, mWidth / 8)
End Sub

Private Sub BuildTree
    Dim board As UIColumn
    board.Initialize.MainAxisSize("max").CrossAxisAlignment("stretch")
    For row = 0 To 7
        Dim line As UIRow
        line.Initialize.MainAxisSize("max").CrossAxisAlignment("stretch")
        For col = 0 To 7
            Dim cell As CheckersCell
            cell.Initialize(row, col).SquareStyle(Colors.Transparent, Colors.White) _
                .Interactive(True).OnTap(Me, "Cell_Click")
            mCells(row, col) = cell
            line.AddChild(cell)
        Next
        board.AddChild(line)
    Next
    mTree = board
End Sub

Public Sub Unmount
    If mTreeReady Then
        If SubExists(mTree, "Unmount") Then CallSub(mTree, "Unmount")
    End If
    mBaseView = Null
    mParent = Null
    mTreeReady = False
End Sub

' Natural measurement: the board is square, eight cells wide and tall.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
    Dim result As List
    result.Initialize
    Dim safeMaxWidth As Int = MaxWidth
    Dim safeMaxHeight As Int = MaxHeight
    If safeMaxWidth <= 0 Then safeMaxWidth = 10000
    If safeMaxHeight <= 0 Then safeMaxHeight = 10000
    Dim side As Int = Max(1, safeMaxWidth / 8)
    result.Add(Min(8 * side, safeMaxWidth))
    result.Add(Min(8 * side, safeMaxHeight))
    Return result
End Sub

' ===== Visual state =====

' Records one cell's visual state. CommitUpdate applies only the cells
' whose recorded state actually changed, keeping gameplay renders small.
Public Sub SetCell(Row As Int, Col As Int, Glyph As String, SquareColor As Int, PieceColor As Int, Selected As Boolean, LastMove As Boolean, Legal As Boolean) As CheckersBoard
    If mGlyph(Row, Col) <> Glyph Or mSquareColor(Row, Col) <> SquareColor _
        Or mPieceColor(Row, Col) <> PieceColor Or mSelected(Row, Col) <> Selected _
        Or mLastMove(Row, Col) <> LastMove Or mLegal(Row, Col) <> Legal Then
        mGlyph(Row, Col) = Glyph
        mSquareColor(Row, Col) = SquareColor
        mPieceColor(Row, Col) = PieceColor
        mSelected(Row, Col) = Selected
        mLastMove(Row, Col) = LastMove
        mLegal(Row, Col) = Legal
        mDirty(Row, Col) = True
    End If
    Return Me
End Sub

' Re-renders only the cells marked dirty since the last commit.
Public Sub CommitUpdate As CheckersBoard
    For row = 0 To 7
        For col = 0 To 7
            If mDirty(row, col) Then
                Dim cell As CheckersCell = mCells(row, col)
                cell.SquareStyle(mSquareColor(row, col), mPieceColor(row, col)) _
                    .Selected(mSelected(row, col)).LastMove(mLastMove(row, col)) _
                    .LegalMove(mLegal(row, col)).Text(mGlyph(row, col)).Render
                mDirty(row, col) = False
            End If
        Next
    Next
    Return Me
End Sub

' ===== Animation choreography =====

' Blocks cell taps while a move animation is in flight.
Public Sub BeginAnimation
    mBusy = True
End Sub

Public Sub EndAnimation
    mBusy = False
End Sub

Public Sub IsBusy As Boolean
    Return mBusy
End Sub

Public Sub GlideDuration As Int
    If mSpriteReady = False Then Return 260
    Return mSprite.GetGlideDuration
End Sub

' Mounts the floating piece sprite at the given cell.
Public Sub ShowSpriteAt(Row As Int, Col As Int, Glyph As String, GlyphColor As Int)
    EnsureSprite
    mSprite.SetGlyph(Glyph, GlyphColor)
    mSprite.ShowAt(mBaseView, mCellSize, Row, Col)
End Sub

' Starts the glide of the floating sprite to the given cell.
Public Sub GlideSprite(Row As Int, Col As Int)
    If mSpriteReady Then mSprite.GlideTo(Row, Col)
End Sub

Public Sub HideSprite
    If mSpriteReady Then mSprite.Hide
End Sub

' Mounts the ghost of a captured piece and fades it out.
Public Sub FadeOutGhost(Row As Int, Col As Int, Glyph As String, GlyphColor As Int)
    EnsureGhost
    mGhost.SetGlyph(Glyph, GlyphColor)
    mGhost.ShowAt(mBaseView, mCellSize, Row, Col)
    mGhost.FadeOut(150)
End Sub

Public Sub HideGhost
    If mGhostReady Then mGhost.Hide
End Sub

' Pops the cell out and settles it with an easeOutBack bounce.
' The Expand value is the growth in pixels on each side.
Public Sub PulseCell(Row As Int, Col As Int, Expand As Int)
    Dim cellView As B4XView = mCells(Row, Col).GetView
    If cellView = Null Then Return
    If False = cellView.IsInitialized Then Return
    Dim originalLeft As Int = cellView.Left
    Dim originalTop As Int = cellView.Top
    Dim originalWidth As Int = cellView.Width
    Dim originalHeight As Int = cellView.Height
    Dim grow As Int = Max(1, Expand)
    cellView.SetLayoutAnimated(0, originalLeft - grow / 2, originalTop - grow / 2, originalWidth + grow, originalHeight + grow)
    Dim pulse As UIAnimation
    pulse.Initialize.TargetView(cellView) _
        .MoveAndResize(originalLeft, originalTop, originalWidth, originalHeight) _
        .Duration(220).Easing("easeOutBack").Start
End Sub

' Material staggered entrance: every cell starts transparent and each row
' fades in 140ms with a 40ms offset, row by row from the top.
Public Sub Reveal As ResumableSub
    For row = 0 To 7
        For col = 0 To 7
            Dim cellView As B4XView = mCells(row, col).GetView
            If cellView <> Null Then
                If cellView.IsInitialized Then
                    Dim hide As UIAnimation
                    hide.Initialize.TargetView(cellView).SetAlpha(0).Start
                End If
            End If
        Next
    Next
    For row = 0 To 7
        For col = 0 To 7
            Dim cellView As B4XView = mCells(row, col).GetView
            If cellView <> Null Then
                If cellView.IsInitialized Then
                    Dim fadeIn As UIAnimation
                    fadeIn.Initialize.TargetView(cellView).FadeIn(140).Start
                End If
            End If
        Next
        Sleep(40)
    Next
    Return True
End Sub

' Fades the floating piece sprite in from nothing.
Public Sub FadeSpriteIn(DurationMs As Int)
    If mSpriteReady = False Then Return
    mSprite.SetAlpha(0)
    mSprite.FadeIn(Max(0, DurationMs))
End Sub

Private Sub EnsureSprite
    If mSpriteReady Then Return
    Dim sprite As PieceSprite
    sprite.Initialize("●", Colors.White)
    mSprite = sprite
    mSpriteReady = True
End Sub

Private Sub EnsureGhost
    If mGhostReady Then Return
    Dim ghost As PieceSprite
    ghost.Initialize("●", Colors.White)
    mGhost = ghost
    mGhostReady = True
End Sub

Private Sub Cell_Click(Row As Int, Col As Int)
    If mBusy Then Return
    If mTargetReady = False Or mEventName.Trim = "" Then Return
    If SubExists(mTarget, mEventName) Then CallSub3(mTarget, mEventName, Row, Col)
End Sub
