# Purchase Order Detail — Rebuild (May 2026)

## Summary

Purchase order detail (`purchase_detail_page.dart`) was rebuilt for warehouse operations: reliable PDF export/share/print, no duplicate actions, compact layout, and desktop split pane.

## P0 — Export reliability

- **`pdf_locale.dart`** — `ensurePdfLocalesInitialized()` for `en_IN` / `en` (fixes `LocaleDataException` on PDF paths).
- **`main.dart`** — locale init during bootstrap.
- **`purchase_export_service.dart`** — validation + `exportSharePurchase` / `exportPrintPurchase` / `exportDownloadPurchase` with friendly failure messages (no raw exceptions in UI).
- **`buildPurchaseSharePdfFileName`** — `PO_{SUPPLIER}_{DD}_{MMM}_{YYYY}.pdf` (e.g. `PO_AMBAL_MODERN_RICE_MILL_25_MAY_2026.pdf`).

## UI

| Widget | Role |
|--------|------|
| `purchase_detail_action_bar.dart` | Mark as Paid + horizontal scroll: Edit, Export PDF, Share, Print |
| `purchase_detail_header.dart` | Supplier, broker, date, status pill |
| `purchase_detail_summary_strip.dart` | Amount \| Weight \| Profit |
| `purchase_detail_delivery_banner.dart` | Pending / received + Mark Received |
| `purchase_detail_line_row.dart` | Compact bordered line rows |

- AppBar: back, title, delete overflow only (document actions in bottom bar).
- Desktop (≥1100px): ~58% main scroll + ~42% charges/balance panel.
- Staff: `hideFinancials` hides summary, lines financials, and action bar (unchanged contract).

## Storage (mobile)

- **`pdf_download_io.dart`** — saves under `warehouse_exports/{year}/{month}/{supplier_slug}/` in app documents when native download succeeds; web unchanged.

## Tests

- `purchase_export_locale_test.dart`
- `purchase_export_filename_test.dart`
- `purchase_export_validation_test.dart`
- `purchase_detail_action_bar_test.dart`
- `purchase_pdf_search_parity_test.dart` — `setUpAll` locale init

## Manual QA

- [ ] 320px: action labels not truncated; horizontal scroll for secondary actions
- [ ] Share / Export PDF / Print: no locale exception
- [ ] Filename `PO_SUPPLIER_25_MAY_2026.pdf`
- [ ] Mark Received → stock invalidation
- [ ] Mark as Paid → status + ledger
- [ ] Staff: no financials / no export bar
- [ ] Desktop ≥1100px: split pane readable

## Deferred (P2)

- Thermal roll PDF (`PdfPageFormat.roll80`)
- Export audit API (`export|print|share` events)
