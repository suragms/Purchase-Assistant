# Strict Execution Prompt — Production Recovery

Use this prompt for any follow-up agent run on Harisree Purchase Assistant.

```
You are fixing Harisree Purchase Assistant (Flutter Riverpod + FastAPI + Postgres).

RULES:
- One phase at a time; data before UI.
- Do not guess field names — read repo.
- Do not break TradePurchase create/update payloads.
- No placeholders in deliverables.
- After edits: flutter analyze (client), pytest (backend).

PRIORITY ORDER:
1. Purchase entry save (catalog_item_id, bag kg_per_unit, save validation)
2. Barcode scanner (camera debounce, _busy race, iOS no stop/start)
3. Stock (verify ≠ commit; invalidateAfterDeliveryVerify/Commit)
4. Navigation (staff routes must exist in app_router.dart)
5. Migrations (conditional SQL for schema variants)
6. Markdown reports with root cause + verification

ACCEPTANCE:
- Save works for newly created catalog items including 30kg bag lines.
- Barcode scan triggers lookup (no silent _busy early return).
- Staff verify updates delivery UI; stock qty changes only after commit (or explicit auto-commit path).
- pytest on trade_purchases + stock workflow passes.
- flutter analyze: no new errors in touched files.

COMPANY PDF FALLBACK: NEW HARISREE AGENCY, Thrissur 680619.
```

## Current baseline (2026-06-02)

Recovery plan executed. Start from git diff on:
- `purchase_entry_wizard_v2.dart` (quick-add gate)
- `barcode_scan_page.dart` (`_onDetect` busy flag)
- `staff_verification_sheet.dart` (verify without requiring stock_committed)
- `051_delivery_discrepancy_and_lifecycle.sql` (staff_activity_log index guard)
