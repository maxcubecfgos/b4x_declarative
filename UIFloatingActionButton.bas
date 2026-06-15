B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UIFloatingActionButton
Sub Class_Globals
	Private mText As String
	Private mBgColor As Int
	Private mTextColor As Int
	Private mTarget As Object
	Private mEventName As String
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UIFloatingActionButton
	mText = "+"
	mBgColor = 0xFF00C853 ' Verde vibrante Material
	mTextColor = Colors.White
	Return Me
End Sub

Public Sub Text(t As String) As UIFloatingActionButton
	mText = t
	Return Me
End Sub

Public Sub BackgroundColor(c As Int) As UIFloatingActionButton
	mBgColor = c
	Return Me
End Sub

Public Sub OnClick(Target As Object, EventName As String) As UIFloatingActionButton
	mTarget = Target
	mEventName = EventName
	Return Me
End Sub

' Módulo de Clase: UIFloatingActionButton (Versión Corregida)
Public Sub Render(Parent As B4XView, Left As Int, Top As Int, Width As Int, Height As Int)
	' 1. La BaseView de cara al Scaffold SIEMPRE debe ser un Panel (ViewGroup)
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		Parent.AddView(mBaseView, Left, Top, Width, Height)
	End If
    
	mBaseView.SetLayoutAnimated(0, Left, Top, Width, Height)
    
	' 2. El botón real lo manejamos como una sub-vista interna ocupando el 100% del panel
	Dim btn As Button
	If mBaseView.NumberOfViews = 0 Then
		btn.Initialize("btn")
		Dim xBtn As B4XView = btn
		mBaseView.AddView(xBtn, 0, 0, Width, Height)
	Else
		Dim xBtn As B4XView = mBaseView.GetView(0)
		btn = xBtn
	End If
    
	' 3. Seteamos las propiedades sobre el botón nativo
	btn.Text = mText
	btn.TextSize = 24
	btn.TextColor = mTextColor
    
	' 4. El truco del fondo circular se lo aplicamos directamente al botón interno
	Dim cd As ColorDrawable
	cd.Initialize2(mBgColor, Width / 2, 0, 0)
	btn.Background = cd
End Sub

' Cambiamos el interceptor para capturar el evento del botón interno de forma segura
Private Sub btn_Click
	If mTarget <> Null And mEventName <> "" Then
		If SubExists(mTarget, mEventName) Then
			CallSub(mTarget, mEventName)
		End If
	End If
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub