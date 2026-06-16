$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$root = Resolve-Path "$PSScriptRoot\.."
$app = Join-Path $root "app"

function Ensure-Directory([string] $path) {
  if (-not (Test-Path -LiteralPath $path)) {
    New-Item -ItemType Directory -Path $path | Out-Null
  }
}

function New-WritelerBitmap([int] $size) {
  $bitmap = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.Clear([System.Drawing.Color]::FromArgb(38, 76, 67))

  $scale = $size / 1024.0
  function X([double] $value) { return [int][Math]::Round($value * $scale) }

  $cream = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(247, 244, 237))
  $paper = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(239, 231, 213))
  $gold = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(201, 162, 39))
  $ink = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(38, 76, 67), (X 24))
  $ink.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $ink.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

  $leftPage = [System.Drawing.Point[]] @(
    [System.Drawing.Point]::new((X 210), (X 292)),
    [System.Drawing.Point]::new((X 512), (X 292)),
    [System.Drawing.Point]::new((X 512), (X 766)),
    [System.Drawing.Point]::new((X 210), (X 766))
  )
  $rightPage = [System.Drawing.Point[]] @(
    [System.Drawing.Point]::new((X 512), (X 292)),
    [System.Drawing.Point]::new((X 814), (X 292)),
    [System.Drawing.Point]::new((X 814), (X 766)),
    [System.Drawing.Point]::new((X 512), (X 766))
  )
  $graphics.FillPolygon($cream, $leftPage)
  $graphics.FillPolygon($paper, $rightPage)
  $graphics.DrawLine($ink, (X 512), (X 292), (X 512), (X 766))

  $bookmark = [System.Drawing.Point[]] @(
    [System.Drawing.Point]::new((X 650), (X 260)),
    [System.Drawing.Point]::new((X 766), (X 260)),
    [System.Drawing.Point]::new((X 766), (X 674)),
    [System.Drawing.Point]::new((X 708), (X 634)),
    [System.Drawing.Point]::new((X 650), (X 674))
  )
  $graphics.FillPolygon($gold, $bookmark)

  foreach ($y in @(380, 468)) {
    $graphics.DrawLine($ink, (X 276), (X $y), (X 432), (X ($y - 4)))
  }
  foreach ($y in @(390, 478)) {
    $graphics.DrawLine($ink, (X 592), (X $y), (X 706), (X ($y - 8)))
  }

  $graphics.Dispose()
  $cream.Dispose()
  $paper.Dispose()
  $gold.Dispose()
  $ink.Dispose()
  return $bitmap
}

function Save-Png([string] $path, [int] $size) {
  Ensure-Directory (Split-Path -Parent $path)
  $bitmap = New-WritelerBitmap $size
  try {
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    $bitmap.Dispose()
  }
}

function New-PngBytes([int] $size) {
  $bitmap = New-WritelerBitmap $size
  $stream = [System.IO.MemoryStream]::new()
  try {
    $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
    return ,$stream.ToArray()
  } finally {
    $stream.Dispose()
    $bitmap.Dispose()
  }
}

function Save-Ico([string] $path, [int[]] $sizes) {
  Ensure-Directory (Split-Path -Parent $path)
  $images = @()
  foreach ($size in $sizes) {
    $images += [PSCustomObject]@{ Size = $size; Bytes = (New-PngBytes $size) }
  }

  $stream = [System.IO.File]::Create($path)
  $writer = [System.IO.BinaryWriter]::new($stream)
  try {
    $writer.Write([UInt16]0)
    $writer.Write([UInt16]1)
    $writer.Write([UInt16]$images.Count)
    $offset = 6 + (16 * $images.Count)
    foreach ($image in $images) {
      $dimensionByte = if ($image.Size -eq 256) { 0 } else { $image.Size }
      $writer.Write([Byte]$dimensionByte)
      $writer.Write([Byte]$dimensionByte)
      $writer.Write([Byte]0)
      $writer.Write([Byte]0)
      $writer.Write([UInt16]1)
      $writer.Write([UInt16]32)
      $writer.Write([UInt32]$image.Bytes.Length)
      $writer.Write([UInt32]$offset)
      $offset += $image.Bytes.Length
    }
    foreach ($image in $images) {
      $writer.Write($image.Bytes)
    }
  } finally {
    $writer.Dispose()
    $stream.Dispose()
  }
}

Save-Png (Join-Path $app "assets\brand\writeler_icon_1024.png") 1024

Save-Png (Join-Path $app "web\favicon.png") 32
Save-Png (Join-Path $app "web\icons\Icon-192.png") 192
Save-Png (Join-Path $app "web\icons\Icon-maskable-192.png") 192
Save-Png (Join-Path $app "web\icons\Icon-512.png") 512
Save-Png (Join-Path $app "web\icons\Icon-maskable-512.png") 512

$androidSizes = @{
  "mipmap-mdpi\ic_launcher.png" = 48
  "mipmap-hdpi\ic_launcher.png" = 72
  "mipmap-xhdpi\ic_launcher.png" = 96
  "mipmap-xxhdpi\ic_launcher.png" = 144
  "mipmap-xxxhdpi\ic_launcher.png" = 192
}
foreach ($entry in $androidSizes.GetEnumerator()) {
  Save-Png (Join-Path $app "android\app\src\main\res\$($entry.Key)") $entry.Value
}

$iosIcons = @{
  "Icon-App-20x20@1x.png" = 20
  "Icon-App-20x20@2x.png" = 40
  "Icon-App-20x20@3x.png" = 60
  "Icon-App-29x29@1x.png" = 29
  "Icon-App-29x29@2x.png" = 58
  "Icon-App-29x29@3x.png" = 87
  "Icon-App-40x40@1x.png" = 40
  "Icon-App-40x40@2x.png" = 80
  "Icon-App-40x40@3x.png" = 120
  "Icon-App-60x60@2x.png" = 120
  "Icon-App-60x60@3x.png" = 180
  "Icon-App-76x76@1x.png" = 76
  "Icon-App-76x76@2x.png" = 152
  "Icon-App-83.5x83.5@2x.png" = 167
  "Icon-App-1024x1024@1x.png" = 1024
}
foreach ($entry in $iosIcons.GetEnumerator()) {
  Save-Png (Join-Path $app "ios\Runner\Assets.xcassets\AppIcon.appiconset\$($entry.Key)") $entry.Value
}

$macIcons = @{
  "app_icon_16.png" = 16
  "app_icon_32.png" = 32
  "app_icon_64.png" = 64
  "app_icon_128.png" = 128
  "app_icon_256.png" = 256
  "app_icon_512.png" = 512
  "app_icon_1024.png" = 1024
}
foreach ($entry in $macIcons.GetEnumerator()) {
  Save-Png (Join-Path $app "macos\Runner\Assets.xcassets\AppIcon.appiconset\$($entry.Key)") $entry.Value
}

Save-Ico (Join-Path $app "windows\runner\resources\app_icon.ico") @(16, 32, 48, 64, 128, 256)

Write-Host "Generated Writeler brand assets."
