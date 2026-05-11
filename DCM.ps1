# Load the Windows UI and ZIP libraries that DCM needs.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Make the Windows Forms controls use the modern Windows visual style.
[System.Windows.Forms.Application]::EnableVisualStyles()

# Create the main app window.
$form = New-Object System.Windows.Forms.Form
$form.Text = "DCM - Decompression Manager"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(760, 560)
$form.MinimumSize = New-Object System.Drawing.Size(680, 500)
$form.BackColor = [System.Drawing.Color]::FromArgb(247, 249, 252)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# Add the app title.
$title = New-Object System.Windows.Forms.Label
$title.Text = "DCM"
$title.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 26)
$title.ForeColor = [System.Drawing.Color]::FromArgb(26, 38, 59)
$title.Location = New-Object System.Drawing.Point(24, 20)
$title.Size = New-Object System.Drawing.Size(220, 48)
$form.Controls.Add($title)

# Add a short description under the title.
$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "Select multiple ZIP files and extract them in one action."
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(83, 96, 118)
$subtitle.Location = New-Object System.Drawing.Point(28, 72)
$subtitle.Size = New-Object System.Drawing.Size(620, 28)
$form.Controls.Add($subtitle)

# Button for choosing one or more ZIP files.
$selectButton = New-Object System.Windows.Forms.Button
$selectButton.Text = "Choose ZIP files"
$selectButton.Location = New-Object System.Drawing.Point(28, 118)
$selectButton.Size = New-Object System.Drawing.Size(190, 38)
$selectButton.BackColor = [System.Drawing.Color]::FromArgb(36, 99, 235)
$selectButton.ForeColor = [System.Drawing.Color]::White
$selectButton.FlatStyle = "Flat"
$selectButton.FlatAppearance.BorderSize = 0
$form.Controls.Add($selectButton)

# Button for clearing the current selection.
$clearButton = New-Object System.Windows.Forms.Button
$clearButton.Text = "Clear list"
$clearButton.Location = New-Object System.Drawing.Point(228, 118)
$clearButton.Size = New-Object System.Drawing.Size(140, 38)
$clearButton.FlatStyle = "Flat"
$form.Controls.Add($clearButton)

# List box that shows the selected ZIP file paths.
$fileList = New-Object System.Windows.Forms.ListBox
$fileList.Location = New-Object System.Drawing.Point(28, 170)
$fileList.Size = New-Object System.Drawing.Size(690, 150)
$fileList.Anchor = "Top,Left,Right"
$fileList.HorizontalScrollbar = $true
$form.Controls.Add($fileList)

# Label for the destination folder input.
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = "Output folder"
$outputLabel.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
$outputLabel.Location = New-Object System.Drawing.Point(28, 340)
$outputLabel.Size = New-Object System.Drawing.Size(120, 24)
$form.Controls.Add($outputLabel)

# Read-only text box that shows the selected output folder.
$outputText = New-Object System.Windows.Forms.TextBox
$outputText.Location = New-Object System.Drawing.Point(28, 368)
$outputText.Size = New-Object System.Drawing.Size(560, 28)
$outputText.Anchor = "Top,Left,Right"
$outputText.ReadOnly = $true
$form.Controls.Add($outputText)

# Button for choosing the output folder.
$outputButton = New-Object System.Windows.Forms.Button
$outputButton.Text = "Choose"
$outputButton.Location = New-Object System.Drawing.Point(600, 366)
$outputButton.Size = New-Object System.Drawing.Size(118, 32)
$outputButton.Anchor = "Top,Right"
$outputButton.FlatStyle = "Flat"
$form.Controls.Add($outputButton)

# Button that starts the extraction process.
$extractButton = New-Object System.Windows.Forms.Button
$extractButton.Text = "Extract all"
$extractButton.Location = New-Object System.Drawing.Point(28, 420)
$extractButton.Size = New-Object System.Drawing.Size(210, 42)
$extractButton.BackColor = [System.Drawing.Color]::FromArgb(17, 130, 90)
$extractButton.ForeColor = [System.Drawing.Color]::White
$extractButton.FlatStyle = "Flat"
$extractButton.FlatAppearance.BorderSize = 0
$form.Controls.Add($extractButton)

# Progress bar that moves forward after each ZIP file is processed.
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(252, 429)
$progress.Size = New-Object System.Drawing.Size(466, 24)
$progress.Anchor = "Top,Left,Right"
$form.Controls.Add($progress)

# Status line for short messages while the app is running.
$status = New-Object System.Windows.Forms.Label
$status.Text = "Ready to choose ZIP files."
$status.ForeColor = [System.Drawing.Color]::FromArgb(83, 96, 118)
$status.Location = New-Object System.Drawing.Point(28, 482)
$status.Size = New-Object System.Drawing.Size(690, 28)
$status.Anchor = "Top,Left,Right"
$form.Controls.Add($status)

# Store the full paths of the selected ZIP files.
$selectedFiles = New-Object System.Collections.Generic.List[string]

# Refresh the file list shown in the UI.
function Update-FileList {
    $fileList.Items.Clear()

    foreach ($file in $selectedFiles) {
        [void]$fileList.Items.Add($file)
    }

    $status.Text = "$($selectedFiles.Count) ZIP file(s) selected."
}

# Replace invalid Windows folder-name characters with underscores.
function Get-SafeFolderName([string]$name) {
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()

    foreach ($char in $invalidChars) {
        $name = $name.Replace($char, "_")
    }

    return $name
}

# Open a file picker and add selected ZIP files to the list.
$selectButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "Choose ZIP files"
    $dialog.Filter = "ZIP files (*.zip)|*.zip"
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

# Clear selected files and reset the progress bar.
$clearButton.Add_Click({
    $selectedFiles.Clear()
    $progress.Value = 0
    Update-FileList
})

# Open a folder picker and store the selected output folder.
$outputButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Choose where DCM should extract the ZIP files"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputText.Text = $dialog.SelectedPath
        $status.Text = "Output folder selected."
    }
})

# Validate the input and extract every selected ZIP file.
$extractButton.Add_Click({
    if ($selectedFiles.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Choose one or more ZIP files first.", "DCM", "OK", "Information") | Out-Null
        return
    }

    if ([string]::IsNullOrWhiteSpace($outputText.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Choose an output folder first.", "DCM", "OK", "Information") | Out-Null
        return
    }

    # Disable controls while extraction is running so the file list cannot change halfway.
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
            # Each ZIP file is extracted into its own folder named after the archive.
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($zipPath)
            $folderName = Get-SafeFolderName $baseName
            $destination = Join-Path $outputText.Text $folderName

            if (-not (Test-Path -LiteralPath $destination)) {
                New-Item -ItemType Directory -Path $destination | Out-Null
            }

            $status.Text = "Extracting: $([System.IO.Path]::GetFileName($zipPath))"
            $form.Refresh()

            [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $destination)
            $successCount++
        }
        catch {
            # Keep going when one ZIP fails, then show all errors at the end.
            $errors.Add("$([System.IO.Path]::GetFileName($zipPath)): $($_.Exception.Message)")
        }
        finally {
            if ($progress.Value -lt $progress.Maximum) {
                $progress.Value++
            }
        }
    }

    # Re-enable the controls when processing is finished.
    $extractButton.Enabled = $true
    $selectButton.Enabled = $true
    $clearButton.Enabled = $true
    $outputButton.Enabled = $true

    if ($errors.Count -eq 0) {
        $status.Text = "Done. Extracted $successCount file(s)."
        [System.Windows.Forms.MessageBox]::Show("All ZIP files were extracted successfully.", "DCM", "OK", "Information") | Out-Null
    }
    else {
        $status.Text = "Done with $successCount success(es) and $($errors.Count) error(s)."
        [System.Windows.Forms.MessageBox]::Show(($errors -join [Environment]::NewLine), "DCM - errors", "OK", "Warning") | Out-Null
    }
})

# Start the app window.
[void]$form.ShowDialog()
