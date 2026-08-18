B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' UIStateTestRunner - on-device state tests for UIState (UIState.bas) and the
' coalescing scheduler (UIRebuildScheduler.bas).
'
' Run the SAME shared cases as tests/test_state.py (Python oracle):
'   1) python3 tests/generate_state_cases.py
'   2) Copy UIStateTestRunner.bas, StateProbe.bas and generated/state_cases.bas
'      into a B4A project that references the DeclarativeUI b4xlib.
'   3) Call UIStateTestRunner.Run(Activity) once from Activity_Create.
'
' Output convention (matches the repo harness):
'   DeclarativeUI TEST PASS/FAIL  <id>  state
'   DeclarativeUI TEST SUMMARY  passed=N  failed=M
'
' Notes:
' - No native views are involved; Root is accepted only to keep the same call
'   convention as UITestRunner.
' - Run is a ResumableSub because the "flush" step (coalesced delivery) must
'   let the scheduler's Sleep(0) drain. The runner sleeps 5 UI cycles; the
'   scheduler drains in one resume, so this is the only timing-sensitive part
'   of the harness and has a generous margin.
' - Probe event names: only the events used by the shared cases exist on
'   StateProbe (onChange, onCustom). Add subs there if new events appear.
Sub Class_Globals
    Private mProbes As Map
    Private mLog As List
    Private mState As UIState
    Private mPassed As Int
    Private mFailed As Int
End Sub

Public Sub Run(Root As B4XView) As ResumableSub
    Dim cases As List = state_cases.GetStateCases
    For Each c As Map In cases
        Dim id As String = c.Get("id")
        Try
            mProbes.Initialize
            mLog.Initialize
            mState.Initialize(c.Get("initial"))
            RegisterProbes(c)
            Dim caseOk As Boolean = True
            Dim steps() As Object = c.Get("steps")
            For Each step As Map In steps
                Dim op As String = step.Get("op")
                Select Case op
                    Case "subscribe"
                        Dim p As StateProbe = ResolveTarget(step.Get("target"))
                        mState.Subscribe(p, step.Get("event"))
                        If p <> Null Then
                        	If step.ContainsKey("behavior") Then p.SetBehavior(step.Get("behavior"))
                        End If
                    Case "unsubscribe"
                        mState.Unsubscribe(ResolveTarget(step.Get("target")), step.Get("event"))
                    Case "unsubscribeTarget"
                        mState.UnsubscribeTarget(ResolveTarget(step.Get("target")))
                    Case "clear"
                        mState.ClearListeners
                    Case "coalesce"
                        mState.CoalesceNotifications(step.Get("enabled"))
                    Case "set"
                        mLog.Clear
                        mState.SetState(step.Get("value"))
                        If CheckExpect(step, True) = False Then caseOk = False
                    Case "flush"
                        mLog.Clear
                        For i = 1 To 5
                            Sleep(0)
                        Next
                        If CheckExpect(step, True) = False Then caseOk = False
                    Case "get"
                        If mState.GetState = step.Get("expect") = False Then
                            Log("DeclarativeUI TEST INFO  " & id & "  value mismatch on get")
                            caseOk = False
                        End If
                End Select
                If caseOk = False Then Exit
            Next
            Report(id, caseOk, "state")
        Catch
            Report(id, False, "state")
            Log("DeclarativeUI TEST INFO  " & id & "  " & LastException.Message)
        End Try
    Next
    Log("DeclarativeUI TEST SUMMARY  passed=" & mPassed & "  failed=" & mFailed)
End Sub

' Registers one StateProbe per target name referenced by the case (subscribe
' steps plus behavior scripts). "self" and "null" are not probe names.
Private Sub RegisterProbes(c As Map)
    Dim steps() As Object = c.Get("steps")
    For Each step As Map In steps
        Dim op As String = step.Get("op")
        If op = "subscribe" Then
            Dim t As String = step.Get("target")
            If t <> "self" And t <> "null" Then EnsureProbe(t)
        End If
        If step.ContainsKey("behavior") Then
            RegisterBehaviorTargets(step.Get("behavior"))
        End If
    Next
End Sub

Private Sub RegisterBehaviorTargets(Beh As Object)
    Dim b As Map = Beh
    If b.ContainsKey("actions") Then
        Dim actions() As Object = b.Get("actions")
        For Each act As Map In actions
            RegisterActionTargets(act)
        Next
    Else
        RegisterActionTargets(b)
    End If
End Sub

Private Sub RegisterActionTargets(a As Map)
    If a.ContainsKey("subscribe") Then
        Dim s As Map = a.Get("subscribe")
        Dim t As String = s.Get("target")
        If t <> "self" And t <> "null" Then EnsureProbe(t)
    End If
    If a.ContainsKey("unsubscribe") Then
        Dim u As Map = a.Get("unsubscribe")
        Dim t As String = u.Get("target")
        If t <> "self" And t <> "null" Then EnsureProbe(t)
    End If
End Sub

Private Sub EnsureProbe(Name As String)
    If mProbes.ContainsKey(Name) Then Return
    Dim p As StateProbe
    p.Initialize(Name, mLog, mProbes)
    mProbes.Put(Name, p)
End Sub

' "null" resolves to Null (Subscribe/Unsubscribe then no-op, as in UIState).
Private Sub ResolveTarget(Name As String) As StateProbe
    If Name = "null" Then Return Null
    If mProbes.ContainsKey(Name) Then
        Dim p As StateProbe = mProbes.Get(Name)
        Return p
    End If
    Return Null
End Sub

' Checks the optional "expect" map of a set/flush step: the new state value
' and the exact sequence of notifications recorded since the step started.
Private Sub CheckExpect(Step As Map, CheckValue As Boolean) As Boolean
    If Step.ContainsKey("expect") = False Then Return True
    Dim exp As Map = Step.Get("expect")
    If CheckValue Then
        If exp.ContainsKey("value") Then
            If mState.GetState = exp.Get("value") = False Then
                Log("DeclarativeUI TEST INFO  value mismatch: " & mState.GetState & " expected " & exp.Get("value"))
                Return False
            End If
        End If
    End If
    If exp.ContainsKey("notified") Then
        Dim expected() As Object = exp.Get("notified")
        If mLog.Size <> expected.Length Then
            Log("DeclarativeUI TEST INFO  notified count " & mLog.Size & " expected " & expected.Length)
            Return False
        End If
        For i = 0 To expected.Length - 1
            Dim e() As Object = expected(i)
            Dim entry As Map = mLog.Get(i)
            Dim pr As StateProbe = entry.Get("Probe")
            If pr.Name <> e(0) Then
                Log("DeclarativeUI TEST INFO  notified " & pr.Name & " expected " & e(0))
                Return False
            End If
            If entry.Get("Event") = e(1) = False Then
                Log("DeclarativeUI TEST INFO  event mismatch " & entry.Get("Event") & " expected " & e(1))
                Return False
            End If
            If entry.Get("Value") = e(2) = False Then
                Log("DeclarativeUI TEST INFO  value mismatch " & entry.Get("Value") & " expected " & e(2))
                Return False
            End If
        Next
    End If
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
