@echo off
setlocal
cd /d "%~dp0"

echo ===========================================
echo   Disable Wi-Fi Auto Fix at Startup
echo ===========================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Remove-WiFi-AutoFix-Startup.ps1"
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Remove failed, exit code: %EXIT_CODE%
)

endlocal
