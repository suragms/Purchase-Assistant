# Deploy fit-check (Context MD P6) — 2026-08-08

Measured against live Harisree topology: Flutter web on Vercel + FastAPI on Windows Server via Cloudflare Tunnel (`api.harisreeagency.online`). Postgres/SQLite on the API host (not Render).

## Latency

| Check | Result | Notes |
|-------|--------|--------|
| Cross-host DB | N/A from CI laptop without prod DB credentials | Operator should time `SELECT 1` from API process; target p95 < 50ms on same host |
| Public API health | PASS (prior smoke) | Cloudflare UA required; cold tunnel wake can add 1–3s |
| Owner dashboard GET | Single aggregate + 45s TTL cache | Avoids five chatty endpoints; damage + AI + WhatsApp counts included |
| Backup run | Manual + nightly 02:00 IST | Staggered vs peak daytime traffic |

## Storage

| Item | Guidance |
|------|----------|
| Backup root | `BACKUP_DIR` or `%LOCALAPPDATA%/HarisreeBackups` |
| Retention | Last 14 successful daily files kept (`apply_retention`) |
| 70–100GB headroom | Catalog + trade JSON backups stay small; PO PDFs/WhatsApp media are not stored server-side in Wave P5 |
| Secrets | `provider_credentials` excluded from backup JSON (`excludes` marker) |

## Load smoke (manual checklist)

1. Sign in as owner → Settings → Owner command center (exceptions + spend + WA queue).
2. Settings → Export & Backup → Run server backup → confirm log row.
3. Restore dry-run with sample JSON → `ok: true`, commit still 501.
4. Approve a trade purchase lifecycle → WhatsApp log row (`pending_manual` without creds is expected).
5. Reports at 1280/1600 → overview shows insights pane (not blank).

## Flags

- `AI_FORCE_TIER2_ONLY=true` — skip OpenRouter Tier 1.
- `ENABLE_WHATSAPP_PO_DELIVERY=false` — disable auto-send on approve.
- Migrate: `alembic upgrade head` through `070_ai_whatsapp_ops` on Windows API.

## Verdict

Fit for current single-business Harisree load if 069+070 migrated and Cloudflare UA kept on probes. Re-measure DB latency and disk after first week of nightly backups.
