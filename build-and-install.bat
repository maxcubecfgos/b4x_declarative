@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Always work relative to this script, even when launched by double-click.
cd /d "%~dp0"
if errorlevel 1 goto :error

set "SOURCE=%~dp0DeclarativeUI.b4xlib"
set "DEST=C:\Program Files\Anywhere Software\extra\DeclarativeUI.b4xlib"

rem If we are not running as Administrator, relaunch this script elevated.
rem The user confirms the UAC prompt once; the elevated copy continues from here.
net session >nul 2>&1
if errorlevel 1 (
    echo Requesting administrator privileges to install the library...
    powershell.exe -NoLogo -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

rem Build the library first, then install it into the B4A additional libraries folder.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-b4xlib.ps1"
if errorlevel 1 goto :error

if not exist "%SOURCE%" (
    echo ERROR: Missing %SOURCE%
    goto :error
)

copy /y "%SOURCE%" "%DEST%" >nul
if errorlevel 1 goto :error

echo.
echo DeclarativeUI.b4xlib installed successfully to:
echo   %DEST%
echo.
exit /b 0

:error
echo.
echo ERROR: The b4xlib could not be built or installed.
echo Check that Windows PowerShell is available and that the B4A extra folder exists.
echo.
pause
exit /b 1
