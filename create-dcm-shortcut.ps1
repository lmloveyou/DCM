# Create a DCM shortcut inside the project folder.
$shortcutPath = Join-Path $PSScriptRoot "DCM.lnk"

# Point the shortcut directly to the main PowerShell app script.
$scriptPath = Join-Path $PSScriptRoot "DCM.ps1"

# Use the generated DCM icon for the shortcut.
$iconPath = Join-Path $PSScriptRoot "assets\dcm.ico"

# Generate the icon first if it does not exist yet.
if (-not (Test-Path -LiteralPath $iconPath)) {
    & (Join-Path $PSScriptRoot "make-icon.ps1")
}

# Use the Windows Script Host COM API to create a real .lnk shortcut.
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)

# Start PowerShell directly so Windows does not ask how to open a .vbs file.
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.IconLocation = $iconPath
$shortcut.Description = "DCM - Decompression Manager"
$shortcut.Save()

Write-Host "Shortcut created: $shortcutPath"
