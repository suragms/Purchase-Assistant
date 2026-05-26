# HARISREE WAREHOUSE — MASTER RULES & PLAN
**Project:** PurchaseAssistant (Harisree Warehouse, Kerala)
**Stack:** Flutter (Riverpod + GoRouter) · FastAPI (SQLAlchemy async) · PostgreSQL
**Client:** Sunil (owner) + warehouse staff, Kerala, India
**Version in zip:** 0.1.4+5

---

## CRITICAL READING BEFORE ANY CODE CHANGE

### Golden Rules
1. **NEVER update stock when a purchase is created.** Stock only updates when staff marks delivery as `is_delivered = True` via PATCH `/{purchase_id}/delivery`.
2. **NEVER guess.** Every change must be traceable to a specific bug, client request, or feature in this document.
3. **Speed is a feature.** Every API call must return in < 500 ms. Every Flutter screen must reach interactive state in < 1.5 s on a mid-range Android.
4. **No duplicate data fetches.** Use `Future.wait()` for parallel calls. Never chain two sequential awaits when they can be parallel.
5. **Mobile-first, desktop-enhanced.** Mobile < 600 px = single column + bottom nav. Tablet 600–1023 px = 2 column. Desktop ≥ 1024 px = sidebar rail + 3+ column tables.
6. **No text overflow anywhere.** All table cells must use `overflow: TextOverflow.ellipsis`. All labels must use `maxLines: 1` or `maxLines: 2` with ellipsis.
7. **Keyboard must not cover input fields.** All form pages must use `resizeToAvoidBottomInset: true` and wrap content in `SingleChildScrollView`.

---

## REPOSITORY STRUCTURE (from zip analysis)

```
PurchaseAssiastant-main/
├── backend/                         ← FastAPI + SQLAlchemy
│   ├── app/
│   │   ├── main.py                  ← router registration + CORS + startup
│   │   ├── routers/
│   │   │   ├── trade_purchases.py   ← PO CRUD + delivery patch (BUG HERE)
│   │   │   ├── stock.py             ← stock list, barcode lookup, adjustments
│   │   │   ├── notifications.py     ← in-app notifications (empty list bug)
│   │   │   ├── ai_chat.py           ← REMOVE ENTIRELY
│   │   │   ├── whatsapp_reports.py  ← REMOVE ENTIRELY
│   │   │   ├── cloud_expense.py     ← REMOVE ENTIRELY
│   │   │   ├── billing.py           ← REMOVE Razorpay webhook integration
│   │   │   ├── razorpay_webhook.py  ← REMOVE ENTIRELY
│   │   │   └── catalog.py           ← barcode assign, item detail
│   │   ├── services/
│   │   │   ├── trade_purchase_service.py  ← patch_trade_purchase_delivery MISSING stock call
│   │   │   ├── stock_inventory.py         ← apply_confirmed_purchase_stock lives here
│   │   │   ├── app_assistant_chat.py      ← REMOVE ENTIRELY
│   │   │   ├── assistant_business_context.py ← REMOVE ENTIRELY
│   │   │   └── assistant_entity.py        ← REMOVE ENTIRELY
│   │   ├── models/
│   │   │   ├── catalog.py           ← CatalogItem (missing: opening_stock field)
│   │   │   ├── stock_adjustment.py  ← StockAdjustment (has opening_stock type)
│   │   │   ├── whatsapp_report_schedule.py ← REMOVE
│   │   │   ├── ai_engine.py         ← REMOVE
│   │   │   └── cloud_expense.py     ← REMOVE
│   │   └── schemas/
│   │       └── stock.py             ← StockListItemOut (missing: physical_stock, opening_stock)
│   └── alembic/versions/            ← 32 migration files (gaps at 026, 027)
├── flutter_app/
│   ├── pubspec.yaml                 ← razorpay_flutter, speech_to_text MUST BE REMOVED
│   └── lib/
│       ├── main.dart
│       ├── features/
│       │   ├── barcode/presentation/barcode_scan_page.dart  ← SLOW (DetectionSpeed.normal)
│       │   ├── notifications/presentation/notifications_page.dart
│       │   ├── purchase/presentation/purchase_detail_page.dart ← PDF/share buttons broken
│       │   ├── shell/shell_screen.dart  ← badge count wired to stock alerts, NOT notifications
│       │   ├── shell/responsive_shell_layout.dart ← stub only, needs full implementation
│       │   ├── staff/presentation/staff_receive_shipment_page.dart
│       │   ├── stock/presentation/stock_page.dart  ← missing physical/purchased/diff columns
│       │   └── voice/presentation/voice_page.dart  ← REMOVE ENTIRELY
│       └── core/
│           ├── providers/
│           │   ├── notifications_provider.dart  ← badge count = stock alerts (WRONG, must be unified)
│           │   ├── home_owner_dashboard_providers.dart ← stockAlertCountsProvider (2 API calls)
│           │   └── cloud_expense_provider.dart  ← REMOVE
│           └── services/
│               └── purchase_pdf.dart  ← PDF generation works but share/download broken on web
└── admin_web/                       ← KEEP IN REPO, do NOT deploy to client
```

---

## CONFIRMED FEATURES TO REMOVE COMPLETELY

| Feature | Backend files to delete | Flutter files to delete | pubspec packages |
|---------|------------------------|------------------------|-----------------|
| AI Chatbot / voice assistant | `routers/ai_chat.py`, `services/app_assistant_chat.py`, `services/assistant_business_context.py`, `services/assistant_entity.py` | `features/voice/presentation/voice_page.dart` | `speech_to_text: ^7.0.0` |
| WhatsApp auto report | `routers/whatsapp_reports.py`, `models/whatsapp_report_schedule.py` | `features/reports/presentation/reports_whatsapp_sheet.dart` | — |
| Razorpay billing in Flutter | `routers/razorpay_webhook.py`, `routers/billing.py` (keep health endpoints if any) | Remove Razorpay import from `settings_page.dart` | `razorpay_flutter: ^1.4.4` |
| Cloud expense tracking | `routers/cloud_expense.py`, `models/cloud_expense.py`, `models/platform_integration.py`, `models/platform_monthly_expense.py` | `core/providers/cloud_expense_provider.dart` | — |
| Admin web panel | Keep in repo | — | — |

Remove router registrations from `backend/app/main.py` for all above.

---

## CONFIRMED BUG LIST (from code analysis)

### BUG-01: Delivery confirmation does NOT update stock [CRITICAL]
**File:** `backend/app/services/trade_purchase_service.py` → `patch_trade_purchase_delivery()`
**Root cause:** Function sets `is_delivered = True`, commits, but NEVER calls `apply_confirmed_purchase_stock()`.
The function at lines 1170–1199 skips the stock update entirely.
Compare with `create_trade_purchase()` at line 943 which calls `apply_confirmed_purchase_stock()` — delivery patch is missing this call.

### BUG-02: Notification bell shows stock-alert count, page is empty [CRITICAL]
**File:** `flutter_app/lib/features/shell/shell_screen.dart` line 97 + 191
**Root cause:** `stockAlertN` (from `stockLowCountProvider`) drives the badge. But the notifications page renders `mergedNotificationFeedProvider` which mixes server notifications + stock alerts. The stock count shown in the badge (e.g. 30 low-stock items) never matches the notification list items which are just 3–5 aggregated entries.
**Fix needed:** Badge = `notificationsUnreadCountProvider` (unified count). Notifications page = 3 tabs (Stock Alerts / Purchases / System).

### BUG-03: Barcode scan extremely slow [CRITICAL]
**File:** `flutter_app/lib/features/barcode/presentation/barcode_scan_page.dart`
**Root cause 1:** `DetectionSpeed.normal` — causes camera to process every frame through ML. Change to `DetectionSpeed.noDuplicates`.
**Root cause 2:** On successful scan, `_camera?.stop()` is called BEFORE the API call, adding ~300 ms pause.
**Root cause 3:** Debounce is 1500 ms (`_kDebounceMs`) — too high, causes perceived lag.
**Root cause 4:** API `barcodeStockLookup` goes through full auth middleware + 2 DB joins — needs caching.

### BUG-04: PDF download / share buttons not working [HIGH]
**File:** `flutter_app/lib/features/purchase/presentation/purchase_detail_page.dart`
**Root cause:** `sharePurchasePdf()` uses `share_plus` which on web tries `XFile` share — not supported in all browsers. On mobile, `Uint8List.fromList(data)` logo download sometimes times out and throws, causing the whole PDF generation to fail silently (catch swallows).
**Fix:** Wrap logo fetch in try/catch that returns `null` (already done in `_tryLogo` but outer callers are not handling null gracefully). Add explicit error snackbar instead of silent fail.

### BUG-05: Notifications page shows icons/staff/rules text — not actual alerts
**Root cause:** `notifications_page.dart` renders `NotificationItem` objects. The `warehouseAlertNotificationItemsProvider` creates 3 items max (low_stock, missing_barcode, missing_item_code) but the badge shows the raw count from `stockLowCountProvider` (e.g. 30 items). This mismatch = badge 30, page shows 3 items or none if provider fails.

### BUG-06: Stock list table columns overlap on mobile
**File:** `flutter_app/lib/features/stock/presentation/stock_page.dart` + `widgets/stock_table_row.dart`
**Root cause:** Fixed-width columns without `Flexible`/`Expanded` wrappers. Text not using `overflow: TextOverflow.ellipsis`.

### BUG-07: App slow — too many sequential API calls on startup
**Files:** Multiple providers in `core/providers/`
**Root cause:** Shell screen watches 6+ providers that each make independent API calls on startup. `stockAlertCountsProvider` alone makes 2 sequential API calls.
**Fix:** Use `Future.wait()` for parallel fetches. Add `keepAlive()` to expensive providers.

---

## CONFIRMED NEW FEATURES TO BUILD

| ID | Feature | Priority |
|----|---------|---------|
| FEAT-01 | Purchase → Delivery → Stock flow fix (Bug-01 fix + UI for staff confirmation) | CRITICAL |
| FEAT-02 | Staff Quick Purchase Log (backfill + ongoing, separate from owner PO) | HIGH |
| FEAT-03 | Opening Stock Setup (one-time per item, owner-only override) | HIGH |
| FEAT-04 | Physical Stock Entry (staff counts physical bags, system shows diff) | HIGH |
| FEAT-05 | Stock Page: Physical / Purchased Qty / Difference columns | HIGH |
| FEAT-06 | Notification page: 3-tab layout (Stock / Purchase / System) + badge fix | HIGH |
| FEAT-07 | Barcode public URL (no-auth QR scan shows item + stock, no edit allowed) | HIGH |
| FEAT-08 | Desktop/tablet responsive layout (sidebar rail, wider tables) | MEDIUM |
| FEAT-09 | Auto backup PDF (daily schedule, manual download) | MEDIUM |
| FEAT-10 | Sales comparison report (upload external PDF/Excel, compare with app data) | MEDIUM |
| FEAT-11 | Help/Guide page (bundled markdown, no internet) | LOW |
| FEAT-12 | Item detail page: show total purchased qty, confirmed by owner/staff | MEDIUM |

---

## DATABASE CHANGES REQUIRED

### New migration 033: opening_stock + physical_stock on catalog_items
```sql
ALTER TABLE catalog_items ADD COLUMN opening_stock NUMERIC(14,3);
ALTER TABLE catalog_items ADD COLUMN opening_stock_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE catalog_items ADD COLUMN opening_stock_set_by UUID REFERENCES users(id);
```

### New migration 034: physical_stock_entries table
```sql
CREATE TABLE physical_stock_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    catalog_item_id UUID NOT NULL REFERENCES catalog_items(id),
    physical_qty NUMERIC(14,3) NOT NULL,
    notes TEXT,
    entered_by UUID NOT NULL REFERENCES users(id),
    entered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
CREATE INDEX ON physical_stock_entries(business_id, catalog_item_id);
CREATE INDEX ON physical_stock_entries(entered_at DESC);
```

### New migration 035: staff_purchase_log table
```sql
CREATE TABLE staff_purchase_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    catalog_item_id UUID NOT NULL REFERENCES catalog_items(id),
    qty NUMERIC(14,3) NOT NULL,
    unit VARCHAR(50),
    supplier_name VARCHAR(255),
    log_date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    entered_by UUID NOT NULL REFERENCES users(id),
    entered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    converted_to_purchase_id UUID REFERENCES trade_purchases(id)
);
CREATE INDEX ON staff_purchase_log(business_id, catalog_item_id);
```

### New migration 036: public_item_token on catalog_items
```sql
ALTER TABLE catalog_items ADD COLUMN public_token VARCHAR(32) UNIQUE;
-- Run: UPDATE catalog_items SET public_token = encode(gen_random_bytes(16), 'hex') WHERE public_token IS NULL;
```

---

## API ENDPOINTS TO ADD

### Backend new routes
```
GET  /public/item/{public_token}           ← no auth, returns name+stock only
POST /v1/businesses/{bid}/stock/{item_id}/physical-count   ← staff physical stock entry
GET  /v1/businesses/{bid}/stock/{item_id}/physical-history ← last 30 entries
POST /v1/businesses/{bid}/stock/{item_id}/opening-stock    ← owner only, one-time
POST /v1/businesses/{bid}/staff-purchase-log               ← staff quick purchase log
GET  /v1/businesses/{bid}/staff-purchase-log               ← list
```

### Backend routes to REMOVE from main.py
```
whatsapp_reports.router
whatsapp_reports.internal_router
ai_chat.router
cloud_expense.router
billing.router          ← entire file can be deleted
razorpay_webhook.router
```

---

## FLUTTER NAVIGATION CHANGES

### Routes to REMOVE
```dart
// Remove from app_router.dart:
GoRoute(path: '/voice', ...)
GoRoute(path: '/ai-chat', ...)
GoRoute(path: '/reports/whatsapp', ...)
```

### Routes to ADD
```dart
GoRoute(path: '/stock/physical-count/:itemId', ...)
GoRoute(path: '/stock/opening-stock/:itemId', ...)
GoRoute(path: '/staff/purchase-log', ...)
GoRoute(path: '/staff/purchase-log/add', ...)
GoRoute(path: '/help', ...)
```

---

## PERFORMANCE RULES

1. `stockAlertCountsProvider` — replace 2 sequential calls with `Future.wait([...])` — already done but verify.
2. `mergedNotificationFeedProvider` — uses `autoDispose` — good. Keep.
3. `barcode scan` — change `DetectionSpeed.normal` → `DetectionSpeed.noDuplicates`.
4. `_kDebounceMs = 1500` → change to `800`.
5. All list providers: add `.keepAlive()` on `stockListProvider` and `catalogItemsListProvider`.
6. Backend: all list endpoints that do > 2 queries must use `Future.gather` or SQLAlchemy `selectinload`.
7. Render/Supabase cold start: existing `render-keepalive.yml` and `supabase-keepalive.yml` already in `.github/workflows/` — keep them.

---

## BARCODE / QR CODE RULES

### In-app scanner
- Change `DetectionSpeed.normal` → `DetectionSpeed.noDuplicates`
- Reduce debounce: `_kDebounceMs = 800`
- Keep camera running during API call (only stop on confirmed found + navigation)
- Add loading indicator overlay during lookup instead of stopping camera

### Public QR code (no app needed)
- QR code payload: `https://yourapp.com/item/{public_token}`
- Public endpoint returns: `{name, item_code, current_stock, unit, stock_status}`
- No auth required for read
- Auth required for any write (stock update requires login)
- Show a branded mini web page: item name, current stock level, last updated time
- "Log in to update stock" button for staff/owner

### Barcode label print
- Current: `barcode: ^2.2.9` + `pdf: ^3.11.1` — keep these
- Fix: barcode PNG rendering — use `barcode` package's `Barcode.code128()` to SVG, then render in PDF with `pw.SvgImage`
- Increase label DPI: use `PdfPageFormat.roll57` for label printer format

---

## MOBILE UX RULES

1. **Bottom sheet over full page** for quick actions (physical stock entry, barcode actions).
2. **No horizontal scroll** on stock table on mobile — use single-column card layout < 600 px.
3. **Thumb-reachable actions** — primary buttons always at bottom of screen, not top.
4. **Keyboard awareness** — all forms: `resizeToAvoidBottomInset: true` + `SingleChildScrollView`.
5. **Row tap area** — minimum 48 × 48 px touch target on all list rows.
6. **Loading shimmer** — use existing `shimmer` package on all list pages during fetch.
7. **No modals on mobile** — use bottom sheets instead of `showDialog` for data entry.

---

## DESKTOP UX RULES

1. **Sidebar nav** at ≥ 1024 px: `NavigationRail` with `extended: true`.
2. **Table layout** at ≥ 768 px: proper `DataTable` or custom `Row`-based table with sortable columns.
3. **Min column widths:** Item 200 px | Physical Stock 110 px | Purchased Qty 110 px | Diff 90 px | Action 60 px.
4. **Hover states** on table rows: `InkWell` with `onHover`.
5. **Right-click context menu** on rows: not needed for this client.
6. **No bottom nav bar** at ≥ 900 px — already implemented in `shell_screen.dart` with `c.maxWidth >= 900` check.

---

## BACKUP RULES

- PDF only (no CSV, no JSON export to client)
- Three documents: Ledger PDF + Stock Snapshot PDF + Monthly Purchase Summary PDF
- Schedule: daily at user-set time (default 22:00 IST)
- Use `flutter_local_notifications` alarm (already in pubspec)
- On Android: save to `Downloads/HarisreeWarehouse/` folder
- On iOS: save to Files app `HarisreeWarehouse/` folder  
- On web/desktop: trigger browser download
- In-app list: show last 30 backups with download buttons
- No server-side backup — purely client-side generation + save

---

## FILE NAMING FOR AGENT PROMPTS

Each agent prompt file covers one area. Run them IN ORDER:

| Order | File | Agent task |
|-------|------|-----------|
| 01 | `01_REMOVE_UNWANTED_FEATURES.md` | Delete AI/WhatsApp/Razorpay/Voice/CloudExpense from backend + Flutter |
| 02 | `02_BUG_FIX_DELIVERY_STOCK.md` | Fix BUG-01: delivery confirmation must update stock |
| 03 | `03_BUG_FIX_NOTIFICATIONS.md` | Fix BUG-02+05: notification badge + page 3-tab layout |
| 04 | `04_BUG_FIX_BARCODE_SCAN.md` | Fix BUG-03: barcode scan speed + public QR endpoint |
| 05 | `05_BUG_FIX_PDF_SHARE.md` | Fix BUG-04: PDF download/share/print |
| 06 | `06_STOCK_PAGE_COLUMNS.md` | FEAT-05: stock page physical/purchased/diff columns |
| 07 | `07_OPENING_STOCK_PHYSICAL_STOCK.md` | FEAT-03+04: opening stock setup + physical count entry |
| 08 | `08_STAFF_PURCHASE_LOG.md` | FEAT-02: staff quick purchase log |
| 09 | `09_ITEM_DETAIL_PAGE.md` | FEAT-12: item detail with purchase history, confirmed totals |
| 10 | `10_DESKTOP_MOBILE_LAYOUT.md` | FEAT-08: full responsive layout overhaul |
| 11 | `11_BACKUP_AND_REPORTS.md` | FEAT-09+10: auto backup + sales comparison report |
| 12 | `12_PERFORMANCE_AND_SPEED.md` | All speed fixes: parallel fetches, keepAlive, debounce |
| 13 | `13_HELP_PAGE_AND_GUIDE.md` | FEAT-11: bundled help/guide page |

---

## WHAT NOT TO BUILD (CONFIRMED REMOVALS)

- AI chatbot or voice input
- WhatsApp report scheduling
- Razorpay payment in Flutter app
- Cloud expense / SaaS billing tracking
- Admin web panel changes (keep as-is for developer use)
- Google Sign-In (already in pubspec but not used by Harisree — keep but do not promote)
- Maintenance payment screen (internal SaaS feature, not for Harisree)
- Commission/broker features (used in other businesses, keep in code but not on Harisree nav)
