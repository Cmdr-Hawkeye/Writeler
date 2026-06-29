param(
  [int]$Port = 8090,
  [switch]$NoBrowser,
  [switch]$CheckOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$appDir = Join-Path $repoRoot "app"
$webDir = Join-Path $appDir "build\web"
$indexFile = Join-Path $webDir "index.html"
$mainJsFile = Join-Path $webDir "main.dart.js"
$builtWorkerFile = Join-Path $webDir "drift_worker.js"
$webServerScript = Join-Path $repoRoot "scripts\writeller_web_server.dart"

function Find-DartCommand {
  $dart = Get-Command dart -ErrorAction SilentlyContinue
  if ($dart) {
    return $dart.Source
  }

  throw "Dart was not found. Install Flutter or add Dart to PATH, then run this starter again."
}

function Test-PortAvailable([int]$CandidatePort) {
  $listener = Get-NetTCPConnection -LocalAddress 127.0.0.1 -LocalPort $CandidatePort -State Listen -ErrorAction SilentlyContinue
  return -not $listener
}

function Find-AvailablePort([int]$StartPort) {
  for ($candidate = $StartPort; $candidate -lt ($StartPort + 20); $candidate++) {
    if (Test-PortAvailable $candidate) {
      return $candidate
    }
  }

  throw "No free local port found between $StartPort and $($StartPort + 19)."
}

function Test-WebBuildStale {
  if (
    -not (Test-Path -LiteralPath $indexFile) -or
    -not (Test-Path -LiteralPath $mainJsFile) -or
    -not (Test-Path -LiteralPath $builtWorkerFile)
  ) {
    return $true
  }

  $mainBuildTime = (Get-Item -LiteralPath $mainJsFile).LastWriteTimeUtc
  $webShellBuildTime = (Get-Item -LiteralPath $indexFile).LastWriteTimeUtc
  $workerBuildTime = (Get-Item -LiteralPath $builtWorkerFile).LastWriteTimeUtc

  $libDir = Join-Path $appDir "lib"
  if (Test-Path -LiteralPath $libDir) {
    $newerDartFile = Get-ChildItem -LiteralPath $libDir -Recurse -File |
      Where-Object { $_.LastWriteTimeUtc -gt $mainBuildTime } |
      Select-Object -First 1
    if ($newerDartFile) {
      return $true
    }
  }

  $webDirSource = Join-Path $appDir "web"
  if (Test-Path -LiteralPath $webDirSource) {
    $newerWebFile = Get-ChildItem -LiteralPath $webDirSource -Recurse -File |
      Where-Object { $_.Name -notmatch '^drift_worker\.js(\.deps|\.map)?$' } |
      Where-Object { $_.LastWriteTimeUtc -gt $webShellBuildTime } |
      Select-Object -First 1
    if ($newerWebFile) {
      return $true
    }
  }

  foreach ($file in @((Join-Path $appDir "pubspec.yaml"), (Join-Path $appDir "pubspec.lock"))) {
    if ((Test-Path -LiteralPath $file) -and (Get-Item -LiteralPath $file).LastWriteTimeUtc -gt $mainBuildTime) {
      return $true
    }
  }

  $workerBuildScript = Join-Path $repoRoot "scripts\build_web_assets.ps1"
  if ((Test-Path -LiteralPath $workerBuildScript) -and (Get-Item -LiteralPath $workerBuildScript).LastWriteTimeUtc -gt $workerBuildTime) {
    return $true
  }

  return $false
}

if (Test-WebBuildStale) {
  Write-Host "Web build missing or stale. Building Writeller web assets..."
  & (Join-Path $repoRoot "scripts\build_web_assets.ps1")
  Push-Location $appDir
  try {
    & flutter build web --no-pub --no-web-resources-cdn --pwa-strategy=none
  } finally {
    Pop-Location
  }
}

$dartCommand = Find-DartCommand
$selectedPort = Find-AvailablePort $Port
$url = "http://127.0.0.1:$selectedPort"

Write-Host ""
Write-Host "Writeller web server"
Write-Host "URL: $url"
Write-Host "Directory: $webDir"

if ($CheckOnly) {
  Write-Host "Check completed. The starter is ready."
  exit 0
}

if (-not $NoBrowser) {
  Start-Process $url
}

Write-Host "Close this window or press Ctrl+C to stop the server."
Write-Host ""

$dartArgs = @("run", "$webServerScript", "--port", "$selectedPort", "--bind", "127.0.0.1", "--directory", "$webDir")

& $dartCommand $dartArgs
