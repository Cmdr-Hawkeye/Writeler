$ErrorActionPreference = "Stop"

Write-Host "Checking Writeler local toolchain..."

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "Flutter was not found in PATH."
  exit 1
}

flutter doctor

Push-Location "$PSScriptRoot\..\app"
try {
  dart pub get
  flutter analyze --no-pub
  flutter test --no-pub
} finally {
  Pop-Location
}
