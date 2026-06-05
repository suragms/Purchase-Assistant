# Render service settings checklist — align live my-purchases-api with render.yaml.
# MCP cannot update web service build settings; apply in Dashboard:
# https://dashboard.render.com/web/srv-d7ea0il8nd3s73e4fvl0/settings
$ErrorActionPreference = "Stop"

Write-Host "Render service sync checklist (my-purchases-api)" -ForegroundColor Cyan
Write-Host ""
Write-Host "General:"
Write-Host "  rootDir:              backend"
Write-Host "  branch:               main"
Write-Host "  autoDeploy:           Yes"
Write-Host ""
Write-Host "Build & Deploy:"
Write-Host "  buildCommand:         pip install -r requirements.txt"
Write-Host "  preDeployCommand:     alembic upgrade head"
Write-Host "  startCommand:         uvicorn app.main:app --host 0.0.0.0 --port `$PORT --log-level info"
Write-Host "  healthCheckPath:      /health/ready"
Write-Host ""
Write-Host "Environment (merge, do not wipe secrets):"
Write-Host "  APP_ENV=production"
Write-Host "  AUTO_MIGRATE=0          (migrations via preDeploy only)"
Write-Host "  AUTO_STOCK_BACKFILL_ON_START=false"
Write-Host "  CORS_ORIGINS includes https://purchase-assistant.vercel.app"
Write-Host ""
Write-Host "After saving, Manual Deploy once, then:"
Write-Host "  powershell -File scripts/verify-deploy.ps1"
