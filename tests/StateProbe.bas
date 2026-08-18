B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' StateProbe - a UIState listener target used by UIStateTestRunner.bas.
' It records every notification (target, event, value at call time) into a
' shared log and optionally runs a behavior script, so the harness can assert
' exactly who was notified and drive reentrancy / subscribe / unsubscribe
' from inside a callback - mirroring what the Python oracle models.
'
' Behavior scripts (set via SetBehavior) mirror the JSON in state_cases.json:
'   {"set": value}                  - calls State.SetState(value)
'   {"setNext": true}               - calls State.SetState(State.GetState + 1)
'   {"subscribe": {target, event}}  - target is a probe name, "self" or "null"
'   {"unsubscribe": {target, event}}
'   {"actions": [action, ...]}      - runs several actions in order
'
' Event subs: only the event names used by the shared cases are defined here.
' Adding a new event name to state_cases.json requires adding the matching
' sub (same pattern as onChange).
Sub Class_Globals
    Private mName As String
    Private mLog As List
    Private mRegistry As Map
    Private mBehavior As Map
End Sub

Public Sub Initialize(Name As String, Log As List, Registry As Map) As StateProbe
    mName = Name
    mLog = Log
    mRegistry = Registry
    Return Me
End Sub

' Stores the behavior script for this probe (may be Null for passive probes).
Public Sub SetBehavior(Behavior As Map)
    mBehavior = Behavior
End Sub

Public Sub Name As String
    Return mName
End Sub

Public Sub onChange(State As UIState)
    RecordNotify("onChange", State)
    RunBehavior(State)
End Sub

Public Sub onCustom(State As UIState)
    RecordNotify("onCustom", State)
    RunBehavior(State)
End Sub

Private Sub RecordNotify(EventName As String, State As UIState)
    Dim entry As Map
    entry.Initialize
    entry.Put("Probe", Me)
    entry.Put("Event", EventName)
    entry.Put("Value", State.GetState)
    mLog.Add(entry)
End Sub

Private Sub RunBehavior(State As UIState)
    If mBehavior = Null Then Return
    If mBehavior.ContainsKey("actions") Then
        Dim actions() As Object = mBehavior.Get("actions")
        For Each act As Map In actions
            RunAction(State, act)
        Next
    Else
        RunAction(State, mBehavior)
    End If
End Sub

Private Sub RunAction(State As UIState, a As Map)
    If a.ContainsKey("set") Then
        State.SetState(a.Get("set"))
    Else If a.GetDefault("setNext", False) Then
        State.SetState(State.GetState + 1)
    Else If a.ContainsKey("subscribe") Then
        Dim s As Map = a.Get("subscribe")
        State.Subscribe(ResolveProbe(s.Get("target"), Me), s.Get("event"))
    Else If a.ContainsKey("unsubscribe") Then
        Dim u As Map = a.Get("unsubscribe")
        State.Unsubscribe(ResolveProbe(u.Get("target"), Me), u.Get("event"))
    End If
End Sub

Private Sub ResolveProbe(Name As String, SelfProbe As StateProbe) As StateProbe
    If Name = "self" Then Return SelfProbe
    If Name = "null" Then Return Null
    If mRegistry.ContainsKey(Name) Then
        Dim p As StateProbe = mRegistry.Get(Name)
        Return p
    End If
    Return Null
End Sub
