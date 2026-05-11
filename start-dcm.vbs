' Create a shell object that can start another program.
Set shell = CreateObject("WScript.Shell")

' Find the folder where this launcher is stored.
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Build the PowerShell command that starts the DCM app without a console window.
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptDir & "\DCM.ps1"""

' Run DCM without showing a separate console window.
shell.Run command, 0, False
