# Smoke-check live Render + Vercel after deploy (no secrets required).
$ErrorActionPreference = "Stop"

$renderHealth = "https://my-purchases-api.onrender.com/health"
$renderReady = "https://my-purchases-api.onrender.com/health/ready"
$vercelApps = @(
  "https://purchase-assistant.vercel.app",
  "https://purchase-assiastant.vercel.app"
)
$expectedAlembic = "060_stock_list_performance_indexes"

function Test-UrlOk {
  param([string]$Url, [string]$Label)
  Write-Host ""
  Write-Host "=== $Label ===" -ForegroundColor Cyan
  try {
    $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 90
    Write-Host "OK $($r.StatusCode) $Url"
    return @{ Ok = $true; Body = $r.Content }
  } catch {
    Write-Host "FAIL $Url - $($_.Exception.Message)" -ForegroundColor Red
    return @{ Ok = $false; Body = $null }
  }
}

$ok = $true

$health = Test-UrlOk -Url $renderHealth -Label "Render /health"
if (-not $health.Ok) { $ok = $false }

$ready = Test-UrlOk -Url $renderReady -Label "Render /health/ready (DB + schema)"
if (-not $ready.Ok) {
  $ok = $false
} elseif ($ready.Body) {
  try {
    $payload = $ready.Body | ConvertFrom-Json
    $db = $payload.db
    $schemaOk = $payload.schema_ok
    $alembic = $payload.schema.alembic_version
    $stockSync = $payload.stock_sync_ready
    $staffV2 = $payload.schema.staff_activity_v2

    Write-Host "  db: $db"
    Write-Host "  alembic_version: $alembic"
    Write-Host "  stock_sync_ready: $stockSync"
    Write-Host "  staff_activity_v2: $staffV2"
    Write-Host "  schema_ok: $schemaOk"

    if ($db -ne "ok") {
      Write-Host "FAIL: database not ok" -ForegroundColor Red
      $ok = $false
    }
    if (-not $stockSync) {
      Write-Host "WARN: stock_sync_ready is false (delivery pipeline columns missing?)" -ForegroundColor Yellow
    }
    if ($alembic -ne $expectedAlembic) {
      Write-Host "FAIL: expected alembic $expectedAlembic, got $alembic" -ForegroundColor Red
      Write-Host "  Run: Render Shell -> cd backend && alembic upgrade head" -ForegroundColor Yellow
      Write-Host "  Or set AUTO_MIGRATE=1 and redeploy once." -ForegroundColor Yellow
      $ok = $false
    }
    if ($null -ne $schemaOk -and -not $schemaOk) {
      Write-Host "WARN: schema_ok is false (migration 059 staff activity CHECK may be missing)" -ForegroundColor Yellow
      if ($alembic -ne $expectedAlembic) { $ok = $false }
    }
  } catch {
    Write-Host "WARN: could not parse /health/ready JSON: $_" -ForegroundColor Yellow
  }
}

$vercelOk = $false
foreach ($app in $vercelApps) {
  $shell = Test-UrlOk -Url $app -Label "Vercel app shell ($app)"
  if ($shell.Ok) {
    $vercelOk = $true
    $js = "$app/main.dart.js"
    Write-Host ""
    Write-Host "=== Vercel main.dart.js ===" -ForegroundColor Cyan
    try {
      $head = Invoke-WebRequest -Uri $js -Method Head -UseBasicParsing -TimeoutSec 90
      Write-Host "OK $($head.StatusCode) $js"
    } catch {
      Write-Host "FAIL $js - Flutter web build may not be deployed" -ForegroundColor Red
      $ok = $false
    }
  }
}
if (-not $vercelOk) {
  Write-Host "FAIL: no Vercel app URL responded" -ForegroundColor Red
  $ok = $false
}

if (-not $ok) {
  Write-Host ""
  Write-Host "Deploy smoke FAILED." -ForegroundColor Red
  Write-Host "Render dashboard: https://dashboard.render.com/web/srv-d7ea0il8nd3s73e4fvl0/settings" -ForegroundColor Yellow
  Write-Host "Align service with render.yaml: rootDir=backend, preDeployCommand=alembic upgrade head, healthCheckPath=/health/ready" -ForegroundColor Yellow
  exit 1
}

Write-Host ""
Write-Host "Deploy smoke: Render + Vercel look healthy (alembic $expectedAlembic)." -ForegroundColor Green
