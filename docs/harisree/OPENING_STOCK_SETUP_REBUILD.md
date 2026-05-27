# Opening Stock Setup — Operational Rebuild (2026-05-27)

## Goal
Rebuild the Opening Stock Setup screen into an industrial “warehouse onboarding” workflow:
compact chrome, fast search/filters, an operational `ITEM | UNIT | OPENING | STATUS` table, and audit-safe opening stock writes backed by the ledger + realtime invalidation.

## Backend (FastAPI)
### List endpoint
- **`GET /v1/businesses/{id}/stock/opening/setup`**
  - Paginated list with server-side search and filters
  - Summary payload: `pending_count`, `completed_count`, `total_count`, `last_updated_at`, `last_updated_by`

### Hardened write endpoint
- **`POST /v1/businesses/{id}/stock/{item_id}/opening-stock`**
  - Staff permission: uses `stock_edit` for write access (owner is visible via audit metadata)
  - When editing a locked opening value and the qty changes, the API requires a **non-empty** `reason`
  - Uses `apply_stock_movement(..., movement_kind="opening_stock")` to record ledger + staff activity
  - Accepts `idempotency_key` and optional `notes`
  - Publishes `stock.changed` realtime event for UI refresh

## Flutter UI
### New operational primitives
- `OpeningStockTopBar`: Back + Search + Filters + Progress
- `OpeningStockSummaryBar`: Pending / Completed / Remaining + last updated by/time
- `OpeningStockFilterChips`: Pending / Completed / Low / Missing Barcode / Missing Code
- `OpeningStockTableHeader` + `OpeningStockTableRow`: bordered operational table row
- `OpeningStockSetSheet`: compact qty/notes/reason sheet for setting opening stock
- `OpeningStockProgressSheet`: progress summary with a quick “pending” view
- `OpeningStockFilterSheet`: advanced filter modal (category/subcategory/supplier/unit/stock status/updated by/updated today/pending-only)
- `OpeningStockRowActions`: bottom sheet actions for set, item detail, activity, and ledger

### Page rebuild
- `opening_stock_setup_page.dart`
  - search toggle + debounce (`q=...`)
  - pagination via `StockPaginationBar`
  - targeted invalidation after successful writes

### Catalog item detail header
- Updated `_ItemWarehouseHeroHeader` to display:
  - opening, current, diff, and last stock update fields
  - opening box deep-links to `/stock/opening-setup?q=<item_code>`

### Bulk set (P1)
- Multi-select opening rows (long-press / checkbox)
- Bulk “Set opening qty” applies qty sequentially to selected items
- Missing barcode inline warning navigates to `/stock/missing-barcodes`

## Test + QA notes
### Backend
- `backend/tests/test_opening_stock_setup.py` passes (list summary/filters + hardened set behavior).

### Flutter
- Updated `flutter_app/test/responsive_layout_smoke_test.dart` with an overflow guard for `OpeningStockTableRow` across phone/tablet widths.

## Manual QA checklist
- Pending/Completed chips filter correctly and resets pagination
- Search matches item name / code / barcode
- Set sheet:
  - allows first-time set
  - enforces reason when updating locked qty
  - updates stock page + counts after save
- Bulk set:
  - selection works (long-press + checkbox)
  - sequential set applies to all selected items
- Missing barcode warning tap opens `/stock/missing-barcodes`

