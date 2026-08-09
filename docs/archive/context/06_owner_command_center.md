# FEATURE: Owner Super-Admin Command Center

## Context
Single dashboard, owner-role-only. Pulls together data that already exists in scattered form (damage reports, trade reports) plus new data from other features in this build (staff tasks, backups, AI usage). Backend is 2 vCPU/8GB — this dashboard must be built with pre-aggregation, not live heavy joins on every page load, or it becomes the next "slow" complaint.

## Dependencies (build these first, this dashboard is a consumer)
- Staff performance data → `05_staff_management.md`
- AI usage data → `03_ai_provider_openrouter.md` (`ai_usage_log` table)
- Backup status → `04_auto_backup_restore.md` (`backup_log` table)
- Damage reports → already exist (`routers/damage_reports.py`, migration `056_purchase_damage_reports.py`) — surface, don't rebuild.
- Comparison reports → check `routers/reports_trade.py` / `report_views.py` for existing aggregation logic before writing new SQL.

## Panels

### 1. Staff performance
Per staff: tasks completed today/week/month, avg response time, avg completion time, pending count, correction/rejection rate. Sourced from `staff_task` aggregation (file 05).

### 2. Stock flow & prediction
Current stock, daily/weekly average consumption (SQL-computed — deterministic, never AI-estimated), estimated days-to-stockout, reorder-point flag. Include damaged/written-off stock from the existing damage-reports data alongside live stock, not as a disconnected separate report — an owner should see "120 in stock, 8 damaged this month" in one view.

### 3. Comparison reports
Today/yesterday, this week/last week, this month/last month, YoY. Reuse existing `reports_trade.py`/`report_views.py` aggregation — confirm what's already computed before adding new queries.

### 4. Infrastructure stats (genuinely new)
- DB storage used vs the 70–100GB allocation, growth rate trend, projected time-to-limit.
- Backend health snapshot — extend the existing `routers/health.py` rather than building a parallel health check.
- Backup status: last run time, size, success/fail, retention compliance — from `backup_log`.

### 5. AI usage stats
Requests/day by tier and model, estimated cost (from the cost-config table in file 03), Tier-1 → Tier-2 escalation rate. A rising escalation rate is itself a signal worth surfacing — it means Tier-1 prompts/models need tuning.

## Task
### Step 1 — Aggregation strategy
Decide per panel: materialized view refreshed on a schedule (reuse the APScheduler pattern already in `main.py`) vs on-demand query with short-TTL cache. Default to scheduled aggregation for anything hitting large tables (stock movements, staff tasks, AI usage log); on-demand is fine only for genuinely small/cheap queries.

### Step 2 — Single dashboard endpoint, not five
`GET /v1/businesses/{business_id}/owner/dashboard` returning all panel data in one payload (or a small number of grouped calls if payload size becomes unwieldy) — avoid the frontend firing 5+ separate requests on dashboard load, which directly reintroduces the problem identified in file 02.

### Step 3 — Flutter screen
New owner-only route, gated the same way other owner-only features in this build are gated (reuse the role-check pattern, don't invent a new one). Layout: exception-first — surface only what needs attention prominently (stock running low, staff tasks stuck, backup failed, AI escalation rate spiking), with drill-down into full detail per panel rather than dumping every number at once.

## Deliverable
- Materialized views / scheduled aggregation jobs per panel
- Single (or minimal-count) dashboard endpoint
- Owner-only Flutter dashboard screen

## Risk
Medium — the main risk is this becoming exactly the kind of API-overload/slow-UI problem this whole build is trying to fix, if aggregation isn't done properly. Load-test the dashboard endpoint under realistic data volume before considering it done.

## Tests
- Dashboard loads correctly with zero data (new business, nothing to show yet) — no crashes on empty aggregates.
- Dashboard reflects a stock-damage event, a failed backup, and an AI escalation spike correctly when manually triggered in a test environment.
- Role gate: non-owner accounts get a 403, not a partial/empty dashboard.
- Load test: dashboard endpoint response time under realistic multi-month data volume, confirm it stays acceptable on the actual 2-core/8GB server profile.
