# Harisree Warehouse Implementation Phases

Generated: 2026-05-26

This is the ordered build plan for completing the warehouse app. Execute phases in order and do not start a later data model phase before earlier stock correctness phases pass verification.

## Phase 0 — Baseline And Guardrails

- Confirm current git status, migration head, and recent pushed commits.
- Keep unrelated schema audit artifacts out of commits unless a phase explicitly needs them.
- Re-read `TASKS.md`, `docs/harisree/MASTER_REFERENCE.md`, and this file before implementation work.
- Validate Render/Vercel smoke before production QA.

## Phase 1 — Remove Unwanted SaaS Features

- Remove AI chat, voice, WhatsApp report scheduling, cloud expense, Razorpay, billing, and maintenance payment surfaces from backend and Flutter.
- Keep `admin_web/` in the repo, but do not deploy it to the client.
- Verification: backend app import, Flutter dependency resolution, and targeted searches for removed packages/routes.

## Phase 2 — Delivery Confirmation Stock Correctness

- `Purchase created` must not update stock.
- `Delivery false -> true` must apply purchase stock exactly once.
- `Delivery true -> false` must revert stock with owner confirmation.
- Staff receive and purchase detail flows must invalidate stock lists, alerts, and low-stock providers after delivery changes.

## Phase 3 — Notifications Truth

- Add backend notification mark-all-read, clear-all, and kind filtering.
- Use one truthful badge source: server unread when available, warehouse stock-alert fallback only when server unread is zero.
- Replace the notifications page with three visible tabs: Stock Alerts, Purchases, System.
- Empty states must be explicit, never blank.

## Phase 4 — Barcode Speed And Public QR

- Use faster scanner settings, shorter debounce, live camera during lookup, timeout handling, and a loading overlay.
- Add indexed public item token lookup and a no-auth branded public QR page.
- Public QR must expose only safe stock information.

## Phase 5 — PDF Reliability

- Logo loading must fail gracefully.
- Share/download/print must use a shared utility and user-visible progress/success/error feedback.
- PDF actions must not silently fail on web or mobile.

## Phase 6 — Physical Stock, Purchased Qty, Difference

- Add physical stock entry table and API.
- Extend stock list response with latest physical count, period purchased qty, and physical-minus-purchased difference.
- Mobile rows show a purchased/diff sub-row; desktop rows show separate columns.
- Physical count entry saves a separate audit record and updates current stock.

## Phase 7 — Opening Stock Setup

- Add locked opening-stock fields and APIs.
- Build setup page and stock/home banners for items missing opening stock.
- Owner can override with confirmation; staff cannot override locked values.
- Opening stock initializes current stock when current stock is zero.

## Phase 8 — Staff Quick Purchase Logs

- Add staff purchase log table and endpoints.
- Staff quick cash buys increment stock immediately because goods are already received.
- Owner can review all staff purchase logs.
- Item detail separates formal received purchase orders from staff quick logs.

## Phase 9 — Responsive Desktop And UX Audit

- Mobile: bottom navigation, single column, no overflowing table headers.
- Tablet: bottom navigation, denser two-column surfaces where useful.
- Desktop: NavigationRail, wider sheets, multi-column stock/report tables.
- Audit text overflow, keyboard safety, and bottom sheet safe areas on touched pages.

## Phase 10 — Performance

- Keep stock-critical providers alive where appropriate.
- Invalidate providers explicitly after mutations.
- Parallelize independent API calls and remove double loading.
- Validate return-navigation speed and stock search responsiveness.

## Phase 11 — Help And Backup

- Add offline Help & Guide from Settings.
- Add manual backup first, then schedule/history once platform behavior is stable.
- Backup outputs: monthly ledger PDF, stock snapshot PDF, monthly purchase summary PDF.
- Current implementation status: Help & Guide and manual ZIP backup exist; daily auto backup schedule/history remains deferred.

## Phase 12 — Sales Comparison

- Build only after critical stock, notification, scan, PDF, responsive, and performance phases pass.
- Upload ERP/Tally PDF/XLSX, extract quantities, fuzzy match catalog, compare with app stock movement, and export differences.
- Current implementation status: pasted-row fuzzy catalog comparison exists; PDF/XLSX upload, extraction, date-range movement comparison, and PDF export remain pending full scope.

## Pending Production Validation

- Run full backend tests and apply Alembic migrations against the target Supabase database.
- Run `flutter pub get`, full `flutter analyze`, and targeted widget/device checks.
- Smoke Render + Vercel, then sign out/in and test stale-session recovery.
- Device QA: barcode camera, PDF share/download/print, keyboard forms, large text, offline/sync behavior.

## Verification Gates

- Backend: import app, run focused tests, apply migrations in order, verify stock SQL/audit rows.
- Flutter: `flutter pub get`, targeted `flutter analyze`, targeted tests, full analyze before push.
- Business: purchase creation no stock change; delivery confirm adds; revoke reverts; opening stock initializes; physical count records; staff quick buy increments.
- Device: Android mobile, web mobile width, desktop width, barcode camera, PDF download/share/print, keyboard forms, overflow.

