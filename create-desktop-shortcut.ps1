$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "DCM.lnk"
$scriptPath = Join-Path $PSScriptRoot "DCM.ps1"
$iconPath = Join-Path $PSScriptRoot "assets\dcm.ico"

if (-not (Test-Path -LiteralPath $iconPath)) {
    & (Join-Path $PSScriptRoot "make-icon.ps1")
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.IconLocation = $iconPath
$shortcut.Description = "DCM - Decompressie Manager"
$shortcut.Save()

Write-Host "Desktop shortcut created: $shortcutPath"
