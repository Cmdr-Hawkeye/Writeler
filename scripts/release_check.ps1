param(
  [switch] $SkipTests,
  [switch] $SkipWebBuild,
  [switch] $IncludeWindowsBuild,
  [switch] $IncludeAndroidApk
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path "$PSScriptRoot\.."
$app = Join-Path $root "app"

Write-Host "Writeler release check"
Write-Host "Workspace: $root"

Push-Location $app
try {
  dart pub get
  flutter analyze --no-pub

  if (-not $SkipTests) {
    flutter test --no-pub
  }

  if (-not $SkipWebBuild) {
    Push-Location $root
    try {
      powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build_web_assets.ps1
    } finally {
      Pop-Location
    }
    flutter build web --no-pub --no-web-resources-cdn
  }

  if ($IncludeWindowsBuild) {
    flutter build windows --no-pub --release
  }

  if ($IncludeAndroidApk) {
    flutter build apk --no-pub --release
  }
} finally {
  Pop-Location
}

Write-Host "Writeler release check completed."
