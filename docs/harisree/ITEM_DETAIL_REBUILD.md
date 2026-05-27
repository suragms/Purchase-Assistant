# Item Details Page — Enterprise Rebuild (May 2026)

This document tracks the complete rebuild of the Harisree Warehouse item details screen into a **warehouse operations control surface** (not a catalog/profile page).

## Route

- Primary: `/catalog/item/:itemId` → `ItemDetailPage`
- Deep link: `/catalog/item/:itemId/ledger` (advanced statement view)
- Redirect: `/stock/intelligence/:itemId` → `ItemDetailPage`

## Core UX goals

When an owner/admin/staff opens an item, they should immediately understand:

- System stock, physical stock, and difference (with clear “missing/extra” language)
- Opening stock and purchased quantity (period)
- Reorder level + pending incoming status
- Who updated stock and when
- Operational ledger rows with before→after stock, actor, and reference
- Purchase history that is scannable on mobile (no horizontal scrolling)

## New architecture

### Orchestrator

- `flutter_app/lib/features/catalog/presentation/item_detail_page.dart`
  - Mobile: `CustomScrollView`
  - Desktop (≥1100px): left summary panel + right TabBar (`Ledger | Purchases | Analytics`)

### Providers

- `flutter_app/lib/core/providers/item_detail_providers.dart`: `itemDetailBundleProvider(itemId)` parallel fetch (catalog + stock + activity + intel purchases list)
- Uses existing stock providers:
  - `stockItemDetailProvider`
  - `stockItemIntelligenceProvider`
  - `stockItemActivityProvider`

### Key widgets

- `ItemDetailHeader`: compact header + status chip
- `ItemStockSnapshotCard`: system vs physical + diff, opening, purchased, reorder, pending incoming
- `ItemQuickActionsBar`: compact action chips (role-gated) + PDF export
- `ItemLedgerSection`: ledger-style rows from stock activity endpoint
- `ItemPurchaseHistorySection`: mobile purchase cards with range chips
- `ItemSupplierIntelligenceSection`: per-supplier rollup (client-side)
- `ItemPhysicalVerificationCard`: last physical count + verify flow (owner/admin)
- `ItemAnalyticsSection`: reorder hint (advisory) + movement baseline
- `ItemTimelineSection`: compact recent event timeline

## PDF export

- `flutter_app/lib/core/services/item_export_service.dart`
  - Uses `ensurePdfLocalesInitialized()` via `pdf_actions.dart`
  - Filename format: `{ItemSlug}_Statement_{ddMMMyyyy}.pdf`

## Backend enhancements

- `GET /v1/businesses/{id}/stock/{item_id}/activity` now supports:
  - `offset`
  - `kind` (comma-separated kinds)

## Notes

- Financial visibility is already enforced via existing role logic and server redaction (`should_redact_financials`).
- “Expected stock formula” is shown only where backend has authoritative components; client “reorder hint” is advisory.

