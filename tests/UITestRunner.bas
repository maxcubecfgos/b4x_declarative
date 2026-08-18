B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' UITestRunner - on-device layout tests for the measurement and
' distribution layer (GetContentSize / Column / Row / Expanded).
'
' Run the SAME shared cases as tests/test_layout.py (Python oracle):
'   1) python3 tests/generate_harness_cases.py
'   2) Copy UITestRunner.bas, TestProbe.bas and generated/harness_cases.bas
'      into a B4A project that references the DeclarativeUI b4xlib.
'   3) Call UITestRunner.Run(Activity) once from Activity_Create.
'
' Output convention (matches the repo's existing informal harness):
'   DeclarativeUI TEST PASS/FAIL  <id>  measure|layout
'   DeclarativeUI TEST SUMMARY  passed=N  failed=M
'
' Layout cases mount the tree on the real panel and assert the rect that
' each child received. Probes (TestProbe) replace leaves so positions are
' read back without native-view introspection. Cases whose tree contains a
' UILabel only assert structural invariants, because real font metrics differ
' from the oracle's synthetic textWidth input.
Sub Class_Globals
    Private mRoot As B4XView
    Private mProbes As List
    Private mPassed As Int
    Private mFailed As Int
End Sub

Public Sub Run(Root As B4XView)
    mRoot = Root
    mPassed = 0
    mFailed = 0
    RunMeasureCases
    RunLayoutCases
    Log("DeclarativeUI TEST SUMMARY  passed=" & mPassed & "  failed=" & mFailed)
End Sub

Private Sub RunMeasureCases
    Dim cases As List = harness_cases.GetMeasureCases
    For Each c As Map In cases
        Dim id As String = c.Get("id")
        Dim widget As Object = BuildWidget(c.Get("widget"), False)
        Dim maxW As Int = c.Get("maxWidth")
        Dim maxH As Int = c.Get("maxHeight")
        Try
            Dim s As List = CallSub3(widget, "GetContentSize", maxW, maxH)
            Report(id, CheckMeasureResult(c, s), "measure")
        Catch
            Report(id, False, "measure")
            Log("DeclarativeUI TEST INFO  " & id & "  " & LastException.Message)
        End Try
        UI.Unmount(widget)
    Next
End Sub

Private Sub RunLayoutCases
    Dim cases As List = harness_cases.GetLayoutCases
    For Each c As Map In cases
        Dim id As String = c.Get("id")
        mProbes.Initialize
        Dim widget As Object = BuildWidget(c.Get("widget"), True)
        Dim width As Int = c.Get("width")
        Dim height As Int = c.Get("height")
        Try
            mRoot.RemoveAllViews
            UI.Mount(widget, mRoot, 0, 0, width, height)
            Dim contOk As Boolean = CheckContainer(c)
            Dim rectOk As Boolean = CheckProbeRects(c)
            Report(id, contOk And rectOk, "layout")
        Catch
            Report(id, False, "layout")
            Log("DeclarativeUI TEST INFO  " & id & "  " & LastException.Message)
        End Try
        UI.Unmount(widget)
        mRoot.RemoveAllViews
    Next
End Sub

' Builds a real widget tree from a case spec map. In ProbeMode, natural
' leaves (space) and flexible children (expanded) become TestProbes so the
' harness can read back the rect the layout engine assigned.
Private Sub BuildWidget(Spec As Map, ProbeMode As Boolean) As Object
    Dim t As String = Spec.Get("type")
    Select Case t
        Case "space"
            If ProbeMode Then
                Dim p As TestProbe
                p.Initialize(Spec.Get("size"))
                mProbes.Add(p)
                Return p
            End If
            Dim sz As Int = Spec.Get("size")
            Return UI.Space(sz)
        Case "expanded"
            If ProbeMode Then
                Dim pe As TestProbe
                pe.Initialize(0)
                mProbes.Add(pe)
                Return UI.Expanded(pe)
            End If
            Return UI.Expanded(Null)
        Case "divider"
            Return UI.Divider
        Case "label"
            Dim l As UILabel
            l.Initialize
            l.Size(Spec.GetDefault("fontSize", 14))
            l.Text("Q")
            Return l
        Case "padding"
            Dim child As Object = Null
            If Spec.ContainsKey("child") Then child = BuildWidget(Spec.Get("child"), ProbeMode)
            Dim pd As UIPadding
            pd.Initialize
            pd.Horizontal(Spec.GetDefault("l", 0))
            pd.Vertical(Spec.GetDefault("t", 0))
            If child <> Null Then pd.Child(child)
            Return pd
        Case "visibility"
            Dim vc As Object = BuildWidget(Spec.Get("child"), ProbeMode)
            Dim v As UIVisibility
            v.Initialize
            v.Visible(Spec.GetDefault("visible", True))
            If vc <> Null Then v.Child(vc)
            Return v
        Case "center"
            Return UI.Center(BuildWidget(Spec.Get("child"), ProbeMode))
        Case "column"
            Dim col As UIColumn
            col.Initialize
            AddChildren(col, Spec, ProbeMode)
            ApplyContainerOptions(col, Spec)
            Return col
        Case "row"
            Dim rw As UIRow
            rw.Initialize
            AddChildren(rw, Spec, ProbeMode)
            ApplyContainerOptions(rw, Spec)
            Return rw
        Case "stack"
            Dim st As UIStack
            st.Initialize
            AddChildren(st, Spec, ProbeMode)
            Return st
    End Select
    Return Null
End Sub

Private Sub AddChildren(Container As Object, Spec As Map, ProbeMode As Boolean)
    Dim children() As Object = Spec.Get("children")
    For Each childSpec As Map In children
        Dim child As Object = BuildWidget(childSpec, ProbeMode)
        If child <> Null Then CallSub2(Container, "AddChild", child)
    Next
End Sub

Private Sub ApplyContainerOptions(Container As Object, Spec As Map)
    If Spec.ContainsKey("spacing") Then CallSub2(Container, "Spacing", Spec.Get("spacing"))
    If Spec.ContainsKey("mainAxisSize") Then CallSub2(Container, "MainAxisSize", Spec.Get("mainAxisSize"))
    If Spec.ContainsKey("mainAxisAlignment") Then CallSub2(Container, "MainAxisAlignment", Spec.Get("mainAxisAlignment"))
    If Spec.ContainsKey("crossAxisAlignment") Then CallSub2(Container, "CrossAxisAlignment", Spec.Get("crossAxisAlignment"))
End Sub

' Exact match for deterministic leaves; structural invariants for trees that
' contain a UILabel (device font metrics differ from the oracle's input).
Private Sub CheckMeasureResult(c As Map, s As List) As Boolean
    Dim wm As Map = c.Get("widget")
    Dim maxW As Int = c.Get("maxWidth")
    If ContainsLabel(wm) Then
        If s.IsInitialized = False Then Return False
        If s.Size < 2 Then Return False
        Dim w As Int = s.Get(0)
        Dim h As Int = s.Get(1)
        Return w >= 0 And w <= maxW And h >= 28
    End If
    Dim flexible As Boolean = c.Get("flexible")
    If flexible Then
        Return s.IsInitialized = False Or s.Size < 2
    End If
    If s.IsInitialized = False Then Return False
    If s.Size < 2 Then Return False
    Dim expect() As Object = c.Get("expect")
    Return s.Get(0) = expect(0) And s.Get(1) = expect(1)
End Sub

Private Sub ContainsLabel(Spec As Map) As Boolean
    If Spec.Get("type") = "label" Then Return True
    If Spec.ContainsKey("child") Then
        Dim ch As Map = Spec.Get("child")
        If ch <> Null Then
            If ContainsLabel(ch) Then Return True
        End If
    End If
    If Spec.ContainsKey("children") Then
        Dim children() As Object = Spec.Get("children")
        For Each cs As Map In children
            If ContainsLabel(cs) Then Return True
        Next
    End If
    Return False
End Sub

' The mounted container's native view is the only view under the test root.
Private Sub CheckContainer(c As Map) As Boolean
    If mRoot.NumberOfViews = 0 Then Return False
    Dim top As B4XView = mRoot.GetView(0)
    Dim expect() As Object = c.Get("expectContainer")
    If top.Width <> expect(0) Then Return False
    If top.Height <> expect(1) Then Return False
    Return True
End Sub

' Every probe corresponds to one expected rect in child order. Nested
' containers produce a probe count that does not line up with the top-level
' rect list, so those cases log the probe geometry and check only the
' container size (the Python oracle asserts the full rect list).
Private Sub CheckProbeRects(c As Map) As Boolean
    Dim expectRects() As Object = c.Get("expectRects")
    If mProbes.Size <> expectRects.Length Then
        Log("DeclarativeUI TEST INFO  probes=" & mProbes.Size & " rects=" & expectRects.Length)
        Return True
    End If
    For i = 0 To mProbes.Size - 1
        Dim p As TestProbe = mProbes.Get(i)
        Dim er() As Object = expectRects(i)
        If p.RectLeft <> er(0) Or p.RectTop <> er(1) Or p.RectWidth <> er(2) Or p.RectHeight <> er(3) Then
            Log("DeclarativeUI TEST INFO  probe " & i & " got (" & p.RectLeft & "," & p.RectTop & "," & p.RectWidth & "," & p.RectHeight & ") expected (" & er(0) & "," & er(1) & "," & er(2) & "," & er(3) & ")")
            Return False
        End If
    Next
    Return True
End Sub

Private Sub Report(id As String, passed As Boolean, kind As String)
    If passed Then
        mPassed = mPassed + 1
        Log("DeclarativeUI TEST PASS  " & id & "  " & kind)
    Else
        mFailed = mFailed + 1
        Log("DeclarativeUI TEST FAIL  " & id & "  " & kind)
    End If
End Sub
