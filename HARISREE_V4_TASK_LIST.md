# 🏭 HARISREE AGENCY — v4.0 Master Task List
**Flutter • FastAPI • PostgreSQL | HexaStack Solutions — Anandu | May 2026**

**Verified:** `dart analyze` — **0 errors** (May 2026)

---

## 📋 MD FILE RULES (Always Check)
- Mark `- [x]` only after `flutter analyze` passes with 0 errors
- NEVER break `calc_engine.dart` or GST logic — extend only
- All new UI uses `hexa_ds_tokens.dart` + `hexa_colors.dart`
- All new routes go in `app_router.dart` only
- Every new page: **loading skeleton → data → error** (all 3 states required)

---

## 🔴 P1 — CRITICAL BUG FIXES ✅

### [FIX-1] Home Page — Timer/Ref After Dispose
- [x] Capture `container` BEFORE any `await` in `_doHandlePurchasePostSave`
- [x] Guard `_resumeRefreshDebounce` callback: `if (!mounted) return`
- [x] Add `if (!mounted) return` after every `await` in async methods
- [x] `_loadCapTimer` removed in v4 home redesign (N/A)

### [FIX-2] Date Field Hidden Behind Keyboard
- [x] `lib/shared/widgets/date_picker_button.dart`
- [x] `purchase_party_step.dart`
- [x] `purchase_entry_wizard_v2.dart` (date on step 0 via `PurchasePartyStep`)

### [FIX-3] Supplier/Broker Dropdown Hidden Behind Keyboard
- [x] `keyboard_aware_suggestion_overlay.dart` + OverlayPortal
- [x] `party_inline_suggest_field.dart`, `inline_search_field.dart`, `typeahead_suggestions_card.dart`

### [FIX-4] Remove Self-Registration
- [x] `/signup` removed from router + get-started

### [FIX-5] Barcode Scan
- [x] `lib/features/barcode/presentation/barcode_scan_page.dart` (route `/barcode/scan`)
- [x] mobile_scanner, scan line, torch, manual entry, vibrate, create-item dialog, recent 10
- [x] iOS `NSCameraUsageDescription`

---

## 🟠 P2 — CORE NEW FEATURES ✅

### [FEAT-1] Stock Page — `/stock` + staff `/staff/stock`
- [x] Search 300ms, filters, category/subcategory, sort, 50/page, row colors, swipe update, shell tab index 1

### [FEAT-2] Item Detail — Warehouse Redesign
- [x] Hero: 22px name + code chip + status chip + 80×80 tile
- [x] Info grid: Stock | Reorder | Unit | Category | Subcategory | Rack | Supplier | Last purchase
- [x] Code128 + QR + Print label + Share barcode
- [x] Actions: Update stock, History, Quick edit, Notify owner, Reorder list
- [x] Recent purchases (5) + stock history timeline (10)

### [FEAT-3] Update Stock Sheet — [x]

### [FEAT-4] Owner Home Dashboard — [x]

### [FEAT-5] Staff Home + Shell — [x]

### [FEAT-6] Tax Mode Toggle — [x]

### [FEAT-7] Barcode Print — [x]

### [FEAT-8] User Management — [x]

---

## 🟡 P3 — IMPORTANT POLISH

### [POLISH-1] Item Create — Session Memory — [x]
### [POLISH-2] Duplicate Detection — [x]
### [POLISH-3] Smart Unit — [x]
### [POLISH-4] Bulk Barcode Print — [x]
### [POLISH-5] Super Admin — [x] scaffold *(expand business list / impersonate later)*
### [POLISH-6] Low Stock Notifications
- [x] Backend hourly job
- [x] Stock tab badge, notify owner, reorder list API + SQL `025`
- [x] Local notification when backgrounded (unread delta)
- [ ] Supabase realtime *(30s poll used instead)*

### [POLISH-7] Real-Time Home
- [x] Live green dot when online
- [x] 30s polling refresh
- [ ] Supabase realtime subscriptions

### [POLISH-8] Staff Activity — [x]
### [POLISH-9] User Detail — [x]
### [POLISH-10] Login — [x]
### [POLISH-11] Stock History — [x]

---

## 🟢 P4 — NICE TO HAVE (not started)
- [ ] LATER-1 … LATER-5

---

## 🗄️ BACKEND ✅ (prefix `/v1/businesses/{id}/…`)

- [x] BE-1 Role guards (`require_role`)
- [x] BE-2 Users, stock, fuzzy-check, barcode, notifications, notify-owner, reorder
- [x] BE-3 Tables: stock_adjustment_log, notifications, user sessions, reorder_list (`021`–`025`)
- [x] BE-4 Session + `updated_by` on stock actions

---

## 📁 NEW FILES CHECKLIST — all ✅

| File | Status |
|------|--------|
| `shared/widgets/date_picker_button.dart` | ✅ |
| `shared/widgets/keyboard_aware_suggestion_overlay.dart` | ✅ |
| `features/barcode/presentation/barcode_scan_page.dart` | ✅ |
| `features/stock/presentation/stock_page.dart` | ✅ |
| `features/stock/presentation/update_stock_sheet.dart` | ✅ |
| `features/stock/presentation/stock_history_page.dart` | ✅ |
| `features/staff/presentation/staff_home_page.dart` | ✅ |
| `features/staff/presentation/staff_shell_screen.dart` | ✅ |
| `features/staff/presentation/staff_activity_page.dart` | ✅ |
| `features/barcode/presentation/barcode_print_page.dart` | ✅ |
| `features/barcode/presentation/bulk_barcode_print_page.dart` | ✅ |
| `features/barcode/services/barcode_pdf_service.dart` | ✅ |
| `features/settings/presentation/user_management_page.dart` | ✅ |
| `features/settings/presentation/user_detail_page.dart` | ✅ |
| `features/admin/presentation/super_admin_page.dart` | ✅ |
| `core/services/duplicate_detection_service.dart` | ✅ |
| `core/services/smart_unit_service.dart` | ✅ |

---

## ⚠️ Shell Branch Index Map (current)

```
0 → /home
1 → /stock
2 → /reports
3 → /purchase (History)
4 → /search
```

Staff: `/staff/home` | `/staff/stock` | `/staff/scan` | `/staff/search`

---

*END — Deploy SQL `021`–`025` on Supabase before production. Optional next: Supabase realtime, P4 reports.*
