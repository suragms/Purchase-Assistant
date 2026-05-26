# AGENT PROMPT 13 — SALES COMPARISON REPORT

Status: first-pass pasted-row comparison is implemented. Full PDF/XLSX upload is pending.

## Implemented First Pass

- Reports page links to Sales comparison.
- User can paste rows as `item name, qty, amount`.
- Backend fuzzy matches pasted item names against catalog items.
- Flutter page shows matched, review, and missing counts.
- CSV copy is available for review/export.

## Key Files

- `backend/app/routers/reports_trade.py`
- `flutter_app/lib/features/reports/presentation/sales_comparison_page.dart`
- `flutter_app/lib/features/reports/presentation/reports_page.dart`
- `flutter_app/lib/core/api/hexa_api.dart`

## Pending Full Scope

- PDF upload and extraction.
- XLSX upload and header detection.
- Compare external sales quantity against app stock movement for a date range.
- PDF export of comparison table.

## Verification

- Pasted sales rows produce catalog matches without auth or server errors.
- Low-confidence rows appear as review or missing.
- CSV copy includes source, match, status, score, qty, and amount.

