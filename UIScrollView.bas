B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
    Private xui As XUI
    Private mBridge As UIWidgetBridge
    Private mChild As Object
    #If B4A
    Private mScrollView As ScrollView
    #Else
    Private mScrollView As ScrollPane
    Private mContentPanel As B4XView
    #End If
    Private mBaseView As B4XView
    Private mParent As B4XView
    Private mMountedChild As Object
    Private mLeft, mTop, mWidth, mHeight As Int
    Private mContentHeight As Int
    Private mTheme As UITheme
End Sub

' Creates an empty declarative scroll container.
Public Sub Initialize As UIScrollView
    mBridge.Initialize
    mChild = Null
    mScrollView = Null
    mBaseView = Null
    mParent = Null
    mMountedChild = Null
    mContentHeight = 0
    mTheme = Null
    Return Me
End Sub

' Sets the single child rendered inside the scrollable content panel.
Public Sub Child(Component As Object) As UIScrollView
    If IsWidgetProtocol(Component) Then mChild = Component
    Return Me
End Sub

' Returns the currently assigned child.
Public Sub GetChild As Object
    Return mChild
End Sub

' Propagates the active theme to the scroll surface and to the child.
Public Sub ApplyTheme(Theme As UITheme) As UIScrollView
    If Theme = Null Then Return Me
    If Theme.IsInitialized = False Then Return Me
    mTheme = Theme
    ApplyThemeSurface
    If mChild <> Null Then
        If SubExists(mChild, "ApplyTheme") Then CallSub2(mChild, "ApplyTheme", Theme)
    End If
    Return Me
End Sub

' Styles the native scroll surface with the theme background so the viewport
' never shows platform-default colors (white ScrollPane on B4J).
Private Sub ApplySelfBackground
    If mTheme = Null Then Return
    If mTheme.IsInitialized = False Then Return
    If mBaseView = Null Then Return
    If mBaseView.IsInitialized = False Then Return
    #If B4J
    Dim css As String = "-fx-background-color: " & RgbOf(mTheme.Background) & ";"
    Dim scrollJO As JavaObject = mBaseView
    scrollJO.RunMethod("setStyle", Array(css))
    If mContentPanel <> Null Then
        If mContentPanel.IsInitialized Then
            Dim contentJO As JavaObject = mContentPanel
            contentJO.RunMethod("setStyle", Array(css))
        End If
    End If
    ' Scrollbar chrome: transparent track/buttons, themed thumb. Skins only
    ' exist after a layout pulse, so this runs best-effort here and again
    ' from the deferred pass in ApplyThemeSurface.
    StyleScrollPart(scrollJO, ".scroll-bar", "-fx-background-color: transparent; -fx-background-radius: 0;")
    StyleScrollPart(scrollJO, ".track", "-fx-background-color: transparent; -fx-background-radius: 0;")
    StyleScrollPart(scrollJO, ".thumb", "-fx-background-color: " & RgbOf(mTheme.SecondaryBar) & "; -fx-background-radius: 4; -fx-background-insets: 2;")
    StyleScrollPart(scrollJO, ".decrement-button", "-fx-background-color: transparent;")
    StyleScrollPart(scrollJO, ".increment-button", "-fx-background-color: transparent;")
    StyleScrollPart(scrollJO, ".decrement-arrow", "-fx-background-color: transparent;")
    StyleScrollPart(scrollJO, ".increment-arrow", "-fx-background-color: transparent;")
    #Else
    mScrollView.Panel.Color = mTheme.Background
    #End If
End Sub

' Immediate styling plus one deferred pass: JavaFX creates scrollbar skin
' nodes during the first layout pulse, so a second pass is required for the
' lookups to find them.
Private Sub ApplyThemeSurface
    ApplySelfBackground
    Sleep(0)
    ApplySelfBackground
End Sub

' Applies an inline CSS rule to every node matching Selector under ParentJO.
#If B4J
Private Sub StyleScrollPart(ParentJO As JavaObject, Selector As String, Css As String)
    Dim nodes As JavaObject = ParentJO.RunMethod("lookupAll", Array(Selector))
    Dim arr As Object = nodes.RunMethod("toArray", Null)
    Dim reflector As JavaObject
    reflector.InitializeStatic("java.lang.reflect.Array")
    Dim count As Int = reflector.RunMethod("getLength", Array(arr))
    For i = 0 To count - 1
        Dim node As JavaObject = reflector.RunMethod("get", Array(arr, i))
        node.RunMethod("setStyle", Array(Css))
    Next
End Sub
#End If

' ARGB int to the rgb(...) fragment used by JavaFX inline CSS.
#If B4J
Private Sub RgbOf(Color As Int) As String
    Return "rgb(" & Bit.And(Bit.ShiftRight(Color, 16), 0xFF) & "," & Bit.And(Bit.ShiftRight(Color, 8), 0xFF) & "," & Bit.And(Color, 0xFF) & ")"
End Sub
#End If

' Assigns the native parent container used during rendering.
Public Sub SetParent(Parent As B4XView)
    mParent = Parent
End Sub

' Stores the position assigned by the parent layout.
Public Sub SetPosition(Left As Int, Top As Int)
    mLeft = Left
    mTop = Top
End Sub

' Stores the viewport size assigned by the parent layout.
Public Sub SetSize(Width As Int, Height As Int)
    mWidth = Max(0, Width)
    mHeight = Max(0, Height)
End Sub

' Mounts the native ScrollView and lays out its declarative child.
' Re-rendering updates the existing content tree instead of rebuilding it.
Public Sub Render
    If mParent = Null Then Return
    If mParent.IsInitialized = False Then Return

    Dim needsCreate As Boolean = False
    If mBaseView = Null Then
        needsCreate = True
    Else If mBaseView.IsInitialized = False Then
        needsCreate = True
    End If

    If needsCreate Then
        #If B4A
        ' B4A ScrollView.Initialize receives the initial content height, not an event name.
        mScrollView.Initialize(0)
        mBaseView = mScrollView
        #Else
        ' Desktop: native ScrollPane wrapped around an inner AnchorPane.
        mScrollView.Initialize("")
        mScrollView.SetHScrollVisibility("NEVER")
        mBaseView = mScrollView
        mContentPanel = mScrollView.InnerNode
        #End If
        mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
    End If

    ' Re-attach when the view was temporarily detached (e.g. a navigator
    ' recycled this screen): RemoveViewFromParent keeps IsInitialized True,
    ' so the needsCreate branch alone would never re-add the view.
    If mBaseView.Parent <> mParent Then
        If mBaseView.Parent <> Null Then mBaseView.RemoveViewFromParent
        mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
    End If

    ApplyThemeSurface

    mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    ' Keep the native ScrollView and the same declarative child mounted during
    ' ordinary updates. This preserves scroll position, focus and native state.
    ' A replaced child is structural, so remove only the previous content tree.
    If mMountedChild <> Null Then
		If mMountedChild <> mChild Then
			mBridge.Unmount(mMountedChild)
			ContentPanel.RemoveAllViews
			mMountedChild = Null
		End If
	End If
    SetContentSize(Max(0, mWidth), Max(0, mHeight))

    Dim viewportWidth As Int = Max(0, mWidth)
    Dim viewportHeight As Int = Max(0, mHeight)
    Dim contentHeight As Int = viewportHeight

    If mChild <> Null Then
        Dim childSize As List = mBridge.GetContentSize(mChild, viewportWidth, 100000dip)
        If mBridge.LastCallSucceeded = False Then childSize = Null
        If childSize <> Null Then
            If childSize.IsInitialized Then
                If childSize.Size >= 2 Then contentHeight = Max(viewportHeight, childSize.Get(1))
            End If
        End If
        mContentHeight = contentHeight

        SetContentSize(viewportWidth, contentHeight)
        Dim surface As B4XView = ContentPanel
        mBridge.SetParent(mChild, surface)
        mBridge.SetPosition(mChild, 0, 0)
        mBridge.SetSize(mChild, viewportWidth, contentHeight)
        mBridge.Render(mChild)
        mMountedChild = mChild
    Else
        If mMountedChild <> Null Then
            mBridge.Unmount(mMountedChild)
            ContentPanel.RemoveAllViews
            mMountedChild = Null
        End If
        mContentHeight = viewportHeight
        SetContentSize(viewportWidth, viewportHeight)
    End If
End Sub

' Returns the scrollable content surface on the active platform.
Private Sub ContentPanel As B4XView
    #If B4A
    Return mScrollView.Panel
    #Else
    Return mContentPanel
    #End If
End Sub

' Sizes the content surface on the active platform.
Private Sub SetContentSize(W As Int, H As Int)
    #If B4A
    mScrollView.Panel.Width = W
    mScrollView.Panel.Height = H
    #Else
    mContentPanel.SetLayoutAnimated(0, 0, 0, W, H)
    #End If
End Sub

' Scrolls to an absolute vertical content position.
Public Sub ScrollTo(Position As Int)
    If mScrollView = Null Then Return
    If mScrollView.IsInitialized = False Then Return
    #If B4A
    mScrollView.ScrollPosition = Max(0, Min(Position, Max(0, mContentHeight - mHeight)))
    #Else
    ' Desktop exposes a normalized position; convert through the scrollable range.
    Dim range As Double = Max(1, mContentHeight - mHeight)
    mScrollView.VPosition = Max(0, Min(Position, range - 1)) / range
    #End If
End Sub

' Returns the current vertical scroll position.
Public Sub GetScrollPosition As Int
    If mScrollView = Null Then Return 0
    If mScrollView.IsInitialized = False Then Return 0
    #If B4A
    Return mScrollView.ScrollPosition
    #Else
    Dim range As Double = Max(1, mContentHeight - mHeight)
    Return mScrollView.VPosition * range
    #End If
End Sub

' Temporarily detaches the viewport while preserving scroll position and child identity.
Public Sub Detach
    If mBaseView <> Null Then
        If mBaseView.IsInitialized Then
            If mBaseView.Parent <> Null Then mBaseView.RemoveViewFromParent
        End If
    End If
    If mChild <> Null Then mBridge.Detach(mChild)
    mParent = Null
End Sub

' Removes the native view and releases child mounting references.
Public Sub Unmount
    If mMountedChild <> Null Then
        mBridge.Unmount(mMountedChild)
    End If
    If mBaseView <> Null Then
        If mBaseView.IsInitialized Then mBaseView.RemoveViewFromParent
    End If
    mScrollView = Null
    #If B4J
    mContentPanel = Null
    #End If
    mBaseView = Null
    mParent = Null
    mMountedChild = Null
    mContentHeight = 0
End Sub

Private Sub IsWidgetProtocol(Widget As Object) As Boolean
    Return mBridge.IsWidgetProtocol(Widget)
End Sub

' Returns the child's natural size when it can be measured.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
    If mChild <> Null Then
        Dim childSize As List = mBridge.GetContentSize(mChild, MaxWidth, MaxHeight)
        If mBridge.LastCallSucceeded = False Then childSize = Null
        If childSize <> Null Then
            If childSize.IsInitialized Then
                If childSize.Size >= 2 Then Return childSize
            End If
        End If
    End If

    Dim flexibleSize As List
    flexibleSize.Initialize
    Return flexibleSize
End Sub