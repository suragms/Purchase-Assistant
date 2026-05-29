# FEATURE PRUNING — HARISREE PURCHASE ASSISTANT
> Remove everything that doesn't serve: Owner, Staff, Stock, Purchases.

---

## 1. SETTINGS PAGE — REMOVE THESE

**File:** `lib/features/settings/presentation/settings_page.dart`

| Setting | Action | Reason |
|---------|--------|--------|
| Brand name / business name display | REMOVE | Not needed in warehouse ERP |
| Theme selector (Dark/Light) | REMOVE | Unnecessary complexity |
| Language toggle | REMOVE | Malayalam + English only, hardcoded |
| Developer mode toggle | REMOVE | Security risk in production |
| API endpoint override | REMOVE | SERIOUS security risk |
| "About" / version screen | KEEP (1 row) | Needed for support |
| Change password | KEEP | Essential |
| Notification preferences | KEEP | Essential |
| Logout | KEEP | Essential |

**Settings page after pruning: 4 items. Not 15.**

---

## 2. ANALYTICS / BI FEATURES — REMOVE

**Folders to delete:**
```
lib/features/analytics/          ← entire folder
lib/core/providers/analytics_breakdown_providers.dart
lib/core/providers/analytics_kpi_provider.dart
lib/core/providers/reports_bi_providers.dart
lib/core/providers/full_reports_insights_providers.dart
lib/core/providers/reports_prior_period_provider.dart
backend/app/routers/analytics.py  ← keep basic dashboard endpoint only
```

**What to keep from analytics:**
- Monthly purchase total → move to reports page
- Top supplier spending → move to contacts page
- Low stock trend → already in stock page

---

## 3. CATALOG / ITEM MANAGEMENT — SIMPLIFY

**Current:** Catalog has 12+ sub-pages (barcode management, public QR, catalog suppliers, etc.)

**Keep:**
- Add item
- Edit item (name, category, unit, reorder level)
- Barcode scan/assign
- Item list with search

**Remove:**
- Public QR page (customer-facing — not needed in warehouse ERP)
- Catalog AI suggestions (entry_intent system)
- "Smart unit intelligence" UI (keep backend, remove complex UI)
- Catalog supplier defaults page (too advanced for current stage)

---

## 4. UNUSED PAGES — DELETE

**Flutter pages with zero or near-zero usage:**

| File | Evidence | Action |
|------|----------|--------|
| `features/get_started/` | Onboarding flow — app is already deployed | DELETE |
| `features/admin/` | Only 1 file, no real content | MERGE into settings |
| `features/dashboard/` | Only re-exports | DELETE |
| `features/item/` | Duplicate of catalog | DELETE |
| `features/splash/` | Keep only if needed | KEEP (app needs splash) |

---

## 5. DEAD BACKEND SERVICES — REMOVE

| Service | Evidence | Action |
|---------|----------|--------|
| `services/entry_intent_resolution.py` | Check if called | DELETE one copy |
| `services/entry_intent_resolution_v2.py` | Check if called | DELETE one copy |
| `services/scanner_v3/` | Incomplete (1 file) | DELETE |
| `services/intent_stub.py` | Stub — placeholder only | DELETE |
| `services/monthly_payment_reminder.py` | Subscription reminder — not core | REMOVE from auto-run |
| `services/google_oauth.py` | No Google login in Flutter | DELETE if unused |
| `services/rate_display_context.py` | Complex rate display — unused? | AUDIT |
| `services/ocr_confidence_service.py` | OCR confidence — is OCR used? | AUDIT |
| `services/ocr_learning_service.py` | OCR learning loop | AUDIT |

---

## 6. STOCK PAGE — REMOVE TABS/FILTERS

**Current stock page has:**
- Tab: All | Low | Critical | Out | Operational | Opening
- Filter bar: Category + Subcategory + Supplier + Status + Period + Sort
- Column header: multiple toggle columns

**This is too complex for staff. Simplify:**

**Keep:**
- Search bar (always visible)
- Status chips: All / Low / Critical / Out (simple horizontal chips)
- Category dropdown (single)

**Remove:**
- Subcategory filter (too granular)
- Period filter (move to reports page)
- "Operational" tab (merge into main with a badge)
- Column toggle (fix columns: Name, System, Pending, Physical, Diff, Status)

---

## 7. PURCHASE PAGE — REMOVE FEATURES

**Remove from purchase form:**
- AI scan (keep as option, but remove from main flow)
- Multiple broker assignment (keep one broker field)
- "Trade intelligence" cards on purchase list
- Duplicate preview modal (show inline, not modal)

**Keep:**
- Manual line item entry
- Supplier assignment
- Invoice number
- Date picker
- Status update buttons

---

## 8. WHAT FEATURES TO ADD (REQUESTED)

### 8A. EXPENSE TRACKER (OWNER)

**New feature requested. Simple implementation:**

**Backend — new table:**
```sql
CREATE TABLE expense_log (
    id UUID PRIMARY KEY,
    business_id UUID REFERENCES businesses(id),
    category VARCHAR(100),  -- 'rent', 'salary', 'transport', 'misc'
    amount DECIMAL(12,2),
    description TEXT,
    expense_date DATE,
    added_by_name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Flutter — new page:**
```dart
// lib/features/expenses/presentation/expense_page.dart
// Simple list + add form
// Categories: Rent, Salary, Transport, Utilities, Misc
// Monthly total at top
// No complex analytics needed
```

### 8B. DELIVERY TRACKING DETAILS (WHO + WHEN)

**Already partially implemented. Complete it:**
- Add `truck_number`, `driver_name`, `driver_phone` to purchase form
- Show in purchase detail card
- Allow staff to update truck status

### 8C. REORDER WORKFLOW (STAFF → OWNER)

**Currently staff can click "Notify Owner" button. Enhance:**

1. Staff clicks [Request Reorder] on low stock item
2. System creates `ReorderListEntry` with `status=pending`
3. Owner sees notification: "Priya requests reorder: Sugar"
4. Owner opens item → sees [Create Purchase Order] with pre-filled qty
5. Owner clicks → goes directly to new purchase form for that item

**This is 80% implemented. Connect the dots.**
