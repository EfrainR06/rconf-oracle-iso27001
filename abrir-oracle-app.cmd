@echo off
setlocal
cd /d "%~dp0"
title Oracle - RCONF_APP - XEPDB1
"%~dp0.venv\Scripts\python.exe" "%~dp0tools\oracle_app_console.py"
if errorlevel 1 pause
endlocal
