Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "DCM - Decompressie Manager"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(760, 560)
$form.MinimumSize = New-Object System.Drawing.Size(680, 500)
$form.BackColor = [System.Drawing.Color]::FromArgb(247, 249, 252)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$title = New-Object System.Windows.Forms.Label
$title.Text = "DCM"
$title.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 26)
$title.ForeColor = [System.Drawing.Color]::FromArgb(26, 38, 59)
$title.Location = New-Object System.Drawing.Point(24, 20)
$title.Size = New-Object System.Drawing.Size(220, 48)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "Selecteer meerdere ZIP-bestanden en pak ze in een keer uit."
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(83, 96, 118)
$subtitle.Location = New-Object System.Drawing.Point(28, 72)
$subtitle.Size = New-Object System.Drawing.Size(620, 28)
$form.Controls.Add($subtitle)

$selectButton = New-Object System.Windows.Forms.Button
$selectButton.Text = "ZIP-bestanden kiezen"
$selectButton.Location = New-Object System.Drawing.Point(28, 118)
$selectButton.Size = New-Object System.Drawing.Size(190, 38)
$selectButton.BackColor = [System.Drawing.Color]::FromArgb(36, 99, 235)
$selectButton.ForeColor = [System.Drawing.Color]::White
$selectButton.FlatStyle = "Flat"
$selectButton.FlatAppearance.BorderSize = 0
$form.Controls.Add($selectButton)

$clearButton = New-Object System.Windows.Forms.Button
$clearButton.Text = "Lijst leegmaken"
$clearButton.Location = New-Object System.Drawing.Point(228, 118)
$clearButton.Size = New-Object System.Drawing.Size(140, 38)
$clearButton.FlatStyle = "Flat"
$form.Controls.Add($clearButton)

$fileList = New-Object System.Windows.Forms.ListBox
$fileList.Location = New-Object System.Drawing.Point(28, 170)
$fileList.Size = New-Object System.Drawing.Size(690, 150)
$fileList.Anchor = "Top,Left,Right"
$fileList.HorizontalScrollbar = $true
$form.Controls.Add($fileList)

$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = "Doelmap"
$outputLabel.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
$outputLabel.Location = New-Object System.Drawing.Point(28, 340)
$outputLabel.Size = New-Object System.Drawing.Size(120, 24)
$form.Controls.Add($outputLabel)

$outputText = New-Object System.Windows.Forms.TextBox
$outputText.Location = New-Object System.Drawing.Point(28, 368)
$outputText.Size = New-Object System.Drawing.Size(560, 28)
$outputText.Anchor = "Top,Left,Right"
$outputText.ReadOnly = $true
$form.Controls.Add($outputText)

$outputButton = New-Object System.Windows.Forms.Button
$outputButton.Text = "Kiezen"
$outputButton.Location = New-Object System.Drawing.Point(600, 366)
$outputButton.Size = New-Object System.Drawing.Size(118, 32)
$outputButton.Anchor = "Top,Right"
$outputButton.FlatStyle = "Flat"
$form.Controls.Add($outputButton)

$extractButton = New-Object System.Windows.Forms.Button
$extractButton.Text = "Alles decomprimeren"
$extractButton.Location = New-Object System.Drawing.Point(28, 420)
$extractButton.Size = New-Object System.Drawing.Size(210, 42)
$extractButton.BackColor = [System.Drawing.Color]::FromArgb(17, 130, 90)
$extractButton.ForeColor = [System.Drawing.Color]::White
$extractButton.FlatStyle = "Flat"
$extractButton.FlatAppearance.BorderSize = 0
$form.Controls.Add($extractButton)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(252, 429)
$progress.Size = New-Object System.Drawing.Size(466, 24)
$progress.Anchor = "Top,Left,Right"
$form.Controls.Add($progress)

$status = New-Object System.Windows.Forms.Label
$status.Text = "Klaar om ZIP-bestanden te kiezen."
$status.ForeColor = [System.Drawing.Color]::FromArgb(83, 96, 118)
$status.Location = New-Object System.Drawing.Point(28, 482)
$status.Size = New-Object System.Drawing.Size(690, 28)
$status.Anchor = "Top,Left,Right"
$form.Controls.Add($status)

$selectedFiles = New-Object System.Collections.Generic.List[string]

function Update-FileList {
    $fileList.Items.Clear()
    foreach ($file in $selectedFiles) {
        [void]$fileList.Items.Add($file)
    }
    $status.Text = "$($selectedFiles.Count) ZIP-bestand(en) geselecteerd."
}

function Get-SafeFolderName([string]$name) {
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    foreach ($char in $invalidChars) {
        $name = $name.Replace($char, "_")
    }
    return $name
}

$selectButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "Kies ZIP-bestanden"
    $dialog.Filter = "ZIP-bestanden (*.zip)|*.zip"
    $dialog.Multiselect = $true

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        foreach ($file in $dialog.FileNames) {
            if (-not $selectedFiles.Contains($file)) {
                $selectedFiles.Add($file)
            }
        }
        Update-FileList
    }
})

$clearButton.Add_Click({
    $selectedFiles.Clear()
    $progress.Value = 0
    Update-FileList
})

$outputButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Kies de map waar DCM alles moet uitpakken"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputText.Text = $dialog.SelectedPath
        $status.Text = "Doelmap gekozen."
    }
})

$extractButton.Add_Click({
    if ($selectedFiles.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Kies eerst een of meer ZIP-bestanden.", "DCM", "OK", "Information") | Out-Null
        return
    }

    if ([string]::IsNullOrWhiteSpace($outputText.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Kies eerst een doelmap.", "DCM", "OK", "Information") | Out-Null
        return
    }

    $extractButton.Enabled = $false
    $selectButton.Enabled = $false
    $clearButton.Enabled = $false
    $outputButton.Enabled = $false
    $progress.Value = 0
    $progress.Maximum = $selectedFiles.Count

    $successCount = 0
    $errors = New-Object System.Collections.Generic.List[string]

    foreach ($zipPath in $selectedFiles) {
        try {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($zipPath)
            $folderName = Get-SafeFolderName $baseName
            $destination = Join-Path $outputText.Text $folderName

            if (-not (Test-Path -LiteralPath $destination)) {
                New-Item -ItemType Directory -Path $destination | Out-Null
            }

            $status.Text = "Bezig met uitpakken: $([System.IO.Path]::GetFileName($zipPath))"
            $form.Refresh()

            [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $destination)
            $successCount++
        }
        catch {
            $errors.Add("$([System.IO.Path]::GetFileName($zipPath)): $($_.Exception.Message)")
        }
        finally {
            if ($progress.Value -lt $progress.Maximum) {
                $progress.Value++
            }
        }
    }

    $extractButton.Enabled = $true
    $selectButton.Enabled = $true
    $clearButton.Enabled = $true
    $outputButton.Enabled = $true

    if ($errors.Count -eq 0) {
        $status.Text = "Klaar. $successCount bestand(en) uitgepakt."
        [System.Windows.Forms.MessageBox]::Show("Alles is succesvol gedecomprimeerd.", "DCM", "OK", "Information") | Out-Null
    }
    else {
        $status.Text = "Klaar met $successCount succes(sen) en $($errors.Count) fout(en)."
        [System.Windows.Forms.MessageBox]::Show(($errors -join [Environment]::NewLine), "DCM - fouten", "OK", "Warning") | Out-Null
    }
})

[void]$form.ShowDialog()
