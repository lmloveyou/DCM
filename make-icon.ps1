# Load the drawing library used to generate the PNG and ICO files.
Add-Type -AssemblyName System.Drawing

# Create the assets folder if it does not already exist.
$assetsDir = Join-Path $PSScriptRoot "assets"
if (-not (Test-Path -LiteralPath $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir | Out-Null
}

# Define where the generated image files will be saved.
$pngPath = Join-Path $assetsDir "dcm-icon.png"
$icoPath = Join-Path $assetsDir "dcm.ico"

# Create a transparent 256x256 canvas for the icon.
$bitmap = New-Object System.Drawing.Bitmap 256, 256
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.Clear([System.Drawing.Color]::Transparent)

# Build a rounded rectangle path because older PowerShell versions do not have FillRoundedRectangle.
function New-RoundedRectanglePath([System.Drawing.Rectangle]$rect, [int]$radius) {
    $diameter = $radius * 2
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath

    $path.AddArc($rect.X, $rect.Y, $diameter, $diameter, 180, 90)
    $path.AddArc(($rect.Right - $diameter), $rect.Y, $diameter, $diameter, 270, 90)
    $path.AddArc(($rect.Right - $diameter), ($rect.Bottom - $diameter), $diameter, $diameter, 0, 90)
    $path.AddArc($rect.X, ($rect.Bottom - $diameter), $diameter, $diameter, 90, 90)
    $path.CloseFigure()

    return $path
}

# Draw the blue-to-green rounded background.
$bgRect = New-Object System.Drawing.Rectangle 14, 14, 228, 228
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $bgRect,
    [System.Drawing.Color]::FromArgb(36, 99, 235),
    [System.Drawing.Color]::FromArgb(17, 130, 90),
    45
)
$bgPath = New-RoundedRectanglePath $bgRect 42
$graphics.FillPath($bgBrush, $bgPath)

# Draw the white document shape.
$zipBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(248, 250, 252))
$zipRect = New-Object System.Drawing.Rectangle 66, 44, 124, 164
$zipPath = New-RoundedRectanglePath $zipRect 18
$graphics.FillPath($zipBrush, $zipPath)

# Draw the folded page corner.
$foldBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(218, 226, 239))
$fold = New-Object System.Drawing.Drawing2D.GraphicsPath
$fold.AddPolygon([System.Drawing.Point[]]@(
    (New-Object System.Drawing.Point 154, 44),
    (New-Object System.Drawing.Point 190, 80),
    (New-Object System.Drawing.Point 154, 80)
))
$graphics.FillPath($foldBrush, $fold)

# Draw the small horizontal lines on the document.
$linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(33, 53, 87), 8)
$linePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$linePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
for ($y = 82; $y -le 148; $y += 22) {
    $graphics.DrawLine($linePen, 104, $y, 136, $y)
}

# Draw the green downward extraction arrow.
$arrowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(17, 130, 90), 14)
$arrowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$arrowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$graphics.DrawLine($arrowPen, 128, 142, 128, 194)
$graphics.DrawLine($arrowPen, 100, 166, 128, 194)
$graphics.DrawLine($arrowPen, 156, 166, 128, 194)

# Save a PNG preview of the icon.
$bitmap.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)

# Save the same drawing as a Windows ICO file.
$bitmap.GetHicon() | ForEach-Object {
    $icon = [System.Drawing.Icon]::FromHandle($_)
    $fileStream = [System.IO.File]::Create($icoPath)

    try {
        $icon.Save($fileStream)
    }
    finally {
        $fileStream.Dispose()
        $icon.Dispose()
    }
}

# Clean up drawing resources.
$graphics.Dispose()
$bitmap.Dispose()
$bgPath.Dispose()
$zipPath.Dispose()
$fold.Dispose()

Write-Host "Icon created: $icoPath"
