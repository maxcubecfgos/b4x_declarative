@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Always work relative to this script, even when launched by double-click.
cd /d "%~dp0"
if errorlevel 1 goto :error

set "SCRIPT=%~dp0build-b4xlib.ps1"
if not exist "%SCRIPT%" (
    echo ERROR: Missing build-b4xlib.ps1
    goto :error
)

rem The PowerShell script creates and validates the package beside this BAT.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
if errorlevel 1 goto :error

if not exist "%~dp0DeclarativeUI-0.1.b4xlib" goto :error

echo.
echo Done. You can copy DeclarativeUI-0.1.b4xlib to the B4A Additional Libraries folder.
echo.
exit /b 0

:error
echo.
echo ERROR: The b4xlib could not be created or validated.
echo Check that Windows PowerShell is available and that the source files are present.
echo.
pause
exit /b 1
