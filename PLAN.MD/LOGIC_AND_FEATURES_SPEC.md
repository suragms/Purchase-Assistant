# LOGIC_AND_FEATURES_SPEC.md
## What Each Page Shows, What Each Role Sees, What Each Button Does
**Audit Date:** May 29, 2026

---

## COMPLETE ROLE MATRIX — EVERY PAGE, EVERY ACTION

### OWNER

| Page | Sees | Can Do | Cannot Do |
|------|------|--------|-----------|
| Home Dashboard | All alerts, all stock summary, delivery pipeline, expense tracker | Everything | — |
| Stock Page | All items, all columns (opening/purchased/pending/system/physical/diff) | Edit reorder level, set opening stock, trigger physical count request | Direct stock edit without audit trail |
| Item Detail | Full stock history, all purchases, physical count history, profit info | Purchase, set reorder, approve variance | — |
| Purchase List | All purchases, delivery status pipeline | Create, edit (draft only), mark dispatched, commit verified delivery | Staff verification step |
| Purchase Detail | Full detail including payment and delivery track | All actions | — |
| Reports | Full financial reports | Export PDF/Excel | — |
| Notifications | All system alerts | Dismiss, act on | — |
| User Management | All users | Add, edit roles, deactivate | Cannot edit own role |
| Settings | All settings | All | — |
| Expense Tracker | All expenses | Add, edit, delete, categorize | — |

---

### MANAGER

| Page | Sees | Can Do | Cannot Do |
|------|------|--------|-----------|
| Home Dashboard | Stock alerts, delivery pipeline, tasks | Same as owner minus expense | Delete data |
| Stock Page | All items, same columns as owner | Edit reorder level, request physical count | Set opening stock directly |
| Item Detail | Same as owner | Purchase, set reorder | Delete item |
| Purchase List | All purchases | Create, edit draft, mark dispatched | Commit to stock (owner-only) |
| Reports | Operational reports | Export | Financial P&L |
| User Management | View users | Cannot edit | All edits |
| Settings | Limited | View only | Change business settings |
| Expense Tracker | Cannot see | — | Everything |

---

### STAFF

| Page | Sees | Can Do | Cannot Do |
|------|------|--------|-----------|
| Staff Home | My tasks, pending deliveries, warehouse totals, recent | Mark arrived, start verify | Everything else |
| Stock Page | Item name, physical stock column only | Enter physical count | See purchase prices |
| Item Detail | Item name, physical stock, reorder level | Submit physical count | See financial data |
| Purchase List | Deliveries assigned to me | Mark arrived, verify quantities | Create/edit |
| Verify Delivery | Delivery details + entry form | Count and submit | Approve/commit |
| Reorder Request | Reorder list | Tap "Inform Owner" | Approve |
| Settings | My profile only | Change name/password | — |

---

## NOTIFICATION MATRIX — COMPLETE

### OWNER RECEIVES:

| Trigger | Message | Priority | Tappable Action |
|---------|---------|----------|----------------|
| Item hits reorder level | "⚠️ Sugar below reorder: 15 bags (limit: 50)" | HIGH | Open item → Quick purchase |
| Item out of stock | "🔴 Rice is OUT OF STOCK" | CRITICAL | Open item → Purchase now |
| Staff verified delivery | "✅ Anil verified Sugar delivery: 708/711 bags" | HIGH | Open purchase → Commit to stock |
| Large stock variance | "⚠️ Sugar physical 800 vs system 812. Diff: -12" | HIGH | Open item → Review |
| Opening stock missing | "📋 47 items have no opening stock set" | MEDIUM | Open opening stock setup |
| Staff reorder request | "📌 Anil requests reorder: Oil (0 bags)" | HIGH | Open item → Purchase |
| Delivery arrived (no action 2h) | "📦 Sugar delivery arrived 2h ago — assign for verification" | HIGH | Open purchase → Assign |
| Expense logged | "💰 Anil logged expense: ₹500 (transport)" | LOW | Open expense tracker |

### STAFF RECEIVES:

| Trigger | Message | Priority | Tappable Action |
|---------|---------|----------|----------------|
| Delivery dispatched | "🚛 Sugar 711 bags dispatched. Watch for arrival." | MEDIUM | Open delivery |
| Delivery assigned to me | "📦 Verify Sugar delivery — 711 bags expected" | HIGH | Open verify screen |
| Owner committed to stock | "✅ Sugar 708 bags added to system stock" | LOW | View |
| Reorder approved | "✅ Owner approved reorder: Oil" | LOW | View |
| Daily physical count reminder | "🌙 Evening count: 12 items pending" | MEDIUM | Open stock count |

---

## STOCK PAGE — COLUMN LOGIC (Complete)

### Every Row Must Show:

```
ITEM NAME        | OPENING | PURCHASED | PENDING | SYSTEM | PHYSICAL | DIFF | STATUS
Sugar (1kg Bag)  |   101   |    711    |   50    |  812   |   800    |  -12 |  ⚠️
Rice (25kg Bag)  |   100   |    200    |    0    |  300   |   300    |   0  |  ✅
Oil (15L Can)    |    20   |     15    |    0    |   35   |    10    |  -25 |  🔴
```

**Column Definitions:**
- **Opening:** `catalog_items.opening_stock_qty` — set once at period start
- **Purchased:** `SUM(stock_movements.delta_qty WHERE movement_kind='delivery_receive')` — only verified+committed
- **Pending:** `SUM(trade_purchase_lines.qty WHERE delivery_status IN ('pending','dispatched','in_transit','arrived','staff_verified'))` — not yet committed
- **System:** `Opening + Purchased` — calculated, NOT stored (prevents drift)
- **Physical:** `catalog_items.physical_stock_qty` — latest staff count
- **Diff:** `Physical - System` — negative = loss/sales; positive = excess

**NOT System = `catalog_items.current_stock`**  
The current `current_stock` column is a running total maintained by individual stock movements. It drifts over time. Replace with calculated `opening + sum(committed deliveries)` for clarity.

---

## ITEM DETAIL PAGE — COMPLETE CONTENT SPEC

### Owner View:

```
HEADER
  Item Name (large)
  Category · Subcategory
  Item Code    Reorder Level: 50 bags   [Edit]

STOCK SUMMARY CARD (always visible, top)
  Opening:       101 bags
  + Purchased:   711 bags  (committed deliveries only)
  + Pending:      50 bags  (not yet verified)
  = System:      812 bags
  Physical:      800 bags  (last count: May 29, by Anil)
  Difference:    -12 bags  ⚠️ (possible loss/sales)
  [Verify Physical Count]  [Commit Pending Delivery]

DELIVERY PIPELINE CARD (collapsible)
  🚛 PO #145: 50 bags dispatched (May 28)
  ✅ PO #144: 711 bags committed (May 22, by Anil)

TABS:
  [Purchase History] [Physical Counts] [Activity Log]

Purchase History Tab:
  Date     Qty   Rate    Total    Supplier   Status
  May 20   711  ₹63.50  ₹45,128  ABC       ✅ Committed
  Mar 15   500  ₹62.00  ₹31,000  ABC       ✅ Committed
  Jan 02   200  ₹60.00  ₹12,000  XYZ       ✅ Committed

Physical Counts Tab:
  Date     Physical   System   Diff   By
  May 29     800        812    -12    Anil
  May 28     810        812     -2    Anil
  May 22     101        101      0    Opening stock

Activity Log Tab:
  May 29 11:45  Anil — Physical count: 800 (was 810)
  May 22 12:00  Owner — Committed 711 bags to stock
  May 22 11:45  Anil — Verified delivery: 711 bags
  May 20 10:15  Owner — Created PO #145
```

### Staff View (no prices):

```
HEADER
  Item Name
  Category

STOCK SUMMARY (simplified)
  System Stock:   812 bags
  Physical Count: 800 bags
  Difference:     -12 bags  ⚠️
  [Update My Count]

MY TASKS FOR THIS ITEM
  📦 PO #145: Pending verification (50 bags expected)
  [Start Verification]

NO: purchase history prices, no financial data
```

---

## EXPENSE TRACKER — NEW FEATURE SPEC

**Not in current app. Must be added.**

Owner needs to track:
- Transport/freight costs
- Packaging costs  
- Labour costs
- Miscellaneous warehouse costs

### Database:

```sql
CREATE TABLE IF NOT EXISTS expense_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id UUID NOT NULL REFERENCES businesses(id),
  amount NUMERIC(12,2) NOT NULL,
  category VARCHAR(50) NOT NULL  -- transport, labour, packaging, misc
    CHECK (category IN ('transport','labour','packaging','utilities','misc')),
  description TEXT,
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  logged_by UUID REFERENCES users(id),
  logged_by_name VARCHAR(255),
  linked_purchase_id UUID REFERENCES trade_purchases(id),  -- optional link
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Flutter Files to Create:
- `lib/features/expenses/presentation/expense_tracker_page.dart`
- `lib/features/expenses/presentation/add_expense_sheet.dart`
- `lib/core/providers/expense_providers.dart`
- `lib/core/api/hexa_api.dart` — add `getExpenses()`, `addExpense()`, `deleteExpense()`

### Owner Dashboard Card:

```
EXPENSES THIS MONTH
  Total: ₹12,450
  Transport: ₹5,000
  Labour:    ₹4,000
  Packaging: ₹3,450
  [View All] [+ Add Expense]
```

---

## STAFF HOME DASHBOARD — COMPLETE CONTENT ORDER

```
TOP (always visible, no scroll needed):
  ┌─────────────────────────────────────┐
  │ Good morning, Anil 👋               │
  │ May 29, 2026                        │
  └─────────────────────────────────────┘

SECTION 1 — MY TASKS (highest priority, tap to act)
  🔴 [URGENT] Verify Sugar delivery — 50 bags expected
  🟡 [TODAY] Physical count: 8 items pending
  ✅ [DONE] Rice delivery committed

SECTION 2 — WAREHOUSE SUMMARY (compact, 2-column grid)
  Purchased Today: 711 bags    |  System Stock items: 45
  Pending Delivery: 2 orders   |  Physical done today: 3 items

SECTION 3 — PENDING DELIVERIES (scroll if more than 3)
  🚛 Sugar: 50 bags (dispatched May 28)   [Mark Arrived]
  🚛 Oil: 20 cans (dispatched May 27)     [Mark Arrived]

SECTION 4 — LOW STOCK (tap to request reorder)
  🔴 Rice: 0 bags (OUT)         [Inform Owner]
  ⚠️ Oil: 3 cans (low)          [Inform Owner]
  ⚠️ Flour: 5 bags (low)        [Inform Owner]

SECTION 5 — TOOLS (horizontal scroll, icon+label)
  [Scan Barcode] [Physical Count] [Quick Buy] [My Activity]

SECTION 6 — RECENT ACTIVITY (last 10 actions by me)
  11:45 — Verified Sugar 711 bags
  10:30 — Marked Oil arrived
  09:15 — Physical count: Rice 0 bags
```

**STRICT ORDER — do not reorder.** Staff needs tasks first, then context, then tools.

---

## OWNER HOME DASHBOARD — COMPLETE CONTENT ORDER

```
SECTION 1 — CRITICAL ALERTS (red/orange — must act)
  [🔴 Rice OUT OF STOCK — Buy Now]
  [⚠️ 1 delivery needs verification — 2 hours waiting]
  [⚠️ 8 items below reorder level]

SECTION 2 — STOCK SUMMARY (always visible)
  System Stock:  45 items tracked
  Physical Done: 38/45 items this period
  Missing Count:  7 items ← tap to assign

SECTION 3 — PENDING DELIVERIES (tap to act)
  🚛 Sugar PO#145: Dispatched (50 bags)
  ✅ Rice PO#144: Verified by Anil — [Commit to Stock]

SECTION 4 — OPENING STOCK MISSING (one-time action)
  Only if: items with no opening_stock_qty set
  [Set Up Opening Stock (47 items)]

SECTION 5 — LOW STOCK
  [see 8 items below reorder level]

SECTION 6 — OUT OF STOCK
  [Rice — 0 bags — Buy Now]

SECTION 7 — EXPENSES THIS MONTH
  ₹12,450 total  [+ Add Expense]

SECTION 8 — TOOLS (horizontal scroll)
  [New Purchase] [Stock Audit] [Reorder List] [Reports] [Users]

SECTION 9 — MY TASKS (owner checklist)
  [ ] Commit Sugar delivery to stock
  [ ] Approve Anil's reorder request for Oil
  [+ Add Task]

SECTION 10 — RECENT ACTIVITY (last 20 events)
  May 29 11:45  Anil — Physical count submitted
  May 29 11:00  Anil — Sugar marked arrived
  May 29 10:15  Owner — PO #145 dispatched
```

---

## SETTINGS PAGE — FEATURES TO REMOVE

Currently has:
- Brand name settings (remove — not needed)
- Units/language settings (keep)
- Barcode settings (keep)
- Help guide (keep)
- Notification settings (add: granular per-type toggles)
- User profile (keep)

**Remove from settings:**
- Business theme/brand color selector
- Marketing/catalog public URL toggle (not a warehouse feature)
- OCR learning settings (internal tool, not for owner)
