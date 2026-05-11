@echo off
REM Get the folder where this launcher is stored.
set SCRIPT_DIR=%~dp0

REM Start the DCM PowerShell app from that same folder.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%DCM.ps1"
