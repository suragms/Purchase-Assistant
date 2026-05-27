# Owner & Admin Dashboard Rebuild

Purchase-first warehouse control center on Flutter home (`HomePage`).

## Access

- `sessionHasOwnerDashboard` in `lib/core/auth/dashboard_role.dart` — `owner`, `admin`, `manager`, `super_admin`.
- Staff continues on `staff_home_page.dart`.

## Section order (owner/admin)

1. `HomeCompactHeader` — role chip, sync, notifications, settings (48dp)
2. `HomeLiveStatusBar`
3. `ResumePurchaseDraftBanner` + conditional `HomeSessionDataBanner` / opening stock banner
4. `HomeCriticalAlertsGrid` — 2-column priority cards (non-zero only)
5. **Sticky** `HomePeriodFilterRow` via `HomeStickyPeriodHeader`
6. `HomePurchaseControlCenter` — amount, bills, deliveries, units, quick actions
7. `HomeWarehouseHealthCard` — GOOD / WARNING / CRITICAL (`warehouse_health.dart`)
8. `HomeWarehouseActivityFeed` — up to 15 rows from `homeRecentActivityFeedProvider`
9. `HomeStaffOperationsPanel` — pending approvals + recent staff stock actions
10. `HomeOwnerQuickActions` — 7 actions (no scan in primary row)
11. `HomeLowStockSection`

## Removed from home (consolidated)

- `HomeMultiAlertStrip`, `HomeContactsQuickRow`, `HomePurchaseStatsCard`
- `HomeStockTotalsCard`, `HomeAnalyticsComparisonStrip`
- `HomeRecentChangesSection`, `HomeStockMovementSection`, `HomeStockAuditStrip`

## Providers

- KPIs: `homeDashboardDataProvider`, `warehouseAlertsProvider`, `stockAlertCountsProvider`
- Activity: `homeRecentActivityFeedProvider` (cap 15)
- Refresh: pull-to-refresh, 30s home poll, `realtimeInvalidationProvider` tick

## Backend summary fields (`reportsHomeOverview` / trade snapshot)

- `supplier_count`, `broker_count`, `received_delivery_count`, `negative_stock_count`

## Tests

- `flutter_app/test/home_warehouse_health_test.dart`

## QA

- Default period **Month**; chips sticky on scroll
- Bell badge matches notifications unread (All tab)
- Critical cards hidden at count 0
- Admin sees same dashboard as owner
