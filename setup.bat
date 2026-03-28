@echo off
setlocal

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "SETUP_SCRIPT=%ROOT%\setup.ps1"

set "PS_CMD=pwsh"
where pwsh >nul 2>&1
if errorlevel 1 set "PS_CMD=powershell"

echo.
echo ==> Running setup.ps1
"%PS_CMD%" -NoProfile -ExecutionPolicy Bypass -File "%SETUP_SCRIPT%"
if errorlevel 1 goto :fail

echo.
echo Setup complete.
exit /b 0

:fail
echo.
echo Setup failed.
exit /b 1
