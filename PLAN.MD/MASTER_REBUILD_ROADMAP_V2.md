# MASTER_REBUILD_ROADMAP_V2.md
## Complete Ordered Task List — Every File, Every Fix, Every Priority
**Audit Date:** May 29, 2026  
**This document extends the original MASTER_REBUILD_ROADMAP.md with deep code analysis**

---

## P0 — CRITICAL (DO THESE FIRST — app is producing wrong data)

### Task 1 — Fix `ref.watch` → `ref.read` in item_detail_providers.dart
**File:** `flutter_app/lib/core/providers/item_detail_providers.dart`
**Lines:** 27–35
**Change:**
```dart
// BEFORE:
ref.watch(catalogItemDetailProvider(itemId).future),
// AFTER:
ref.read(catalogItemDetailProvider(itemId).future),
```
Apply to all 4 providers inside `Future.wait`. This stops the cascade rebuild loop.  
**Effort:** 10 minutes. **Risk:** Low.

---

### Task 2 — Fix dual polling timers on home page
**File:** `flutter_app/lib/features/home/presentation/home_page.dart`
**Lines:** 95–115
- Remove `_rtPollAlerts` timer (every 20s)
- Keep `_rtPollFull` but change interval to 60s
- Add debounce to all invalidation calls: 500ms minimum between calls
- Verify `_throttleHomeInvalidate` is called by ALL 5 refresh sources

**Effort:** 30 minutes. **Risk:** Medium (test refresh still works after).

---

### Task 3 — Add `delivery_status` to database
**File:** Create `backend/sql/040_purchase_delivery_tracking.sql`
```sql
ALTER TABLE trade_purchases
  ADD COLUMN IF NOT EXISTS delivery_status VARCHAR(30) NOT NULL DEFAULT 'pending'
    CHECK (delivery_status IN ('pending','dispatched','in_transit','arrived',
           'staff_verifying','staff_verified','stock_committed','partial','cancelled')),
  ADD COLUMN IF NOT EXISTS dispatched_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS arrived_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS staff_verified_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS staff_verified_by UUID REFERENCES users(id),
  ADD COLUMN IF NOT EXISTS staff_verified_by_name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS stock_committed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS staff_verified_qty NUMERIC(12,3),
  ADD COLUMN IF NOT EXISTS truck_number VARCHAR(100),
  ADD COLUMN IF NOT EXISTS driver_contact VARCHAR(100);

UPDATE trade_purchases SET delivery_status = 'stock_committed' WHERE is_delivered = TRUE;
```
Run on production database.  
**Effort:** 20 minutes. **Risk:** Low (additive only).

---

### Task 4 — Add `DeliveryStatus` enum to Flutter model
**File:** `flutter_app/lib/core/models/trade_purchase_models.dart`
- Add `DeliveryStatus` enum (pending/dispatched/in_transit/arrived/staff_verifying/staff_verified/stock_committed/partial)
- Add `deliveryStatus` field to `TradePurchase` class
- Add `deliveredQtyCommitted`, `staffVerifiedQty`, `truckNumber` fields
- Update `TradePurchase.fromJson()` to parse new fields

**Effort:** 45 minutes. **Risk:** Low.

---

### Task 5 — Add backend delivery API endpoints
**File:** `backend/app/routers/purchases.py` (or wherever purchase routes live)

Add 4 endpoints:
1. `POST /v1/businesses/{id}/purchases/{pid}/dispatch`
2. `POST /v1/businesses/{id}/purchases/{pid}/arrive`
3. `POST /v1/businesses/{id}/purchases/{pid}/verify`  
4. `POST /v1/businesses/{id}/purchases/{pid}/commit-to-stock`
5. `GET /v1/businesses/{id}/purchases/delivery-pipeline`

The `commit-to-stock` endpoint must call `apply_stock_movement(movement_kind='delivery_receive', qty=verified_qty)` for each line item.

**Effort:** 3 hours. **Risk:** High (core stock logic — test thoroughly).

---

### Task 6 — Fix stock column calculation
**File:** `flutter_app/lib/features/catalog/presentation/widgets/item_stock_snapshot_card.dart`

Change `systemQty` from reading `catalog_items.current_stock` to:
```dart
final systemQty = openingQty + purchasedQty;  // opening + committed deliveries
```

Change `purchasedQty` to use lifetime total (not period-filtered):
```dart
final purchasedQty = coerceToDouble(
  stock['total_delivered_qty'] ?? intel['total_purchased_qty']
);
```

Add `pendingQty`:
```dart
final pendingQty = coerceToDouble(stock['total_pending_delivery_qty']);
```

**Effort:** 1 hour. **Risk:** High (touches number users see — verify with screenshots).

---

### Task 7 — Add `total_delivered_qty` to stock API response
**File:** `backend/app/routers/stock.py` (or wherever `/v1/businesses/{id}/stock/{itemId}` is defined)

Query must include:
```sql
SELECT 
  ci.*,
  COALESCE(
    (SELECT SUM(sm.delta_qty) 
     FROM stock_movements sm 
     WHERE sm.item_id = ci.id 
     AND sm.movement_kind = 'delivery_receive'), 0
  ) AS total_delivered_qty,
  COALESCE(
    (SELECT SUM(tpl.qty_in_stock_unit)
     FROM trade_purchase_lines tpl
     JOIN trade_purchases tp ON tpl.purchase_id = tp.id
     WHERE tpl.catalog_item_id = ci.id
     AND tp.delivery_status NOT IN ('stock_committed','cancelled')
     AND tp.deleted_at IS NULL), 0
  ) AS total_pending_delivery_qty
FROM catalog_items ci
WHERE ci.id = :item_id
```

**Effort:** 2 hours. **Risk:** Medium.

---

### Task 8 — Delete `catalog_item_detail_page.dart`
**File to delete:** `flutter_app/lib/features/catalog/presentation/catalog_item_detail_page.dart` (3018 lines)

Steps:
1. Search for all `CatalogItemDetailPage` references: `grep -rn "CatalogItemDetailPage" lib/`
2. Redirect all navigation to `ItemDetailPage`
3. Verify `app_router.dart` route points to `ItemDetailPage`
4. Move any missing features from `catalog_item_detail_page.dart` to appropriate widget in `item_detail_page.dart`
5. Delete file
6. `flutter analyze` — fix any errors

**Effort:** 2 hours. **Risk:** High (large page removal — test all navigation paths).

---

### Task 9 — Fix idempotency in stock movements (prevent double-commit)
**File:** `backend/app/services/stock_movement_service.py`
**File:** `flutter_app/lib/core/api/hexa_api.dart` — all stock movement calls must send `idempotency_key`

```dart
// Flutter: generate key before API call
final key = 'delivery_${purchaseId}_${itemId}_${DateTime.now().millisecondsSinceEpoch}';
await api.commitDeliveryToStock(purchaseId: purchaseId, idempotencyKey: key);
```

```python
# Backend: check before applying
existing = await db.execute(
  select(StockMovement).where(
    StockMovement.business_id == business_id,
    StockMovement.idempotency_key == idempotency_key,
  )
)
if existing.scalar_one_or_none():
  return existing  # already committed, safe to return
```

**Effort:** 1 hour. **Risk:** Medium.

---

## P1 — MAJOR (UI/UX broken — do after P0)

### Task 10 — Rebuild staff home dashboard section order
**File:** `flutter_app/lib/features/staff/presentation/staff_home_page.dart`  
**File:** `flutter_app/lib/features/staff/presentation/widgets/staff_home_dashboard_widgets.dart`

Order must be:
1. Greeting + date
2. MY TASKS (pending delivery verifications, physical counts)
3. WAREHOUSE SUMMARY (compact 2-col grid)
4. PENDING DELIVERIES (with Mark Arrived button)
5. LOW STOCK (with Inform Owner button)
6. TOOLS (horizontal scroll)
7. RECENT ACTIVITY (my last 10 actions)

Remove: `StaffWarehouseTotalsCard` and `StaffWarehouseDifferenceCard` from current top position — they show confusing numbers before tasks.

**Effort:** 2 hours. **Risk:** Low.

---

### Task 11 — Rebuild owner home dashboard section order
**File:** `flutter_app/lib/features/home/presentation/home_page.dart`  
**Files:** `lib/features/home/presentation/widgets/` (all widget files)

Order must be:
1. Critical alerts (low stock, out of stock, pending verification)
2. Stock summary (system/physical/diff totals)
3. Pending deliveries (with commit button)
4. Opening stock missing (if any)
5. Low stock items
6. Out of stock items
7. Expenses this month (new feature)
8. Tools (horizontal)
9. My tasks checklist
10. Recent activity

**Effort:** 3 hours. **Risk:** Medium.

---

### Task 12 — Fix user management page horizontal scroll
**File:** `flutter_app/lib/features/admin/presentation/` (user management)

Replace `TabBarView` inside `Column` with `Row` layout:
- Left column: `ListView` of user roles (fixed 200px)
- Right column: `Expanded` user detail panel

**Effort:** 2 hours. **Risk:** Low.

---

### Task 13 — Fix bottom sheet keyboard overlap in all forms
Search for all `showModalBottomSheet` calls in:
- `update_stock_sheet.dart`
- `opening_stock_set_sheet.dart`  
- `stock_compact_update_sheet.dart`
- `purchase_item_entry_sheet.dart`
- All other sheet files

Each must add:
```dart
Padding(
  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
  child: SingleChildScrollView(child: form),
)
```

**Effort:** 2 hours. **Risk:** Low.

---

### Task 14 — Add delivery pipeline card to owner home
**New file:** `flutter_app/lib/features/home/presentation/widgets/home_delivery_pipeline_card.dart`

Shows:
- Count dispatched (with names)
- Count arrived (needs verification) — highlighted
- Count verified (needs commit) — CTA button
- Taps navigate to `PurchaseListPage(filterBy: 'pipeline')`

**Effort:** 3 hours. **Risk:** Low.

---

### Task 15 — Add delivery status badges to purchase list rows
**File:** `flutter_app/lib/features/purchase/presentation/` (list page)

Each purchase row must show two badges:
- Payment status (existing): Paid/Pending/Overdue
- Delivery status (new): Dispatched/Arrived/Verified/Committed

Color codes per `DESKTOP_DESIGN_SPEC.md`.

**Effort:** 2 hours. **Risk:** Low.

---

### Task 16 — Add verify-and-commit flow to purchase detail page
**File:** `flutter_app/lib/features/purchase/presentation/purchase_detail_page.dart`

Add UI flow:
- If `delivery_status == arrived`: show [Start Verification] button (staff only)
- If `delivery_status == staff_verified`: show [Commit to Stock] button (owner/manager)
- Show delivery status timeline strip at top of detail
- Show who did each step and when

**Effort:** 4 hours. **Risk:** High.

---

### Task 17 — Fix stock page vertical scroll (remove excessive widgets)
**File:** `flutter_app/lib/features/stock/presentation/stock_page.dart`

- Remove duplicate filter headers
- Use `SliverAppBar` with collapsing search
- Use `ListView.builder` not nested `Column`
- Target: stock list is reachable without scrolling on mobile

**Effort:** 2 hours. **Risk:** Medium.

---

### Task 18 — Delete 9 confirmed duplicate files
See `DUPLICATE_CODE_DEEP_REPORT.md` for list.

Delete in this order:
1. `features/dashboard/state/dashboard_provider.dart`
2. `features/stock/presentation/low_stock_operations_page.dart`
3. `features/stock/presentation/low_stock_owner_page.dart`
4. `features/stock/presentation/reorder_suggestions_page.dart`
5. `features/stock/presentation/stock_compact_update_sheet.dart`
6. `features/stock/presentation/stock_quick_edit_sheet.dart`
7. `features/stock/presentation/quick_stock_patch_sheet.dart`
8. Merge stock_today_feed_page, stock_changes_page, stock_movement_page, stock_history_page → tabs in stock_page
9. `features/catalog/presentation/catalog_item_detail_page.dart` (do last, Task 8)

**Effort:** 6 hours total. **Risk:** Medium per file.

---

### Task 19 — Add expense tracker feature
**New files:**
- `lib/features/expenses/presentation/expense_tracker_page.dart`
- `lib/features/expenses/presentation/add_expense_sheet.dart`
- `lib/core/providers/expense_providers.dart`
- `backend/sql/041_expense_logs.sql` (create table)
- Backend endpoint: `GET/POST /v1/businesses/{id}/expenses`

**Effort:** 8 hours. **Risk:** Low (new isolated feature).

---

### Task 20 — Reorder notification flow (staff → owner)
**File:** `flutter_app/lib/features/stock/presentation/widgets/low_stock_item_row.dart`
**File:** `backend/app/services/notification_emitter.py`

Staff taps "Inform Owner" → creates reorder notification:
```python
await emit_notification(
  business_id=business_id,
  target_roles=['owner', 'manager'],
  type='REORDER_REQUEST',
  title=f'{item_name} needs reorder',
  body=f'{staff_name} requests: {item_name} (current: {qty} {unit})',
  action_url=f'/stock/item/{item_id}',
  metadata={'item_id': item_id, 'requested_by': actor_id},
)
```

Owner taps notification → item detail opens → [Purchase Now] shown.

**Effort:** 3 hours. **Risk:** Medium.

---

## P2 — UX POLISH (after P0 + P1)

### Task 21 — Reduce card whitespace
**File:** `flutter_app/lib/core/design_system/hexa_operational_tokens.dart`
- Change mobile section gap to 10
- Change card padding to 12 on mobile
- Test all pages render correctly

### Task 22 — Fix search dropdown keyboard overlap
**File:** `flutter_app/lib/features/search/presentation/search_page.dart`
Use `LayoutBuilder` + `viewInsets.bottom` to position dropdown above keyboard.

### Task 23 — Fix stock row touch targets
All stock list rows must have minimum height 52dp on mobile.

### Task 24 — Remove settings features (brand name, catalog URL, OCR)
**File:** `flutter_app/lib/features/settings/presentation/settings_page.dart`
Remove 3 settings sections that don't belong in warehouse app.

### Task 25 — Add activity log to item detail
Every item detail must show who edited what, when, with old → new values.  
Read from `stock_movements` table filtered by `item_id`.

### Task 26 — Add "last edited by / when" to stock list rows
Each row in stock list should show small text: "Updated May 29 · Anil"  
Field: `catalog_items.last_stock_updated_at` + `last_stock_updated_by`

### Task 27 — Desktop split pane for stock page
**File:** `flutter_app/lib/features/stock/presentation/widgets/stock_desktop_detail_pane.dart` (already exists)
Connect to `stockSelectedItemIdProvider` — when user taps row on desktop, show detail in right pane without navigation.

### Task 28 — Desktop user management layout
Replace nested tab layout with side-by-side layout per `DESKTOP_DESIGN_SPEC.md`.

### Task 29 — Reports page scrollable with date filter
**File:** `flutter_app/lib/features/reports/presentation/reports_page.dart`
Add `[Today] [Week] [Month] [Year] [Custom]` chip row at top.
Make entire page scrollable with `CustomScrollView + SliverList`.

### Task 30 — Performance: add cache TTL to high-frequency providers
```dart
// Add to stockListProvider and similar:
void _providerKeepAlive(Ref ref, Duration ttl) {
  final link = ref.keepAlive();
  final timer = Timer(ttl, link.close);
  ref.onDispose(timer.cancel);
}
// In provider body:
_providerKeepAlive(ref, const Duration(seconds: 30));
```

---

## VALIDATION CHECKLIST (after all tasks)

```
STOCK LOGIC:
[ ] Sugar shows opening: 101, purchased: 711, system: 812 (not 101)
[ ] Pending delivery qty shows separately (not in system total)
[ ] Physical count different from system → shows red difference
[ ] Verified delivery → system stock increases immediately
[ ] No double-commit possible (idempotency works)

PERFORMANCE:
[ ] Home page loads in < 1.5s on 4G
[ ] No refresh loop on item detail page
[ ] Stock list scrolls at 60fps (test 200 items)
[ ] API calls per 60s idle: ≤ 4

PURCHASE FLOW:
[ ] Owner can mark dispatched with truck number
[ ] Staff gets notification when dispatched
[ ] Staff can mark arrived
[ ] Staff can verify with quantity entry
[ ] Owner gets notification when verified
[ ] Owner can commit → stock updates
[ ] Timeline shows who did what and when

UI/UX:
[ ] No white space below forms in bottom sheets
[ ] Search dropdown visible above keyboard
[ ] All tap targets ≥ 48dp
[ ] Item detail page fits in 2–3 screens on mobile
[ ] User management tabs don't cut off on left
[ ] Desktop shows master-detail layout on stock page

ROLES:
[ ] Staff cannot see purchase prices
[ ] Staff cannot commit to stock
[ ] Owner sees expense tracker
[ ] Manager sees all operational data
[ ] Notification badges show correct counts

NEW FEATURES:
[ ] Expense tracker: add, view, categorize
[ ] Reorder request: staff taps → owner notified
[ ] Physical count evening reminder notification
[ ] Delivery pipeline card on owner home
[ ] Activity log on every item detail
```

---

## CURSOR PRO INSTRUCTIONS

When working through this list:

1. Announce task number: "Starting Task 5: Add backend delivery endpoints"
2. Show exact file and current code
3. Show exact replacement code
4. After each task: "Task 5 complete. System stock now updates only on verified delivery commit."
5. Never combine multiple tasks in one response
6. If a file doesn't exist yet: create it, then continue
7. If a test file exists for changed code: update the test
8. Do NOT stop — ask if unclear, then continue with best guess

**Start with Task 1.** Do not skip to UI tasks before P0 tasks are complete.

---

## ESTIMATED TIMELINE

| Phase | Tasks | Effort | Outcome |
|-------|-------|--------|---------|
| P0 Fix (critical) | 1–9 | 1.5 days | Correct stock numbers |
| P1 Major | 10–20 | 3 days | Usable delivery flow, clean UI |
| P2 Polish | 21–30 | 2 days | Fast, clean, desktop-ready |
| **Total** | **30** | **~7 days** | Production-ready ERP |
