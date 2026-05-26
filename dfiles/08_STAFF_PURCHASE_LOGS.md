# AGENT PROMPT 08 — STAFF QUICK PURCHASE LOGS AND ITEM HISTORY

Status: implemented first pass.

## Scope

- Staff quick cash purchase logs are separate from formal purchase orders.
- Cash buys increment stock immediately because goods are already received.
- Owner can review staff cash purchase logs.
- Item detail must separate formal purchase order history from staff cash buys.

## Key Files

- `backend/app/models/staff_purchase_log.py`
- `backend/app/routers/stock.py`
- `flutter_app/lib/features/staff/presentation/staff_quick_purchase_page.dart`
- `flutter_app/lib/features/stock/presentation/staff_purchase_logs_page.dart`
- `flutter_app/lib/features/catalog/presentation/catalog_item_detail_page.dart`

## Verification

- Staff quick cash buy adds stock immediately.
- Formal purchase creation still does not update stock.
- Item detail shows staff cash buys separately from purchase orders.
- Owner Settings links to staff cash purchase log review.

