# FEATURE_PRUNING_COMPLETE.md
## What to Remove, What to Keep, What to Merge — Exact File Locations
**Audit Date:** May 29, 2026

---

## REMOVE IMMEDIATELY — NO BUSINESS VALUE

### 1. Tenant Branding Provider
**File:** `flutter_app/lib/core/providers/tenant_branding_provider.dart`

This loads brand colors / logo from backend for white-label support. Not needed for a single-business warehouse app. Adds 1 API call on startup.

**Remove:** Provider file + all imports + Settings UI for brand name  
**Also remove from settings:** `settings_page.dart` — brand name section

---

### 2. Catalog Public QR / Public URL Feature
**File:** `backend/sql/033_catalog_public_qr.sql` + `backend/sql/030_catalog_barcode.dart`

Public catalog URL for customers to see item QR codes. This is a B2C catalog feature, not a warehouse ERP feature.

**Remove from Flutter:** Any "public catalog" or "share catalog" button in settings  
**Keep:** Internal barcode generation for warehouse labels (different feature)

---

### 3. OCR Learning Service
**File:** `backend/app/services/ocr_learning_service.py`  
**File:** `backend/app/services/package_detection_service.py`

Machine learning feature that "learns" from purchase entry patterns. Not broken but not visible to users. Adds background processing load.

**Action:** Keep backend service (passive), remove from Settings page entirely. Users don't need to know about it.

---

### 4. Analytics BI Tab
**File:** `flutter_app/lib/features/reports/reports_bi_tab.dart`  
**File:** `flutter_app/lib/features/reports/presentation/reports_item_bi_page.dart`  
**File:** `flutter_app/lib/features/analytics/presentation/item_analytics_detail_page.dart`

Advanced BI analytics with charts. Owner of a small warehouse business does not need trend charts and BI dashboards — they need to know what to buy and what is missing. These pages add complexity without solving warehouse pain points.

**Remove:** All 3 files  
**Keep:** Simple reports (purchase list, stock report, expense report)  
**Simplify:** Reports page to: purchases list, stock variance report, expense summary

---

### 5. Broker Feature
**File:** `flutter_app/lib/features/broker/presentation/`  
**Backend:** Broker tables and endpoints

Brokers are assigned to purchases as middlemen. If the current business doesn't use brokers, this is unused UI that adds confusion.

**Decision required from owner:** Do you use brokers? If no: remove broker assignment from purchase form, remove broker list page, remove broker from reports. If yes: keep but clean up UI.

**Audit:** Check if any purchase in database has `broker_id != NULL`. If all null → safe to remove.

---

### 6. Get Started / Onboarding Screens
**File:** `flutter_app/lib/features/get_started/presentation/`

If business is already running with data, onboarding screens are dead code. Verify if router ever navigates here.

**Action:** Check `app_router.dart` for routes to `get_started`. If route is unreachable → delete folder.

---

### 7. Duplicate Shell Implementations
**Files:**  
- `flutter_app/lib/features/shell/shell_screen.dart`  
- `flutter_app/lib/features/staff/presentation/staff_shell_screen.dart`

Two nearly identical shell implementations with separate branch providers. Merge into `AppShell(role: UserRole)` that conditionally renders nav items based on role.

---

## REDUCE COMPLEXITY — MERGE THESE

### 8. 6 Stock Edit Sheets → 1
Remove: `stock_compact_update_sheet.dart`, `stock_quick_edit_sheet.dart`, `quick_stock_patch_sheet.dart`  
Keep: `update_stock_sheet.dart` (most complete)  
Rename to: `StockUpdateSheet(mode: compact | full)`

### 9. 4 Low Stock Pages → 2
Remove: `low_stock_operations_page.dart`, `low_stock_owner_page.dart`  
Keep: `low_stock_dashboard_page.dart` (owner), `staff_low_stock_page.dart` (staff)

### 10. Reports Page — Remove Nested Tabs
Current reports page has tabs within tabs. Remove inner tabs.  
Replace with: Single scrollable report page with period filter at top.

---

## SETTINGS PAGE — WHAT TO KEEP VS REMOVE

### KEEP:
- User profile (name, password change)
- Notification preferences (add per-type toggles)
- Units preference (kg/bags/pieces default display)
- Help guide

### REMOVE:
- Brand name customization
- Business theme colors  
- Public catalog URL
- OCR settings
- "Advanced" anything

### ADD (missing):
- Notification preferences (per alert type: on/off)
- Physical count reminder time setting (e.g. "remind staff at 8 PM")
- Reorder alert threshold override (global)

---

## NAVIGATION — WHAT TO REMOVE FROM BOTTOM BAR

Current bottom nav (inferred from shell_screen.dart): Home, Stock, Purchase, Reports, More/Settings

**Owner bottom nav should be:**
1. 🏠 Home (dashboard)
2. 📦 Stock (stock list)
3. 🛒 Purchase (purchase list)
4. 📊 Reports
5. ⚙️ Settings

**Staff bottom nav should be:**
1. 🏠 Home (task list)
2. 📦 Stock (physical count)
3. 🚛 Deliveries (verify/receive)
4. ⚙️ Settings

Remove from staff nav: Reports, Purchase creation, User management.

---

## FEATURE PRUNING IMPACT

| Category | Current Files | After Pruning | Reduction |
|----------|--------------|---------------|-----------|
| Stock edit sheets | 6 | 1 | -83% |
| Low stock pages | 4 | 2 | -50% |
| Item detail pages | 4 | 1 | -75% |
| Dashboard providers | 4 | 2 | -50% |
| Stock list views | 6 | 1+tabs | -70% |
| Reports pages | 4+ | 1 | -75% |
| Analytics pages | 3 | 0 | -100% |
| Settings sections | 8 | 4 | -50% |

**Total estimated: ~13,000 lines removed. App becomes faster and easier to navigate.**

---

## WHAT MUST NOT BE REMOVED

| Feature | Why Keep |
|---------|---------|
| Barcode scanning | Warehouse essential |
| Physical stock count | Core ERP |
| Opening stock setup | Business start |
| Reorder levels | Staff → owner workflow |
| Purchase wizard | Core data entry |
| Staff activity log | Accountability |
| Delivery verification | Critical missing (add, not remove) |
| Expense tracker | Add this (missing) |
| Notification system | Critical (fix, not remove) |
| User management | Multi-staff essential |
| Stock movements ledger | Audit trail |
