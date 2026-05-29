# NOTIFICATION REBUILD — HARISREE PURCHASE ASSISTANT
> Right notification. Right person. Right time. No duplicates.

---

## 1. NOTIFICATION MATRIX

| Event | Notify | Badge | Push |
|-------|--------|-------|------|
| Stock goes low (< reorder) | Owner + Manager | ✅ | ✅ |
| Stock goes critical (< 50% reorder) | Owner | ✅ | ✅ |
| Stock out | Owner + Manager | ✅ | ✅ |
| Staff requests reorder | Owner | ✅ | ✅ |
| Staff notifies about item | Owner | ✅ | ✅ |
| Physical count mismatch > 5% | Owner + Manager | ✅ | ✅ |
| Delivery arrived at warehouse | Owner + Manager | ✅ | ✅ |
| Purchase marked In Transit | Owner | ❌ | ❌ (no noise) |
| Staff logs cash buy | Owner | ✅ | ❌ (batch) |
| Opening stock missing item | Owner (weekly) | ✅ | ❌ |

| Event | Notify | Badge | Push |
|-------|--------|-------|------|
| Delivery verification task assigned | Staff | ✅ | ✅ |
| Physical count due (evening) | Staff | ✅ | ✅ |
| Owner approved reorder request | Staff who requested | ✅ | ✅ |

---

## 2. DEDUPLICATION RULES

**Critical:** Same notification must NOT fire twice for same event.

```python
# In notification_emitter.py:
async def emit_notification(
    db: AsyncSession,
    business_id: uuid.UUID,
    user_id: uuid.UUID,
    kind: str,
    title: str,
    body: str,
    payload: dict,
    dedupe_key: str,  # ALWAYS REQUIRED
    dedupe_window_hours: int = 24,
) -> bool:
    """Returns True if notification was created, False if duplicate."""
    
    window_start = datetime.now(timezone.utc) - timedelta(hours=dedupe_window_hours)
    existing = await db.execute(
        select(AppNotification.id).where(
            AppNotification.business_id == business_id,
            AppNotification.dedupe_key == dedupe_key,
            AppNotification.created_at >= window_start,
        ).limit(1)
    )
    if existing.scalar_one_or_none():
        return False
    
    db.add(AppNotification(
        id=uuid.uuid4(),
        business_id=business_id,
        user_id=user_id,
        kind=kind,
        title=title,
        body=body,
        payload=payload,
        dedupe_key=dedupe_key,
    ))
    return True
```

**Dedupe key format:**
```python
f"low_stock:{item_id}:{date.today().isoformat()}"      # once per day per item
f"out_of_stock:{item_id}:{date.today().isoformat()}"    # once per day per item
f"delivery_arrived:{purchase_id}"                        # once per purchase
f"staff_alert:{item_id}:{user_id}:{date.today()}"       # once per day per staff+item
f"mismatch:{item_id}:{audit_id}"                         # once per audit
```

---

## 3. CURRENT DUPLICATE NOTIFICATION PROVIDERS (Flutter)

**Problem:** Three providers all fetch notifications:
```
core/providers/notifications_provider.dart         ← poll
core/providers/realtime_notifications_provider.dart ← SSE
core/providers/server_notifications_provider.dart   ← another poll
```

**Fix:** ONE provider. SSE for live updates. Poll every 5 minutes as backup.

```dart
// File: lib/core/providers/notifications_provider.dart (rewrite)

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) async* {
  final session = ref.read(sessionProvider);
  if (session == null) { yield []; return; }
  
  // Initial load
  final initial = await api.getNotifications(businessId: session.primaryBusiness.id);
  yield initial;
  
  // Listen to SSE for updates
  await for (final event in ref.read(realtimeEventsProvider)) {
    if (event.kind == 'notification.changed') {
      final updated = await api.getNotifications(businessId: session.primaryBusiness.id);
      yield updated;
    }
  }
});
```

---

## 4. NOTIFICATION BELL UI

**File:** `lib/shared/widgets/notification_bell.dart`

```dart
class NotificationBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = notifications.valueOrNull?.where((n) => !n.isRead).length ?? 0;

    return Stack(children: [
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () => navigate(NotificationsPage()),
      ),
      if (unread > 0)
        Positioned(
          right: 8, top: 8,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$unread',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
    ]);
  }
}
```

---

## 5. NOTIFICATION PAGE

**File:** `lib/features/notifications/presentation/notifications_page.dart`

```
Notifications    [Mark All Read]

TODAY
─────────────────────────────────────────
🔴 Stock Out: Sugar                 2:30 PM
   Only 0 bags remaining. Reorder now.
   [View Item →]

⚠️  Low Stock: Rice                 1:15 PM
   12 kg left (reorder: 50 kg)
   [View Item →]

📦 Anil verified TP-0042            11:30 AM
   500 bags of Sugar received.
   [View Purchase →]

YESTERDAY
─────────────────────────────────────────
✉️  Priya requested reorder: Atta   6:45 PM
   [Approve →] [Reject →]
```

**Rules:**
- Group by day: Today / Yesterday / Older
- Each notification has one clear action button
- Tap anywhere on row → mark as read + navigate
- Mark All Read → bulk update
- Pull to refresh

---

## 6. BACKEND — FIX MISSING NOTIFICATIONS

### Low Stock Trigger — Currently triggered ONLY on stock_patch / physical_update

**Fix:** Also trigger on delivery received (stock increment):

**File:** `backend/app/services/low_stock_notifications.py`

```python
async def check_and_emit_low_stock_notifications(
    db: AsyncSession,
    business_id: uuid.UUID,
    item_ids: list[uuid.UUID],
):
    """Call this after any stock change that might push item to low/out."""
    for item_id in item_ids:
        item = await get_item(db, item_id)
        cur = catalog_stock_qty(item)
        ro = catalog_reorder(item)
        st = stock_status(cur, ro)
        
        if st in ("low", "critical", "out"):
            await emit_low_stock_notification(db, business_id, item, st)
```

**Call sites:** Add `await check_and_emit_low_stock_notifications(...)` to:
- `apply_confirmed_purchase_stock()` — after delivery decrements (for items that run out)
- `patch_stock_item()` — already has it
- `update_physical_stock()` — already has it

---

## 7. STAFF EVENING COUNT REMINDER

**File:** `backend/app/services/low_stock_notifications.py`

Add scheduled task (run at 6 PM daily):

```python
async def send_evening_count_reminders(db: AsyncSession, business_id: uuid.UUID):
    """Notify staff to do physical count for items not counted today."""
    today = date.today()
    
    # Find items with no physical count today
    counted_today_ids = await db.execute(
        select(StockPhysicalCount.item_id).where(
            StockPhysicalCount.business_id == business_id,
            func.date(StockPhysicalCount.counted_at) == today,
        )
    )
    counted_ids = {row[0] for row in counted_today_ids.all()}
    
    all_active = await db.execute(
        select(CatalogItem.id).where(
            CatalogItem.business_id == business_id,
            CatalogItem.deleted_at.is_(None),
        )
    )
    uncounted = [iid for iid, in all_active.all() if iid not in counted_ids]
    
    if uncounted:
        # Notify all staff members
        await emit_notification(
            db, business_id, user_id=...,  # all staff
            kind="evening_count_reminder",
            title=f"Evening Count: {len(uncounted)} items",
            body="Please complete physical stock count before closing.",
            dedupe_key=f"evening_count:{business_id}:{today}",
        )
```
