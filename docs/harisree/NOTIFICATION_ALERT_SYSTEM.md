# Notification & Alert System (May 2026)

## Summary

Rebuilt in-app notifications so **badge count, list, and mark-read** use one merged feed. Backend uses Postgres `notifications` + centralized `notification_emitter.py` with realtime `notification.changed` events.

## P0 fixes

- Shell bottom bar badge uses `notificationsUnreadCountProvider` (same as home bell).
- Unread count = `mergedNotificationFeedProvider` unread rows (not orphan server count).
- Notifications page default tab: **All**; filters: Critical / Warehouse / Purchases / Staff / System.
- `invalidateNotificationSurfaces` on warehouse realtime + dedicated `notification.changed` handling.
- 15s boost poll on notifications page (`realtimeNotificationsBoostProvider`).

## Backend

- Migration `038_notification_alert_v2`: `priority`, `category`, `action_route`, relations, `metadata`.
- [`notification_emitter.py`](../../backend/app/services/notification_emitter.py) — dedupe, role routing, realtime publish.
- API: list filters, `GET …/summary`, `POST …/client-event` (export/sync failures).
- Hooks: low stock scan, stock variance, delivery patch, audit pending approval.

## Flutter

- [`notifications_repository.dart`](../../flutter_app/lib/features/notifications/data/notifications_repository.dart)
- [`notification_alert_card.dart`](../../flutter_app/lib/features/notifications/presentation/widgets/notification_alert_card.dart)
- Export failures reported via `purchase_export_service` → client-event API.
- Computed warehouse cards suppressed when server rows exist for same kind.

## Manual QA

- [ ] Badge on home = unread rows on All tab
- [ ] Mark all read clears badge without restart
- [ ] Stock/delivery actions create notifications within ~30s
- [ ] Export PDF failure shows friendly alert (no stack trace)
- [ ] Approval card opens stock audits

## Deferred

- FCM push, thermal printer alerts, full SSE client (boost poll used as fallback).
