# ITEM DETAIL REBUILD — HARISREE PURCHASE ASSISTANT
> Three pages → One page. Role-based sections. No auto-refresh.

---

## 1. CURRENT PROBLEMS (CODE-BASED)

### Problem 1: Three separate pages for the same item

```
features/catalog/presentation/item_detail_page.dart         ← version A
features/catalog/presentation/catalog_item_detail_page.dart ← version B  
features/reports/presentation/reports_item_detail_page.dart ← version C
```

All three:
- Fetch from different providers
- Have independent realtime listeners
- Can show stale data simultaneously
- Cause "item swapping" bug (one page's realtime update affects another open page)

### Problem 2: Multiple providers watching the same item

```dart
// In item detail, these all run independently:
ref.watch(stockItemDetailProvider(itemId))      // GET /stock/{id}
ref.watch(stockItemIntelligenceProvider(itemId)) // GET /stock/{id}/intelligence
ref.watch(stockItemActivityProvider(itemId))     // GET /stock/{id}/activity
ref.watch(catalogItemProvider(itemId))           // GET /catalog/{id}  ← same data!
```

**4 API calls for 1 item. Data can be slightly out of sync between calls.**

### Problem 3: Auto-refresh on item page

Item detail listens to realtime `stock.changed` events. When ANY item changes, this page re-fetches — even if it's a different item.

---

## 2. NEW UNIFIED ITEM DETAIL PAGE

**Single file:** `lib/features/stock/presentation/item_detail_page.dart`

Delete all three existing pages. Create one.

---

## 3. OWNER VIEW LAYOUT

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HEADER (sticky)
  Item Name (large)
  Category > Subcategory
  Status badge [Healthy/Low/Critical/Out]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STOCK SNAPSHOT (4 values in 2×2 grid)
  Opening Stock | System Stock
  Pending Deliv | Physical Count
  [Difference: -12 bags] (red if negative)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LAST PURCHASE INFO
  Supplier: AL Traders · May 28, 2026
  Qty: 500 bags · Rate: ₹45/bag
  Status: [Delivered ✓]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OWNER ACTIONS (horizontal row)
  [New Purchase] [Edit Item] [Set Reorder]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PURCHASE HISTORY (last 5)
  Expandable. Shows date, qty, supplier, rate.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STOCK ACTIVITY (last 10 movements)
  Each row: who, what, when, qty change
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 4. STAFF VIEW LAYOUT

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HEADER
  Item Name
  Status badge
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STOCK SNAPSHOT (simplified — no rates)
  System Stock | Pending Delivery
  My Last Count | Difference
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STAFF ACTIONS
  [Log Cash Buy] [Update Physical Count] [Notify Owner]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECENT COUNTS (last 3 physical counts I did)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Staff does NOT see:**
- Purchase rates / landing costs
- Purchase history (financial)
- Profit analysis

---

## 5. FLUTTER IMPLEMENTATION

**File:** `lib/features/stock/presentation/item_detail_page.dart`

```dart
class ItemDetailPage extends ConsumerWidget {
  final String itemId;
  const ItemDetailPage({required this.itemId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.read(sessionProvider)?.role ?? 'staff';
    
    // ONE provider. ONE API call.
    final detail = ref.watch(itemDetailProvider(itemId));

    return detail.when(
      loading: () => const ItemDetailSkeleton(),
      error: (e, st) => ItemDetailError(error: e),
      data: (item) => Scaffold(
        body: CustomScrollView(slivers: [
          // Sticky header
          SliverPersistentHeader(
            pinned: true,
            delegate: ItemDetailHeader(item: item),
          ),

          // Stock snapshot
          SliverToBoxAdapter(child: StockSnapshotGrid(item: item, role: role)),

          // Last purchase
          SliverToBoxAdapter(child: LastPurchaseInfo(item: item, role: role)),

          // Actions
          SliverToBoxAdapter(child: ItemActions(item: item, role: role)),

          // History sections (lazy loaded)
          if (role == 'owner' || role == 'manager')
            SliverToBoxAdapter(child: PurchaseHistorySection(itemId: itemId)),

          SliverToBoxAdapter(child: StockActivitySection(itemId: itemId)),
        ]),
      ),
    );
  }
}
```

---

## 6. ONE BACKEND ENDPOINT FOR ITEM DETAIL

**New endpoint:** `GET /v1/businesses/{id}/stock/{item_id}/full`

```python
@router.get("/{item_id}/full")
async def get_stock_item_full(
    business_id: uuid.UUID,
    item_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    membership: Membership = Depends(require_membership),
):
    """
    Single endpoint for item detail page.
    Returns item + recent purchases + recent activity + physical count.
    """
    item = await get_stock_item(business_id, item_id, db, membership)
    purchases = await _recent_purchases(db, item_data, limit=5)
    activity = await _get_item_activity(db, business_id, item_id, limit=10)
    phys = await _latest_physical_count_map(db, business_id, [item_id])
    
    return {
        "item": item,
        "recent_purchases": purchases if not should_redact_financials(membership.role) else [],
        "recent_activity": activity,
        "physical_count": phys.get(item_id),
    }
```

---

## 7. NAVIGATION — FIX THE ROUTE

**Current problem:** App uses 3 different routes to item detail:
- `/catalog/items/{id}`
- `/stock/items/{id}`  
- `/reports/items/{id}`

**Fix:** One route. Use query params for context.
```dart
// Single route:
GoRoute(
  path: '/items/:id',
  builder: (ctx, state) => ItemDetailPage(
    itemId: state.pathParameters['id']!,
    // context: state.uri.queryParameters['from'] ?? 'stock'
  ),
),
```

All navigation in the app should push `'/items/{id}'`. Delete the other routes.

---

## 8. FIX AUTO-REFRESH BUG

**Current (BROKEN):**
```dart
// In item detail — watches realtime for ANY stock change
ref.listen(realtimeEventsProvider, (_, event) {
  if (event?.kind == 'stock.changed') {
    ref.invalidate(stockItemDetailProvider(itemId));  // ← fires even for OTHER items
  }
});
```

**Fix:**
```dart
// Only refresh if THIS item changed
ref.listen(realtimeEventsProvider, (_, event) {
  final changedItemId = event?.payload?['item_id'];
  if (event?.kind == 'stock.changed' && changedItemId == itemId) {
    ref.invalidate(itemDetailProvider(itemId));
  }
});
```
