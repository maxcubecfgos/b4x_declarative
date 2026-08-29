B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=13.5
@EndOfDesignText@
Sub Process_Globals
End Sub

' Applies a rounded background with a press ripple on Android (API 21+) and a
' rounded ColorDrawable fallback on older devices, plus a flat rounded fallback
' on the desktop. This consolidates the SetRoundedRippleBackground logic that
' was duplicated in UIButton and UIFloatingActionButton.
'
' view        - target view (Button or B4XView)
' color       - fill color
' radius      - corner radius in pixels
' borderWidth - stroke width in pixels (0 for no border)
' borderColor - stroke color (ignored when borderWidth = 0)
' rippleColor - theme ripple color used for the pressed state
Public Sub ApplyRipple(view As B4XView, color As Int, radius As Int, borderWidth As Int, borderColor As Int, rippleColor As Int)
	If view = Null Then Return
	If view.IsInitialized = False Then Return

	#If B4A
	Dim nb As Button = view
	Dim version As JavaObject
	version.InitializeStatic("android.os.Build$VERSION")
	Dim sdkInt As Int = version.GetField("SDK_INT")
	If sdkInt < 21 Then
		Dim fallback As ColorDrawable
		fallback.Initialize2(color, radius, borderWidth, borderColor)
		nb.Background = fallback
		Return
	End If

	Dim shape As JavaObject
	shape.InitializeNewInstance("android.graphics.drawable.GradientDrawable", Null)
	shape.RunMethod("setColor", Array(color))
	Dim radiusFloat As Float = radius
	shape.RunMethod("setCornerRadius", Array(radiusFloat))
	If borderWidth > 0 Then shape.RunMethod("setStroke", Array(borderWidth, borderColor))

	' RippleDrawable owns both objects. Keep the mask independent so the
	' content drawable and its clipping drawable do not share mutable state.
	Dim mask As JavaObject
	mask.InitializeNewInstance("android.graphics.drawable.GradientDrawable", Null)
	mask.RunMethod("setColor", Array(Colors.White))
	mask.RunMethod("setCornerRadius", Array(radiusFloat))

	Dim colorStateList As JavaObject
	colorStateList.InitializeStatic("android.content.res.ColorStateList")
	Dim rippleColorJO As JavaObject = colorStateList.RunMethodJO("valueOf", Array(rippleColor))
	Dim ripple As JavaObject
	ripple.InitializeNewInstance("android.graphics.drawable.RippleDrawable", Array(rippleColorJO, shape, mask))
	Dim nativeView As JavaObject = nb
	nativeView.RunMethod("setBackground", Array(ripple))
	#Else
	' Desktop fallback: flat rounded background (no ripple dependency).
	view.SetColorAndBorder(color, borderWidth, borderColor, radius)
	#End If
End Sub
