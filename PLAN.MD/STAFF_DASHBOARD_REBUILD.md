# STAFF DASHBOARD REBUILD — HARISREE PURCHASE ASSISTANT
> Staff dashboard must be task-focused. Not info-heavy.

---

## 1. LAYOUT — EXACT ORDER

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 1] MY TASKS TODAY (top priority)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 2] WAREHOUSE SUMMARY (compact — 4 stat boxes)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 3] PENDING DELIVERIES (action cards)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 4] LOW STOCK ALERTS (compact list)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[SECTION 5] RECENT MY ACTIVITY (last 5 actions)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 2. SECTION 1 — MY TASKS TODAY

**This is the FIRST thing staff sees. Most important section.**

```
My Tasks · May 29              [2 of 5 done]

□ Receive Delivery: TP-0042 (Sugar 500 bags)    [🚛 Arrived]
□ Physical Count: Sugar — evening count          [📊 Due Tonight]
□ Update stock: Rice (staff purchase logged)     [📝 Pending]
☑ Barcode check: Atta batch                     ✓ Done 10:30 AM
☑ Morning checklist completed                   ✓ Done 9:15 AM
```

**Rules:**
- Tasks auto-generated from system state + manual checklist
- Auto-task: Any purchase at `arrived_warehouse` status → "Receive Delivery" task
- Auto-task: If evening (after 6 PM) → "Physical Count" task for each item with no count today
- Auto-task: Any pending staff_purchase_log from today → "Verify entry" task
- Manual tasks: from `StaffChecklistTemplate` table
- Completed tasks: greyed out, moved to bottom
- Tap task → navigate directly to action page

---

## 3. SECTION 2 — WAREHOUSE SUMMARY

**Compact. No graphs. Numbers only.**

```
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Purchased│ │Warehouse │ │ Physical │ │  Diff    │
│ Today    │ │ Stock    │ │ Stock    │ │          │
│ 3 items  │ │ 504 items│ │ 487      │ │ 17 items │
│ 850 bags │ │          │ │ counted  │ │ uncounted│
└──────────┘ └──────────┘ └──────────┘ └──────────┘
```

**Tap each card → navigate to filtered stock view.**

---

## 4. SECTION 3 — PENDING DELIVERIES

**Action-focused. Each card has one clear button.**

```
┌────────────────────────────────────────────────┐
│ 🚛 TP-0042 · AL Traders                        │
│ Sugar: 500 bags · Rice: 200 kg                 │
│ Expected: Today · Status: Arrived              │
│                          [Verify Delivery →]   │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│ 🕐 TP-0039 · Kalyan Traders                    │
│ Atta: 100 bags                                 │
│ Status: In Transit · ETA: May 30               │
│                          [Track →]             │
└────────────────────────────────────────────────┘
```

**Button logic:**
- `arrived_warehouse` or `staff_verifying` → [Verify Delivery] (primary action)
- `in_transit` → [Mark Arrived] (available only if staff has permission)
- `pending_supplier` or earlier → [View Details] (read-only)

---

## 5. SECTION 4 — LOW STOCK ALERTS

**Compact list. Two actions per item.**

```
Low Stock  [12 items]
────────────────────────────────────────────────
⚠️ Sugar    8 bags left  (reorder: 50)   [Log Cash Buy] [Notify Owner]
🔴 Rice     0 kg          (out of stock)  [Notify Owner]
⚠️ Atta     15 bags left  (reorder: 40)   [Log Cash Buy] [Notify Owner]
                                          [See All 12 →]
```

**Show max 3. [See All] navigates to low stock page.**

**[Log Cash Buy]:** Opens quick purchase modal — staff logs a small cash purchase immediately. Adds to `StaffPurchaseLog` and updates stock.

**[Notify Owner]:** Sends push notification to owner. Disabled for 24 hours after sending (de-duplicate).

---

## 6. SECTION 5 — MY RECENT ACTIVITY

**Only staff's own actions. Not all business activity.**

```
My Activity Today
────────────────────────────────────────────────
✓ Physical count: Sugar 800 bags          7:45 PM
✓ Verified delivery: TP-0042              6:30 PM
✓ Logged cash buy: Rice 20 kg             4:15 PM
✓ Barcode scan: Atta batch QC             2:30 PM
```

**Data source:** `StaffActivityLog` filtered by `user_id = current_user.id` and `usage_date = today`.

---

## 7. FLUTTER IMPLEMENTATION

**File:** `lib/features/staff/presentation/staff_dashboard_page.dart`

```dart
@override
Widget build(BuildContext context) {
  final staffData = ref.watch(staffHomeProvider);

  return Scaffold(
    appBar: AppBar(
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Good ${_greeting()}, ${staffData.userName}'),
        Text('${staffData.businessName}', style: captionStyle),
      ]),
      actions: [NotificationBell()],
    ),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(staffHomeProvider),
      child: CustomScrollView(slivers: [
        
        // Section 1: My Tasks
        SliverToBoxAdapter(child: StaffTasksList(tasks: staffData.tasks)),
        
        // Section 2: Warehouse Summary
        SliverToBoxAdapter(child: WarehouseSummaryGrid(summary: staffData.summary)),
        
        // Section 3: Pending Deliveries
        if (staffData.pendingDeliveries.isNotEmpty)
          SliverToBoxAdapter(child: SectionHeader(label: 'Pending Deliveries')),
        SliverList(delegate: SliverChildBuilderDelegate(
          (ctx, i) => PendingDeliveryCard(delivery: staffData.pendingDeliveries[i]),
          childCount: staffData.pendingDeliveries.length,
        )),
        
        // Section 4: Low Stock
        SliverToBoxAdapter(child: LowStockAlertsList(items: staffData.lowStock.take(3).toList())),
        
        // Section 5: My Activity
        SliverToBoxAdapter(child: StaffActivityList(events: staffData.myActivity)),
      ]),
    ),
  );
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Morning';
  if (hour < 17) return 'Afternoon';
  return 'Evening';
}
```

---

## 8. STAFF HOME PROVIDER — SINGLE API CALL

**File:** `lib/core/providers/staff_home_providers.dart`

```dart
// One provider, one API call, all sections
final staffHomeProvider = FutureProvider.autoDispose<StaffHomeData>((ref) async {
  final session = ref.read(sessionProvider);
  if (session == null) return StaffHomeData.empty;
  
  // ONE call to backend
  final data = await ref.read(hexaApiProvider).getStaffHomeSummary(
    businessId: session.primaryBusiness.id,
  );
  return StaffHomeData.fromJson(data);
});
```

**New backend endpoint:** `GET /v1/businesses/{id}/staff/home-summary`

Returns everything the staff dashboard needs in one response:
```json
{
  "tasks": [...],
  "warehouse_summary": {...},
  "pending_deliveries": [...],
  "low_stock": [...],
  "my_activity": [...]
}
```

---

## 9. WHAT TO REMOVE FROM CURRENT STAFF DASHBOARD

| Currently Shown | Action |
|-----------------|--------|
| Analytics charts | REMOVE — staff doesn't need spend analysis |
| Period filter chips (Today/Week/Month) | REMOVE — staff always sees TODAY |
| Business profile card | REMOVE |
| Trade intelligence cards | REMOVE |
| Spend ring chart | REMOVE |
| Multiple tab navigation inside dashboard | REMOVE — use single scroll |
