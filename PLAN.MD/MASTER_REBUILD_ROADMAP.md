# MASTER REBUILD ROADMAP — HARISREE PURCHASE ASSISTANT
> 100-task execution plan. Ordered by priority. No guessing.

---

## HOW TO USE THIS FILE

1. Copy this entire file to Cursor as a prompt
2. Tell Cursor: "Work through this task list one by one. Do not skip. Do not summarize. Show exact code for each task."
3. After each task, check the checkbox in this file
4. Never jump ahead — each task depends on the previous

---

## ⚠️ P0 CRITICAL — FIX THESE FIRST (Business Loss Risk)

### Task 1: DELETE SECURITY RISK FILE
```
File: /login-test.json
Action: git rm login-test.json && git commit -m "security: remove plaintext credentials"
Also: Check git history for this file. If credentials are real, rotate them immediately.
```
**Status:** [ ] Not done

---

### Task 2: FIX STOCK FORMULA — BACKEND
```
File: backend/app/routers/stock.py
Function: _item_to_list_row()
Change line: warehouse_diff = cur - period_purchased_qty
To: warehouse_diff = physical_stock_qty - cur (if physical_stock_qty else None)
Rename field in StockListItemOut: warehouse_diff_qty → physical_vs_system_diff
Update backend/app/schemas/stock.py accordingly
```
**Status:** [ ] Not done

---

### Task 3: FIX STOCK FORMULA — FLUTTER UI
```
File: lib/features/stock/presentation/widgets/stock_row_metrics.dart
Change column header: "Diff" to "Physical Diff"
Change data source: item.warehouseDiffQty → item.physicalVsSystemDiff
Color rule: negative = red, zero = grey, null = show dash "—"
```
**Status:** [ ] Not done

---

### Task 4: STOP INFINITE REFRESH LOOP
```
File: lib/core/providers/stock_providers.dart
Find ALL instances of: ref.watch(sessionProvider) inside FutureProvider
Replace with: ref.read(sessionProvider)
Find ALL instances of: ref.watch(stockListQueryProvider) inside FutureProvider
Replace with: pass query as family parameter instead
```
**Status:** [ ] Not done

---

### Task 5: THROTTLE REALTIME STOCK INVALIDATION
```
File: lib/core/providers/realtime_events_provider.dart (or wherever stock.changed is handled)
Add debounce: only invalidate stockListProvider if 30+ seconds since last invalidation
Add item-specific check: only invalidate if event.payload['item_id'] matches watched item
```
**Status:** [ ] Not done

---

### Task 6: REMOVE THIRD DASHBOARD PROVIDER
```
File: lib/features/dashboard/state/dashboard_provider.dart
This file only contains: export '../../../core/providers/dashboard_provider.dart';
Action: Delete this file. Update all imports to use core path directly.
Then delete: lib/features/dashboard/ entire folder (it's empty after this)
```
**Status:** [ ] Not done

---

### Task 7: PREVENT DOUBLE STOCK ON DELIVERY
```
File: backend/app/services/stock_inventory.py
Function: apply_confirmed_purchase_stock()
Add check: query StockMovement for existing delivery_receive for this purchase_id
If found: raise ValueError("Stock already applied for this purchase")
This prevents double-counting if delivery endpoint is called twice
```
**Status:** [ ] Not done

---

### Task 8: FIX ITEM DETAIL AUTO-REFRESH (WRONG ITEM BUG)
```
File: wherever item detail listens to realtime
Current: ref.listen(realtimeEventsProvider, ...) { ref.invalidate(stockItemDetailProvider(itemId)) }
Bug: fires even for OTHER items' changes
Fix: only invalidate if event.payload['item_id'] == itemId
```
**Status:** [ ] Not done

---

## P0 CRITICAL — DUPLICATE PROVIDERS (Crash Risk)

### Task 9: MERGE REALTIME NOTIFICATION PROVIDERS
```
Delete: lib/core/providers/realtime_notifications_provider.dart
Delete: lib/core/providers/server_notifications_provider.dart
Keep: lib/core/providers/notifications_provider.dart
Migrate: any features using deleted files → use notifications_provider
```
**Status:** [ ] Not done

---

### Task 10: DELETE login-test.json AND OTHER DEV ARTIFACTS
```
git rm login-test.json mcp_query.json schema_expected.json schema_missing_cols.sql
git rm .cursor/KICHU
Move: master_item_profiles.json → backend/seeds/
Move: production_unit_metadata_update.sql → backend/alembic/manual_migrations/
```
**Status:** [ ] Not done

---

## P1 MAJOR — STOCK LOGIC COMPLETION

### Task 11: ADD PURCHASE STATUS STATES TO DATABASE
```
File: create backend/alembic/versions/040_purchase_status_extended.py
Add status values: pending_supplier, supplier_confirmed, dispatched, in_transit, arrived_warehouse, staff_verifying, verified, partially_delivered
Add columns: dispatched_at, arrived_at, verified_at, verified_by_name, expected_arrival, truck_number
```
**Status:** [ ] Not done

---

### Task 12: ADD STATUS TRANSITION VALIDATION
```
File: backend/app/routers/trade_purchases.py
Add: VALID_TRANSITIONS dict
Add: validate_status_transition() function
Apply to: PATCH status endpoint
Ensure: stock only added when → delivered (not at verified)
```
**Status:** [ ] Not done

---

### Task 13: CREATE DELIVERY VERIFICATION ENDPOINT
```
File: backend/app/routers/trade_purchases.py
New endpoint: POST /v1/businesses/{id}/trade-purchases/{purchase_id}/verify-delivery
Body: { lines: [{item_id, expected_qty, actual_qty, notes}] }
Logic: Compare actual vs expected. If all match → status = verified. If mismatch → stay in staff_verifying + notify owner
```
**Status:** [ ] Not done

---

### Task 14: CREATE DELIVERY VERIFICATION PAGE (FLUTTER)
```
New file: lib/features/purchase/presentation/delivery_verification_page.dart
Layout: List of purchase lines, each with expected qty + input for actual qty
Footer: Submit button + mismatch warning
Navigation: Tap "Verify Delivery" card on staff dashboard → this page
```
**Status:** [ ] Not done

---

### Task 15: ADD WHO/WHEN AUDIT TO PURCHASE STATUS CHANGES
```
File: backend/app/routers/trade_purchases.py
On every status change: insert StaffActivityLog row
Fields: user_name, action_type=f"PURCHASE_{new_status}", before/after data
```
**Status:** [ ] Not done

---

## P1 MAJOR — ITEM DETAIL (STOP FLICKERING)

### Task 16: CREATE UNIFIED ITEM DETAIL PAGE
```
New file: lib/features/stock/presentation/item_detail_page.dart
Delete: lib/features/catalog/presentation/catalog_item_detail_page.dart
Delete: lib/features/reports/presentation/reports_item_detail_page.dart
Keep: lib/features/catalog/presentation/item_detail_page.dart → move here
Single route: /items/:id
Role-based sections using: ref.read(sessionProvider)?.role
```
**Status:** [ ] Not done

---

### Task 17: CREATE UNIFIED ITEM DETAIL BACKEND ENDPOINT
```
File: backend/app/routers/stock.py
New endpoint: GET /{item_id}/full
Returns: item + recent_purchases (5) + activity (10) + physical_count
Single query, single response
```
**Status:** [ ] Not done

---

### Task 18: CREATE itemDetailProvider (SINGLE PROVIDER)
```
File: lib/core/providers/item_detail_providers.dart (rewrite)
Single FutureProvider.family<ItemDetail, String>(itemId)
Calls: GET /stock/{id}/full
Replace: all usage of stockItemDetailProvider + stockItemIntelligenceProvider + stockItemActivityProvider
```
**Status:** [ ] Not done

---

## P1 MAJOR — OWNER DASHBOARD

### Task 19: CREATE COMBINED HOME SUMMARY ENDPOINT
```
File: backend/app/routers/dashboard.py (or new routers/home.py)
New endpoint: GET /v1/businesses/{id}/home/summary
Returns: alerts + inventory + purchase_status_counts + notifications_unread_count
One SQL transaction. All or nothing.
```
**Status:** [ ] Not done

---

### Task 20: REBUILD OWNER HOME PAGE
```
File: lib/features/home/presentation/home_page.dart
New structure: AlertsStrip → PurchaseStatusStrip → StockSummaryCards → ToolsRow → TasksChecklist → RecentActivity
Single homePageProvider — calls GET /home/summary
Remove: all independent provider watches from home page
```
**Status:** [ ] Not done

---

### Task 21: CREATE ALERTS STRIP WIDGET
```
New file: lib/features/home/presentation/widgets/alerts_strip.dart
Horizontal scroll, pill chips, icon + count + label
Colors: red (critical/out), amber (low), orange (pending delivery), blue (verify needed), purple (opening missing)
Hidden if no alerts
```
**Status:** [ ] Not done

---

### Task 22: CREATE STOCK SUMMARY CARDS
```
New file: lib/features/home/presentation/widgets/stock_summary_cards.dart
3 cards: System Stock | Pending Delivery | Physical Diff
Each card: title + item count + qty + value (owner only)
Tappable → navigate to filtered stock page
```
**Status:** [ ] Not done

---

### Task 23: CREATE PURCHASE STATUS STRIP
```
New file: lib/features/home/presentation/widgets/purchase_status_strip.dart
Counts by status: Pending | In Transit | Arrived | Delivered Today
New endpoint: GET /trade-purchases/status-summary
```
**Status:** [ ] Not done

---

### Task 24: REMOVE SPEND RING CHART FROM HOME
```
File: lib/features/home/presentation/home_page.dart
Remove: SpendRingChart widget
Remove: widgets/spend_ring_chart.dart imports
Remove: lib/widgets/spend_ring_chart.dart (if only used here)
```
**Status:** [ ] Not done

---

## P1 MAJOR — STAFF DASHBOARD

### Task 25: CREATE STAFF HOME SUMMARY ENDPOINT
```
File: backend/app/routers/ (new: staff.py or home.py)
New endpoint: GET /v1/businesses/{id}/staff/home-summary
Returns: tasks + warehouse_summary + pending_deliveries (limit 5) + low_stock (limit 3) + my_activity (limit 5)
Filter my_activity by current user
```
**Status:** [ ] Not done

---

### Task 26: REBUILD STAFF DASHBOARD
```
File: lib/features/staff/presentation/staff_dashboard_page.dart
New structure: TasksList → WarehouseSummaryGrid → PendingDeliveryCards → LowStockAlerts → MyActivity
Single staffHomeProvider
Greeting: Good Morning/Afternoon/Evening, {name}
```
**Status:** [ ] Not done

---

### Task 27: CREATE STAFF TASKS LIST WIDGET
```
New file: lib/features/staff/presentation/widgets/staff_tasks_list.dart
Auto-tasks from system state + manual checklist
Pending at top, completed at bottom (greyed, strikethrough)
Tap task → navigate to action
```
**Status:** [ ] Not done

---

### Task 28: CREATE PENDING DELIVERY CARD
```
New file: lib/features/staff/presentation/widgets/pending_delivery_card.dart
Shows: Purchase ID, Supplier, Items summary, Status badge
Button: "Verify Delivery" (if arrived) | "Mark Arrived" | "View"
```
**Status:** [ ] Not done

---

## P1 MAJOR — STOCK TABLE

### Task 29: DEFINE CORRECT STOCK COLUMNS
```
File: lib/features/stock/presentation/widgets/stock_table_layout.dart
Columns (fixed): Item Name | System Stock | Pending | Physical | Diff | Status
Remove: period_purchased column from default view (move to reports)
Remove: variance_qty column (it's now physical_diff)
```
**Status:** [ ] Not done

---

### Task 30: FIX STOCK TABLE HORIZONTAL SCROLL
```
File: lib/features/stock/presentation/widgets/stock_table_layout.dart
Freeze first column (Item Name: 140px)
Scroll remaining 5 columns horizontally
Both scrolls share one vertical ScrollController
```
**Status:** [ ] Not done

---

### Task 31: REDUCE STOCK ROW HEIGHT
```
File: lib/features/stock/presentation/widgets/stock_table_row.dart
Set container height: 52px
Remove excessive padding from cells
Use compact typography: 13px for labels, 14px for values
```
**Status:** [ ] Not done

---

## P1 MAJOR — PURCHASE TRACKING UI

### Task 32: CREATE PURCHASE STATUS TIMELINE WIDGET
```
New file: lib/features/purchase/presentation/widgets/purchase_status_timeline.dart
Vertical timeline: Created → Supplier Confirmed → Dispatched → In Transit → Arrived → Verified → Delivered
Completed steps: filled dot + timestamp + actor name
Current step: animated dot
Future steps: empty dot, grey
```
**Status:** [ ] Not done

---

### Task 33: ADD STATUS COLORS TO PURCHASE LIST
```
File: lib/features/purchase/presentation/purchase_list_page.dart
Add statusColor() and statusIcon() functions
Apply colored badge to each row
Sort: most recent activity first (last_activity_at desc)
```
**Status:** [ ] Not done

---

## P1 MAJOR — PERFORMANCE

### Task 34: DELETE /stock/search ENDPOINT (ALIAS)
```
File: backend/app/routers/stock.py
Delete: search_stock() function and @router.get("/search") decorator
Update Flutter: any calls to /stock/search → /stock/list?q=...
```
**Status:** [ ] Not done

---

### Task 35: DELETE /stock/low ENDPOINT (SUPERSEDED)
```
File: backend/app/routers/stock.py
Delete: low_stock() function and @router.get("/low") decorator
Update Flutter: any calls to /stock/low → /stock/low-stock/operations
```
**Status:** [ ] Not done

---

### Task 36: ADD HTTP CACHE HEADERS
```
File: backend/app/main.py
Add middleware: Cache-Control private max-age=30 for /stock/list
Cache-Control private max-age=60 for /alerts-summary and /inventory-summary
Cache-Control no-cache for /notifications/
```
**Status:** [ ] Not done

---

### Task 37: ADD const CONSTRUCTORS TO STOCK ROWS
```
File: lib/features/stock/presentation/widgets/stock_table_row.dart
File: lib/features/stock/presentation/widgets/stock_row_metrics.dart
Add const to constructors where all fields are final
Wrap each row in RepaintBoundary
```
**Status:** [ ] Not done

---

## P1 MAJOR — NOTIFICATIONS

### Task 38: FIX DEDUPLICATION IN NOTIFICATION_EMITTER
```
File: backend/app/services/notification_emitter.py
Ensure all notification.create() calls include a dedupe_key
Format: "{kind}:{item_id}:{date}"
Add 24h window check before creating notification
```
**Status:** [ ] Not done

---

### Task 39: FIX NOTIFICATION BELL — SINGLE PROVIDER
```
Delete: lib/core/providers/realtime_notifications_provider.dart
Delete: lib/core/providers/server_notifications_provider.dart
Rewrite: lib/core/providers/notifications_provider.dart as StreamProvider
Source: SSE events + initial HTTP load
```
**Status:** [ ] Not done

---

### Task 40: REBUILD NOTIFICATION PAGE
```
File: lib/features/notifications/presentation/notifications_page.dart
Group by: Today / Yesterday / Older
Each row: icon + title + body (1 line) + time + action button
Mark as read on tap
Pull to refresh
```
**Status:** [ ] Not done

---

## P1 MAJOR — UI/UX FIXES

### Task 41: CREATE AppSpacing TOKENS
```
New file: lib/core/theme/app_spacing.dart
Define: xs(4) sm(8) md(12) lg(16) xl(20) xxl(24)
Define: cardPadding, sectionGap, stockRowHeight, actionButtonHeight
Apply throughout (find all EdgeInsets.all(24+) and replace)
```
**Status:** [ ] Not done

---

### Task 42: FIX KEYBOARD OVERLAP IN SEARCH
```
Apply KeyboardAwareSuggestionOverlay to:
- lib/features/stock/presentation/widgets/stock_inline_search_bar.dart
- lib/shared/widgets/smart_search_field.dart
- Any other inline search that shows suggestions
```
**Status:** [ ] Not done

---

### Task 43: FIX MODAL BOTTOM SHEETS — ALL FORMS
```
All showModalBottomSheet() calls must have:
  isScrollControlled: true
  child: KeyboardSafeFormViewport(child: form)
Files to check: PhysicalStockBottomSheet, QuickPurchaseBottomSheet, ReorderLevelSheet, OpeningStockSetSheet
```
**Status:** [ ] Not done

---

### Task 44: FIX ITEM DETAIL EXCESSIVE WHITESPACE
```
File: lib/features/stock/presentation/item_detail_page.dart (new unified page)
Remove: Padding(all: 24) outer wrapper → use Padding(horizontal: 12, vertical: 8)
Remove: SizedBox(height: 32) between sections → use SizedBox(height: 12)
Remove: excessive card internal padding → use EdgeInsets.all(12)
```
**Status:** [ ] Not done

---

### Task 45: FIX REPORT PAGE — MAKE SCROLLABLE
```
File: lib/features/reports/presentation/reports_page.dart
Replace: Column → CustomScrollView with SliverList
Add: period chips as SliverPersistentHeader (sticky)
Add: summary stats as 2×2 grid
Add: paginated item table
```
**Status:** [ ] Not done

---

### Task 46: FIX USER MANAGEMENT NESTED SCROLL
```
File: lib/features/admin/presentation/user_management_page.dart (or users page)
Replace: TabBarView with nested ListView → use SliverList for each tab
Move tab bar to SliverPersistentHeader
Remove: nested ScrollView inside TabBarView
```
**Status:** [ ] Not done

---

### Task 47: FIX PURCHASE STATUS HIGHLIGHT
```
File: lib/features/purchase/presentation/widgets/purchase_status_card.dart (or wherever)
Add colored Container for status
Use statusColor() + statusIcon()
Make status the FIRST thing visible (not buried in card)
```
**Status:** [ ] Not done

---

### Task 48: ADD DESKTOP SPLIT PANE
```
File: lib/features/stock/presentation/stock_page.dart
Detect: MediaQuery.of(context).size.width > 768
If desktop: show StockDesktopDetailPane (file exists: stock_desktop_detail_pane.dart)
Left: stock list (40%) | Right: selected item detail (60%)
```
**Status:** [ ] Not done

---

## P1 MAJOR — ROLE FIXES

### Task 49: HIDE FINANCIAL DATA FROM STAFF/MANAGER
```
File: lib/features/stock/presentation/widgets/stock_table_row.dart
File: lib/features/purchase/presentation/purchase_detail_page.dart
Apply: if (role == 'owner') { show rates/values } else { hide }
Backend already has should_redact_financials() — ensure Flutter respects it
```
**Status:** [ ] Not done

---

### Task 50: ADD CASH BUYER HOME PAGE
```
New file: lib/features/staff/presentation/cash_buyer_home_page.dart
Layout: [Quick Purchase] large button + [Low Stock List] + [My Purchases Today]
Route: if role == 'cash_buyer' → show this page instead of staff dashboard
```
**Status:** [ ] Not done

---

## P2 MINOR — CODE CLEANUP

### Tasks 51–60: DELETE DUPLICATE FILTER SHEETS
```
Delete: stock_warehouse_filter_sheet.dart
Delete: operational_stock_filter_sheet.dart
Delete: opening_stock_filter_sheet.dart
Delete: stock_page_filter_header.dart
Keep: stock_filter_bottom_sheet.dart (add mode param: normal | warehouse | opening)
Update all references to use single sheet
```
**Status:** [ ] Not done

---

### Tasks 61–65: DELETE DUPLICATE TOP BAR WIDGETS
```
Delete: stock_operational_top_bar.dart
Delete: opening_stock_top_bar.dart
Delete: low_stock_ops_header.dart
Keep: stock_compact_top_bar.dart
Update all references
```
**Status:** [ ] Not done

---

### Tasks 66–70: DELETE DUPLICATE SEARCH BARS
```
Delete: smart_search_field.dart (it wraps inline_search_field.dart with no extra logic)
Delete: stock_search_sliver.dart
Keep: inline_search_field.dart (shared/widgets)
Keep: stock_inline_search_bar.dart but make it a thin wrapper
```
**Status:** [ ] Not done

---

### Task 71: DELETE SCANNER V3 (INCOMPLETE)
```
Verify: which scanner version is imported in purchase_scan_ai.py
If scanner_v2 is imported: delete backend/app/services/scanner_v3/
If scanner_v3 is imported: delete scanner_v2 and complete v3
```
**Status:** [ ] Not done

---

### Task 72: DELETE ONE ENTRY INTENT SERVICE
```
Check: backend/app/routers/entries.py imports
Keep: whichever is imported (v1 or v2)
Delete: the other
```
**Status:** [ ] Not done

---

### Task 73: CLEAN SETTINGS PAGE
```
File: lib/features/settings/presentation/settings_page.dart
Remove: brand name, theme selector, language toggle, developer mode, API override
Keep: change password, notification preferences, logout, app version
```
**Status:** [ ] Not done

---

### Task 74: REMOVE ANALYTICS FOLDER
```
Check: if any non-duplicate analytics pages are needed in reports
Delete: lib/features/analytics/ folder
Delete: analytics_breakdown_providers.dart, analytics_kpi_provider.dart, reports_bi_providers.dart, full_reports_insights_providers.dart, reports_prior_period_provider.dart
```
**Status:** [ ] Not done

---

### Task 75: REMOVE PUBLIC QR FROM CATALOG
```
File: backend/app/routers/public_items.py
If no Flutter page uses public items: disable route
File: backend/alembic/versions/033_catalog_public_qr.py — column stays but feature hidden
```
**Status:** [ ] Not done

---

## P2 MINOR — NEW FEATURES (REQUESTED)

### Task 76–80: EXPENSE TRACKER
```
Task 76: Create expense_log table (alembic migration 041)
Task 77: Create backend/app/models/expense_log.py
Task 78: Create backend/app/routers/expenses.py (CRUD)
Task 79: Create lib/features/expenses/presentation/expense_page.dart
Task 80: Add to owner dashboard: monthly expense total
```
**Status:** [ ] Not done

---

### Task 81–85: REORDER WORKFLOW COMPLETION
```
Task 81: Staff [Request Reorder] button visible on low stock items
Task 82: Creates ReorderListEntry with status=pending
Task 83: Owner gets notification: "Staff requests reorder: {item}"
Task 84: Owner can click notification → opens pre-filled purchase form
Task 85: Reorder entry status updates to ordered when purchase created
```
**Status:** [ ] Not done

---

### Task 86–90: PURCHASE STATUS TRACKING DETAILS
```
Task 86: Add truck_number, driver_name, driver_phone to purchase form
Task 87: Show these in purchase detail page
Task 88: Staff can update truck number when marking In Transit
Task 89: Show delivery tracking timeline in purchase detail
Task 90: Owner can see who changed each status and when
```
**Status:** [ ] Not done

---

### Task 91–95: STOCK ACTIVITY IMPROVEMENTS
```
Task 91: Sort items by last_activity_at desc (most recently changed first)
Task 92: Add activity timestamp to stock row (e.g., "Updated 2 min ago")
Task 93: Show WHO last updated in stock row (subtle, grey text)
Task 94: Full activity log page per item (existing endpoint, needs better UI)
Task 95: Filter activity by: Purchases | Physical Counts | Adjustments | All
```
**Status:** [ ] Not done

---

### Task 96–100: PERFORMANCE FINAL PASS
```
Task 96: Run Flutter analyze — fix all warnings
Task 97: Profile home page load — target < 500ms
Task 98: Profile stock list render — target < 16ms per frame
Task 99: Check backend slow queries — add EXPLAIN ANALYZE to stock/list
Task 100: Load test: 10 concurrent users → no 500 errors
```
**Status:** [ ] Not done

---

## CURSOR PRO INSTRUCTIONS

When working through this list in Cursor:

1. **Announce task number** before starting: "Starting Task 3: Fix stock formula in Flutter"
2. **Show the exact current code** (what you found)
3. **Show the exact fix** (what you're changing to)
4. **After each task**: state "Task X complete" and what the next task is
5. **Never combine multiple tasks** into one response — do one at a time
6. **If a file is missing**: say so explicitly, create it, then continue
7. **If a test exists for the changed code**: update the test
8. **Do not stop** because of complexity — ask if unclear, then continue

---

## VALIDATION CHECKLIST (after all 100 tasks)

- [ ] Sugar stock page shows correct numbers (system stock = 812, not 612)
- [ ] No auto-refresh on home page (only on manual pull-to-refresh)
- [ ] Item detail does not swap/flicker
- [ ] Purchase status shows correct colored badge
- [ ] Staff dashboard loads in < 2 seconds
- [ ] Owner home loads in < 1.5 seconds
- [ ] Physical count shows in stock table
- [ ] Difference column shows Physical − System (not Purchased − System)
- [ ] No nested scroll issues anywhere
- [ ] Keyboard does not cover suggestions or submit buttons
- [ ] login-test.json is gone from repository
- [ ] No duplicate providers calling same API
