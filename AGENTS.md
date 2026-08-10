# AGENTS.md — Authoritative engineering contract

**New Harisree Agency Purchase Assistant** (repo slug: PurchaseAssiastant).  
This file is the single agent contract. Roadmap: `PLAN.md`. Board: `TASKS.md`. Design: `DESIGN.md`. Deploy: `DEPLOYMENT.md`. Architecture: `ARCHITECTURE.md`.

---

## Doc ownership

| File | Owns |
|------|------|
| `AGENTS.md` | Rules, non-negotiables, lessons learned |
| `CODE_HYGIENE.md` | Search-first / no-duplication / dead-code & API audit protocols |
| `PLAN.md` | Master feature roadmap |
| `TASKS.md` | Current execution board only |
| `README.md` | Intro + setup |
| `DESIGN.md` | Design system |
| `DEPLOYMENT.md` | Deployment only |

Do not duplicate rules across `.cursorrules`, always-apply `.mdc` files, and this file.

---

## Architecture (stack truth)

- **Stack:** Flutter web/PWA (`flutter_app/`, Riverpod, GoRouter, Dio) + FastAPI (`backend/`) + PostgreSQL.
- **Purchases:** `trade_purchases` + `trade_purchase_lines` (not legacy `entries` for main flow).
- **Line money:** weight lines → `qty × kg_per_unit × landing_cost_per_kg`; else `qty × landing_cost`.
- **Supplier/broker:** header on `trade_purchases`; lines carry `catalog_item_id`.
- **Money:** Backend is authoritative; UI formats with `en_IN` / ₹ only.
- **Reports spend KPIs:** trade-backed `/v1/businesses/{id}/reports/trade-*` only.
- **API prefix:** `/v1/businesses/{business_id}/...` — add routes; do not rename without migration.
- **Sheets:** Always `showHexaBottomSheet` — never ad-hoc `showModalBottomSheet` for app chrome.
- **Design tokens:** `HexaColors` / `HexaDsColors` / `HexaDsType` / `HexaDsSpace` + root `DESIGN.md`.
- **Production web host:** `https://purchase-assiastant.vercel.app` (spelling **assiastant**).
- **API host (current):** `api.harisreeagency.online` (see `DEPLOYMENT.md`).
- Specs: `specs/`. Skills: `.cursor/skills/`. Specialist rules: `.cursor/rules/` (code-review, design-quality, figma, harisree-docs).

### Company fallback (PDF / display)

- Name: NEW HARISREE AGENCY  
- Address: 6/366A, Thrithallur, Thrissur 680619  
- Phone: 8078103800 / 7025333999  
Use `BusinessProfile.legalName` / `displayTitle` — not a non-existent `.name` field.

---

## Workflow

- One phase at a time — finish and validate before the next.
- Data before UI — wire providers/APIs first; then layout.
- Do not guess — inspect the repo or ask; keep existing behaviour when unsure.
- Do not add features outside the active `TASKS.md` / approved plan phase.
- Do not break `TradePurchase` create/update payloads or backend validation.
- After substantive edits: `flutter analyze`; `pytest` when backend touched.
- Never commit secrets. Never push/deploy/migrate production without explicit approval.
- Do not trust an agent summary — verify with `git diff` / `git diff --stat`.

---

## Evidence protocol

| Label | Meaning |
|---|---|
| `VERIFIED_CODE` | Confirmed in current source |
| `VERIFIED_TEST` | Confirmed by a test that was run |
| `VERIFIED_RUNTIME` | Confirmed against a running environment |
| `DOCUMENTATION_CLAIM` | Stated in a doc; not independently verified |
| `ASSUMPTION` | Temporary; must not ship without approval |
| `UNKNOWN/BLOCKED` | Missing input — stop and ask |

Never invent endpoints, fields, screens, permissions, or financial numbers.

---

## Non-negotiables

- **AI does not finalize purchases** — draft + wizard + explicit confirm + backend totals.
- **Landing cost** is always manual at entry.
- **No client-side financial truth** — Flutter/admin render formatted values only.
- **Preview → confirm** before persisting purchases.
- Auth/RBAC enforced server-side, membership-scoped.
- No parallel navigation, state systems, or design systems without approval.
- AI may suggest/parse within schema; AI is never source of truth for stock, price, tax, totals, profit, permissions, or workflow state.

---

## Flutter SSOT and protected symbols

- Purchase draft: `purchaseDraftProvider` (`lib/features/purchase/state/purchase_draft_provider.dart`)
- No `setState` for core purchase totals (UI-only state is OK)
- Protected: `purchaseDraftProvider`, `purchaseTotalsProvider`, `purchaseStrictBreakdownProvider`, `tradePurchasesListProvider`, `tradePurchasesParsedProvider`, `suppliersListProvider`, `brokersListProvider`, stock list providers
- Canonical catalog create: `CatalogItemCreatePage` + `/catalog/quick-add`
- Canonical supplier **create**: `SupplierCreateSimple`; **edit**: `SupplierCreateWizardPage`
- Canonical purchase line UI: `PurchaseItemEntrySheet` + wizard — extend, do not duplicate

---

## ALWAYS

- Pre-write search gate: before any new file/provider/widget/API, follow `CODE_HYGIENE.md` (grep existing owners first; no `_v2`/`_new` forks)
- HapticFeedback: selection on main nav; medium on save where appropriate
- `ref.invalidate(...)` after mutations that affect lists, KPIs, or reports
- Loading: skeletons / section `LinearProgressIndicator` — not blocking full-screen spinners on shell tabs
- Confirm before delete or discard with unsaved changes
- Search: ≥1 character; debounce ~300ms on heavy queries
- Home/reports local lists: filter loaded data locally; stock list may debounce server query
- Float near-integers: `(n - n.roundToDouble()).abs() < 0.001`
- `ref.listen` + `setState`: always `WidgetsBinding.instance.addPostFrameCallback`
- After stock patch: invalidate `stockListProvider` (and related audit/period providers as applicable)
- Empty page = icon + message + action; never blank white
- No section header (Today/Earlier) without items beneath
- Sub-page back: `context.pop()` in shell routes
- Touch targets ≥ 48×48 dp
- TabBar with ≥3 tabs: `isScrollable: true`
- Category filter chips: `Wrap`, not horizontal `SingleChildScrollView`
- Keep-alive `/health` every 10 minutes after session bootstrap
- Money UI: `NumberFormat.currency(locale: 'en_IN', symbol: '₹', ...)`

### Role display

- OWNER only: ₹ prices, rates, profit, UPI/payment, financial totals
- OWNER + MANAGER: purchase history, reports, contacts, supplier rates
- ALL roles: stock quantities (no prices), item names, categories
- Settings maintenance payment: owner only

---

## NEVER

- Show `DioException`, HTTP codes, or stacks to users (debug-only in `kDebugMode`)
- HSN mandatory on catalog create
- Snackbars for field validation (use inline `errorText`)
- Emoji in PDF body
- Duplicate purchase/item entry flows
- Entry-only queries for trade spend reports
- Auto-save purchases
- `setState` directly inside `ref.listen`
- Horizontal filter-chip scroll rows for 5+ options (use sheet + Wrap)
- Four columns in a mobile list row
- `Navigator.pop` on shell routes when `context.pop()` is required
- Nested `HexaResponsiveSheetViewport` under `showHexaBottomSheet`
- Align + maxWidth-only around desktop scrollables (bind height too)

---

## Lessons learned (real bugs — do not remove, only add)

### Home dashboard failure banner must be rendered
**Rule:** If `HomeDashboardPayload.banner` is set, UI must show it (with Retry). Do not hide empty KPIs without surfacing the failure string.
**Why:** Empty-DB heuristics hid cold API failures → silent blank Home totals.
**Check:** `HomeSessionDataBanner` reads `snapshot.banner`; grep UI for unused `banner` fields.

### Verify agent edits actually persisted
**Rule:** After any agent run, run `git diff` / `git diff --stat` before trusting the agent's summary.
**Why:** Agents have reported complete work when edits never wrote to disk.
**Check:** Expected files appear in `git diff --stat`; open changed lines and confirm.

### Desktop sheet zero-height blank
**Rule:** On desktop, `showHexaBottomSheet(compact: true)` must shrink-wrap; `compact: false` needs fixed dialog height. Never nest a second `HexaResponsiveSheetViewport` inside a sheet already hosted by `showHexaBottomSheet`.
**Why:** Non-shrink-wrapping scroll under Dialog collapsed to blank white panels.
**Check:** `sheet_compact_height_test.dart`; no nested viewport under `showHexaBottomSheet`.

### Do not remove HTML splash on empty first Flutter frame
**Rule:** Call `removeBootOverlayIfPresent` only after bootstrap spinner, error UI, or `HexaApp` is in the tree — never from `initState` alone before `_prepare` paints (UID-001).
**Why:** Early overlay removal left gray body while CanvasKit/session started.
**Check:** `main.dart` `_scheduleBootOverlayRelease` from bootstrap/error/app mount only.

### Align + maxWidth-only blanks ListView
**Rule:** Desktop master-detail panes must bind width **and** height (`LayoutBuilder` + `SizedBox(height: constraints.maxHeight)`).
**Why:** Align-only width left height unbounded → blank CanvasKit panes.
**Check:** Stock and purchase desktop detail panes use height-bound `SizedBox` inside `Expanded`.

### Wrong production web host
**Rule:** Bookmark/deploy only `purchase-assiastant.vercel.app`.
**Why:** Lookalike hosts are different projects / 404 for `main.dart.js`.
**Check:** Canonical host loads Flutter; wrong host shows guidance.

### Never leak API errors to users
**Rule:** Use `FriendlyLoadError` / `HexaErrorCard` / `userFacingError`.
**Why:** Raw Dio messages broke warehouse-staff trust.
**Check:** Grep touched UI for `DioException` in SnackBars.

### Trade purchases vs Entry analytics
**Rule:** Trade spend KPIs/tables use trade-backed endpoints only.
**Why:** Mixed sources made Home/Reports disagree with purchase history.
**Check:** Paths call `/reports/trade-*` or trade providers.

### Do not call primaryBusiness list `.first` without empty guard
**Rule:** After login/session refresh, never assume `businesses.first` exists.
**Why:** Empty membership blanks the whole shell on web.
**Check:** Recoverable UI when business list is empty.

### Reports filters must use showHexaBottomSheet on phone
**Rule:** Mobile Reports filters via `showHexaBottomSheet(compact: false)` + explicit height.
**Why:** Ad-hoc drag sheets broke the blank-sheet host contract.
**Check:** No `showModalBottomSheet` under `features/` for filter chrome.

### Nested HexaResponsiveSheetViewport under showHexaBottomSheet
**Rule:** Never wrap sheet *body* in `HexaResponsiveSheetViewport` when already hosted by `showHexaBottomSheet`.
**Why:** Double viewport produced blank/collapse on Flutter web.
**Check:** Prefer `Column(mainAxisSize: min)` or explicit `SizedBox(height:)`.

### Hexa sheet host owns keyboard inset; compact modes differ
**Rule:** Bodies under `showHexaBottomSheet` must not add `MediaQuery.viewInsets` padding — `HexaResponsiveSheetViewport` already lifts once. Phone `compact: true` = maxHeight + **shrinkWrap** `ListView` (hugs short forms; scrolls when tall); `compact: false` = fixed height, **no** outer scroll (body owns `ListView`/`Expanded`). Never use a non-shrinkWrap `SingleChildScrollView` under compact maxHeight — it expands to a blank full-height sheet.
**Why:** Double insets over-lift forms; outer expanding SCSV caused stock-update blank white sheets; outer SCSV around fixed-height filter/picker sheets causes nested-scroll bounce.
**Check:** `sheet_compact_height_test.dart` (hug-height + keyboard + compact:false); grep sheet bodies for `viewInsetsOf` under Hexa host.

### Purchase history empty off History branch is intentional
**Rule:** Do not “fix” empty `tradePurchasesListProvider` when shell branch is not History (unless fullscreen search).
**Why:** IndexedStack keeps tabs alive; empty list ≠ empty KPI.
**Check:** History tab + fullscreen search load; KPIs use separate providers.

### Reports shell must stretch + bind height
**Rule:** Reports desktop `Row` uses `CrossAxisAlignment.stretch` and body `LayoutBuilder` + height bind.
**Why:** Unbounded height left main pane at 0 height.
**Check:** `reports_shell_page.dart` (≥1024).

---

## Verification

After touching code: `pytest` (backend), `flutter analyze` / targeted `flutter test`.  
Report exact commands and results. Do not claim “works” without running them.

## Stop conditions

Stop and ask when: requirement conflicts with data ownership; destructive migration; missing external contract; unclear role/permission; user-facing number cannot be traced to backend; AI would affect authoritative business value; rename/delete of routes/tables without approval.
