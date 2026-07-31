B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
    Private mDark As Boolean
End Sub

' Creates a light theme by default.
Public Sub Initialize As UITheme
    mDark = False
    Return Me
End Sub

' Selects the active color scheme and returns the same theme instance.
Public Sub DarkMode(Value As Boolean) As UITheme
    mDark = Value
    Return Me
End Sub

' Toggles the active color scheme and returns the new state.
Public Sub Toggle As Boolean
    mDark = Not(mDark)
    Return mDark
End Sub

' Returns True when the dark color scheme is active.
Public Sub IsDark As Boolean
    Return mDark
End Sub

' Returns the main application background color.
Public Sub Background As Int
    If mDark Then Return 0xFF0F172A
    Return 0xFFF4F7FB
End Sub

' Returns the default card and surface color.
Public Sub Surface As Int
    If mDark Then Return 0xFF1E293B
    Return Colors.White
End Sub

' Returns a secondary surface color for controls and muted buttons.
Public Sub SurfaceVariant As Int
    If mDark Then Return 0xFF334155
    Return 0xFFDCE5F2
End Sub

' Returns the primary readable text color.
Public Sub PrimaryText As Int
    If mDark Then Return 0xFFF8FAFC
    Return 0xFF132238
End Sub

' Returns the secondary readable text color.
Public Sub SecondaryText As Int
    If mDark Then Return 0xFFCBD5E1
    Return 0xFF6B7B91
End Sub

' Returns the low-emphasis text color.
Public Sub MutedText As Int
    If mDark Then Return 0xFF94A3B8
    Return 0xFF7D8CA1
End Sub

' Returns the dashboard app bar color.
Public Sub DashboardBar As Int
    If mDark Then Return 0xFF0B1220
    Return 0xFF132238
End Sub

' Returns the secondary app bar color.
Public Sub SecondaryBar As Int
    If mDark Then Return 0xFF111827
    Return 0xFF253B5B
End Sub

' Returns the highlighted dashboard hero surface.
Public Sub HeroSurface As Int
    If mDark Then Return 0xFF123C3C
    Return 0xFFE8F8F5
End Sub

' Returns the primary teal accent color.
Public Sub Accent As Int
    Return 0xFF00A896
End Sub

' Returns the blue informational accent color.
Public Sub Info As Int
    Return 0xFF3D6FE8
End Sub

' Returns the destructive action color.
Public Sub Negative As Int
    Return 0xFFE45757
End Sub

' Returns the divider color.
Public Sub Divider As Int
    If mDark Then Return 0xFF475569
    Return 0xFFE0E0E0
End Sub

' Returns the card border color.
Public Sub Border As Int
    If mDark Then Return 0xFF334155
    Return 0xFFE0E0E0
End Sub

' Returns the readable text color for buttons placed on variant surfaces.
Public Sub ButtonText As Int
    If mDark Then Return Colors.White
    Return PrimaryText
End Sub

' Returns the background used by the theme action button.
Public Sub ThemeAction As Int
    If mDark Then Return 0xFF0F766E
    Return PrimaryText
End Sub