B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
    Private xui As XUI
    Private mChild As Object
    Private mScrollView As ScrollView
    Private mBaseView As B4XView
    Private mParent As B4XView
    Private mLeft, mTop, mWidth, mHeight As Int
    Private mContentHeight As Int
End Sub

' Creates an empty declarative scroll container.
Public Sub Initialize As UIScrollView
    mChild = Null
    mScrollView = Null
    mBaseView = Null
    mParent = Null
    mContentHeight = 0
    Return Me
End Sub

' Sets the single child rendered inside the scrollable content panel.
Public Sub Child(Component As Object) As UIScrollView
    mChild = Component
    Return Me
End Sub

' Returns the currently assigned child.
Public Sub GetChild As Object
    Return mChild
End Sub

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
        ' B4A ScrollView.Initialize receives the initial content height, not an event name.
        mScrollView.Initialize(0)
        mBaseView = mScrollView
        mParent.AddView(mBaseView, mLeft, mTop, mWidth, mHeight)
    End If

    mBaseView.SetLayoutAnimated(0, mLeft, mTop, mWidth, mHeight)
    If mChild <> Null And needsCreate = False Then
        If xui.SubExists(mChild, "Unmount", 0) Then CallSub(mChild, "Unmount")
    End If
    mScrollView.Panel.RemoveAllViews
    mScrollView.Panel.Width = Max(0, mWidth)

    Dim viewportWidth As Int = Max(0, mWidth)
    Dim viewportHeight As Int = Max(0, mHeight)
    Dim contentHeight As Int = viewportHeight

    If mChild <> Null Then
        Dim childSize As List = CallSub3(mChild, "GetContentSize", viewportWidth, 100000dip)
        If childSize <> Null And childSize.IsInitialized And childSize.Size >= 2 Then
            contentHeight = Max(viewportHeight, childSize.Get(1))
        End If
        mContentHeight = contentHeight

        mScrollView.Panel.Height = contentHeight
        Dim contentPanel As B4XView = mScrollView.Panel
        CallSub2(mChild, "SetParent", contentPanel)
        CallSub3(mChild, "SetPosition", 0, 0)
        CallSub3(mChild, "SetSize", viewportWidth, contentHeight)
        CallSub(mChild, "Render")
    Else
        mContentHeight = viewportHeight
        mScrollView.Panel.Width = viewportWidth
        mScrollView.Panel.Height = viewportHeight
    End If
End Sub

' Scrolls to an absolute vertical content position.
Public Sub ScrollTo(Position As Int)
    If mScrollView = Null Then Return
    If mScrollView.IsInitialized = False Then Return
    mScrollView.ScrollPosition = Max(0, Min(Position, Max(0, mContentHeight - mHeight)))
End Sub

' Returns the current vertical scroll position.
Public Sub GetScrollPosition As Int
    If mScrollView = Null Then Return 0
    If mScrollView.IsInitialized = False Then Return 0
    Return mScrollView.ScrollPosition
End Sub

' Removes the native view and releases child mounting references.
Public Sub Unmount
    If mChild <> Null And xui.SubExists(mChild, "Unmount", 0) Then CallSub(mChild, "Unmount")
    If mBaseView <> Null Then
        If mBaseView.IsInitialized Then mBaseView.RemoveViewFromParent
    End If
    mScrollView = Null
    mBaseView = Null
    mParent = Null
    mContentHeight = 0
End Sub

' Returns the child's natural size when it can be measured.
Public Sub GetContentSize(MaxWidth As Int, MaxHeight As Int) As List
    If mChild <> Null Then
        Dim childSize As List = CallSub3(mChild, "GetContentSize", MaxWidth, MaxHeight)
        If childSize <> Null And childSize.IsInitialized And childSize.Size >= 2 Then Return childSize
    End If

    Dim flexibleSize As List
    flexibleSize.Initialize
    Return flexibleSize
End Sub