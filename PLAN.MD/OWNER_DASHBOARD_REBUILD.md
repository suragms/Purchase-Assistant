# OWNER DASHBOARD REBUILD — HARISREE PURCHASE ASSISTANT
> Current dashboard is confusing. This is the new design.

---

## 1. LAYOUT — EXACT ORDER (DO NOT CHANGE ORDER)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 1] CRITICAL ALERTS STRIP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 2] PURCHASE STATUS STRIP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 3] STOCK SUMMARY (3 cards)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 4] TOOLS QUICK-ACCESS (horizontal scroll)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 5] MY TASKS (checklist)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 6] RECENT ACTIVITY (last 10 events)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 2. SECTION 1 — CRITICAL ALERTS STRIP

**File:** `lib/features/home/presentation/widgets/alerts_strip.dart`

```dart
// Horizontal scrolling pill chips
// Only show chips where count > 0
// Tapping a chip navigates to the relevant page

Widget build() => SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(children: [
    if (alerts.pendingDeliveries > 0)
      _AlertChip(
        icon: Icons.local_shipping,
        label: '${alerts.pendingDeliveries} Deliveries',
        color: Colors.orange,
        onTap: () => navigate(PurchaseListPage(filter: 'pending')),
      ),
    if (alerts.criticalStock > 0)
      _AlertChip(
        icon: Icons.warning_amber,
        label: '${alerts.criticalStock} Critical Stock',
        color: Colors.red,
        onTap: () => navigate(StockPage(filter: 'critical')),
      ),
    if (alerts.lowStock > 0)
      _AlertChip(
        icon: Icons.trending_down,
        label: '${alerts.lowStock} Low Stock',
        color: Colors.amber,
        onTap: () => navigate(StockPage(filter: 'low')),
      ),
    if (alerts.pendingVerifications > 0)
      _AlertChip(
        icon: Icons.fact_check,
        label: '${alerts.pendingVerifications} Need Verify',
        color: Colors.blue,
        onTap: () => navigate(StockPage(filter: 'needs_verification')),
      ),
    if (alerts.openingStockMissing > 0)
      _AlertChip(
        icon: Icons.inventory_2,
        label: '${alerts.openingStockMissing} Opening Missing',
        color: Colors.purple,
        onTap: () => navigate(OpeningStockSetupPage()),
      ),
  ]),
);
```

**Rules:**
- If no alerts: hide section entirely (do NOT show "All Clear" card — wastes space)
- Max height: 44px
- Each chip: 12px horizontal padding, rounded corners

---

## 3. SECTION 2 — PURCHASE STATUS STRIP

**File:** `lib/features/home/presentation/widgets/purchase_status_strip.dart`

```
[🕐 2 Pending] [🚛 1 In Transit] [📦 1 Arrived] [✅ 3 Delivered Today]
```

Each chip taps to filtered purchase list.

**Data source:** Single query from `/trade_purchases?summary=true` (create this endpoint)

```python
# New endpoint: GET /v1/businesses/{id}/trade-purchases/status-summary
# Returns:
{
  "pending_supplier": 2,
  "in_transit": 1,
  "arrived_warehouse": 1,
  "staff_verifying": 0,
  "delivered_today": 3,
  "total_pending_value": 45000.00
}
```

---

## 4. SECTION 3 — STOCK SUMMARY (3 CARDS)

**File:** `lib/features/home/presentation/widgets/stock_summary_cards.dart`

```
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ System Stock    │ │ Pending Delivery │ │ Physical Diff   │
│                 │ │                 │ │                 │
│ 504 items       │ │ 12 items        │ │ 8 items off     │
│ 812 bags        │ │ 450 bags pending│ │ -24 bags lost   │
│ ₹2,45,000       │ │ ₹89,000 value   │ │ ₹3,200 variance │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

**Rules:**
- Tap "System Stock" → goes to full stock list
- Tap "Pending Delivery" → goes to stock list filtered for pending
- Tap "Physical Diff" → goes to stock list filtered for items with difference

**Data source:** Combine `/stock/inventory-summary` + `/stock/warehouse/alerts-summary` (one call).

---

## 5. SECTION 4 — TOOLS QUICK-ACCESS

**File:** `lib/features/home/presentation/widgets/tools_row.dart`

```dart
// Horizontal scrolling icon grid
// 6 tools max (more clutters)
final tools = [
  Tool(icon: Icons.add_shopping_cart, label: 'New Purchase', route: NewPurchasePage()),
  Tool(icon: Icons.inventory, label: 'Stock Count', route: StockPage()),
  Tool(icon: Icons.qr_code_scanner, label: 'Scan Barcode', route: BarcodeScanPage()),
  Tool(icon: Icons.bar_chart, label: 'Reports', route: ReportsPage()),
  Tool(icon: Icons.people, label: 'Contacts', route: ContactsPage()),
  Tool(icon: Icons.receipt_long, label: 'Purchases', route: PurchaseListPage()),
];
```

**Size:** 72px icon + label. No border. Background: surface color.

---

## 6. SECTION 5 — MY TASKS (CHECKLIST)

**File:** `lib/features/home/presentation/widgets/tasks_checklist.dart`

```
My Tasks Today  [3/5 done]
☑  Set opening stock for new items
☑  Review pending deliveries
☐  Update physical count — Sugar
☐  Approve TP-0042 delivery
☐  Review month-end report
```

**Rules:**
- Max 5 tasks shown. [See All] link.
- Tasks are owner-specific checklist items
- Completed tasks shown with strikethrough, grey
- Sorted: incomplete first

---

## 7. SECTION 6 — RECENT ACTIVITY

**File:** `lib/features/home/presentation/widgets/recent_activity_feed.dart`

```
Recent Activity
────────────────
🟢 Anil updated Sugar stock → 800 bags        2 min ago
🔴 Low stock alert: Rice (12 kg remaining)    15 min ago
📦 TP-0042 marked In Transit                  1 hour ago
🔵 Priya added Purchase TP-0043              2 hours ago
📊 Physical count: Atta 95 bags (diff: -5)   3 hours ago
                                      [Load More]
```

**Rules:**
- Lazy load. Show 10. [Load More] fetches next 10.
- No auto-refresh. User pulls to refresh manually.
- Each row: icon + description + time. Tap → navigate to relevant page.

---

## 8. WHAT TO REMOVE FROM CURRENT DASHBOARD

| Currently Shown | Action |
|-----------------|--------|
| Brand name / business name (large header) | REMOVE or make small subtitle |
| Spend ring chart | REMOVE — too abstract for warehouse |
| "Trade intelligence" cards | REMOVE |
| "Unit breakdown" bar | REMOVE — put in stock summary only |
| Multiple period filter dropdowns | REMOVE — period filter = Today/Week/Month chips only |
| Notification bell with separate page | KEEP but simplify |
| Settings gear (top right) | KEEP |

---

## 9. FLUTTER IMPLEMENTATION

**File:** `lib/features/home/presentation/home_page.dart`

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(businessName, style: smallStyle),
      actions: [NotificationBell(), SettingsIcon()],
    ),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(homePageProvider),
      child: CustomScrollView(
        slivers: [
          // Section 1: Alerts strip (hidden if empty)
          SliverToBoxAdapter(child: AlertsStrip()),

          // Section 2: Purchase status
          SliverToBoxAdapter(child: PurchaseStatusStrip()),

          // Section 3: Stock summary 3 cards
          SliverToBoxAdapter(child: StockSummaryCards()),

          // Divider
          SliverToBoxAdapter(child: SectionDivider(label: 'Tools')),

          // Section 4: Tools
          SliverToBoxAdapter(child: ToolsRow()),

          // Divider
          SliverToBoxAdapter(child: SectionDivider(label: 'My Tasks')),

          // Section 5: Tasks
          SliverToBoxAdapter(child: TasksChecklist()),

          // Divider
          SliverToBoxAdapter(child: SectionDivider(label: 'Recent Activity')),

          // Section 6: Activity (paginated)
          SliverList(delegate: SliverChildBuilderDelegate(
            (ctx, i) => ActivityRow(event: events[i]),
            childCount: events.length,
          )),

          // Load more
          SliverToBoxAdapter(child: LoadMoreButton()),
        ],
      ),
    ),
  );
}
```

**One `homePageProvider` fetches all home data in a single API call. No cascading providers.**
