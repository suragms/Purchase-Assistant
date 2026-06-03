# Database Refactor Notes

**Date:** 2026-06-02  
**Focus:** Reliability without breaking TradePurchase contracts

## Principles

1. Add routes/columns; do not rename `/v1/businesses/{id}/...` paths without migration.
2. Migrations must be **idempotent** and **schema-variant safe** (`IF EXISTS`, `DO $$` blocks).
3. Stock truth = movements + `current_stock`; repairs via SQL backfill, not ad-hoc client math.

## Recent migration inventory

| Script | Purpose |
|--------|---------|
| `051_delivery_discrepancy_and_lifecycle.sql` | Lifecycle events, delivery discrepancies, indexes, stock backfill, report_saved_views cleanup fn |

## Refactor actions taken

- Conditional FK for `broker_id` → `contacts`
- Conditional index DDL for legacy tables missing soft-delete columns
- Guard `staff_activity_log` index creation
- `cleanup_report_saved_views(retention)` function for old saved views

## Not refactored (deferred)

- Merging legacy `entries` into trade reports (already trade-backed on client)
- Adding `supplier_id` per line (would need schema + API version)

## Alembic / Render

- Alembic versions in `backend/alembic/versions/` — keep in sync with `backend/sql/` for ops
- Production: run SQL files manually; confirm with `pytest` and smoke purchase→stock

## Connection pooling

- Use Supabase pooler for serverless bursts; Render web service should use internal DB URL where available

## Verification checklist

- [x] `051` applies on DB without `contacts`
- [x] `051` applies without `staff_activity_log`
- [x] pytest trade + stock suites green
