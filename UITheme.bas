B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=13.62
@EndOfDesignText@
Sub Class_Globals
    Private mDark As Boolean
    Private mSeedColor As Int
End Sub

' Creates a light theme with the default teal seed color.
Public Sub Initialize As UITheme
    mDark = False
    mSeedColor = 0xFF00A896
    Return Me
End Sub

' Creates a light theme from a seed color in one declarative call.
' Use a normal B4A ARGB color, for example 0xFF6750A4.
Public Sub InitializeWithScheme(SeedColor As Int) As UITheme
    mDark = False
    mSeedColor = NormalizeColor(SeedColor)
    Return Me
End Sub

' Selects the seed color used to derive the active palette.
' This is the library equivalent of a Flutter ColorScheme seed color.
Public Sub Scheme(SeedColor As Int) As UITheme
    mSeedColor = NormalizeColor(SeedColor)
    Return Me
End Sub

' Returns the current seed color.
Public Sub GetScheme As Int
    Return mSeedColor
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
    If mDark Then Return MixColors(mSeedColor, Colors.Black, 0.88)
    Return MixColors(Colors.White, mSeedColor, 0.03)
End Sub

' Returns the default card and surface color.
Public Sub Surface As Int
    If mDark Then Return MixColors(mSeedColor, Colors.Black, 0.72)
    Return MixColors(Colors.White, mSeedColor, 0.01)
End Sub

' Returns a secondary surface color for controls and muted buttons.
Public Sub SurfaceVariant As Int
    If mDark Then Return MixColors(mSeedColor, Colors.Black, 0.52)
    Return MixColors(Colors.White, mSeedColor, 0.14)
End Sub

' Returns the primary readable text color.
Public Sub PrimaryText As Int
    If mDark Then Return MixColors(Colors.White, mSeedColor, 0.08)
    Return MixColors(0xFF132238, mSeedColor, 0.08)
End Sub

' Returns the secondary readable text color.
Public Sub SecondaryText As Int
    If mDark Then Return MixColors(0xFFCBD5E1, mSeedColor, 0.12)
    Return MixColors(0xFF6B7B91, mSeedColor, 0.10)
End Sub

' Returns the low-emphasis text color.
Public Sub MutedText As Int
    If mDark Then Return MixColors(0xFF94A3B8, mSeedColor, 0.16)
    Return MixColors(0xFF7D8CA1, mSeedColor, 0.08)
End Sub

' Returns the dashboard app bar color.
Public Sub DashboardBar As Int
    If mDark Then Return MixColors(mSeedColor, Colors.Black, 0.92)
    Return MixColors(mSeedColor, Colors.Black, 0.76)
End Sub

' Returns a readable foreground for the dashboard app bar.
Public Sub DashboardBarText As Int
    Return OnColor(DashboardBar)
End Sub

' Returns the secondary app bar color.
Public Sub SecondaryBar As Int
    If mDark Then Return MixColors(mSeedColor, Colors.Black, 0.82)
    Return MixColors(mSeedColor, Colors.Black, 0.64)
End Sub

' Returns the default snackbar background.
Public Sub SnackbarBackground As Int
    If mDark Then Return MixColors(mSeedColor, Colors.Black, 0.94)
    Return MixColors(mSeedColor, Colors.Black, 0.82)
End Sub

' Returns a readable snackbar message color.
Public Sub SnackbarText As Int
    Return OnColor(SnackbarBackground)
End Sub

' Returns a readable snackbar action color.
Public Sub SnackbarAction As Int
    If SnackbarText = Colors.White Then Return MixColors(mSeedColor, Colors.White, 0.20)
    Return MixColors(mSeedColor, Colors.Black, 0.20)
End Sub

' Returns the highlighted dashboard hero surface.
Public Sub HeroSurface As Int
    If mDark Then Return MixColors(mSeedColor, Colors.Black, 0.60)
    Return MixColors(Colors.White, mSeedColor, 0.12)
End Sub

' Returns the primary teal accent color.
Public Sub Accent As Int
    If mDark Then Return MixColors(mSeedColor, Colors.White, 0.08)
    Return mSeedColor
End Sub

' Returns the blue informational accent color.
Public Sub Info As Int
    Return MixColors(0xFF3D6FE8, mSeedColor, 0.12)
End Sub

' Returns the destructive action color.
Public Sub Negative As Int
    Return MixColors(0xFFE45757, mSeedColor, 0.06)
End Sub

' Returns the divider color.
Public Sub Divider As Int
    If mDark Then Return MixColors(mSeedColor, Colors.White, 0.24)
    Return MixColors(Colors.White, mSeedColor, 0.12)
End Sub

' Returns the card border color.
Public Sub Border As Int
    If mDark Then Return MixColors(mSeedColor, Colors.White, 0.16)
    Return MixColors(Colors.White, mSeedColor, 0.18)
End Sub

' Returns the readable text color for buttons placed on variant surfaces.
Public Sub ButtonText As Int
    Return OnColor(SurfaceVariant)
End Sub

' Returns the background used by the theme action button.
Public Sub ThemeAction As Int
    Return MixColors(mSeedColor, Colors.Black, 0.74)
End Sub

' Returns a readable foreground for the theme action button.
Public Sub ThemeActionText As Int
    Return OnColor(ThemeAction)
End Sub

' Returns a readable foreground for the primary accent.
Public Sub AccentText As Int
    Return OnColor(Accent)
End Sub

' Returns a readable foreground for the informational accent.
Public Sub InfoText As Int
    Return OnColor(Info)
End Sub

' Returns a readable foreground for the destructive accent.
Public Sub NegativeText As Int
    Return OnColor(Negative)
End Sub

' Returns either a dark or light foreground with useful contrast against Value.
Private Sub OnColor(Value As Int) As Int
    Dim lightContrast As Float = ContrastRatio(Value, Colors.White)
    Dim darkContrast As Float = ContrastRatio(Value, 0xFF132238)
    If lightContrast >= darkContrast Then Return Colors.White
    Return 0xFF132238
End Sub

' Blends two opaque colors. Amount 0 returns First and 1 returns Second.
Private Sub MixColors(First As Int, Second As Int, Amount As Float) As Int
    Dim safeAmount As Float = Amount
    If safeAmount < 0 Then safeAmount = 0
    If safeAmount > 1 Then safeAmount = 1
    Dim red As Int = MixChannel(ChannelRed(First), ChannelRed(Second), safeAmount)
    Dim green As Int = MixChannel(ChannelGreen(First), ChannelGreen(Second), safeAmount)
    Dim blue As Int = MixChannel(ChannelBlue(First), ChannelBlue(Second), safeAmount)
    Return ComposeColor(255, red, green, blue)
End Sub

Private Sub MixChannel(First As Int, Second As Int, Amount As Float) As Int
    Dim value As Int = Round(First + (Second - First) * Amount)
    If value < 0 Then value = 0
    If value > 255 Then value = 255
    Return value
End Sub

Private Sub ChannelRed(Value As Int) As Int
    Return Bit.And(Bit.ShiftRight(Value, 16), 0xFF)
End Sub

Private Sub ChannelGreen(Value As Int) As Int
    Return Bit.And(Bit.ShiftRight(Value, 8), 0xFF)
End Sub

Private Sub ChannelBlue(Value As Int) As Int
    Return Bit.And(Value, 0xFF)
End Sub

Private Sub ComposeColor(Alpha As Int, Red As Int, Green As Int, Blue As Int) As Int
    Return Bit.Or(Bit.Or(Bit.Or(Bit.ShiftLeft(Alpha, 24), Bit.ShiftLeft(Red, 16)), Bit.ShiftLeft(Green, 8)), Blue)
End Sub

Private Sub RelativeLuminance(Value As Int) As Float
    Return ChannelRed(Value) * 0.299 + ChannelGreen(Value) * 0.587 + ChannelBlue(Value) * 0.114
End Sub

' Compares two foreground colors using their relative luminance over Value.
Private Sub ContrastRatio(Value As Int, Foreground As Int) As Float
    Dim backgroundLuminance As Float = RelativeLuminance(Value) / 255
    Dim foregroundLuminance As Float = RelativeLuminance(Foreground) / 255
    Dim lighter As Float = Max(backgroundLuminance, foregroundLuminance) + 0.05
    Dim darker As Float = Min(backgroundLuminance, foregroundLuminance) + 0.05
    Return lighter / darker
End Sub

' Treat colors without an explicit alpha channel as opaque for predictable themes.
Private Sub NormalizeColor(Value As Int) As Int
    Dim alpha As Int = Bit.And(Bit.ShiftRight(Value, 24), 0xFF)
    If alpha = 0 Then alpha = 255
    Return ComposeColor(alpha, ChannelRed(Value), ChannelGreen(Value), ChannelBlue(Value))
End Sub