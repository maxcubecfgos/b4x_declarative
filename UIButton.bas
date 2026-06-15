B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Módulo de Clase: UIButton
Sub Class_Globals
	Private mText As String
	Private mColor As Int
	Private mTarget As Object
	Private mEventName As String
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UIButton
	mText = ""
	mColor = Colors.LightGray
	Return Me
End Sub

Public Sub Text(t As String) As UIButton
	mText = t
	Return Me
End Sub

Public Sub BackgroundColor(c As Int) As UIButton
	mColor = c
	Return Me
End Sub

Public Sub OnClick(Target As Object, EventName As String) As UIButton
	mTarget = Target
	mEventName = EventName
	Return Me
End Sub

' Contrato de Renderizado
Public Sub Render(Parent As B4XView, Left As Int, Top As Int, Width As Int, Height As Int)
	If mBaseView.IsInitialized = False Then
		Dim btn As Button
		btn.Initialize("NativeBtn")
		mBaseView = btn
		mBaseView.Tag = Me ' Inyección de la instancia en el Tag nativo
		Parent.AddView(mBaseView, Left, Top, Width, Height)
	End If
    
	mBaseView.SetLayoutAnimated(0, Left, Top, Width, Height)
    
	If mBaseView.Text <> mText Then mBaseView.Text = mText
	If mBaseView.Color <> mColor Then mBaseView.Color = mColor
End Sub

Private Sub NativeBtn_Click
	Dim btn As Button = Sender
	Dim instance As UIButton = btn.Tag
	instance.TriggerClick
End Sub

Public Sub TriggerClick
	If mTarget <> Null And mEventName <> "" Then
		CallSub(mTarget, mEventName)
	End If
End Sub

' Añade esto al final de la clase UIButton existente
Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub