# AGENT PROMPT 03 — FIX NOTIFICATIONS: BADGE COUNT + 3-TAB PAGE
**Priority:** HIGH — users see badge "30" but page shows nothing useful.

---

## ROOT CAUSE ANALYSIS

### Problem 1: Badge shows wrong number
**File:** `flutter_app/lib/features/shell/shell_screen.dart` line 97
```dart
final stockAlertN = ref.watch(stockLowCountProvider).valueOrNull ?? 0;
// ...
stockBadgeCount: stockAlertN,  // line 191
```
`stockLowCountProvider` returns the RAW COUNT of low-stock items (e.g. 30 items are low-stock). 
The badge shows "30". But the notifications page shows only 3–5 grouped notification cards.
This mismatch confuses the owner: badge says 30, page looks empty.

### Problem 2: Notifications page is empty / shows static text
**Root cause:** The notification list renders items from `mergedNotificationFeedProvider` which:
- Includes server notifications (from API `GET /notifications`) — but the backend `AppNotification` table is likely empty since nothing writes to it automatically
- Includes `warehouseAlertNotificationItemsProvider` — generates 2–3 grouped cards maximum  
- Result: page looks nearly empty even when badge shows 30

### Problem 3: Server notifications API returns 0 rows
The `AppNotification` model exists and the table is created, but nothing in the backend writes low-stock notifications automatically. The `run_low_stock_notification_scan` function in `main.py` startup creates notifications, but it may not be running reliably.

---

## BACKEND FIX: Auto-populate low-stock notifications

**File:** `backend/app/services/low_stock_notifications.py` (find this file or create it)

Add a function that creates per-item notifications when stock drops:
```python
async def create_low_stock_notification_for_item(
    db: AsyncSession,
    business_id: uuid.UUID,
    user_ids: list[uuid.UUID],
    item_id: uuid.UUID,
    item_name: str,
    current_stock: float,
    reorder_level: float,
    unit: str | None,
):
    """Create an AppNotification row for each user in the business when an item goes low."""
    from app.models.notification import AppNotification
    from datetime import datetime, timezone
    
    # Avoid duplicate notifications: check if one was created in last 24h for this item
    existing = await db.execute(
        select(AppNotification).where(
            AppNotification.business_id == business_id,
            AppNotification.kind == "low_stock",
            AppNotification.created_at >= datetime.now(timezone.utc) - timedelta(hours=24),
        ).limit(1)
    )
    if existing.scalar_one_or_none():
        return  # already notified today
    
    for uid in user_ids:
        n = AppNotification(
            business_id=business_id,
            user_id=uid,
            kind="low_stock",
            title=f"Low stock: {item_name}",
            body=f"Only {current_stock} {unit or 'units'} left (reorder at {reorder_level})",
            payload={"item_id": str(item_id)},
        )
        db.add(n)
    await db.commit()
```

---

## BACKEND FIX: Add "mark all read" and bulk notification endpoints

**File:** `backend/app/routers/notifications.py`

Add these endpoints:

```python
@router.post("/mark-all-read", status_code=status.HTTP_204_NO_CONTENT)
async def mark_all_notifications_read(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    user: Annotated[User, Depends(get_current_user)],
    _m: Annotated[object, Depends(require_membership)],
):
    del _m
    await db.execute(
        update(AppNotification)
        .where(
            AppNotification.business_id == business_id,
            AppNotification.user_id == user.id,
            AppNotification.read_at.is_(None),
        )
        .values(read_at=datetime.now(timezone.utc))
    )
    await db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.delete("/clear-all", status_code=status.HTTP_204_NO_CONTENT)
async def clear_all_notifications(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    user: Annotated[User, Depends(get_current_user)],
    _m: Annotated[object, Depends(require_membership)],
):
    """Delete all read notifications older than 30 days."""
    del _m
    cutoff = datetime.now(timezone.utc) - timedelta(days=30)
    await db.execute(
        delete(AppNotification).where(
            AppNotification.business_id == business_id,
            AppNotification.user_id == user.id,
            AppNotification.read_at <= cutoff,
        )
    )
    await db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
```

Add needed imports to `notifications.py`:
```python
from sqlalchemy import update, delete
from datetime import timedelta
from fastapi import Response
```

Also add a `kind` filter param to `list_notifications`:
```python
@router.get("", response_model=list[NotificationOut])
async def list_notifications(
    ...
    kind: str | None = Query(None),  # ADD THIS
):
    q = select(AppNotification).where(
        AppNotification.business_id == business_id,
        AppNotification.user_id == user.id,
    )
    if kind:
        q = q.where(AppNotification.kind == kind)
    q = q.order_by(AppNotification.created_at.desc()).offset(off).limit(per_page)
    ...
```

---

## FLUTTER FIX: Badge count — use unified unread count

**File:** `flutter_app/lib/features/shell/shell_screen.dart`

### Change badge source

Find line ~97:
```dart
final stockAlertN = ref.watch(stockLowCountProvider).valueOrNull ?? 0;
```

Replace with:
```dart
final stockAlertN = ref.watch(stockLowCountProvider).valueOrNull ?? 0;
final notifUnread = ref.watch(notificationsUnreadCountProvider);
// Badge = unread notifications OR stock alert count, whichever is larger
final badgeN = notifUnread > 0 ? notifUnread : stockAlertN;
```

And change the bottom bar call:
```dart
stockBadgeCount: badgeN,  // was: stockAlertN
```

This ensures the badge shows total unread notifications (which includes stock alerts).

---

## FLUTTER FIX: Notifications Page — 3-tab layout

**File:** `flutter_app/lib/features/notifications/presentation/notifications_page.dart`

Replace the entire page with a 3-tab layout:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/notifications_provider.dart';
import '../../../core/providers/home_owner_dashboard_providers.dart';
import '../../../core/providers/stock_providers.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(mergedNotificationFeedProvider);
    final stockItems = allItems
        .where((n) => n.serverKind == 'low_stock' || n.type == NotificationType.serverInApp)
        .toList();
    final purchaseItems = allItems
        .where((n) =>
            n.type == NotificationType.purchaseDue ||
            n.type == NotificationType.purchaseOverdue)
        .toList();
    final systemItems = allItems
        .where((n) =>
            n.type == NotificationType.system ||
            n.type == NotificationType.reminder)
        .toList();

    final stockBadge = stockItems.where((n) => !n.isRead).length;
    final purchaseBadge = purchaseItems.where((n) => !n.isRead).length;
    final systemBadge = systemItems.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Mark all read'),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(
              child: _TabLabel(
                label: 'Stock Alerts',
                badge: stockBadge,
              ),
            ),
            Tab(
              child: _TabLabel(
                label: 'Purchases',
                badge: purchaseBadge,
              ),
            ),
            Tab(
              child: _TabLabel(
                label: 'System',
                badge: systemBadge,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _StockAlertsTab(),                    // Tab 1: stock alerts with real per-item data
          _NotificationListTab(items: purchaseItems),  // Tab 2: purchase due/overdue
          _NotificationListTab(items: systemItems),    // Tab 3: system/reminders
        ],
      ),
    );
  }

  Future<void> _markAllRead() async {
    // Call backend mark-all-read + update local notificationsNotifier
    final notifier = ref.read(notificationsProvider.notifier);
    for (final n in ref.read(notificationsProvider)) {
      notifier.markRead(n.id);
    }
    // Also call API for server-side notifications
    final session = ref.read(sessionProvider);
    if (session != null) {
      try {
        await ref.read(hexaApiProvider).markAllNotificationsRead(
          businessId: session.primaryBusiness.id,
        );
        ref.invalidate(appNotificationsListProvider);
      } catch (_) {}
    }
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.label, required this.badge});
  final String label;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        if (badge > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge > 99 ? '99+' : '$badge',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ],
    );
  }
}
```

### Tab 1: Stock Alerts Tab — show real per-item data
```dart
class _StockAlertsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockAsync = ref.watch(stockAlertCountsProvider);
    return stockAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load stock alerts: $e')),
      data: (counts) {
        if (counts.low + counts.critical == 0) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                SizedBox(height: 12),
                Text('All stock levels are healthy', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (counts.critical > 0)
              _AlertCard(
                icon: Icons.error_outline,
                color: Colors.red,
                title: 'Critical Stock',
                subtitle: '${counts.critical} item(s) critically low — order now',
                onTap: () => context.push('/stock/low-stock'),
              ),
            if (counts.low > 0)
              _AlertCard(
                icon: Icons.warning_amber_outlined,
                color: Colors.orange,
                title: 'Low Stock',
                subtitle: '${counts.low} item(s) below reorder level',
                onTap: () => context.push('/stock/low-stock'),
              ),
          ],
        );
      },
    );
  }
}
```

### Tab 2 & 3: Generic notification list
```dart
class _NotificationListTab extends StatelessWidget {
  const _NotificationListTab({required this.items});
  final List<NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No notifications', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final n = items[i];
        return ListTile(
          dense: true,
          leading: Icon(
            n.type == NotificationType.purchaseOverdue
                ? Icons.warning_rounded
                : Icons.notifications_outlined,
            color: n.isRead ? Colors.grey : Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            n.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            n.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            if (n.actionRoute != null) context.push(n.actionRoute!);
          },
        );
      },
    );
  }
}
```

---

## FLUTTER FIX: Add markAllNotificationsRead to API client

**File:** `flutter_app/lib/core/api/hexa_api.dart` (or wherever API methods are defined)

Add:
```dart
Future<void> markAllNotificationsRead({required String businessId}) async {
  await _dio.post('/v1/businesses/$businessId/notifications/mark-all-read');
}
```

---

## VERIFICATION CHECKLIST

- [ ] Badge on bottom nav shows unified unread count, not raw stock count
- [ ] Tapping bell navigates to notifications page
- [ ] Notifications page has 3 tabs: Stock Alerts | Purchases | System
- [ ] Stock Alerts tab shows critical (red) and low (orange) count cards with "Tap to see list" navigation
- [ ] Purchases tab shows overdue/due-soon purchase alerts
- [ ] System tab shows system messages
- [ ] "Mark all read" button works and resets badge to 0
- [ ] Each tab shows "No notifications" when empty (never shows blank/frozen)
- [ ] Tab badges update when items are read
