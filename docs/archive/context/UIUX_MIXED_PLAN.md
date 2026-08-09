# UIUX_MIXED_PLAN.md — Current and Future Page Plan

## Scope and evidence rule

This is a **planning document**, not proof that every page or future feature exists. Current pages must be enumerated from the actual GoRouter source, feature files, tests, and API consumers. Future pages must be labelled `PROPOSED` until a supplied wireframe, business requirement, or approved feature brief exists.

Do not invent a screen, workflow, field, chart, color, copy, endpoint, or interaction. If screenshots/wireframes are not available, compare against the repository’s actual design tokens and mark visual comparison `BLOCKED — DESIGN ASSET MISSING`.

## Current page inventory protocol

Generate and maintain this table from the actual repository:

| Page ID | Route | Source file | Role | Purpose | API calls | State/provider | Backend/service | Status | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| AUTH-LOGIN | `/login` | actual router/page path | public | Sign in | actual calls only | session/auth | auth router | `VERIFY` | code/test |
| AUTH-FORGOT | `/forgot-password` | actual source | public | Password recovery | actual calls only | auth state | auth router | `VERIFY` | code/test |
| AUTH-RESET | `/reset-password` | actual source | public | Password reset | actual calls only | auth state | auth router | `VERIFY` | code/test |
| HOME | actual route | actual source | owner/manager/staff | Operational overview | actual calls only | home providers | dashboard/home routes | `VERIFY` | code/test |
| STOCK | `/stock` | actual source | permitted staff | Inventory list/detail | actual calls only | stock providers | stock services | `VERIFY` | code/test |
| REPORTS | `/reports` | actual source | owner/manager | Reports and drill-down | actual calls only | report providers | trade report routes | `VERIFY` | code/test |
| PURCHASE | `/purchase` | actual source | permitted staff | Trade purchase workflow | actual calls only | purchase draft/providers | trade purchase services | `VERIFY` | code/test |
| SEARCH | `/search` | actual source | authenticated | Unified search | actual calls only | search state | search route | `VERIFY` | code/test |
| CATALOG | actual route | actual source | permitted staff | Product master | actual calls only | catalog providers | catalog router | `VERIFY` | code/test |
| BARCODE | actual route | actual source | staff | Barcode lookup/print/assign | actual calls only | barcode state | catalog/media routes | `VERIFY` | code/test |
| CONTACTS | actual route | actual source | permitted staff | Customer/contact operations | actual calls only | contacts state | contacts router | `VERIFY` | code/test |
| SUPPLIERS | actual route | actual source | permitted staff | Supplier operations | actual calls only | supplier state | contacts/catalog routes | `VERIFY` | code/test |
| BROKERS | actual route | actual source | permitted staff | Broker operations | actual calls only | broker state | contacts routes | `VERIFY` | code/test |
| STAFF | actual route | actual source | owner/manager | Users/tasks/activity | actual calls only | staff state | users/operations routes | `VERIFY` | code/test |
| OPERATIONS | actual route | actual source | staff/manager | Checklists/alerts/work | actual calls only | operations state | operations/notifications | `VERIFY` | code/test |
| NOTIFICATIONS | actual route | actual source | authenticated | Alerts/unread | actual calls only | notification state | notifications router | `VERIFY` | code/test |
| SETTINGS | actual route | actual source | permitted roles | Profile/business/backup | actual calls only | settings state | me/exports/business routes | `VERIFY` | code/test |

The rows above are an audit scaffold. Replace `actual route`, `actual source`, and `VERIFY` values using code evidence. Do not treat the scaffold as a claim that every route is present.

## Page-state contract

Every current and proposed page must specify all states below. A page without a state is incomplete:

| State | Required behavior |
|---|---|
| Initial/loading | Show a stable skeleton or progress state without layout collapse. |
| Success | Show the verified server result and freshness/source where relevant. |
| Empty | Explain why empty and provide the next valid action; never show a blank page. |
| Validation error | Preserve entered values and place the message near the field. |
| Auth error | Refresh/re-authenticate through the existing session path; avoid loops. |
| Permission denied | Explain the missing access without leaking protected data. |
| Not found | Provide a safe recovery route; do not crash the shell. |
| Network timeout | Offer bounded retry and preserve user input/state. |
| Server error | Use friendly existing error components; do not expose raw exceptions. |
| Offline/degraded | Identify stale/local data and prevent unsafe authoritative writes. |
| Conflict | Show server value, local value, reason, and explicit resolution. |
| Destructive action | Show impact, confirmation, and reversal/cancellation path where supported. |
| Success after mutation | Reconcile with server; do not rely on an optimistic value indefinitely. |

## Design-system contract

Use only the repository’s actual design tokens unless a new token is approved first. Current documented/source values include deep teal primary `#0E4F46`, secondary `#065F4F`, accent `#159A8A`, restrained gold `#D4AF37`, warm off-white background `#F7F9F6`, white cards, Plus Jakarta Sans, 8px spacing, tokenized radii, and 48px minimum touch targets. Verify every value against `DESIGN.md`, `hexa_colors.dart`, `hexa_ds_tokens.dart`, and theme code before use.

Use existing page shells, form rows, table/list components, status badges, report cards, and `showHexaBottomSheet`. Do not add ad-hoc colors, inline typography, arbitrary radii, or a second modal-sheet system. Do not use gold as a general highlight; reserve it for verified profit/premium signals.

## Responsive device contract

The source responsive implementation defines compact phone below 360px, phone below 600px, tablet/rail ranges, desktop at or above 1024px, and ultra-wide at or above 1600px. Use the code tokens as truth when documentation and implementation differ.

| Width class | Layout rule | UX obligation |
|---|---|---|
| Compact phone <360 | Single column, stacked forms, short labels | No horizontal overflow; controls remain reachable |
| Phone <600 | Bottom navigation, cards/list fallback, full-width actions | Touch-first, preserved input, sheets with safe height |
| Tablet 600–1023 | Compact rail, adaptable two-column forms where safe | Avoid desktop density that makes fields unusable |
| Desktop ≥1024 | Rail/sidebar, master-detail, dense tables/KPI grids | Use bounded width and height; no blank panes |
| Ultra-wide ≥1600 | Wider gutters/content bands, same density | Do not stretch cards/forms edge-to-edge |

## Desktop page plan

Desktop is a workbench for warehouse and management users. Use the existing rail/sidebar and bounded content primitives. Tables may be dense, but filters, status, source/freshness, and primary actions must remain visible.

| Surface | Desktop behavior | Required checks |
|---|---|---|
| Shell | Stable rail/sidebar and top-level route state | Hard reload, deep link, empty membership, unauthorized route |
| Home | KPI/exception overview with bounded content | KPI source, freshness, drill-through, no invented metrics |
| Stock | Dense list + detail pane | Height-bound panes, 409 conflict, pagination, filters |
| Purchase | Multi-step wizard + review/tally | Server preview/validate, totals, confirmation, rollback |
| Reports | KPI → filter → drill → transaction | Query/date/source reconciliation |
| Catalog | Search/list/detail/variant editing | Debounce, paging, duplicate detection, permission |
| Barcode | Lookup/print/assign/create fallback | Camera/permission failure, manual fallback |
| Staff/operations | Queue/assignment/SLA emphasis | Role filtering, overdue and unassigned states |
| Settings | Bounded forms and export/backup controls | Sensitive permissions, confirmations, audit events |

## Mobile page plan

Mobile is not a smaller desktop. Prioritize one-handed operations, focused decisions, clear unit/value labels, and reachable actions. At 360–430px, convert tables to cards or prioritized rows, move filters into safe sheets, stack form fields, and keep submit/cancel actions reachable without dangerous accidental taps.

| Surface | Mobile behavior | Required checks |
|---|---|---|
| Shell | Bottom navigation and route-preserving stack | Back behavior, deep link, refresh, session expiry |
| Home | Exception-first cards; no dashboard sprawl | Readable numbers, drill-through, loading/empty states |
| Stock | Focused item/count card | Unit visible, conflict resolution, offline guard |
| Purchase | Step-by-step wizard with sticky actions | Keyboard, validation, draft preservation, duplicate submit |
| Reports | Summary cards + filter sheet + drill page | No clipped charts, accessible values, export permissions |
| Catalog/search | Debounced search + result cards | Cancel stale calls, no-results guidance |
| Barcode | Camera permission and manual fallback | Unsupported browser/device behavior |
| Staff/tasks | Simple status/assignment controls | One-handed operation, SLA visibility |
| Settings | Single-column forms | Unsaved-change warning, secure export/backup |

## Current page review order

Review current pages in this order because defects here affect all workflows:

1. App bootstrap, splash, shell, session restore, business selection, and error boundary.
2. Login, forgot password, reset password, and protected-route behavior.
3. Home/dashboard and notification/operations surfaces.
4. Stock list/detail, physical count, opening stock, audit, low stock, reorder, and staff stock.
5. Purchase wizard, draft, preview/tally, confirmation, history, detail, delivery, payment, damage, and lifecycle states.
6. Catalog, item detail, categories, variants, barcode lookup/print/assign, and search.
7. Reports shell, filters, overview, purchases, stock, items, supplier/category breakdowns, and drill-down pages.
8. Contacts, suppliers, brokers, staff, settings, profile, business profile, user management, backup/export, and help.

For each page, fill the page audit table from code. A page with no test or no API/DB evidence remains `UNKNOWN` even if the widget renders.

## Future-feature screen plans — proposed only

### P1: Inbound WhatsApp order inbox

`PROBLEM → multi-number customer messages are not proven as a complete current workflow.`  
`FLOW → webhook verification → deduplication → conversation/customer match → language normalization → draft lines → confidence review → staff assignment → approval → order → acknowledgement.`  
`SCREENS → Inbox, Conversation, Draft Order Review, Assignment/SLA, Integration Status.`  
`GUARDS → no silent approval, no unrestricted AI/DB access, idempotent webhook, retry/dead-letter, attachment policy.`

### P1: AI Malayalam/Manglish/English order understanding

`PROBLEM → manual interpretation of mixed-language orders.`  
`FLOW → raw message preserved → structured parse → product/alias candidates → unit/quantity ambiguity → confidence threshold → human approval.`  
`SCREENS → AI Review Queue, Line Ambiguity Drawer, Alias Approval.`  
`GUARDS → backend owns price/stock/tax/totals; model/version/confidence logged; fallback when AI unavailable.`

### P1: ERP adapter and reconciliation

`PROBLEM → ERP integration is not proven complete in the archive.`  
`FLOW → local event → mapping → idempotency → outbound sync → retry/backoff → dead letter → reconciliation/replay.`  
`SCREENS → Integration Status, Failed Syncs, Mapping/Field Ownership, Reconciliation Detail.`  
`GUARDS → provider-neutral contract, system-of-record decision, no duplicate external records.`

### P1: Staff SLA and missed-order management

`PROBLEM → operational work can be missed or delayed.`  
`FLOW → event/task creation → assignment → due time → escalation → resolution → audit.`  
`SCREENS → Work Queue, Task Detail, SLA/Overdue View, Staff Workload.`  
`GUARDS → permission-scoped visibility, idempotent notifications, no unsupported productivity scoring.`

### P1: Customer 360 and payment/outstanding intelligence

`PROBLEM → customer context and balances need a single verified view.`  
`FLOW → customer identity → orders/interactions → statement → ageing → payment/correction → audit.`  
`SCREENS → Customer 360, Statement, Payment Allocation, Dispute/Correction.`  
`GUARDS → backend formulas, role-protected financial data, reproducible date/currency rules.`

### P1: Stock/supplier intelligence and management briefing

`PROBLEM → managers need actionable exceptions, not speculative AI dashboards.`  
`FLOW → verified ledger/report data → threshold/metric → explanation → source transactions → action.`  
`SCREENS → Stock Risk, Supplier Reliability, KPI Drill-through, Daily Briefing.`  
`GUARDS → every metric has formula/source/freshness; AI explains or summarizes only verified data.`

## UI acceptance checklist

A current or future page is visually accepted only when:

- It uses the approved design tokens and existing components.
- It has all required state variants.
- It works at compact phone, phone, tablet, desktop, and ultra-wide widths relevant to the flow.
- It has no horizontal overflow, zero-height sheet, clipped dialog, blank CanvasKit pane, or unbounded scroll region.
- It preserves input across validation, retry, refresh, and navigation conditions where safe.
- It respects role/permission and does not leak protected values.
- It distinguishes AI suggestion from approved system value.
- It provides keyboard/focus/semantic labels and does not rely on color alone.
- Its API/DB data source and test evidence are recorded.
- Its screenshot comparison is labelled `VERIFIED`, `BLOCKED`, or `NOT APPLICABLE`; never implied.

## Anti-slop checklist

Reject any UI or feature proposal that contains: invented KPIs, fake data, generic chatbot copy, decorative gradients not in tokens, arbitrary animations, unexplained icons, duplicate pages, duplicate APIs, untraceable numbers, AI-generated business rules, or “smart” features with no owner, evidence, permission, API, DB, test, and rollback path.
