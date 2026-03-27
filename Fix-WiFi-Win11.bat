@echo off
setlocal
cd /d "%~dp0"

echo ===========================================
echo   Windows 11 Wi-Fi One-Click Fix Tool
echo ===========================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Fix-WiFi-Win11.ps1"
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Fix failed, exit code: %EXIT_CODE%
)

endlocal
