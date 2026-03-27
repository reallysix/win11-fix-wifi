@echo off
setlocal
cd /d "%~dp0"

echo ===========================================
echo   Enable Wi-Fi Auto Fix at Startup
echo ===========================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-WiFi-AutoFix-Startup.ps1"
set EXIT_CODE=%ERRORLEVEL%

if not "%EXIT_CODE%"=="0" (
    echo.
    echo [ERROR] Install failed, exit code: %EXIT_CODE%
)

endlocal
