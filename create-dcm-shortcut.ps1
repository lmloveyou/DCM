$shortcutPath = Join-Path $PSScriptRoot "DCM.lnk"
$targetPath = Join-Path $PSScriptRoot "start-dcm.vbs"
$iconPath = Join-Path $PSScriptRoot "assets\dcm.ico"

if (-not (Test-Path -LiteralPath $iconPath)) {
    & (Join-Path $PSScriptRoot "make-icon.ps1")
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.IconLocation = $iconPath
$shortcut.Description = "DCM - Decompressie Manager"
$shortcut.Save()

Write-Host "Shortcut created: $shortcutPath"
