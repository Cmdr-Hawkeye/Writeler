$ErrorActionPreference = "Stop"

$appDir = Resolve-Path "$PSScriptRoot\..\app"
Push-Location $appDir
try {
  dart compile js -O2 -o web/drift_worker.js web/drift_worker.dart
} finally {
  Pop-Location
}
