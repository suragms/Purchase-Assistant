# PLAN.MD — Execution controller

**Last updated:** 2026-05-29  
**Rule:** [MASTER_REBUILD_ROADMAP_V2.md](MASTER_REBUILD_ROADMAP_V2.md) wins over V1 when they conflict.  
**Product truth:** [docs/harisree/MASTER_REFERENCE.md](../docs/harisree/MASTER_REFERENCE.md), [context/rules/MASTER_CURSOR_RULES.md](../context/rules/MASTER_CURSOR_RULES.md)  
**Living board:** [TASKS.md](../TASKS.md) § PLAN.MD execution

## Per-file status (23)

| # | File | Phase | Status |
|---|------|-------|--------|
| 1 | PROJECT_AUDIT_REPORT.md | 1 | done |
| 2 | ROLE_MATRIX.md | 1 | done |
| 3 | LOGIC_AND_FEATURES_SPEC.md | 1 | done |
| 4 | STOCK_LOGIC_AUDIT.md | 1 | done |
| 5 | STOCK_LOGIC_DEEP_AUDIT.md | 1 | done |
| 6 | PURCHASE_AUDIT.md | 1 | done |
| 7 | PURCHASE_FLOW_DEEP_AUDIT.md | 1–2 | done (pipeline API + Flutter; deploy 040/041 pending) |
| 8 | NETWORK_DEEP_AUDIT.md | 1 | done |
| 9 | PERFORMANCE_AUDIT.md | 1 | done |
| 10 | PERFORMANCE_DEEP_AUDIT.md | 1 | done |
| 11 | UIUX_AUDIT.md | 1 | done |
| 12 | UIUX_DEEP_AUDIT.md | 1 | done (2026-05-29 item detail stock summary, stock chrome, low-stock tap) |
| 13 | DUPLICATE_CODE_REPORT.md | 1 | done |
| 14 | DUPLICATE_CODE_DEEP_REPORT.md | 1 | done |
| 15 | MASTER_REBUILD_ROADMAP.md | 2 | reconciled |
| 16 | MASTER_REBUILD_ROADMAP_V2.md | 2–4 | done (P0 verified; P1 pipeline card, staff order, reorder notify, sheets) |
| 17 | NOTIFICATION_REBUILD.md | 3 | done (7fcae7c + emitter dedupe) |
| 18 | ITEM_DETAIL_REBUILD.md | 3 | done (snapshot + delivery card; ref.read bundle) |
| 19 | OWNER_DASHBOARD_REBUILD.md | 3 | done (2026-05-28 sprints) |
| 20 | STAFF_DASHBOARD_REBUILD.md | 3 | done (2026-05-28 sprints) |
| 21 | FEATURE_PRUNING.md | 5 | done (settings prune + dead low-stock page removed) |
| 22 | FEATURE_PRUNING_COMPLETE.md | 5 | partial (analytics BI kept for reports) |
| 23 | DESKTOP_DESIGN_SPEC.md | 6 | done (1024 breakpoint, shell rail, home grid, stock/purchase/users master-detail, item detail, reports KPI row) |

## V1 ↔ V2 task map (P0)

| V1 (MASTER_REBUILD_ROADMAP) | V2 (MASTER_REBUILD_ROADMAP_V2) |
|-----------------------------|--------------------------------|
| Task 4 infinite refresh | Task 1 item_detail_providers `ref.read` |
| Task 5 realtime throttle | Task 2 home polling |
| Task 7 double stock delivery | Task 9 idempotency |
| Task 2–3 stock formula | Tasks 6–7 stock API + snapshot |
| — | Tasks 3–5 delivery_status pipeline |

## Baseline verify (2026-05-28)

| Check | Result |
|-------|--------|
| `flutter test` notification_alert_card + badge_parity | pass |
| `pytest tests/test_notifications.py` | 5 passed |
| `pytest tests/test_purchase_stock_reversal.py` | 3 passed (incl. idempotency) |
| `dart analyze` item_detail + home + trade_purchase | pass |
| Supabase MCP `notifications` unread | 2 rows |
| Render MCP logs | blocked (workspace not authorized) |

## Workflow (every file)

Read → extract tickets → reconcile code/TASKS → implement → verify → update this table + TASKS.md
