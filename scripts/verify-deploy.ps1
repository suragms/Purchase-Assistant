# Smoke-check live Render + Vercel after deploy (no secrets required).
$ErrorActionPreference = "Stop"

$renderHealth = "https://my-purchases-api.onrender.com/health"
$renderReady = "https://my-purchases-api.onrender.com/health/ready"
$vercelApp = "https://purchase-assiastant.vercel.app"
$vercelJs = "$vercelApp/main.dart.js"

function Test-UrlOk {
  param([string]$Url, [string]$Label)
  Write-Host ""
  Write-Host "=== $Label ===" -ForegroundColor Cyan
  try {
    $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 45
    Write-Host "OK $($r.StatusCode) $Url"
    if ($r.Content.Length -lt 500) { Write-Host $r.Content }
    return $true
  } catch {
    Write-Host "FAIL $Url - $($_.Exception.Message)" -ForegroundColor Red
    return $false
  }
}

$ok = $true
if (-not (Test-UrlOk -Url $renderHealth -Label "Render /health")) { $ok = $false }
if (-not (Test-UrlOk -Url $renderReady -Label "Render /health/ready")) { $ok = $false }
if (-not (Test-UrlOk -Url $vercelApp -Label "Vercel app shell")) { $ok = $false }

Write-Host ""
Write-Host "=== Vercel main.dart.js ===" -ForegroundColor Cyan
try {
  $head = Invoke-WebRequest -Uri $vercelJs -Method Head -UseBasicParsing -TimeoutSec 45
  Write-Host "OK $($head.StatusCode) $vercelJs (build artifact present)"
} catch {
  Write-Host "FAIL $vercelJs - Flutter web build may not be deployed" -ForegroundColor Red
  $ok = $false
}

if (-not $ok) { exit 1 }
Write-Host ""
Write-Host "Deploy smoke: Render + Vercel look healthy." -ForegroundColor Green
