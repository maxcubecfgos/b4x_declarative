B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	Private mHost As B4XView
	Private mCanvas As B4XCanvas
End Sub

Public Sub Initialize(x As XUI) As UIMeasureEngine
	xui = x
	Return Me
End Sub

' Returns the shared measurement canvas. The host panel is never mounted,
' so measuring cannot affect any visible view (on B4J Initialize inserts
' the canvas as a child node of the host).
Public Sub GetCanvas As B4XCanvas
	If mHost <> Null Then
		If mHost.IsInitialized Then Return mCanvas
	End If
	mHost = xui.CreatePanel("")
	#If B4A
	Dim measureLp As JavaObject
	measureLp.InitializeNewInstance("android.view.ViewGroup$LayoutParams", Array(2048, 512))
	Dim measureHostJO As JavaObject = mHost
	measureHostJO.RunMethod("setLayoutParams", Array(measureLp))
	#End If
	Dim cvs As B4XCanvas
	cvs.Initialize(mHost)
	mCanvas = cvs
	Return mCanvas
End Sub
