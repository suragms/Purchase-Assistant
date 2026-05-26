# AGENT PROMPT 09 — DESKTOP RESPONSIVE LAYOUT AND UX AUDIT

Status: implemented focused pass; device and full overflow QA still required.

## Scope

- Mobile uses bottom navigation and single-column stock rows.
- Desktop uses NavigationRail and wider stock table columns.
- Stock table shows physical, purchased, and difference fields on desktop.
- Mobile keeps purchased/difference information as a compact sub-row.

## Key Files

- `flutter_app/lib/features/shell/shell_screen.dart`
- `flutter_app/lib/features/staff/presentation/staff_shell_screen.dart`
- `flutter_app/lib/features/stock/presentation/widgets/stock_list_column_header.dart`
- `flutter_app/lib/features/stock/presentation/widgets/stock_table_row.dart`
- `flutter_app/lib/features/stock/presentation/widgets/stock_table_layout.dart`

## Verification

- Width under 600 px: bottom navigation, no desktop-only columns.
- Width 1024 px and above: NavigationRail visible.
- Long item names and table values ellipsize.
- Keyboard-safe form QA remains part of final device validation.

