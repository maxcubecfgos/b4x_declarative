B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.5
@EndOfDesignText@
' Class Module: UIScaffold
Sub Class_Globals
	Private mAppBar As Object
	Private mBody As Object
	Private mFabLeft As Object
	Private mFabRight As Object
	Private mBaseView As B4XView
End Sub

Public Sub Initialize As UIScaffold
	Return Me
End Sub

Public Sub AppBar(bar As Object) As UIScaffold
	mAppBar = bar
	Return Me
End Sub

Public Sub Body(b As Object) As UIScaffold
	mBody = b
	Return Me
End Sub

Public Sub FloatingActionButtonLeft(fab As Object) As UIScaffold
	mFabLeft = fab
	Return Me
End Sub

Public Sub FloatingActionButtonRight(fab As Object) As UIScaffold
	mFabRight = fab
	Return Me
End Sub

Public Sub Render(Parent As B4XView, Left As Int, Top As Int, Width As Int, Height As Int)
	' Solo inicializamos una vez.
	If mBaseView.IsInitialized = False Then
		Dim pnl As Panel
		pnl.Initialize("")
		mBaseView = pnl
		mBaseView.Color = Colors.Transparent
		Parent.AddView(mBaseView, Left, Top, Width, Height)
	End If
    
	mBaseView.SetLayoutAnimated(0, Left, Top, Width, Height)
    
	' En lugar de RemoveAllViews, llamamos al render de los hijos.
	' Los hijos (AppBar, Body, FABs) ya saben cómo actualizarse a sí mismos.
	Dim appBarHeight As Int = 56dip
    
	If mAppBar <> Null Then
		CallSub3(mAppBar, "RenderBridge", Array(mBaseView, 0, 0, Width, appBarHeight), Null)
	End If
    
	If mBody <> Null Then
		CallSub3(mBody, "RenderBridge", Array(mBaseView, 0, appBarHeight, Width, Height - appBarHeight - 80dip), Null)
	End If
    
	Dim fabSize As Int = 56dip
	If mFabRight <> Null Then
		CallSub3(mFabRight, "RenderBridge", Array(mBaseView, Width - fabSize - 16dip, Height - fabSize - 16dip, fabSize, fabSize), Null)
	End If
    
	If mFabLeft <> Null Then
		CallSub3(mFabLeft, "RenderBridge", Array(mBaseView, 16dip, Height - fabSize - 16dip, fabSize, fabSize), Null)
	End If
End Sub

Public Sub RenderBridge(Args() As Object)
	Render(Args(0), Args(1), Args(2), Args(3), Args(4))
End Sub