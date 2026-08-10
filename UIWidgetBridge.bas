B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
	Private mDiagnostics As UIDiagnostics
	Private mLastCallSucceeded As Boolean
End Sub

' Creates a bridge for the common Object-based widget protocol.
Public Sub Initialize As UIWidgetBridge
	Try
		mDiagnostics = UI.Diagnostics
	Catch
		mDiagnostics.Initialize
	End Try
	mLastCallSucceeded = True
	Return Me
End Sub

' Replaces the default diagnostic collector.
Public Sub SetDiagnostics(Diagnostics As UIDiagnostics) As UIWidgetBridge
	If Diagnostics = Null Then Return Me
	If Diagnostics.IsInitialized = False Then Return Me
	mDiagnostics = Diagnostics
	Return Me
End Sub

Public Sub GetDiagnostics As UIDiagnostics
	Return mDiagnostics
End Sub

Public Sub LastCallSucceeded As Boolean
	Return mLastCallSucceeded
End Sub

' Keeps the existing public compatibility contract: the optional
' ParticipatesInLayout sub is deliberately not required here.
Public Sub IsWidgetProtocol(Widget As Object) As Boolean
	If Widget = Null Then Return False
	Return SubExists(Widget, "SetParent") _
		And SubExists(Widget, "SetPosition") _
		And SubExists(Widget, "SetSize") _
		And SubExists(Widget, "Render") _
		And SubExists(Widget, "GetContentSize")
End Sub

' Widgets without this optional sub continue to participate by default.
Public Sub IsLayoutParticipant(Widget As Object) As Boolean
	If Widget = Null Then Return False
	If SubExists(Widget, "ParticipatesInLayout") = False Then Return True
	Try
		Dim result As Boolean = CallSub(Widget, "ParticipatesInLayout")
		Return result
	Catch
		Report("ParticipatesInLayout", Widget, LastException.Message)
		Return False
	End Try
End Sub

Public Sub SetParent(Widget As Object, Parent As B4XView) As Boolean
	If IsWidgetProtocol(Widget) = False Then Return Report("SetParent", Widget, "Object does not implement the widget protocol.")
	Try
		CallSub2(Widget, "SetParent", Parent)
		Return True
	Catch
		Return Report("SetParent", Widget, LastException.Message)
	End Try
End Sub

Public Sub SetPosition(Widget As Object, Left As Int, Top As Int) As Boolean
	If IsWidgetProtocol(Widget) = False Then Return Report("SetPosition", Widget, "Object does not implement the widget protocol.")
	Try
		CallSub3(Widget, "SetPosition", Left, Top)
		Return True
	Catch
		Return Report("SetPosition", Widget, LastException.Message)
	End Try
End Sub

Public Sub SetSize(Widget As Object, Width As Int, Height As Int) As Boolean
	If IsWidgetProtocol(Widget) = False Then Return Report("SetSize", Widget, "Object does not implement the widget protocol.")
	Try
		CallSub3(Widget, "SetSize", Width, Height)
		Return True
	Catch
		Return Report("SetSize", Widget, LastException.Message)
	End Try
End Sub

Public Sub Render(Widget As Object) As Boolean
	If IsWidgetProtocol(Widget) = False Then Return Report("Render", Widget, "Object does not implement the widget protocol.")
	Try
		CallSub(Widget, "Render")
		Return True
	Catch
		Return Report("Render", Widget, LastException.Message)
	End Try
End Sub

' Temporarily detaches a widget when the tree moves or is recycled.
' New widgets may expose Detach to preserve native views and bindings.
' Legacy widgets continue through Unmount without changing their syntax.
Public Sub Unmount(Widget As Object) As Boolean
	If Widget = Null Then Return False
	If SubExists(Widget, "Unmount") = False Then Return True
	Try
		CallSub(Widget, "Unmount")
		Return True
	Catch
		Return Report("Unmount", Widget, LastException.Message)
	End Try
End Sub

' Temporarily detaches a widget for recycling or a tree move. Older custom
' widgets safely fall back to their existing Unmount implementation.
Public Sub Detach(Widget As Object) As Boolean
	If Widget = Null Then Return False
	Dim operation As String = "Detach"
	If SubExists(Widget, operation) = False Then operation = "Unmount"
	If SubExists(Widget, operation) = False Then Return True
	Try
		CallSub(Widget, operation)
		Return True
	Catch
		Return Report(operation, Widget, LastException.Message)
	End Try
End Sub

' Permanently releases a widget when its declarative identity is discarded.
' Dispose is optional so existing custom widgets remain source-compatible.
Public Sub Dispose(Widget As Object) As Boolean
	If Widget = Null Then Return False
	Dim operation As String = "Dispose"
	If SubExists(Widget, operation) = False Then operation = "Unmount"
	If SubExists(Widget, operation) = False Then Return True
	Try
		CallSub(Widget, operation)
		Return True
	Catch
		Return Report(operation, Widget, LastException.Message)
	End Try
End Sub

Public Sub GetContentSize(Widget As Object, MaxWidth As Int, MaxHeight As Int) As List
	Dim result As List
	result.Initialize
	mLastCallSucceeded = False
	If IsWidgetProtocol(Widget) = False Then
		Report("GetContentSize", Widget, "Object does not implement the widget protocol.")
		Return result
	End If
	Try
		Dim value As List = CallSub3(Widget, "GetContentSize", MaxWidth, MaxHeight)
		If value = Null Then Return result
		If value.IsInitialized = False Then Return result
		For Each item As Object In value
			result.Add(item)
		Next
		mLastCallSucceeded = True
		Return result
	Catch
		Report("GetContentSize", Widget, LastException.Message)
		Return result
	End Try
End Sub

Public Sub ReportError(Operation As String, Widget As Object, Message As String) As Boolean
	mLastCallSucceeded = False
	Dim widgetName As String = "Object"
	If Widget <> Null Then widgetName = GetType(Widget)
	mDiagnostics.ReportError(Operation, widgetName & ": " & Message)
	Return False
End Sub

Private Sub Report(Operation As String, Widget As Object, Message As String) As Boolean
	Return ReportError(Operation, Widget, Message)
End Sub