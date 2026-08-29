B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=13.5
@EndOfDesignText@
Sub Process_Globals
	Public Const MODE_NUMERIC As Int = 0
	Public Const MODE_RAW As Int = 1
End Sub

' Centralizes the state-to-text conversion that was previously copy-pasted
' across every widget that binds a UIState to a text label.
'
' MODE_NUMERIC reproduces the original UIButton / UILabel / UIAppBar /
' UIFloatingActionButton / UIInput behavior: whole numbers are formatted with
' NumberFormat2, other values keep their literal text (Null becomes "null").
'
' MODE_RAW reproduces the original UICheckbox / UISwitch / UIRadioButton /
' UIRadioGroup behavior: Null becomes "" and any other value is stringified
' directly, without number reformatting.
Public Sub ToText(Value As Object, Mode As Int) As String
	If Mode = MODE_RAW Then
		If Value = Null Then Return ""
		Return "" & Value
	End If
	Dim valueText As String = ("" & Value).Trim
	If IsNumber(valueText) Then
		Dim number As Double = valueText
		Dim groupingUsed As Boolean = False
		If number = Floor(number) And Abs(number) < 1000000000000 Then
			Return NumberFormat2(number, 0, 12, 0, groupingUsed)
		End If
	End If
	Return valueText
End Sub

' Numeric mode: whole numbers are formatted with NumberFormat2 (e.g. 30.0 -> "30").
Public Sub ToTextNumeric(Value As Object) As String
	Return ToText(Value, MODE_NUMERIC)
End Sub

' Raw mode: stringifies the value directly and maps Null to "" (does NOT number-format;
' e.g. 30.0 -> "30.0" and Null -> "").
Public Sub ToTextRaw(Value As Object) As String
	Return ToText(Value, MODE_RAW)
End Sub
