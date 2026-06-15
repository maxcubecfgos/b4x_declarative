B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UIExpanded
Sub Class_Globals
	Private mChild As Object
End Sub

Public Sub Initialize As UIExpanded
	mChild = Null
	Return Me
End Sub

Public Sub Child(c As Object) As UIExpanded
	mChild = c
	Return Me
End Sub

' Devuelve el hijo interno para que el contenedor lo dibuje directamente
Public Sub GetChild As Object
	Return mChild
End Sub

' El Expanded en sí mismo delega el puente al hijo
Public Sub RenderBridge(Args() As Object)
	If mChild <> Null And SubExists(mChild, "RenderBridge") Then
		CallSub3(mChild, "RenderBridge", Args, Null)
	End If
End Sub