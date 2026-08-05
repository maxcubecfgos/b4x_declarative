B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@

' Offline English draughts engine used by the DeclarativeUI showcase.
' 0 = empty, 1 = human man, 2 = human king,
' 3 = computer man, 4 = computer king.
Sub Class_Globals
    Private Const EMPTY As Int = 0
    Private Const HUMAN As Int = 1
    Private Const COMPUTER As Int = 2
    Private Const HUMAN_MAN As Int = 1
    Private Const HUMAN_KING As Int = 2
    Private Const COMPUTER_MAN As Int = 3
    Private Const COMPUTER_KING As Int = 4

    Private mBoard(8, 8) As Int
    Private mTurn As Int
    Private mCaptureRow As Int
    Private mCaptureCol As Int
    Private mNoCaptureMoves As Int
End Sub

Public Sub Initialize As CheckersEngine
    ResetGame
    Return Me
End Sub

Public Sub ResetGame
    For row = 0 To 7
        For col = 0 To 7
            mBoard(row, col) = EMPTY
        Next
    Next
    For row = 0 To 2
        For col = 0 To 7
            If IsDark(row, col) Then mBoard(row, col) = COMPUTER_MAN
        Next
    Next
    For row = 5 To 7
        For col = 0 To 7
            If IsDark(row, col) Then mBoard(row, col) = HUMAN_MAN
        Next
    Next
    mTurn = HUMAN
    mCaptureRow = -1
    mCaptureCol = -1
    mNoCaptureMoves = 0
End Sub

Public Sub GetPiece(Row As Int, Col As Int) As Int
    If Row < 0 Or Row > 7 Or Col < 0 Or Col > 7 Then Return EMPTY
    Return mBoard(Row, Col)
End Sub

Public Sub GetCurrentPlayer As Int
    Return mTurn
End Sub

Public Sub IsHumanTurn As Boolean
    Return mTurn = HUMAN
End Sub

' Returns 0 while active, 1 when the human wins, 2 when the computer wins,
' and 3 for a draw caused by the no-progress rule.
Public Sub GetWinner As Int
    If mNoCaptureMoves >= 80 Then Return 3
    Dim legal As List = GetMovesForPlayer(mTurn)
    If legal.Size > 0 Then Return 0
    If mTurn = HUMAN Then Return COMPUTER
    Return HUMAN
End Sub

Public Sub GetLegalMoves As List
    Return GetMovesForPlayer(mTurn)
End Sub

' Returns only the legal moves that start on the requested square.
Public Sub GetLegalMovesForPiece(Row As Int, Col As Int) As List
    Dim result As List
    result.Initialize
    For Each move As Map In GetLegalMoves
        If MoveCoordinate(move, "FromRow") = Row And MoveCoordinate(move, "FromCol") = Col Then
            result.Add(move)
        End If
    Next
    Return result
End Sub

' True when the rules require a capture instead of a simple move.
Public Sub IsCaptureRequired As Boolean
    Return GetCaptureMovesForPlayer(mTurn).Size > 0
End Sub

' True while the human player must continue a multiple capture with the
' piece that just jumped. The UI can keep that piece selected and expose only
' its next legal landing squares.
Public Sub IsCaptureContinuation As Boolean
    Return mTurn = HUMAN And mCaptureRow >= 0 And mCaptureCol >= 0
End Sub

Public Sub ApplyMove(Move As Map) As Boolean
    If Move.IsInitialized = False Then Return False
    If IsValidMoveCoordinates(Move) = False Then Return False
    Dim legal As List = GetLegalMoves
    If ContainsEquivalentMove(legal, Move) = False Then Return False

    Dim fromRow As Int = MoveCoordinate(Move, "FromRow")
    Dim fromCol As Int = MoveCoordinate(Move, "FromCol")
    Dim toRow As Int = MoveCoordinate(Move, "ToRow")
    Dim toCol As Int = MoveCoordinate(Move, "ToCol")
    Dim pieceBefore As Int = mBoard(fromRow, fromCol)
    Dim capture As Boolean = Move.GetDefault("IsCapture", False)
    If ApplyMoveToBoard(Move) = False Then Return False

    If capture Then
        mNoCaptureMoves = 0
    Else
        mNoCaptureMoves = mNoCaptureMoves + 1
    End If
    ' Human input is incremental: after one jump, keep the turn if the same
    ' piece has another capture. A man crowned by this jump ends its turn.
    If capture And mTurn = HUMAN Then
        Dim pieceAfter As Int = mBoard(toRow, toCol)
        If pieceAfter = pieceBefore Then
            Dim nextCaptures As List
            nextCaptures.Initialize
            Dim hasNextCapture As Boolean = GenerateCaptures(toRow, toCol, toRow, toCol, pieceAfter, "", nextCaptures)
            If hasNextCapture Then
                mCaptureRow = toRow
                mCaptureCol = toCol
                Return True
            End If
        End If
    End If

    mCaptureRow = -1
    mCaptureCol = -1
    mTurn = OtherPlayer(mTurn)
    Return True
End Sub

Public Sub PlayComputer(Difficulty As Int) As Map
    Dim noMove As Map
    noMove.Initialize
    If mTurn <> COMPUTER Then Return noMove
    Dim depth As Int = 2
    If Difficulty >= 2 Then depth = 3
    If Difficulty >= 3 Then depth = 4
    Dim best As Map = FindBestMove(depth)
    If best.IsInitialized = False Then Return noMove
    If ApplyMove(best) = False Then Return noMove
    Return best
End Sub

Private Sub GetMovesForPlayer(Player As Int) As List
    Dim captures As List = GetCaptureMovesForPlayer(Player)
    If captures.Size > 0 Then Return captures

    Dim moves As List
    moves.Initialize
    For row = 0 To 7
        For col = 0 To 7
            Dim piece As Int = mBoard(row, col)
            If BelongsTo(piece, Player) Then GenerateSimpleMoves(row, col, piece, moves)
        Next
    Next
    Return moves
End Sub

Private Sub GetSearchMovesForPlayer(Player As Int) As List
    Dim captures As List = GetFullCaptureMovesForPlayer(Player)
    If captures.Size > 0 Then Return captures

    Dim moves As List
    moves.Initialize
    For row = 0 To 7
        For col = 0 To 7
            Dim piece As Int = mBoard(row, col)
            If BelongsTo(piece, Player) Then GenerateSimpleMoves(row, col, piece, moves)
        Next
    Next
    Return moves
End Sub

Private Sub GetFullCaptureMovesForPlayer(Player As Int) As List
    Dim captures As List
    captures.Initialize
    For row = 0 To 7
        For col = 0 To 7
            Dim piece As Int = mBoard(row, col)
            If BelongsTo(piece, Player) Then GenerateSearchCaptures(row, col, row, col, piece, "", captures)
        Next
    Next
    Return captures
End Sub

Private Sub GenerateSearchCaptures(StartRow As Int, StartCol As Int, Row As Int, Col As Int, Piece As Int, PathText As String, Result As List) As Boolean
    Dim branch As String = SerializeBoard
    Dim found As Boolean = False
    For Each direction As Map In CaptureDirections
        Dim middleRow As Int = Row + direction.Get("dr")
        Dim middleCol As Int = Col + direction.Get("dc")
        Dim toRow As Int = Row + direction.Get("dr") * 2
        Dim toCol As Int = Col + direction.Get("dc") * 2
        If IsInside(middleRow, middleCol) = False Or IsInside(toRow, toCol) = False Then Continue
        If IsEnemy(mBoard(middleRow, middleCol), Piece) = False Then Continue
        If mBoard(toRow, toCol) <> EMPTY Then Continue

        found = True
        Dim nextPiece As Int = PromotePiece(Piece, toRow)
        mBoard(Row, Col) = EMPTY
        mBoard(middleRow, middleCol) = EMPTY
        mBoard(toRow, toCol) = nextPiece
        Dim nextPath As String = PathText
        If nextPath <> "" Then nextPath = nextPath & ";"
        nextPath = nextPath & toRow & ":" & toCol

        Dim continued As Boolean = False
        ' Search evaluates a complete multi-capture as one move. Crowning
        ' ends the sequence immediately, as required by English draughts.
        If nextPiece = Piece Or IsKing(Piece) Then
            continued = GenerateSearchCaptures(StartRow, StartCol, toRow, toCol, nextPiece, nextPath, Result)
        End If
        If continued = False Then Result.Add(CreateMove(StartRow, StartCol, toRow, toCol, True, nextPath))
        DeserializeBoard(branch)
    Next
    Return found
End Sub

Private Sub GetCaptureMovesForPlayer(Player As Int) As List
    Dim captures As List
    captures.Initialize
    For row = 0 To 7
        For col = 0 To 7
            If Player = HUMAN And mCaptureRow >= 0 Then
                If row <> mCaptureRow Or col <> mCaptureCol Then Continue
            End If
            Dim piece As Int = mBoard(row, col)
            If BelongsTo(piece, Player) Then GenerateCaptures(row, col, row, col, piece, "", captures)
        Next
    Next
    Return captures
End Sub

Private Sub GenerateSimpleMoves(Row As Int, Col As Int, Piece As Int, Result As List)
    Dim directions As List = MoveDirections(Piece)
    For Each direction As Map In directions
        Dim toRow As Int = Row + direction.Get("dr")
        Dim toCol As Int = Col + direction.Get("dc")
        If IsInside(toRow, toCol) And mBoard(toRow, toCol) = EMPTY Then
            Result.Add(CreateMove(Row, Col, toRow, toCol, False, ""))
        End If
    Next
End Sub

' Captures are generated recursively from a serialized branch snapshot. This
' keeps multi-jump exploration isolated and avoids leaking temporary squares.
Private Sub GenerateCaptures(StartRow As Int, StartCol As Int, Row As Int, Col As Int, Piece As Int, PathText As String, Result As List) As Boolean
    Dim branch As String = SerializeBoard
    Dim found As Boolean = False
    For Each direction As Map In CaptureDirections
        Dim middleRow As Int = Row + direction.Get("dr")
        Dim middleCol As Int = Col + direction.Get("dc")
        Dim toRow As Int = Row + direction.Get("dr") * 2
        Dim toCol As Int = Col + direction.Get("dc") * 2
        If IsInside(middleRow, middleCol) = False Or IsInside(toRow, toCol) = False Then Continue
        If IsEnemy(mBoard(middleRow, middleCol), Piece) = False Then Continue
        If mBoard(toRow, toCol) <> EMPTY Then Continue

        found = True
        Dim nextPiece As Int = PromotePiece(Piece, toRow)
        mBoard(Row, Col) = EMPTY
        mBoard(middleRow, middleCol) = EMPTY
        mBoard(toRow, toCol) = nextPiece
        Dim nextPath As String = PathText
        If nextPath <> "" Then nextPath = nextPath & ";"
        nextPath = nextPath & toRow & ":" & toCol
        Dim continued As Boolean = False
        ' Human moves are entered one jump at a time. Computer moves keep the
        ' complete recursive path so the search can evaluate a whole turn.
        If BelongsTo(Piece, HUMAN) Then
            Result.Add(CreateMove(StartRow, StartCol, toRow, toCol, True, nextPath))
        Else
            ' In English draughts, crowning ends the move immediately.
            If nextPiece = Piece Or IsKing(Piece) Then
                continued = GenerateCaptures(StartRow, StartCol, toRow, toCol, nextPiece, nextPath, Result)
            End If
            If continued = False Then Result.Add(CreateMove(StartRow, StartCol, toRow, toCol, True, nextPath))
        End If
        DeserializeBoard(branch)
    Next
    Return found
End Sub

Private Sub CreateMove(FromRow As Int, FromCol As Int, ToRow As Int, ToCol As Int, Capture As Boolean, PathText As String) As Map
    Dim result As Map
    result.Initialize
    result.Put("FromRow", FromRow)
    result.Put("FromCol", FromCol)
    result.Put("ToRow", ToRow)
    result.Put("ToCol", ToCol)
    result.Put("IsCapture", Capture)
    result.Put("Path", PathText)
    Return result
End Sub

Private Sub ApplyMoveToBoard(Move As Map) As Boolean
    If Move.IsInitialized = False Then Return False
    Dim fromRow As Int = MoveCoordinate(Move, "FromRow")
    Dim fromCol As Int = MoveCoordinate(Move, "FromCol")
    Dim toRow As Int = MoveCoordinate(Move, "ToRow")
    Dim toCol As Int = MoveCoordinate(Move, "ToCol")
    If IsInside(fromRow, fromCol) = False Or IsInside(toRow, toCol) = False Then Return False
    Dim piece As Int = mBoard(fromRow, fromCol)
    If piece = EMPTY Then Return False

    If Move.GetDefault("IsCapture", False) Then
        Dim pathText As String = Move.GetDefault("Path", "")
        If pathText.Trim = "" Then Return False
        Dim currentRow As Int = fromRow
        Dim currentCol As Int = fromCol
        For Each part As String In Regex.Split(";", pathText)
            Dim coordinates() As String = Regex.Split(":", part)
            If coordinates.Length < 2 Then Return False
            Dim nextRow As Int = coordinates(0)
            Dim nextCol As Int = coordinates(1)
            If IsInside(nextRow, nextCol) = False Then Return False
            If Abs(nextRow - currentRow) <> 2 Or Abs(nextCol - currentCol) <> 2 Then Return False
            If mBoard(nextRow, nextCol) <> EMPTY Then Return False
            Dim middleRow As Int = (currentRow + nextRow) / 2
            Dim middleCol As Int = (currentCol + nextCol) / 2
            If IsEnemy(mBoard(middleRow, middleCol), piece) = False Then Return False
            currentRow = nextRow
            currentCol = nextCol
            piece = PromotePiece(piece, currentRow)
        Next
        If currentRow <> toRow Or currentCol <> toCol Then Return False
        mBoard(fromRow, fromCol) = EMPTY
        currentRow = fromRow
        currentCol = fromCol
        For Each part As String In Regex.Split(";", pathText)
            Dim coordinates() As String = Regex.Split(":", part)
            Dim nextRow As Int = coordinates(0)
            Dim nextCol As Int = coordinates(1)
            Dim middleRow As Int = (currentRow + nextRow) / 2
            Dim middleCol As Int = (currentCol + nextCol) / 2
            mBoard(middleRow, middleCol) = EMPTY
            currentRow = nextRow
            currentCol = nextCol
            piece = PromotePiece(piece, currentRow)
        Next
        mBoard(currentRow, currentCol) = piece
    Else
        If mBoard(toRow, toCol) <> EMPTY Then Return False
        If Abs(toRow - fromRow) <> 1 Or Abs(toCol - fromCol) <> 1 Then Return False
        mBoard(fromRow, fromCol) = EMPTY
        piece = PromotePiece(piece, toRow)
        mBoard(toRow, toCol) = piece
    End If
    Return True
End Sub

Private Sub FindBestMove(Depth As Int) As Map
    Dim noMove As Map
    noMove.Initialize
    Dim legal As List = GetSearchMovesForPlayer(COMPUTER)
    If legal.Size = 0 Then Return noMove
    Dim bestScore As Int = -1000000
    Dim best As Map = legal.Get(0)
    For Each move As Map In legal
        Dim saved As String = SerializeBoard
        If ApplyMoveToBoard(move) Then
            Dim score As Int = Minimax(Depth - 1, HUMAN, -1000000, 1000000)
            DeserializeBoard(saved)
            If score > bestScore Then
                bestScore = score
                best = move
            End If
        Else
            DeserializeBoard(saved)
        End If
    Next
    Return best
End Sub

Private Sub Minimax(Depth As Int, Player As Int, Alpha As Int, Beta As Int) As Int
    Dim legal As List = GetSearchMovesForPlayer(Player)
    If Depth <= 0 Or legal.Size = 0 Then Return EvaluatePosition(Player, legal.Size)
    Dim maximizing As Boolean = Player = COMPUTER
    Dim value As Int
    If maximizing Then
        value = -1000000
        For Each move As Map In legal
            Dim saved As String = SerializeBoard
            If ApplyMoveToBoard(move) Then
                value = Max(value, Minimax(Depth - 1, HUMAN, Alpha, Beta))
            End If
            DeserializeBoard(saved)
            Alpha = Max(Alpha, value)
            If Beta <= Alpha Then Exit
        Next
    Else
        value = 1000000
        For Each move As Map In legal
            Dim saved As String = SerializeBoard
            If ApplyMoveToBoard(move) Then
                value = Min(value, Minimax(Depth - 1, COMPUTER, Alpha, Beta))
            End If
            DeserializeBoard(saved)
            Beta = Min(Beta, value)
            If Beta <= Alpha Then Exit
        Next
    End If
    Return value
End Sub

Private Sub EvaluatePosition(Player As Int, LegalCount As Int) As Int
    If LegalCount = 0 Then
        If Player = COMPUTER Then Return -900000
        Return 900000
    End If
    Dim score As Int = 0
    For row = 0 To 7
        For col = 0 To 7
            Select Case mBoard(row, col)
                Case COMPUTER_MAN
                    score = score + 100 + row * 3
                Case COMPUTER_KING
                    score = score + 180
                Case HUMAN_MAN
                    score = score - 100 - (7 - row) * 3
                Case HUMAN_KING
                    score = score - 180
            End Select
        Next
    Next
    Return score + (8 - LegalCount)
End Sub

Private Sub ContainsEquivalentMove(Moves As List, Candidate As Map) As Boolean
    If Candidate.IsInitialized = False Then Return False
    ' Missing or explicitly Null coordinates become -1, outside the board.
    Dim candidateFromRow As Int = MoveCoordinate(Candidate, "FromRow")
    Dim candidateFromCol As Int = MoveCoordinate(Candidate, "FromCol")
    Dim candidateToRow As Int = MoveCoordinate(Candidate, "ToRow")
    Dim candidateToCol As Int = MoveCoordinate(Candidate, "ToCol")
    Dim candidatePath As String = Candidate.GetDefault("Path", "")
    For Each move As Map In Moves
        Dim moveFromRow As Int = MoveCoordinate(move, "FromRow")
        Dim moveFromCol As Int = MoveCoordinate(move, "FromCol")
        Dim moveToRow As Int = MoveCoordinate(move, "ToRow")
        Dim moveToCol As Int = MoveCoordinate(move, "ToCol")
        Dim movePath As String = move.GetDefault("Path", "")
        If moveFromRow = candidateFromRow And moveFromCol = candidateFromCol _
            And moveToRow = candidateToRow And moveToCol = candidateToCol Then
            If movePath = candidatePath Then Return True
        End If
    Next
    Return False
End Sub

Private Sub IsValidMoveCoordinates(Move As Map) As Boolean
    Dim fromRow As Int = MoveCoordinate(Move, "FromRow")
    Dim fromCol As Int = MoveCoordinate(Move, "FromCol")
    Dim toRow As Int = MoveCoordinate(Move, "ToRow")
    Dim toCol As Int = MoveCoordinate(Move, "ToCol")
    Return IsInside(fromRow, fromCol) And IsInside(toRow, toCol)
End Sub

' Reads a coordinate without ever converting a missing or Null value.
Private Sub MoveCoordinate(Move As Map, Key As String) As Int
    If Move.IsInitialized = False Or Move.ContainsKey(Key) = False Then Return -1
    Dim value As Object = Move.Get(Key)
    If value Is Int Or value Is Long Or value Is Float Or value Is Double Then Return value
    Return -1
End Sub

Private Sub CaptureDirections As List
    Dim result As List
    result.Initialize
    AddDirection(result, -1, -1)
    AddDirection(result, -1, 1)
    AddDirection(result, 1, -1)
    AddDirection(result, 1, 1)
    Return result
End Sub

Private Sub MoveDirections(Piece As Int) As List
    Dim result As List
    result.Initialize
    Dim owner As Int = PieceOwner(Piece)
    If IsKing(Piece) Or owner = HUMAN Then AddDirection(result, -1, -1)
    If IsKing(Piece) Or owner = HUMAN Then AddDirection(result, -1, 1)
    If IsKing(Piece) Or owner = COMPUTER Then AddDirection(result, 1, -1)
    If IsKing(Piece) Or owner = COMPUTER Then AddDirection(result, 1, 1)
    Return result
End Sub

Private Sub AddDirection(Result As List, Dr As Int, Dc As Int)
    Dim direction As Map
    direction.Initialize
    direction.Put("dr", Dr)
    direction.Put("dc", Dc)
    Result.Add(direction)
End Sub

Private Sub SerializeBoard As String
    Dim result As String = ""
    For row = 0 To 7
        For col = 0 To 7
            result = result & mBoard(row, col)
            If row <> 7 Or col <> 7 Then result = result & ","
        Next
    Next
    Return result
End Sub

Private Sub DeserializeBoard(Value As String)
    Dim parts() As String = Regex.Split(",", Value)
    If parts.Length < 64 Then Return
    Dim index As Int = 0
    For row = 0 To 7
        For col = 0 To 7
            mBoard(row, col) = parts(index)
            index = index + 1
        Next
    Next
End Sub

Private Sub IsDark(Row As Int, Col As Int) As Boolean
    Return (Row + Col) Mod 2 = 1
End Sub

Private Sub IsInside(Row As Int, Col As Int) As Boolean
    Return Row >= 0 And Row <= 7 And Col >= 0 And Col <= 7
End Sub

Private Sub BelongsTo(Piece As Int, Player As Int) As Boolean
    If Player = HUMAN Then Return Piece = HUMAN_MAN Or Piece = HUMAN_KING
    Return Piece = COMPUTER_MAN Or Piece = COMPUTER_KING
End Sub

Private Sub PieceOwner(Piece As Int) As Int
    If Piece = HUMAN_MAN Or Piece = HUMAN_KING Then Return HUMAN
    If Piece = COMPUTER_MAN Or Piece = COMPUTER_KING Then Return COMPUTER
    Return 0
End Sub

Private Sub IsEnemy(Piece As Int, MovingPiece As Int) As Boolean
    Return Piece <> EMPTY And PieceOwner(Piece) <> PieceOwner(MovingPiece)
End Sub

Private Sub IsKing(Piece As Int) As Boolean
    Return Piece = HUMAN_KING Or Piece = COMPUTER_KING
End Sub

Private Sub PromotePiece(Piece As Int, Row As Int) As Int
    If Piece = HUMAN_MAN And Row = 0 Then Return HUMAN_KING
    If Piece = COMPUTER_MAN And Row = 7 Then Return COMPUTER_KING
    Return Piece
End Sub

Private Sub OtherPlayer(Player As Int) As Int
    If Player = HUMAN Then Return COMPUTER
    Return HUMAN
End Sub

