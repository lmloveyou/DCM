# Create a DCM shortcut inside the project folder.
$shortcutPath = Join-Path $PSScriptRoot "DCM.lnk"

# Point the shortcut to the silent launcher.
$launcherPath = Join-Path $PSScriptRoot "start-dcm.vbs"

# Use the generated DCM icon for the shortcut.
$iconPath = Join-Path $PSScriptRoot "assets\dcm.ico"

# Generate the icon first if it does not exist yet.
if (-not (Test-Path -LiteralPath $iconPath)) {
    & (Join-Path $PSScriptRoot "make-icon.ps1")
}

# Use the Windows Script Host COM API to create a real .lnk shortcut.
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)

# Start the VBS launcher through wscript.exe so no terminal window is shown.
$shortcut.TargetPath = Join-Path $env:WINDIR "System32\wscript.exe"
$shortcut.Arguments = "`"$launcherPath`""
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.IconLocation = $iconPath
$shortcut.Description = "DCM - Decompression Manager"
$shortcut.Save()

Write-Host "Shortcut created: $shortcutPath"
