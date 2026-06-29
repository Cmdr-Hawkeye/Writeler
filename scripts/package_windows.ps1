param(
  [string] $Configuration = "Release"
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path "$PSScriptRoot\.."
$app = Join-Path $root "app"
$version = (Select-String -Path (Join-Path $app "pubspec.yaml") -Pattern '^version:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
$artifactDir = Join-Path $root "artifacts"
$zipPath = Join-Path $artifactDir "Writeller-$version-windows-x64.zip"

Push-Location $app
try {
  dart pub get
  flutter build windows --no-pub --release
} finally {
  Pop-Location
}

$releaseDir = Join-Path $app "build\windows\x64\runner\$Configuration"
if (-not (Test-Path -LiteralPath $releaseDir)) {
  throw "Windows release directory not found: $releaseDir"
}

if (-not (Test-Path -LiteralPath $artifactDir)) {
  New-Item -ItemType Directory -Path $artifactDir | Out-Null
}
if (Test-Path -LiteralPath $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $releaseDir "*") -DestinationPath $zipPath
Write-Host "Created $zipPath"
