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

function Find-PythonCommand {
  $python = Get-Command python -ErrorAction SilentlyContinue
  if ($python) {
    return @($python.Source)
  }

  $py = Get-Command py -ErrorAction SilentlyContinue
  if ($py) {
    return @($py.Source, "-3")
  }

  throw "Python was not found. Install Python or add it to PATH, then run this starter again."
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

if (-not (Test-Path -LiteralPath $indexFile)) {
  Write-Host "Web build not found. Building Writeler web assets..."
  & (Join-Path $repoRoot "scripts\build_web_assets.ps1")
  Push-Location $appDir
  try {
    & flutter build web --no-pub --no-web-resources-cdn
  } finally {
    Pop-Location
  }
}

$pythonCommand = Find-PythonCommand
$selectedPort = Find-AvailablePort $Port
$url = "http://127.0.0.1:$selectedPort"

Write-Host ""
Write-Host "Writeler web server"
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

$pythonArgs = @()
if ($pythonCommand.Count -gt 1) {
  $pythonArgs += $pythonCommand[1..($pythonCommand.Count - 1)]
}
$pythonArgs += @("-m", "http.server", "$selectedPort", "--bind", "127.0.0.1", "--directory", "$webDir")

& $pythonCommand[0] $pythonArgs
