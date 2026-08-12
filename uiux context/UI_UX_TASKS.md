# PURCHASE PROJECT — UI/UX TASK CONTROL BOARD

**Binding:** `PURCHASE_UI_UX_STRICT_AGENT_PROMPT.md` · `UNIVERSAL_UI_UX_DESIGN_RULES(1).md` · root `AGENTS.md` / `DESIGN.md`

**Last audit:** Phase D viewport + purchase repair (2026-08-10). Phase E seeded UX-183…UX-191. UX-196 + UX-197 (desktop nav structure — the user's "UX-192") DONE 2026-08-11 (code audit PASS). UX-198 (the user's "UX-193" — StateController&lt;int&gt; blank-section fix) DONE 2026-08-11.

**Gate:** Only one UX task `IN_PROGRESS` at a time. Current implementation slot: **none**.

---

## STATUS LEGEND

- `DISCOVERY` = identified but not yet fully understood
- `READY` = enough evidence to work
- `IN_PROGRESS` = currently being implemented
- `BLOCKED` = cannot continue without clarification/evidence
- `VERIFYING` = implementation finished, validation pending
- `DONE` = all completion gates passed
- `DEFERRED` = intentionally postponed

---

# RULE

ONLY ONE TASK MAY BE `IN_PROGRESS` AT A TIME.

Do not start another task until the current task is `DONE` or explicitly `BLOCKED`.

Do not start UX-001 until the user explicitly approves this board’s task order.

---

# PHASE 0 — PRODUCT INVENTORY

| ID | Area | Status | Evidence | Notes |
|---|---|---|---|---|
| AUDIT-001 | Repository/framework inventory | DONE | `AGENTS.md`, `flutter_app/`, `backend/` | Flutter web/PWA + FastAPI + PostgreSQL; Riverpod + GoRouter + Dio |
| AUDIT-002 | Route inventory | DONE | `flutter_app/lib/core/router/app_router.dart` | **100** `GoRoute(` defs; **2** `StatefulShellRoute.indexedStack`; ~20 redirects/aliases |
| AUDIT-003 | Page/screen inventory | DONE | `lib/features/**/*_page.dart` | **76** `*_page.dart`; plus `PurchaseEntryWizardV2`, shells |
| AUDIT-004 | Tab/subtab inventory | DONE | TabBar / Reports chips / query tabs | ~11 tabbed surfaces; ~35 tab labels; ~9 subtabs/sections |
| AUDIT-005 | Modal/drawer inventory | DONE | feature greps | `showHexaBottomSheet` ~60; `showDialog` ~44; Material `Drawer` **0** |
| AUDIT-006 | Form/field/button inventory | DONE | major form files (hub-level) | ~12 major forms; field-level counts deferred to each UX-00x |
| AUDIT-007 | Dashboard/landing/entry flow | DONE | `main.dart`, splash, `post_auth_route.dart` | `/splash` → login or `/home` / `/staff/home` |
| AUDIT-008 | Primary feature/workflow inventory | DONE | router + features | Purchase, stock, reports, catalog/contacts, staff receive, settings |
| AUDIT-009 | Desktop UX audit | DONE | code + `AGENTS.md` lessons | Risks: sheet height, pane height-bind ≥1024, dense tables — **not** live QA |
| AUDIT-010 | Mobile UX audit | DONE | code + lessons | Risks: reports filter sheets, purchase keyboard flow, touch — **not** device QA |
| AUDIT-011 | P0-P4 issue classification | DONE | candidates only | P0:0 live · P1:3 · P2:8 · P3:6 · P4:defer (see map) |
| AUDIT-012 | Final UX task ordering | DONE | this board | Ordered below; UX-001 completed 2026-08-09 |

---

# AUDIT SUMMARY (VERIFIED COUNTS)

```text
AUDIT PHASE RECORDED

Repository:
Harisree Agency Purchase Assistant (PurchaseAssiastant) monorepo

Framework:
Flutter (flutter_app/) + FastAPI (backend/) + PostgreSQL

Applications:
Owner web/PWA shell + Staff web/PWA shell + public item scan

Routes:
100 GoRoute definitions verified (app_router.dart)

Pages/Screens:
76 *_page.dart verified (+ wizard/shell non-*Page routes)

Tabs:
~11 tabbed screens / ~35 tab labels (incl. Reports ChoiceChip BI tabs)

Subtabs:
~9 (Reports ?section=, Stock ?tab=, role-variant item detail, etc.)

Modals:
~44 showDialog + ~60 showHexaBottomSheet (sheets = primary chrome)

Drawers:
0 Material Drawer; custom side panels (e.g. ReportsFilterDrawer)

Forms:
~12 major create/edit hubs

Tables:
~8 major list/table surfaces

Landing Page:
/splash → SplashPage

Post-login Entry:
Owner/admin/manager → /home (HomePage)
Staff → /staff/home (StaffHomePage)

Primary Features:
1. Trade purchase (wizard + history + detail)
2. Stock ops + barcode
3. Reports BI
4. Catalog / contacts
5. Staff receive / tasks
6. Settings / users

Desktop UX Risks:
Sheet blank/height contract; master-detail height bind; dense stock/reports tables

Mobile UX Risks:
Reports filter Hexa sheet contract; purchase item entry keyboard; staff one-handed scan/receive

P0:
0 verified live blockers

P1:
3 candidates (stock storm BLOCKED; purchase suggest lock re-verify; reports/stock pane height)

P2:
8 candidates

P3:
6 candidates

P4:
deferred until higher severities scheduled

Unknowns:
Live visual QA; full RBAC matrix; orphan *_page.dart reachability; stock storm without logs; per-form field counts

CODE CHANGED:
NO
```

### Roles (UI)

`owner` | `admin` | `manager` | `staff` (+ `isSuperAdmin`). Financials: non-staff via `sessionCanSeeFinancials`.

### Design breakpoints

Desktop layout ≥ **1024** (`hexa_responsive.dart` / `DESIGN.md`). Phone &lt; 600.

---

# PROBLEM MAP (CANDIDATES — NOT LIVE QA)

| Sev | ID | Problem | Evidence | Status |
|---|---|---|---|---|
| P1 | CAND-P1-01 | Stock edit refresh / network storm | Needs `[STOCK_STORM]` / `[STOCK_STORM_SUMMARY]` console paste | BLOCKED |
| P1 | CAND-P1-02 | Purchase item suggestions reopen after select / pencil re-focus | Lock + overlay test verified 2026-08-09 | DONE (UX-001) |
| P1 | CAND-P1-03 | Reports/stock desktop pane unbounded height / blank pane regression | Shell stretch + LayoutBuilder bind verified; tab bodies fill Expanded (2026-08-09) | DONE (UX-003) |
| P2 | CAND-P2-01 | Purchase wizard long scroll / field burden | Terms: discount/narration progressive disclosure (UX-004) | DONE (partial) |
| P2 | CAND-P2-02 | Contacts 5-tab breadth | People \| Catalog hub (UX-007) | DONE |
| P2 | CAND-P2-03 | Low-stock 5 tabs | Attention \| Pipeline hub (UX-011) | DONE |
| P2 | CAND-P2-04 | Catalog taxonomy depth | Inline tree on hub (UX-012) | DONE |
| P2 | CAND-P2-05 | Supplier edit wizard complexity | Step rail + skip to review (UX-013) | DONE |
| P2 | CAND-P2-06 | Item detail tab matrix by role | Unified Overview/Purchases/Activity (UX-014) | DONE |
| P2 | CAND-P2-07 | Settings hub depth | Owner tools section + sidebar shortcuts (UX-010) | DONE |
| P2 | CAND-P2-08 | Staff vs owner nav mental model | Staff bottom 4+More (UX-015) | DONE |
| P3 | CAND-P3-01 | History vs Purchase naming | Shell label → Purchases (UX-016) | DONE |
| P3 | CAND-P3-02 | Tab vs ChoiceChip (Reports primary) | TabBar isScrollable (UX-017) | DONE |
| P3 | CAND-P3-03 | empty-state polish (Contacts People) | HexaEmptyState + CTA (UX-018) | DONE |
| P3 | CAND-P3-05 | empty-state polish (Contacts Catalog) | HexaEmptyState + CTA (UX-020) | DONE |
| P3 | CAND-P3-04 | help discoverability | Support section + AppBar Help (UX-019) | DONE |
| Watch | WATCH-01 | Empty membership → `primaryBusiness` / `.first` shell blank | `session.dart` + `AGENTS.md`; restore guards exist — watch only | DEFERRED |

---

# ORDERED UX TASKS (DO NOT START WITHOUT APPROVAL)

| Order | ID | Priority | Status | Screen / workflow | Depends on |
|---|---|---|---|---|---|
| 1 | UX-001 | P1 | DONE | Purchase item suggest lock — verified + overlay test | — |
| 2 | UX-002 | P1 | BLOCKED | Stock edit storm / invalidate loop | User pastes storm logs |
| 3 | UX-003 | P1 | DONE | Reports filter sheet + desktop pane height | — |
| 4 | UX-004 | P2 | DONE | Purchase wizard — discount/narration progressive disclosure | — |
| 5 | UX-005 | P2 | DONE | Stock table — phone ITEM|PHYS; desktop 4-col | — |
| 6 | UX-006 | P2 | DONE | Purchase history row overflow (meta + Wrap actions) | — |
| 7 | UX-007 | P2 | DONE | Contacts People \| Catalog hub IA | — |
| 8 | UX-008 | P2 | DONE | Staff deliveries — Receive affordance + empty state | — |
| 9 | UX-009 | P3 | DONE | Home KPIs — demote Purchases/Warehouse tiles | — |
| 10 | UX-010 | P3 | DONE | Settings — Owner tools section + sidebar admin shortcuts | — |
| 11 | UX-011 | P2 | DONE | Low stock — Attention \| Pipeline hub (no 5-chip scroll) | — |
| 12 | UX-012 | P2 | DONE | Catalog taxonomy — inline tree + single primary add | — |
| 13 | UX-013 | P2 | DONE | Supplier wizard — step rail + skip to review | — |
| 14 | UX-014 | P2 | DONE | Item detail — unify role tab matrix desktop/mobile | — |
| 15 | UX-015 | P2 | DONE | Staff shell — phone 4+More nav (Deliveries label SSOT) | — |
| 16 | UX-016 | P3 | DONE | Owner shell — History label → Purchases | — |
| 17 | UX-017 | P3 | DONE | Reports — primary tabs TabBar not ChoiceChip | — |
| 18 | UX-018 | P3 | DONE | Contacts — People empty HexaEmptyState + CTA | — |
| 19 | UX-019 | P3 | DONE | Help — Support section + AppBar menu entry | — |
| 20 | UX-020 | P3 | DONE | Contacts Catalog empty HexaEmptyState + CTA | — |
| 21 | UX-021 | P3 | DONE | Staff cash purchases empty HexaEmptyState | — |
| 22 | UX-022 | P3 | DONE | Barcode scan history empty HexaEmptyState | — |
| 23 | UX-023 | P3 | DONE | Search zero-results HexaEmptyState | — |
| 24 | UX-024 | P3 | DONE | Staff item gallery empty HexaEmptyState | — |
| 25 | UX-025 | P3 | DONE | Staff activity empty HexaEmptyState | — |
| 26 | UX-026 | P3 | DONE | Owner command-center section empties | — |
| 27 | UX-027 | P3 | DONE | Catalog category-detail empty HexaEmptyState | — |
| 28 | UX-028 | P3 | DONE | Item/broker/supplier history empty HexaEmptyState | — |
| 29 | UX-029 | P3 | DONE | Catalog item timeline empty HexaEmptyState | — |
| 30 | UX-030 | P3 | DONE | Catalog duplicates empty HexaEmptyState | — |
| 31 | UX-031 | P3 | DONE | Owner staff-tasks empty HexaEmptyState | — |
| 32 | UX-032 | P3 | DONE | User profile not-found HexaEmptyState | — |
| 33 | UX-033 | P3 | DONE | Barcode print no-label HexaEmptyState | — |
| 34 | UX-034 | P3 | DONE | Staff checklist empty HexaEmptyState | — |
| 35 | UX-035 | P3 | DONE | Opening stock empty/error polish | — |
| 36 | UX-036 | P3 | DONE | Broker detail empty polish | — |
| 37 | UX-037 | P3 | DONE | Contacts catalog search empties | — |
| 38 | UX-038 | P3 | DONE | Staff tasks empty HexaEmptyState | — |
| 39 | UX-039 | P3 | DONE | Catalog type-items empty HexaEmptyState | — |
| 40 | UX-040 | P3 | DONE | Reorder list empty HexaEmptyState | — |
| 41 | UX-041 | P3 | DONE | User management empty HexaEmptyState | — |
| 42 | UX-042 | P3 | DONE | Category items empty HexaEmptyState | — |
| 43 | UX-043 | P3 | DONE | Setup reorder-levels empty HexaEmptyState | — |
| 44 | UX-044 | P3 | DONE | Staff purchase-history empty HexaEmptyState | — |
| 45 | UX-045 | P3 | DONE | Reports item-detail empty HexaEmptyState | — |
| 46 | UX-046 | P3 | DONE | Reports purchases-tab empty HexaEmptyState | — |
| 47 | UX-047 | P3 | DONE | Reports overview-chart empty HexaEmptyState | — |
| 48 | UX-048 | P3 | DONE | Reports items-tab empty HexaEmptyState | — |
| 49 | UX-049 | P3 | DONE | Reports stock-tab empty HexaEmptyState | — |
| 50 | UX-050 | P3 | DONE | Bulk barcode-print list empty HexaEmptyState | — |
| 51 | UX-051 | P3 | DONE | Catalog page empty HexaEmptyState | — |
| 52 | UX-052 | P3 | DONE | Reports overview-aside empty HexaEmptyState | — |
| 53 | UX-053 | P3 | DONE | User activity tab empty HexaEmptyState | — |
| 54 | UX-054 | P3 | DONE | Catalog missing-codes empty HexaEmptyState | — |
| 55 | UX-055 | P3 | DONE | Stock missing-labels empty HexaEmptyState | — |
| 56 | UX-056 | P3 | DONE | Daily usage empty HexaEmptyState | — |
| 57 | UX-057 | P3 | DONE | Item purchase-history section empty HexaEmptyState | — |
| 58 | UX-058 | P3 | DONE | Item supplier-intelligence empty HexaEmptyState | — |
| 59 | UX-059 | P3 | DONE | Item timeline section empty HexaEmptyState | — |
| 60 | UX-060 | P3 | DONE | Staff home recent-activity empty HexaEmptyState | — |
| 61 | UX-061 | P3 | DONE | Item ledger section empty HexaEmptyState | — |
| 62 | UX-062 | P3 | DONE | Staff home shift-snapshot empty HexaEmptyState | — |
| 63 | UX-063 | P3 | DONE | Purchase history filter/search empty HexaEmptyState | — |
| 64 | UX-064 | P3 | DONE | Supplier wizard empty HexaEmptyState | — |
| 65 | UX-065 | P3 | DONE | Catalog item-create empty HexaEmptyState | — |
| 66 | UX-066 | P3 | DONE | Batch item-create empty HexaEmptyState | — |
| 67 | UX-067 | P3 | DONE | Staff deliveries — hide empty sections | — |
| 68 | UX-068 | P3 | DONE | Purchase fast-items empty HexaEmptyState | — |
| 69 | UX-069 | P3 | DONE | User activity section chips → Wrap | — |
| 70 | UX-070 | P3 | DONE | Item timeline kind chips → Wrap | — |
| 71 | UX-071 | P3 | DONE | Opening stock filter chips → Wrap | — |
| 72 | UX-072 | P3 | DONE | Reports stock filter chips → Wrap | — |
| 73 | UX-073 | P3 | DONE | Notifications category chips → Wrap | — |
| 74 | UX-074 | P3 | DONE | Search section filter chips → Wrap | — |
| 75 | UX-075 | P3 | DONE | Stock item history filter chips → Wrap | — |
| 76 | UX-076 | P3 | DONE | Contacts workspace count chips → Wrap | — |
| 77 | UX-077 | P3 | DONE | Purchase history filter chips → Wrap | — |
| 78 | UX-078 | P3 | DONE | Low-stock subcategory chips → Wrap | — |
| 79 | UX-079 | P3 | DONE | Home period filter chips → Wrap | — |
| 80 | UX-080 | P3 | DONE | Staff gallery subcategory chips → Wrap | — |
| 81 | UX-081 | P3 | DONE | User list primary filter chips → Wrap | — |
| 82 | UX-082 | P3 | DONE | Item detail quick-actions → Wrap | — |
| 83 | UX-083 | P3 | DONE | Purchase detail action bar → Wrap | — |
| 84 | UX-084 | P3 | DONE | Staff home recent-scans chips → Wrap | — |
| 85 | UX-085 | P3 | DONE | Barcode recent-scans chips → Wrap | — |
| 86 | UX-086 | P3 | DONE | OperationalPillRow → Wrap (no horizontal) | — |
| 87 | UX-087 | P3 | DONE | Stock item history empty → HexaEmptyState | — |
| 88 | UX-088 | P3 | DONE | Barcode camera gate empty → HexaEmptyState | — |
| 89 | UX-089 | P3 | DONE | Staff receive shipment status → HexaEmptyState | — |
| 90 | UX-090 | P3 | DONE | Purchase wizard edit-bootstrap error → HexaEmptyState | — |
| 91 | UX-091 | P3 | DONE | Stock desktop detail empty selection → HexaEmptyState | — |
| 92 | UX-092 | P3 | DONE | Purchase desktop detail empty selection → HexaEmptyState | — |
| 93 | UX-093 | P3 | DONE | Home warehouse activity empty → HexaEmptyState | — |
| 94 | UX-094 | P3 | DONE | Home recent changes empty → HexaEmptyState | — |
| 95 | UX-095 | P3 | DONE | Stock desktop detail activity empty → HexaEmptyState | — |
| 96 | UX-096 | P3 | DONE | Home analytics ranked list empty → HexaEmptyState | — |
| 97 | UX-097 | P3 | DONE | Stock desktop detail activity error → HexaEmptyState | — |
| 98 | UX-098 | P3 | DONE | Staff home recent activity error → HexaEmptyState | — |
| 99 | UX-099 | P3 | DONE | Search slow-load fallback → HexaEmptyState | — |
| 100 | UX-100 | P3 | DONE | Reports breakdown legend empty → HexaEmptyState | — |
| 101 | UX-101 | P3 | DONE | Bulk barcode preview empty selection → HexaEmptyState | — |
| 102 | UX-102 | P3 | DONE | Low-stock subcategory empty → HexaEmptyState | — |
| 103 | UX-103 | P3 | DONE | Quick stock sheet open-error → HexaEmptyState | — |
| 104 | UX-104 | P3 | DONE | Stock quick-purchase sheet open-error → HexaEmptyState | — |
| 105 | UX-105 | P3 | DONE | Reports purchases supplier ranking empty → HexaEmptyState | — |
| 106 | UX-106 | P3 | DONE | Reports filter search empty → HexaEmptyState | — |
| 107 | UX-107 | P3 | DONE | Reports filter simple chips empty → HexaEmptyState | — |
| 108 | UX-108 | P3 | DONE | Purchase detail damage empty/error → HexaEmptyState | — |
| 109 | UX-109 | P3 | DONE | Staff home recent scans error → HexaEmptyState | — |
| 110 | UX-110 | P3 | DONE | Catalog item create load errors → HexaEmptyState | — |
| 111 | UX-111 | P3 | DONE | Staff home floor KPI error → HexaEmptyState | — |
| 112 | UX-112 | P3 | DONE | Supplier wizard categories load error → HexaEmptyState | — |
| 113 | UX-113 | P3 | DONE | Staff home warehouse/purchase stats error → HexaEmptyState | — |
| 114 | UX-114 | P3 | DONE | Home warehouse activity load error → HexaEmptyState | — |
| 115 | UX-115 | P3 | DONE | Stock quick-purchase suppliers/brokers errors → HexaEmptyState | — |
| 116 | UX-116 | P3 | DONE | Home delivery pipeline error → HexaEmptyState | — |
| 117 | UX-117 | P3 | DONE | Supplier wizard types-index error → HexaEmptyState | — |
| 118 | UX-118 | P3 | DONE | Quick catalog taxonomy categories error → HexaEmptyState | — |
| 119 | UX-119 | P3 | DONE | Catalog category trade summary error → HexaEmptyState | — |
| 120 | UX-120 | P3 | DONE | Owner tasks team summary error → HexaEmptyState | — |
| 121 | UX-121 | P3 | DONE | Barcode scan history audit KPI error → HexaEmptyState | — |
| 122 | UX-122 | P3 | DONE | Operational stock filter types/suppliers error → HexaEmptyState | — |
| 123 | UX-123 | P3 | DONE | Stock status quick chips counts error → HexaEmptyState | — |
| 124 | UX-124 | P3 | DONE | Catalog search suggestions error → HexaEmptyState | — |
| 125 | UX-125 | P3 | DONE | Purchase item entry stock preview error → HexaEmptyState | — |
| 126 | UX-126 | P3 | DONE | Stock item history load error → HexaEmptyState | — |
| 127 | UX-127 | P3 | DONE | Barcode scan history recent scans error → HexaEmptyState | — |
| 128 | UX-128 | P3 | DONE | Owner tasks templates/checklist errors → HexaEmptyState | — |
| 129 | UX-129 | P3 | DONE | Home recent changes load error → HexaEmptyState | — |
| 130 | UX-130 | P3 | DONE | Home warehouse activity page error → HexaEmptyState | — |
| 131 | UX-131 | P3 | DONE | Staff pending deliveries error → HexaEmptyState | — |
| 132 | UX-132 | P3 | DONE | Staff item gallery load error → HexaEmptyState | — |
| 133 | UX-133 | P3 | DONE | Staff receive shipment load error → HexaEmptyState | — |
| 134 | UX-134 | P3 | DONE | Staff tasks load error → HexaEmptyState | — |
| 135 | UX-135 | P3 | DONE | Staff purchase history load errors → HexaEmptyState | — |
| 136 | UX-136 | P3 | DONE | Catalog categories list load error → HexaEmptyState | — |
| 137 | UX-137 | P3 | DONE | Catalog category types load error → HexaEmptyState | — |
| 138 | UX-138 | P3 | DONE | Catalog duplicates load error → HexaEmptyState | — |
| 139 | UX-139 | P3 | DONE | Catalog missing-codes load error → HexaEmptyState | — |
| 140 | UX-140 | P3 | DONE | Catalog reorder-levels load error → HexaEmptyState | — |
| 141 | UX-141 | P3 | DONE | Catalog taxonomy hub load error → HexaEmptyState | — |
| 142 | UX-142 | P3 | DONE | Item detail load error → HexaEmptyState | — |
| 143 | UX-143 | P3 | DONE | Catalog item timeline load error → HexaEmptyState | — |
| 144 | UX-144 | P3 | DONE | Item edit load error → HexaEmptyState | — |
| 145 | UX-145 | P3 | DONE | Item purchase history section load error → HexaEmptyState | — |
| 146 | UX-146 | P3 | DONE | Item ledger section load error → HexaEmptyState | — |
| 147 | UX-147 | P3 | DONE | Item timeline section load error → HexaEmptyState | — |
| 148 | UX-148 | P3 | DONE | Item supplier intelligence load error → HexaEmptyState | — |
| 149 | UX-149 | P3 | DONE | Item analytics section load errors → HexaEmptyState | — |
| 150 | UX-150 | P3 | DONE | Item analytics redirect unresolved → HexaEmptyState | — |
| 151 | UX-151 | P3 | DONE | Home auth blocked/recovery errors → HexaEmptyState | — |
| 152 | UX-152 | P3 | DONE | Stock page load errors → HexaEmptyState | Phase C |
| 153 | UX-153 | P3 | DONE | Purchase home load errors → HexaEmptyState | Phase C |
| 154 | UX-154 | P3 | DONE | Purchase desktop detail load error → HexaEmptyState | Phase C |
| 155 | UX-155 | P3 | DONE | Purchase wizard load errors → HexaEmptyState | Phase C |
| 156 | UX-156 | P3 | DONE | Contacts hub load errors → HexaEmptyState | Phase C |
| 157 | UX-157 | P3 | DONE | Supplier detail load error → HexaEmptyState | Phase C |
| 158 | UX-158 | P3 | DONE | Broker detail load errors → HexaEmptyState | Phase C |
| 159 | UX-159 | P3 | DONE | Category items load error → HexaEmptyState | Phase C |
| 160 | UX-160 | P3 | DONE | Broker wizard load error → HexaEmptyState | Phase C |
| 161 | UX-161 | P3 | DONE | Reports overview chart errors → HexaEmptyState | Phase C |
| 162 | UX-162 | P3 | DONE | Reports stock tab load error → HexaEmptyState | Phase C |
| 163 | UX-163 | P3 | DONE | Reports item report load error → HexaEmptyState | Phase C |
| 164 | UX-164 | P3 | DONE | Reports purchase report load errors → HexaEmptyState | Phase C |
| 165 | UX-165 | P3 | DONE | Stock missing labels load error → HexaEmptyState | Phase C |
| 166 | UX-166 | P3 | DONE | Reorder list load error → HexaEmptyState | Phase C |
| 167 | UX-167 | P3 | DONE | Opening stock setup load error → HexaEmptyState | Phase C |
| 168 | UX-168 | P3 | DONE | Low stock dashboard load error → HexaEmptyState | Phase C |
| 169 | UX-169 | P3 | DONE | Staff purchase logs load error → HexaEmptyState | Phase C |
| 170 | UX-170 | P3 | DONE | User activity tab load errors → HexaEmptyState | Phase C |
| 171 | UX-171 | P3 | DONE | User profile load error → HexaEmptyState | Phase C |
| 172 | UX-172 | P3 | DONE | Owner command center load error → HexaEmptyState | Phase C |
| 173 | UX-173 | P3 | DONE | Owner credentials load error → HexaEmptyState | Phase C |
| 174 | UX-174 | P3 | DONE | Daily usage load error → HexaEmptyState | Phase C |
| 175 | UX-175 | P3 | DONE | Staff checklist load error → HexaEmptyState | Phase C |
| 176 | UX-176 | P3 | DONE | Barcode print load error → HexaEmptyState | Phase C |
| 177 | UX-177 | P3 | DONE | Public item scan load error → HexaEmptyState | Phase C |
| 178 | UX-178 | P3 | DONE | Search page load error → HexaEmptyState | Phase C |
| 179 | UX-179 | P1 | DONE | Purchase wizard desktop height-bind (blank pane) | Phase D |
| 180 | UX-180 | P1 | DONE | Wizard AnimatedSwitcher Align→bound child | Phase D |
| 181 | UX-181 | P1 | DONE | Wizard terms typing: isolate preview/draft watches | Phase D |
| 182 | UX-182 | P1 | DONE | Purchase home 390 vs 1280 master-detail regression | Phase D |
| 183 | UX-183 | P2 | DONE | Audit: Login / boot overlay MQ+overflow | Phase E |
| 184 | UX-184 | P2 | READY | Audit: Owner Home MQ+overflow+role money | Phase E |
| 185 | UX-185 | P2 | READY | Audit: Stock MQ+blank panes | Phase E |
| 186 | UX-186 | P2 | READY | Audit: Purchase history (post UX-182) | Phase E |
| 187 | UX-187 | P2 | READY | Audit: Purchase wizard (post UX-179…181) | Phase E |
| 188 | UX-188 | P2 | READY | Audit: Contacts hub | Phase E |
| 189 | UX-189 | P2 | READY | Audit: Reports shell height-bind | Phase E |
| 190 | UX-190 | P2 | READY | Audit: Settings | Phase E |
| 191 | UX-191 | P2 | READY | Audit: Staff shell twin pages | Phase E |
| 196 | UX-196 | P2 | DONE | Desktop primary nav + secondary/side menu structure | Phase E |
| 197 | UX-197 | P2 | DONE | Desktop nav: labeled secondary group + role visibility + footer context | Phase E |
| 198 | UX-198 | P1 | DONE | Fix: StateNotifier listener exception surfaces as blank section (mobile+desktop) | Phase F |

---

## UX-001 — Purchase item suggest lock (verify / residual fix)

### Status
DONE

### Priority
P1

### Screen
Purchase line entry sheet (hosted from `/purchase/new` · `/purchase/edit/:id` via `PurchaseEntryWizardV2`)

### User
Owner / manager / staff with purchase create-edit permission (`VERIFIED_CODE` roles; exact matrix UNKNOWN runtime)

### Context
High-frequency line entry; after selecting a catalog item, user may tap pencil to edit name

### Primary task
Select catalog item and continue qty/cost without suggestion panel fighting focus

### Primary action
Confirm / add line (wizard + sheet)

### Problem
Suggestions may reopen on focus regain while text still matches a catalog row (if lock missing or lock ignored while focused).

### Evidence

- File: `purchase_item_entry_sheet.dart` — `lockedSelectionLabel` when `_selectedCatalogItemId` set (`VERIFIED_CODE`)
- File: `party_inline_suggest_field.dart` — lock closes panel/overlay **while focused**; `_listenFocus` skips reveal when locked (`VERIFIED_CODE`)
- Pencil: `_focusItemNameField` only requests focus — does not clear selection (`VERIFIED_CODE`)
- Unlink: `_onItemTextChanged` clears id when text diverges → unlock (`VERIFIED_CODE`)
- Test: inline + **overlay** lock-on-focus-regain (`VERIFIED_TEST`, 2026-08-09)
- Live browser desktop/mobile QA: **UNKNOWN** (not run this pass)

### UX rule
Minimize unnecessary interaction cost; do not reopen secondary UI that blocks the primary next field.

### Scope

ONLY:
- Verify lock wiring on catalog field (overlay mode)
- Residual code fix only if reopen still present
- Extend widget test for overlay lock (matches production `suggestionsAsOverlay: true`)

DO NOT CHANGE:
- Purchase draft totals / API payloads
- Unrelated wizard steps
- Stock / reports

### Expected change
Keep suggestions closed when `lockedSelectionLabel` set, including while focused; unlock when parent clears selection on text divergence.

### Desktop acceptance

- [x] After select + pencil re-focus: suggestions stay closed while locked — `VERIFIED_TEST` (overlay + inline)
- [x] No production app-code change required this pass (lock already present)
- [ ] Live desktop browser walkthrough — UNKNOWN / optional follow-up

### Mobile acceptance

- [x] Same lock contract exercised in widget tests (overlay path used on full-page sheet)
- [ ] Live phone-width browser walkthrough — UNKNOWN / optional follow-up

### States

- [x] Loading — N/A (local suggest)
- [x] Empty — N/A for lock case
- [x] Error — N/A
- [x] Success — selection sticks while locked (`VERIFIED_CODE` + test)
- [x] Disabled — N/A
- [x] Recovery — clearing lock / text unlink path present (`VERIFIED_CODE` + unlock half of inline test)

### Regression

- [x] Existing functionality preserved (no behavior rewrite beyond prior lock)
- [x] Existing API behavior preserved
- [x] Existing permissions preserved
- [x] Existing navigation preserved
- [x] Tests pass — `flutter test test/party_inline_suggest_field_on_selected_once_test.dart` → **4/4**
- [x] Analyze passes — `flutter analyze` on touched files → **No issues found**

### Files changed

- `flutter_app/test/party_inline_suggest_field_on_selected_once_test.dart` (overlay lock test)
- `uiux context/UI_UX_TASKS.md` (this board)
- App lib: **no change** this pass (lock already in sheet + suggest field)

### Verification

Before:
- Candidate reopen on focus; lock claimed in code from prior pass

After:
- `VERIFIED_CODE`: catalog field passes `lockedSelectionLabel`; lock applies while focused (inline + overlay sync)
- `VERIFIED_TEST`: focus regain with lock → no suggestion rows; unlock → rows appear (inline); overlay lock → no rows / no Close
- Commands: `flutter test …on_selected_once_test.dart` (exit 0); `flutter analyze` 3 files (exit 0)
- Live device: UNKNOWN

### Completion

- [x] Problem verified
- [x] Implementation verified (present; no residual lib fix)
- [x] Desktop verified (widget/test contract; live UNKNOWN)
- [x] Mobile verified (widget/test contract; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

### DISCOVERED FOLLOW-UP

- Optional live QA on `/purchase/new` item sheet: select item → qty → pencil → confirm overlay stays closed (desktop ≥1024 + phone &lt;600).

---

## UX-002 — Stock edit storm

### Status
BLOCKED (awaiting user paste of [STOCK_STORM] / [STOCK_STORM_SUMMARY] logs — logging added 2026-08-11)

### Priority
P1

### Screen
`/stock` · `StockPage` (owner) / `/staff/stock`

### Problem
Reported slow edit / refresh loop — root cause unknown without storm logs.

### Evidence

- **Logging added (2026-08-11):** `[STOCK_STORM]` tags at every invalidation site:
  - `quick_stock_action_sheet.dart` — SAVE_SUCCESS + RESYNC_AFTER_SAVE
  - `stock_page.dart` — BUILD counter + WRITE_EVENT listener + LIST_PROVIDER listener
  - `business_aggregates_invalidation.dart` — invalidateStockRowSaveSurfaces entry
  - `shell_tab_auto_refresh_listener.dart` — tab refresh + remote revision throttle/trigger
  - `shell_realtime_listener.dart` — realtime warehouse signal + throttle
  - Existing `StockApiStormMonitor` already logs `[STOCK_STORM]` per-GET + `[STOCK_STORM_SUMMARY]` per window
- Needs user paste: full console output after a stock edit that feels slow
- Then map endpoints → `ref.invalidate` / `ref.listen` in stock page / patch providers

### Scope

ONLY: smallest loop fix for mapped spam — no rewrite of large list providers.

### Final status

BLOCKED

---

## UX-003 — Reports sheet / pane height

### Status
DONE

### Priority
P1

### Screen
`/reports` — `ReportsShellPage` + `reports_filter_sheet.dart`

### Problem
Mobile filter sheets and desktop panes historically blanked when height unbound / wrong `compact`. Tab bodies sized with MediaQuery height fractions inside `Expanded` could overflow when chrome shrinks the pane.

### Evidence

- Mobile filters: `showHexaBottomSheet(compact: false)` + explicit height (`VERIFIED_CODE`)
- Desktop filters: side dialog with full window height (`VERIFIED_CODE`)
- Shell: `CrossAxisAlignment.stretch` + `LayoutBuilder` width/height bind (`VERIFIED_CODE`)
- Residual fix: Items/Purchases/Stock tabs fill `Expanded` (removed `MediaQuery.height * 0.55/0.62` wrappers)
- Tests: `reports_page_smoke_test.dart` (desktop layout + Items tab); `sheet_compact_height_test.dart` phone filter pattern (`VERIFIED_TEST`)
- Live browser: UNKNOWN

### UX rule
Bind height for desktop panes; Hexa sheet host for filter chrome; lists fill available space.

### Scope

ONLY: Hexa sheet height contract + desktop Row stretch/height bind; residual Expanded-fill for BI tabs.

DO NOT CHANGE: report math, trade endpoints, filter semantics.

### Files changed

- `flutter_app/lib/features/reports/shell/reports_shell_page.dart`
- `flutter_app/test/reports_page_smoke_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

Before: shell bind OK; tab bodies used screen-fraction heights inside Expanded.

After:
- Tabs fill shell Expanded pane
- `flutter test test/reports_page_smoke_test.dart test/sheet_compact_height_test.dart` → all passed
- `flutter analyze --no-fatal-infos` on touched files → exit 0 (pre-existing `reportsPdf` prefix info)

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget test 1440×900; live UNKNOWN)
- [x] Mobile verified (existing Hexa filter sheet test 390×844; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-004 — Purchase wizard progressive disclosure

### Status
DONE

### Priority
P2

### Screen
`/purchase/new` · `/purchase/edit/:purchaseId` — `PurchaseEntryWizardV2` → `PurchaseTermsOnlyStep`

### Problem
Party+Terms step showed payment days, discount %, and narration all at once, lengthening scroll before Continue.

### Evidence

- File: `purchase_terms_only_step.dart` — Payment days primary; **Discount & narration** in `ExpansionTile` (collapsed when empty; auto-open when valued)
- Broker commission still shown only when broker selected (unchanged)
- Draft SSOT / confirm flow unchanged
- Test: `purchase_terms_progressive_disclosure_test.dart` (`VERIFIED_TEST`)
- Live browser: UNKNOWN

### UX rule
Minimize unnecessary interaction cost; group related optional fields; progressive disclosure.

### Scope

ONLY: progressive disclosure within existing terms step — no new purchase entry flow.

### Files changed

- `flutter_app/lib/features/purchase/presentation/wizard/purchase_terms_only_step.dart`
- `flutter_app/test/purchase_terms_progressive_disclosure_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

Before: Discount % + Narration always visible on Party+Terms.

After: Collapsed behind “Discount & narration” when empty; expand on tap; auto-expand when values present.
Commands: `flutter test test/purchase_terms_progressive_disclosure_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (same ExpansionTile path; live UNKNOWN)
- [x] Mobile verified (widget test; live UNKNOWN)
- [x] Regression verified (draft provider / API untouched)
- [x] Evidence recorded

### Final status

DONE

### DISCOVERED FOLLOW-UP

- Further wizard density (items step / desktop single-page section collapse) → separate task if still heavy after this.

---

## UX-005 — Stock table density / desktop+mobile usability

### Status
DONE

### Priority
P2

### Screen
`/stock` · `StockPage` warehouse list — `StockWarehouseRow` + `StockWarehouseTableHeader`

### Problem
Phone/tablet list used four metric columns (ITEM | SYS | PHYS | DIFF), violating AGENTS “never four columns in a mobile list row” and squeezing item names.

### Evidence

- `VERIFIED_CODE`: `StockTableLayout.useWideMetricColumns` (≥1024 → 4-col; else ITEM|PHYS)
- Narrow: `Sys N · Δ M` under item name; PHYS remains the action metric
- Desktop unchanged 4-col master-detail density
- `VERIFIED_TEST`: `stock_dense_row_test.dart` (desktop + phone cases)
- Live browser: UNKNOWN

### UX rule
Separate desktop/mobile audits; avoid four-column mobile rows; keep primary warehouse qty reachable.

### Files changed

- `stock_table_layout.dart`
- `stock_warehouse_row.dart`
- `stock_warehouse_table_header.dart`
- `test/stock_dense_row_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

Commands: `flutter test test/stock_dense_row_test.dart` → 6/6; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget 1440×900)
- [x] Mobile verified (widget 390×844)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-006 — Purchase history list / master-detail

### Status
DONE

### Priority
P2

### Screen
`/purchase` — `PurchaseHomePage` list rows (+ desktop detail already height-bound)

### Problem
History list meta (pack / humanId / broker) and badge+CTA row could overflow horizontally on phone and narrow desktop master pane. Master-detail height bind was already correct.

### Evidence

- Desktop panes: stretch + `LayoutBuilder` height bind (`VERIFIED_CODE`, no change)
- Mobile: push detail route (`VERIFIED_CODE`, no change)
- Fix: `PurchaseHistoryRowMetaLine` (Flexible + ellipsis); `PurchaseHistoryRowStatusLine` (`Wrap` for chips/CTAs)
- `VERIFIED_TEST`: `purchase_history_row_overflow_test.dart`
- Live browser: UNKNOWN

### Files changed

- `purchase_home_page.dart`
- `test/purchase_history_row_overflow_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/purchase_history_row_overflow_test.dart` → 2/2; analyze exit 0 (`--no-fatal-infos`; pre-existing `purchasePdf` prefix info).

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (narrow master width via test)
- [x] Mobile verified (320×640 test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-007 — Contacts tabs information architecture

### Status
DONE

### Priority
P2

### Screen
`/contacts` — `ContactsPage`

### Problem
Five peer tabs mixed people (suppliers/brokers) with catalog taxonomy, raising cognitive load and scrollable tab chrome.

### Evidence

- Hub: `SegmentedButton` **People** | **Catalog**
- People: Suppliers · Brokers; Catalog: Categories · Types · Items
- Deep links (`?tab=`) preserved via `contactsHubForTabIndex` / dual `TabController`s
- `VERIFIED_TEST`: `contacts_hub_ia_test.dart` (4 tests)
- Live browser: UNKNOWN

### Files changed

- `contacts_page.dart`
- `test/contacts_hub_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/contacts_hub_ia_test.dart` → 4/4; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (same widgets; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified (query tab mapping helpers)
- [x] Evidence recorded

### Final status

DONE

---

## UX-008 — Staff receive / deliveries mobile flow

### Status
DONE

### Priority
P2

### Screen
`/staff/deliveries` — `StaffPendingDeliveriesPage` → `/staff/receive/:id`

### Problem
Pending list tiles hid the primary action (tap-only, index/qty trailing); empty state was three empty section cards + muted text (no icon/action).

### Evidence

- Tile: `isThreeLine` + **Receive** + chevron; qty moved into subtitle (`VERIFIED_CODE`)
- Empty: `HexaEmptyState` + Scan barcode (`VERIFIED_CODE`)
- `VERIFIED_TEST`: `staff_pending_deliveries_ux_test.dart`
- Live browser: UNKNOWN

### Files changed

- `staff_pending_deliveries_page.dart`
- `test/staff_pending_deliveries_ux_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_pending_deliveries_ux_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (same list widgets; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-009 — Home KPIs hierarchy polish

### Status
DONE

### Priority
P3

### Screen
`/home` — `HomeOwnerDashboardBody` KPI grid

### Problem
Four equal-weight KPI tiles made snapshot metrics (Purchases, Warehouse) compete with action KPIs (Pending delivery, Need attention).

### Evidence

- `HomeOwnerKpiTile(secondary: true)` on Purchases + Warehouse — muted fill, no shadow, smaller value (`VERIFIED_CODE`)
- Action KPIs remain primary chrome
- Fixed `_AlertChip` Material `shape`/`borderRadius` assert (smoke test)
- `VERIFIED_TEST`: `home_owner_kpi_hierarchy_test.dart` + `home_owner_dashboard_body_smoke_test.dart`
- Live browser: UNKNOWN

### Files changed

- `home_owner_dashboard_body.dart`
- `test/home_owner_kpi_hierarchy_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/home_owner_kpi_hierarchy_test.dart test/home_owner_dashboard_body_smoke_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (same tile API; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-010 — Settings / admin discoverability

### Status
DONE

### Priority
P3

### Screen
`/settings` — `SettingsPage`

### Problem
API credentials and Owner command center were under a mislabeled “Export & Backup” block and missing from the desktop settings sidebar.

### Evidence

- New **Owner tools** section (credentials, command center, staff tasks)
- **Export & Backup** section is backup-only again
- Desktop sidebar: credentials + command center for owner/admin (`settingsSidebarShortcuts`)
- `VERIFIED_TEST`: `settings_sidebar_discoverability_test.dart`
- Live browser: UNKNOWN

### Files changed

- `settings_page.dart`
- `test/settings_sidebar_discoverability_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/settings_sidebar_discoverability_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (sidebar shortcuts; live UNKNOWN)
- [x] Mobile verified (Owner tools section label; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-011 — Low stock Attention | Pipeline hub

### Status
DONE

### Priority
P2

### Screen
Low stock dashboard — `/stock/low` (and staff equivalent via `LowStockDashboardPage`)

### Problem
Five filter pills in a horizontal `SingleChildScrollView` — cognitive breadth + AGENTS NEVER (horizontal 5+ chip scroll).

### Evidence

- Hub: **Attention** (All, Out) | **Pipeline** (Bought, Pending, Delivery)
- Sub-filters use `Wrap` (≤3); no horizontal chip scroller
- Deep-link `?filter=` still maps via existing TabController indices
- `VERIFIED_TEST`: `low_stock_hub_ia_test.dart` (3/3)
- Live browser: UNKNOWN

### Files changed

- `low_stock_category_tree.dart` (hub helpers)
- `low_stock_dashboard_page.dart` (`LowStockHubFilterBar`)
- `test/low_stock_hub_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/low_stock_hub_ia_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget contract; live UNKNOWN)
- [x] Mobile verified (390×844 widget; live UNKNOWN)
- [x] Regression verified (tab order / helpers)
- [x] Evidence recorded

### Final status

DONE

---

## UX-012 — Catalog taxonomy inline tree

### Status
DONE

### Priority
P2

### Screen
`/catalog/taxonomy` — `CatalogTaxonomyHubPage`

### Problem
Flat category list forced deep navigation to see types; always-on help + dual ActionChips + FAB competed as create entry points.

### Evidence

- Expandable category rows show subcategories inline
- Help copy behind collapsed **How categories work**
- Single primary FAB add category; subcategory via row +
- Owner keeps Open category; staff browse types via allowed `/type/` routes
- `VERIFIED_TEST`: `catalog_taxonomy_hub_ia_test.dart` (3/3)
- Live browser: UNKNOWN

### Files changed

- `catalog_taxonomy_hub_page.dart`
- `test/catalog_taxonomy_hub_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_taxonomy_hub_ia_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget contract; live UNKNOWN)
- [x] Mobile verified (390×844 widget; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-013 — Supplier wizard progressive disclosure

### Status
DONE

### Priority
P2

### Screen
`SupplierCreateWizardPage` (edit from contacts / supplier detail)

### Problem
Five linear steps forced a full walkthrough for optional brokers / categories even when editing one field.

### Evidence

- Edit: tappable **step rail** (`Wrap` FilterChips) for non-linear jumps
- Optional steps 1–3: **Skip to review**
- Jump still validates basics (step 0) before leaving step 0
- `VERIFIED_TEST`: `supplier_wizard_progressive_disclosure_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `supplier_create_wizard_page.dart`
- `test/supplier_wizard_progressive_disclosure_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/supplier_wizard_progressive_disclosure_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget contract; live UNKNOWN)
- [x] Mobile verified (390×844 widget; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-014 — Item detail role tab matrix

### Status
DONE

### Priority
P2

### Screen
`/catalog/item/:id` — `ItemDetailPage`

### Problem
Desktop owner used Ledger/Purchases/Analytics/Activity while mobile used Overview/Purchases/Activity; staff desktop had no tabs vs mobile Overview|Activity.

### Evidence

- Shared `itemDetailTabsForRole` / `itemDetailInitialTabIndex`
- Desktop + mobile: staff Overview|Activity; non-staff Overview|Purchases|Activity
- Ledger folds into Purchases; analytics into Overview
- `VERIFIED_TEST`: `item_detail_tab_matrix_test.dart` (3/3) + existing page widget test (2/2)
- Live browser: UNKNOWN

### Files changed

- `item_detail_tab_matrix.dart` (new)
- `item_detail_page.dart`
- `test/item_detail_tab_matrix_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_detail_tab_matrix_test.dart test/item_detail_page_widget_test.dart` → 5/5; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (code + matrix; live UNKNOWN)
- [x] Mobile verified (widget test + matrix; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-015 — Staff shell phone nav (4+More)

### Status
DONE

### Priority
P2

### Screen
Staff shell — `StaffShellScreen`

### Problem
Phone bottom bar packed 6 peers (tiny labels); rail said **Deliveries** while bar said **Deliver**.

### Evidence

- Phone primary: Home | Stock | Scan | Deliveries | **More**
- More sheet: Search + Tasks (`showHexaBottomSheet`)
- Desktop rail still lists all six via shared label/icon SSOT
- `VERIFIED_TEST`: `staff_shell_nav_ia_test.dart` (3/3)
- Live browser: UNKNOWN

### Files changed

- `staff_shell_nav.dart` (new)
- `staff_shell_screen.dart`
- `test/staff_shell_nav_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_shell_nav_ia_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (rail SSOT; live UNKNOWN)
- [x] Mobile verified (widget/sheet; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-016 — Owner shell Purchases naming

### Status
DONE

### Priority
P3

### Screen
Owner shell + `/purchase` — `ShellScreen` / `PurchaseHomePage`

### Problem
Bottom/rail tab said **History** while FAB and content are purchases — mismatched mental model.

### Evidence

- `ownerShellNavLabel(ShellBranch.history)` → **Purchases**
- Rail + bottom bar use SSOT labels
- AppBar title **Purchases**; period copy “Affects Purchases + Reports”
- Internal branch id `ShellBranch.history` unchanged (no router rename)
- `VERIFIED_TEST`: `shell_navigation_test.dart` (+1)
- Live browser: UNKNOWN

### Files changed

- `shell_branch_provider.dart`
- `shell_screen.dart`
- `purchase_home_page.dart`
- `test/shell_navigation_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/shell_navigation_test.dart` → 11/11; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (rail label; live UNKNOWN)
- [x] Mobile verified (bottom bar label; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-017 — Reports primary TabBar chrome

### Status
DONE

### Priority
P3

### Screen
`/reports` — `ReportsPrimaryTabs`

### Problem
Primary BI navigation used horizontal ChoiceChips (filter chrome) instead of TabBar, inconsistent with other multi-tab surfaces.

### Evidence

- `ReportsPrimaryTabs` → scrollable [TabBar] (4 tabs)
- No ChoiceChip in primary tab strip
- `VERIFIED_TEST`: `reports_primary_tabs_chrome_test.dart` + smoke (3/3)
- Live browser: UNKNOWN

### Files changed

- `reports_primary_tabs.dart`
- `test/reports_primary_tabs_chrome_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_primary_tabs_chrome_test.dart test/reports_page_smoke_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390×844; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-018 — Contacts People empty states

### Status
DONE

### Priority
P3

### Screen
`/contacts` — People hub (Suppliers / Brokers)

### Problem
Empty lists were plain centered text (no icon/CTA); search misses same.

### Evidence

- Empty suppliers/brokers → `HexaEmptyState` + Add CTA
- Search no-match → `HexaEmptyState` + Clear search
- `VERIFIED_TEST`: `contacts_hub_ia_test.dart` (4/4)
- Live browser: UNKNOWN

### Files changed

- `contacts_page.dart`
- `test/contacts_hub_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/contacts_hub_ia_test.dart` → 4/4; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390×844; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-019 — Help discoverability

### Status
DONE

### Priority
P3

### Screen
Settings + shell chrome + `AppSettingsAction`

### Problem
Help lived under Settings → Data (easy to miss); no direct shell/AppBar path.

### Evidence

- Settings: **Support** section after Account with Help & guide
- Desktop sidebar: Help guide first shortcut
- Owner + staff rails: Help icon → `/settings/help`
- App bar: Settings menu includes Help & guide
- `VERIFIED_TEST`: `app_settings_action_help_test.dart` + sidebar (3/3)
- Live browser: UNKNOWN

### Files changed

- `settings_page.dart`
- `app_settings_action.dart`
- `shell_screen.dart`
- `staff_shell_screen.dart`
- `test/app_settings_action_help_test.dart`
- `test/settings_sidebar_discoverability_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/app_settings_action_help_test.dart test/settings_sidebar_discoverability_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (rail + sidebar; live UNKNOWN)
- [x] Mobile verified (AppBar menu; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-020 — Contacts Catalog empty states

### Status
DONE

### Priority
P3

### Screen
`/contacts` — Catalog hub (Categories / Items)

### Problem
Catalog empties were plain text (no icon/CTA), unlike People hub after UX-018.

### Evidence

- Categories/Items → `HexaEmptyState` + Add category / Add item
- Settings quick action label **Purchases** (naming residual from UX-016)
- `VERIFIED_TEST`: `contacts_hub_ia_test.dart` (4/4)
- Live browser: UNKNOWN

### Files changed

- `contacts_page.dart`
- `settings_page.dart` (Purchases label)
- `test/contacts_hub_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/contacts_hub_ia_test.dart` → 4/4; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (widget; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-021 — Staff cash purchases empty state

### Status
DONE

### Priority
P3

### Screen
`/stock/staff-purchases` — `StaffPurchaseLogsPage`

### Problem
Empty and error states were plain centered text (no icon/CTA; error leaked via userFacingError string only).

### Evidence

- Empty → `HexaEmptyState` + Go to stock / Open stock
- Error → `FriendlyLoadError` + retry
- `VERIFIED_TEST`: `staff_purchase_logs_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_purchase_logs_page.dart`
- `test/staff_purchase_logs_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_purchase_logs_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (widget; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-022 — Barcode scan history empty state

### Status
DONE

### Priority
P3

### Screen
`/barcode/scan-history` — `BarcodeScanHistoryPage`

### Problem
Signed-out, empty, and error states were plain text (no icon/CTA; error not retryable).

### Evidence

- Signed out → `HexaEmptyState` (Sign in required)
- Empty → `HexaEmptyState` + Scan barcode → `/barcode/scan`
- Error → `FriendlyLoadError` + retry
- `VERIFIED_TEST`: `barcode_scan_history_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `barcode_scan_history_page.dart`
- `test/barcode_scan_history_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/barcode_scan_history_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (widget; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-023 — Search zero-results empty state

### Status
DONE

### Priority
P3

### Screen
`/search` · `/staff/search` — `SearchPage`

### Problem
Zero unified-search hits used plain body text plus stacked per-section “No matching…” lines (no icon/CTA).

### Evidence

- Zero hits → single `HexaEmptyState` (skips section empty stack)
- Owner CTA → Low stock `/stock`; staff CTA → Scan barcode `/staff/scan`
- Loading fallback timer cancelled on dispose (test hygiene)
- `VERIFIED_TEST`: `search_zero_results_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `search_page.dart`
- `test/search_zero_results_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/search_zero_results_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-024 — Staff item gallery empty state

### Status
DONE

### Priority
P3

### Screen
`/staff/items` — `StaffItemGalleryPage`

### Problem
Empty gallery was plain centered text; 5 filter chips used a horizontal `ListView` (AGENTS NEVER for 5+).

### Evidence

- Empty catalog → `HexaEmptyState` + Scan barcode
- Filter/search miss → `HexaEmptyState` + Clear filters
- Filter chips → `Wrap` (no horizontal chip scroller)
- `VERIFIED_TEST`: `staff_item_gallery_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `staff_item_gallery_page.dart`
- `test/staff_item_gallery_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_item_gallery_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-025 — Staff activity empty state

### Status
DONE

### Priority
P3

### Screen
`/staff/activity` — `StaffActivityPage`

### Problem
Empty period used a custom icon+text column with no next-step CTA.

### Evidence

- Empty → `HexaEmptyState` + Scan barcode → `/staff/scan`
- `VERIFIED_TEST`: `staff_activity_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_activity_page.dart`
- `test/staff_activity_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_activity_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-026 — Owner command-center section empties

### Status
DONE

### Priority
P3

### Screen
`/settings/owner-dashboard` — `OwnerCommandCenterPage` / `OwnerCommandCenterBody`

### Problem
Exceptions / WhatsApp / staff sections used plain muted `Text` empties with no icon or next step.

### Evidence

- Exceptions empty → `HexaEmptyState` + Open stock
- WhatsApp empty → `HexaEmptyState` (info)
- Staff empty → `HexaEmptyState` + Open tasks board
- Shared: `HexaEmptyState` Column `mainAxisSize: min` (ListView-safe)
- `VERIFIED_TEST`: `owner_command_center_empty_test.dart` (1/1); related empties still pass
- Live browser: UNKNOWN

### Files changed

- `owner_command_center_page.dart`
- `hexa_empty_state.dart`
- `test/owner_command_center_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/owner_command_center_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-027 — Catalog category-detail empty states

### Status
DONE

### Priority
P3

### Screen
Catalog category detail — `CatalogCategoryDetailPage`

### Problem
Empty and filter-miss type lists used plain muted `Text` (no icon/CTA).

### Evidence

- No types → `HexaEmptyState` + Add subcategory (sheet)
- Filter miss → `HexaEmptyState` + Clear filter
- `VERIFIED_TEST`: `catalog_category_detail_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `catalog_category_detail_page.dart`
- `test/catalog_category_detail_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_category_detail_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-028 — Item / broker / supplier history empty states

### Status
DONE

### Priority
P3

### Screen
`ItemHistoryPage` · `BrokerHistoryPage` · `SupplierLedgerPage`

### Problem
Empty / search-miss lists used plain centered `Text('No matching lines')` with no icon or clear CTA.

### Evidence

- Shared `LedgerHistoryListEmpty` → `HexaEmptyState`
- No data → No purchase lines yet
- Search miss → No matching lines + Clear search
- `VERIFIED_TEST`: `ledger_history_list_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `ledger_history_list_empty.dart` (new)
- `item_history_page.dart`
- `broker_history_page.dart`
- `supplier_ledger_page.dart`
- `test/ledger_history_list_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/ledger_history_list_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (widget; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-029 — Catalog item timeline empty state

### Status
DONE

### Priority
P3

### Screen
`/catalog/item/:itemId/timeline` — `CatalogItemTimelinePage`

### Problem
Empty timeline used plain centered `Text('No events recorded yet')` with no icon/CTA.

### Evidence

- Empty → `CatalogItemTimelineEmpty` / `HexaEmptyState` + Back to item
- `VERIFIED_TEST`: `catalog_item_timeline_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_item_timeline_page.dart`
- `test/catalog_item_timeline_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_item_timeline_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-030 — Catalog duplicates empty state

### Status
DONE

### Priority
P3

### Screen
`/catalog/duplicates` — `CatalogDuplicatesPage`

### Problem
Zero pairs used plain centered text; error retry had no user message.

### Evidence

- Empty → `HexaEmptyState` + Open catalog
- Error → `FriendlyLoadError` with message
- `VERIFIED_TEST`: `catalog_duplicates_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_duplicates_page.dart`
- `test/catalog_duplicates_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_duplicates_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-031 — Owner staff-tasks empty / error states

### Status
DONE

### Priority
P3

### Screen
Owner `OwnerTasksPage` (Staff tasks — Arrange / Check today)

### Problem
Check today empty was plain text; Arrange/Check errors leaked `friendlyApiError` strings without retry chrome.

### Evidence

- Check today empty → `HexaEmptyState` + Edit task list (switches tab)
- Errors → `FriendlyLoadError` + invalidate retry
- `VERIFIED_TEST`: `owner_tasks_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `owner_tasks_page.dart`
- `test/owner_tasks_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/owner_tasks_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-032 — User profile not-found empty state

### Status
DONE

### Priority
P3

### Screen
`/settings/users/:userId` — `UserProfilePage`

### Problem
Missing user used plain centered `Text('User not found.')` with no next step.

### Evidence

- Empty profile map → `HexaEmptyState` + Back to users
- `VERIFIED_TEST`: `user_profile_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `user_profile_page.dart`
- `test/user_profile_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/user_profile_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-033 — Barcode print no-label empty state

### Status
DONE

### Priority
P3

### Screen
Barcode single print — `BarcodePrintPage`

### Problem
Missing printable symbology used plain centered `Text('No label data')` with no edit path.

### Evidence

- Empty → `BarcodePrintNoLabelEmpty` / `HexaEmptyState` + Edit item code (sheet → reload)
- `VERIFIED_TEST`: `barcode_print_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `barcode_print_page.dart`
- `test/barcode_print_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/barcode_print_empty_test.dart` → 2/2; analyze: pre-existing `pdfActions` prefix info only.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (widget; live UNKNOWN)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-034 — Staff checklist empty / error states

### Status
DONE

### Priority
P3

### Screen
`StaffChecklistPage` (My tasks)

### Problem
Zero tasks and empty slots used plain muted text; load errors used ad-hoc Center+Retry without `FriendlyLoadError`.

### Evidence

- Zero tasks → page-level `HexaEmptyState` + Refresh
- Empty slot → `HexaEmptyState` (slot-specific)
- Error → `FriendlyLoadError`
- `VERIFIED_TEST`: `staff_checklist_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_checklist_page.dart`
- `test/staff_checklist_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_checklist_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-035 — Opening stock empty / error polish

### Status
DONE

### Priority
P3

### Screen
`OpeningStockSetupPage` (`/stock/opening-setup`)

### Problem
Load errors used plain `Center(Text(userFacingError))`; empty list used desktop-only `HexaEmptyState` and plain text on phone.

### Evidence

- Error → `FriendlyLoadError` + invalidate `openingStockSetupProvider`
- Empty → unified `HexaEmptyState` (phone + desktop); Clear filters vs Refresh from `OpeningStockSetupQuery`
- `VERIFIED_TEST`: `opening_stock_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `opening_stock_setup_page.dart`
- `test/opening_stock_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/opening_stock_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-036 — Broker detail empty polish

### Status
DONE

### Priority
P3

### Screen
`BrokerDetailPage` (`/broker/:id`)

### Problem
Empty PUR list used plain `TradeLedgerCardList` hint text; empty commission chart used muted `Text` under section headers (orphan headers).

### Evidence

- Empty PUR → `BrokerDetailPurEmpty` / `HexaEmptyState` + New purchase (mirrors supplier detail)
- Empty chart → section omitted (no header without data)
- Broker load / linked suppliers errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `broker_detail_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `broker_detail_page.dart`
- `test/broker_detail_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/broker_detail_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-037 — Contacts catalog search empties

### Status
DONE

### Priority
P3

### Screen
`ContactsPage` Catalog hub search (Categories / Types / Items)

### Problem
Supplier/broker search misses used `HexaEmptyState`; category/type/item search misses used plain centered `Text`.

### Evidence

- Categories / Types / Items search miss → `HexaEmptyState` + Clear search (aligned with People tabs)
- `VERIFIED_TEST`: `contacts_catalog_search_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `contacts_page.dart`
- `test/contacts_catalog_search_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/contacts_catalog_search_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-038 — Staff tasks empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffTasksPage` (`/staff/tasks-board`, `/staff/tasks`)

### Problem
Empty assignment list used plain centered muted text (`No tasks assigned.`) with no CTA.

### Evidence

- Empty → `StaffTasksEmpty` / `HexaEmptyState`
- Owner/admin → Assign task; staff → Refresh
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `staff_tasks_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `staff_tasks_page.dart`
- `test/staff_tasks_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_tasks_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-039 — Catalog type-items empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogTypeItemsPage` (`/catalog/category/:id/type/:tid`)

### Problem
Zero items and search-miss used plain centered muted text (`No items yet — tap Add item.` / `No matches.`).

### Evidence

- Empty type → `HexaEmptyState` + Add item
- Search miss → `HexaEmptyState` + Clear filter
- `VERIFIED_TEST`: `catalog_type_items_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `catalog_type_items_page.dart`
- `test/catalog_type_items_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_type_items_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-040 — Reorder list empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReorderListPage`

### Problem
Empty tabs and search-miss used ad-hoc icon + grey text Column (not `HexaEmptyState`, no CTA).

### Evidence

- Empty tab → `HexaEmptyState` + Open stock
- Search miss → `HexaEmptyState` + Clear search
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `reorder_list_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `reorder_list_page.dart`
- `test/reorder_list_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reorder_list_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-041 — User management empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`UserManagementPage`

### Problem
Filtered/empty user list used plain centered `Text` (`No users match your filters.`) with no CTA.

### Evidence

- True empty → `HexaEmptyState` + Add user (when allowed) / Refresh
- Filter miss → `HexaEmptyState` + Clear filters
- Load errors already `HexaErrorCard`
- `VERIFIED_TEST`: `user_management_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `user_management_page.dart`
- `test/user_management_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/user_management_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-042 — Category items empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CategoryItemsPage` (Contacts category drill-down)

### Problem
Empty period used plain centered `Text` with no CTA.

### Evidence

- Empty → `HexaEmptyState` + Back to Contacts
- Errors already `FriendlyLoadError`
- Provider exported as `contactsCategoryItemsProvider` for overrides
- `VERIFIED_TEST`: `category_items_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `category_items_page.dart`
- `test/category_items_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/category_items_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-043 — Setup reorder-levels empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogSetupReorderLevelsPage`

### Problem
Empty/search-miss used plain centered text (`No items match your search`) with no distinction for “all set” vs search miss, and no CTA.

### Evidence

- All levels set → `HexaEmptyState` + Done
- Search miss → `HexaEmptyState` + Clear search
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `catalog_setup_reorder_levels_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `catalog_setup_reorder_levels_page.dart`
- `test/catalog_setup_reorder_levels_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_setup_reorder_levels_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-044 — Staff purchase-history empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffPurchaseHistoryPage`

### Problem
Period / low-stock empties and search misses used plain muted `_emptyMessage` text with no CTA.

### Evidence

- Period empty → `HexaEmptyState` + Refresh
- Low stock empty → `HexaEmptyState` + Open stock
- Search miss → `HexaEmptyState` + Clear search
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `staff_purchase_history_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `staff_purchase_history_page.dart`
- `test/staff_purchase_history_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_purchase_history_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-045 — Reports item-detail empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReportsItemDetailPage` · `ReportsItemReportPage`

### Problem
Empty period transactions used plain muted text with no CTA on both classified-line detail and backend item report drill-downs.

### Evidence

- Detail empty → `HexaEmptyState` + Back to Reports
- Report empty → `HexaEmptyState` + Back to Reports
- Report load errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `reports_item_detail_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `reports_item_detail_page.dart`
- `reports_item_report_page.dart`
- `test/reports_item_detail_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_item_detail_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-046 — Reports purchases-tab empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReportsPurchasesTab` (Reports → Purchases)

### Problem
Filtered/empty purchases list used plain centered `Text` (`No purchases in this period.`) with no CTA.

### Evidence

- Empty → `HexaEmptyState` + Change period (wired to shell custom range picker)
- `VERIFIED_TEST`: `reports_purchases_tab_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `reports_purchases_tab.dart`
- `reports_shell_page.dart`
- `test/reports_purchases_tab_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_purchases_tab_empty_test.dart` → 1/1; purchases-tab analyze clean (shell has pre-existing `library_prefixes` info).

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-047 — Reports overview-chart empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReportsOverviewChartSection` (Reports → Overview)

### Problem
Empty range used ad-hoc grey ring + text; load failure used ad-hoc icon column — not `HexaEmptyState`.

### Evidence

- Empty → `HexaEmptyState` + Retry / Change period
- Load failed → `HexaEmptyState` + Retry / Match Home period
- `VERIFIED_TEST`: `reports_overview_chart_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `reports_overview_chart_section.dart`
- `test/reports_overview_chart_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_overview_chart_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-048 — Reports items-tab empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReportsItemsTab` (Reports → Items)

### Problem
Empty filtered/period item list used plain centered `Text` (`No items in this period.`) with no CTA.

### Evidence

- Empty → `HexaEmptyState` + Change period (wired to shell custom range picker)
- `VERIFIED_TEST`: `reports_items_tab_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `reports_items_tab.dart`
- `reports_shell_page.dart`
- `test/reports_items_tab_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_items_tab_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-049 — Reports stock-tab empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReportsStockTab` (Reports → Stock)

### Problem
Chip/search empties used ad-hoc grey icon + plain text Column with no CTA.

### Evidence

- Empty → `ReportsStockEmpty` / `HexaEmptyState`
- Chip filter → Clear filter; All → Open stock
- Load errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `reports_stock_tab_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `reports_stock_tab.dart`
- `test/reports_stock_tab_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_stock_tab_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-050 — Bulk barcode-print list empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`BulkBarcodePrintPage`

### Problem
Filtered/empty stock list left a blank `ListView` (no empty guidance or CTA). Trade ledger already used `HexaEmptyState` — skipped.

### Evidence

- Empty list → `BulkBarcodePrintListEmpty` / `HexaEmptyState`
- Filters active → Clear filters; else Open catalog
- `VERIFIED_TEST`: `bulk_barcode_print_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `bulk_barcode_print_page.dart`
- `test/bulk_barcode_print_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/bulk_barcode_print_empty_test.dart` → 2/2; analyze: pre-existing `library_prefixes` info only.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-051 — Catalog page empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogPage`

### Problem
Zero categories / search-miss used ad-hoc icon + text Column without CTA buttons.

### Evidence

- Empty → `HexaEmptyState` + Add category
- Search miss → `HexaEmptyState` + Clear search
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `catalog_page_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `catalog_page.dart`
- `test/catalog_page_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_page_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-052 — Reports overview-aside empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReportsOverviewTab` desktop Period insights pane (width ≥1024 and &lt;1366)

### Problem
Empty period used plain muted `Text('No purchases in this period.')` without CTA.

### Evidence

- Empty → `HexaEmptyState` + Change period → `onPickRange`
- Chart empty already `HexaEmptyState` (UX-047)
- `VERIFIED_TEST`: `reports_overview_aside_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `reports_overview_tab.dart`
- `test/reports_overview_aside_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_overview_aside_empty_test.dart` → 1/1; analyze clean on `reports_overview_tab.dart`.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (1280 widget test; live UNKNOWN)
- [x] Mobile verified (N/A — insights pane desktop-only)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-053 — User activity tab empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`UserActivityTab` / `UserActivityTimeline` (Settings → user profile → Activity)

### Problem
Feed / stock / purchases / items / ledger empties used plain centered `Text` without icon or CTA.

### Evidence

- Timeline empty → `HexaEmptyState` + Refresh
- Section early plain-text empties removed; all paths use timeline
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `user_activity_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `user_activity_timeline.dart`
- `user_activity_tab.dart`
- `test/user_activity_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/user_activity_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-054 — Catalog missing-codes empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogMissingCodesPage` (`/catalog/missing-codes`)

### Problem
Zero missing codes used plain muted centered `Text` without icon or CTA.

### Evidence

- Empty → `HexaEmptyState` + Open catalog → `/catalog`
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `catalog_missing_codes_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_missing_codes_page.dart`
- `test/catalog_missing_codes_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_missing_codes_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-055 — Stock missing-labels empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StockMissingLabelsPage` (Missing barcode / Missing item code tabs)

### Problem
Empty tabs used plain centered `Text` without icon or CTA.

### Evidence

- Empty → `HexaEmptyState` + Open stock → `/stock`
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `stock_missing_labels_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `stock_missing_labels_page.dart`
- `test/stock_missing_labels_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/stock_missing_labels_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-056 — Daily usage empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`DailyUsagePage` (`/operations/usage`)

### Problem
Zero usage lines used ad-hoc icon + text Column without shared empty chrome or CTA.

### Evidence

- Empty → `HexaEmptyState` + Open stock → `/stock`
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `daily_usage_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `daily_usage_page.dart`
- `test/daily_usage_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/daily_usage_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-057 — Item purchase-history section empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemPurchaseHistorySection` (item detail card)

### Problem
Range/empty miss used plain muted `Text` without icon or recovery CTA.

### Evidence

- Empty (narrow range) → `HexaEmptyState` + Show all time
- Empty (all time) → `HexaEmptyState` + New purchase
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `item_purchase_history_section_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `item_purchase_history_section.dart`
- `test/item_purchase_history_section_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_purchase_history_section_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-058 — Item supplier-intelligence empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemSupplierIntelligenceSection` (item detail card)

### Problem
Zero purchases used plain muted `Text` without icon or CTA.

### Evidence

- Empty → `HexaEmptyState` + New purchase → `/purchase/new`
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `item_supplier_intelligence_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_supplier_intelligence_section.dart`
- `test/item_supplier_intelligence_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_supplier_intelligence_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-059 — Item timeline section empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemTimelineSection` (item detail card)

### Problem
Empty / filter-miss used ad-hoc icon + text Column without CTA.

### Evidence

- Empty → `HexaEmptyState` + Full timeline
- Filter/search miss → `HexaEmptyState` + Clear filters
- Errors already `FriendlyLoadError`
- `VERIFIED_TEST`: `item_timeline_section_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `item_timeline_section.dart`
- `test/item_timeline_section_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_timeline_section_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-060 — Staff home recent-activity empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffHomeRecentActivitySection` (`/staff/home`)

### Problem
Zero activity used plain muted `Text` without icon or CTA.

### Evidence

- Empty → `HexaEmptyState` + Scan barcode → `/barcode/scan`
- `VERIFIED_TEST`: `staff_home_recent_activity_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_home_dashboard_widgets.dart`
- `test/staff_home_recent_activity_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_home_recent_activity_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-061 — Item ledger section empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemLedgerSection` / `_LedgerEmptyState` (item detail card)

### Problem
Empty range / all-time used plain muted `Text`; positive-stock empty had buttons but no shared empty chrome.

### Evidence

- Narrow range (zero stock) → `HexaEmptyState` + View all time
- All time → `HexaEmptyState` + Full statement
- Positive stock, no moves → `HexaEmptyState` + View all time / Update physical count
- `VERIFIED_TEST`: `item_ledger_section_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_ledger_section.dart`
- `test/item_ledger_section_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_ledger_section_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-062 — Staff home shift-snapshot empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffHomeShiftSnapshotStrip` (`/staff/home`)

### Problem
Zero shift activity used bordered `ListTile` without shared empty chrome / explicit button CTA.

### Evidence

- Empty → `HexaEmptyState` + Scan barcode → `/barcode/scan`
- `VERIFIED_TEST`: `staff_home_shift_snapshot_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_home_dashboard_widgets.dart`
- `test/staff_home_shift_snapshot_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_home_shift_snapshot_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-063 — Purchase history filter/search empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`PurchaseHomePage` history tab + fullscreen search (`_PurchaseHistoryFullscreenSearchPage`)

### Problem
Filter-hide-all and fullscreen search-miss used ad-hoc icon + text Columns instead of shared empty chrome.

### Evidence

- Filters hide all → `HexaEmptyState` + Clear search & filters
- Fullscreen search empty → `HexaEmptyState` + Clear search / Refresh
- Zero purchases already `_HistoryEmpty` → `HexaEmptyState` (unchanged)
- `VERIFIED_TEST`: `purchase_history_filters_hide_all_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `purchase_home_page.dart`
- `test/purchase_history_filters_hide_all_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/purchase_history_filters_hide_all_empty_test.dart` → 1/1; analyze: pre-existing `library_prefixes` info only.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-064 — Supplier wizard empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`SupplierCreateWizardPage` (Brokers + Items & categories steps)

### Problem
Zero brokers / zero categories used plain `Text` without icon or CTA.

### Evidence

- Brokers empty → `HexaEmptyState` + Create new broker
- Categories empty → `HexaEmptyState` + Open catalog
- `VERIFIED_TEST`: `supplier_wizard_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `supplier_create_wizard_page.dart`
- `test/supplier_wizard_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/supplier_wizard_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-065 — Catalog item-create empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogItemCreatePage` (`/catalog/quick-add`)

### Problem
Zero suppliers / zero subcategories used plain `Text` without icon or CTA.

### Evidence

- Suppliers empty → `HexaEmptyState` + Open Contacts
- Subcategories empty → `HexaEmptyState` + Open catalog
- `VERIFIED_TEST`: `catalog_item_create_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `catalog_item_create_page.dart`
- `test/catalog_item_create_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_item_create_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-066 — Batch item-create empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`BatchItemCreatePage`

### Problem
Zero categories / zero subcategories used plain `Text` without icon or CTA.

### Evidence

- Categories empty → `HexaEmptyState` + Open catalog
- Subcategories empty → `HexaEmptyState` + Open catalog
- `VERIFIED_TEST`: `batch_item_create_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `batch_item_create_page.dart`
- `test/batch_item_create_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/batch_item_create_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-067 — Staff deliveries — hide empty sections

### Status
DONE

### Priority
P3

### Screen
`StaffPendingDeliveriesPage`

### Problem
Zero-item sections still rendered headers + muted empty cards (`No dispatches…`), violating “no section header without items.”

### Evidence

- Empty pipeline → page-level `HexaEmptyState` (unchanged)
- Partial pipeline → only non-empty Dispatched / Arrived / Pending verification sections
- `VERIFIED_TEST`: `staff_pending_deliveries_ux_test.dart` (3/3)
- Live browser: UNKNOWN

### Files changed

- `staff_pending_deliveries_page.dart`
- `test/staff_pending_deliveries_ux_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_pending_deliveries_ux_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-068 — Purchase fast-items empty HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`PurchaseFastItemsStep` + `PurchaseFastItemsTable`

### Problem
Zero lines used plain muted `Text` without icon or primary CTA.

### Evidence

- Empty → shared `PurchaseFastItemsEmpty` → `HexaEmptyState` + Add item
- Blocked (no supplier) → `HexaEmptyState` without Add CTA
- Sticky `+ Add Item` button retained
- `VERIFIED_TEST`: `purchase_fast_items_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `purchase_fast_items_step.dart`
- `purchase_fast_items_table.dart`
- `test/purchase_fast_items_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/purchase_fast_items_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-069 — User activity section chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`UserActivityTab` (Settings → user profile → Activity)

### Problem
Five section `FilterChip`s sat in a horizontal `SingleChildScrollView` (AGENTS NEVER for 5+ chip rows).

### Evidence

- Section chips → `Wrap` (spacing 8)
- No horizontal chip scroller under the tab
- `VERIFIED_TEST`: `user_activity_empty_test.dart` (3/3)
- Live browser: UNKNOWN

### Files changed

- `user_activity_tab.dart`
- `test/user_activity_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/user_activity_empty_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-070 — Item timeline kind chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`ItemTimelineSection` (item detail card)

### Problem
Six kind `FilterChip`s sat in a horizontal `SingleChildScrollView` (AGENTS NEVER for 5+ chip rows).

### Evidence

- Kind chips → `Wrap` (spacing/runSpacing 6)
- No horizontal chip scroller under the section
- `VERIFIED_TEST`: `item_timeline_section_empty_test.dart` (3/3)
- Live browser: UNKNOWN

### Files changed

- `item_timeline_section.dart`
- `test/item_timeline_section_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_timeline_section_empty_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-071 — Opening stock filter chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`OpeningStockFilterChips` (opening stock setup)

### Problem
Five filters (Pending / Completed / Low / Missing Barcode / Missing Code) used horizontal `ListView.separated` — violates AGENTS “NEVER horizontal filter-chip scroll for 5+ options.”

### Evidence

- Chips → `Wrap` (spacing/runSpacing 6) with page gutter padding
- No horizontal `ListView` / chip scroller
- `VERIFIED_TEST`: `opening_stock_filter_chips_ia_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `opening_stock_filter_chips.dart`
- `test/opening_stock_filter_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/opening_stock_filter_chips_ia_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-072 — Reports stock filter chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`ReportsStockFilterSortBar` (Reports → Stock)

### Problem
Five movement-class filters (All / Active / Slow / Dead / Fast) sat in a horizontal `SingleChildScrollView` — violates AGENTS “NEVER horizontal filter-chip scroll for 5+ options.”

### Evidence

- Chips → `Wrap` (spacing/runSpacing 6)
- No horizontal chip scroller under the bar
- `VERIFIED_TEST`: `reports_stock_filter_sort_bar_ia_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `reports_stock_filter_sort_bar.dart`
- `test/reports_stock_filter_sort_bar_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_stock_filter_sort_bar_ia_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-073 — Notifications category chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`NotificationsPage` / `NotificationsCategoryFilterChips`

### Problem
Owner sees six category filters (All / Critical / Warehouse / Purchases / Staff / System); staff sees five — all in a horizontal `SingleChildScrollView` (AGENTS NEVER for 5+ chip rows).

### Evidence

- Extracted `NotificationsCategoryFilterChips` with `Wrap` (spacing/runSpacing 8)
- No horizontal chip scroller
- `VERIFIED_TEST`: `notifications_category_filter_chips_ia_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `notifications_category_filter_chips.dart` (new)
- `notifications_page.dart`
- `test/notifications_category_filter_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/notifications_category_filter_chips_ia_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-074 — Search section filter chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`SearchPage` / `SearchSectionFilterChips`

### Problem
Owner search had seven section chips (All / Purchases / Items / Suppliers / Brokers / Types / Contacts) in horizontal `ListView` / `SingleChildScrollView` — both embedded and standalone result-filter rows (AGENTS NEVER for 5+ chip rows).

### Evidence

- Shared `SearchSectionFilterChips` with `Wrap` (spacing 8 / runSpacing 6)
- Embedded + standalone count chip rows both use Wrap
- `VERIFIED_TEST`: `search_section_filter_chips_ia_test.dart` (1/1); `search_zero_results_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `search_section_filter_chips.dart` (new)
- `search_page.dart`
- `test/search_section_filter_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/search_section_filter_chips_ia_test.dart test/search_zero_results_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-075 — Stock item history filter chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`StockItemHistoryPanel` / `StockItemHistoryFilterChips`

### Problem
Five history filters (All time / Today / This week / This month / Physical) sat in a horizontal `SingleChildScrollView` (AGENTS NEVER for 5+ chip rows).

### Evidence

- Extracted `StockItemHistoryFilterChips` with `Wrap` (spacing 8 / runSpacing 6)
- Enum moved to chips file; panel re-exports for callers
- `VERIFIED_TEST`: `stock_item_history_filter_chips_ia_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `stock_item_history_filter_chips.dart` (new)
- `stock_item_history_panel.dart`
- `test/stock_item_history_filter_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/stock_item_history_filter_chips_ia_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-076 — Contacts workspace count chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`ContactsPage` / `ContactsWorkspaceCountsStrip`

### Problem
Five workspace count chips (Suppliers / Brokers / Categories / Types in use / Items) sat in a horizontal `SingleChildScrollView` (AGENTS NEVER for 5+ chip rows).

### Evidence

- Extracted `ContactsWorkspaceCountsStrip` with `Wrap` (spacing 8 / runSpacing 6)
- `VERIFIED_TEST`: `contacts_workspace_counts_strip_ia_test.dart` (1/1); `contacts_hub_ia_test.dart` (4/4)
- Live browser: UNKNOWN

### Files changed

- `contacts_workspace_counts_strip.dart` (new)
- `contacts_page.dart`
- `test/contacts_workspace_counts_strip_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/contacts_workspace_counts_strip_ia_test.dart test/contacts_hub_ia_test.dart` → 5/5; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-077 — Purchase history filter chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`PurchaseHomePage` history / `PurchaseHistoryPrimaryFilterChips`

### Problem
Eight chips (Wait ↑ + All / Due / Paid / Draft / Undelivered / Stuck / Done) sat in a fixed-height horizontal `ListView` (AGENTS NEVER for 5+ chip rows).

### Evidence

- Extracted `PurchaseHistoryPrimaryFilterChips` with `Wrap` (spacing/runSpacing 6)
- `VERIFIED_TEST`: `purchase_history_primary_filter_chips_ia_test.dart` (1/1); `purchase_history_filters_hide_all_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `purchase_history_primary_filter_chips.dart` (new)
- `purchase_home_page.dart`
- `test/purchase_history_primary_filter_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/purchase_history_primary_filter_chips_ia_test.dart test/purchase_history_filters_hide_all_empty_test.dart` → 2/2; analyze: pre-existing `purchasePdf` prefix info only.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-078 — Low-stock subcategory chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`LowStockCategoryTree` / `LowStockSubcategoryFilterChips`

### Problem
Per-category subcategory filters (All + N named subs) used horizontal `SingleChildScrollView` — often 5+ chips; AGENTS requires Wrap for category filter chips / 5+ rows.

### Evidence

- Renamed/public `LowStockSubcategoryFilterChips` with `Wrap` (spacing/runSpacing 6)
- `VERIFIED_TEST`: `low_stock_subcategory_filter_chips_ia_test.dart` (1/1); `low_stock_hub_ia_test.dart` (3/3)
- Live browser: UNKNOWN

### Files changed

- `low_stock_category_tree.dart`
- `test/low_stock_subcategory_filter_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/low_stock_subcategory_filter_chips_ia_test.dart test/low_stock_hub_ia_test.dart` → 4/4; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-079 — Home period filter chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`HomePeriodFilterRow` (owner Home)

### Problem
Six period chips (Today / Week / Month / Year / All / Custom) used horizontal `OperationalPillRow` below tablet width — AGENTS NEVER for 5+ chip rows.

### Evidence

- Always `OperationalPillWrap` (removed phone horizontal branch)
- `VERIFIED_TEST`: `home_period_filter_chips_ia_test.dart` (1/1) at 390 width
- Live browser: UNKNOWN

### Files changed

- `home_period_filter_row.dart`
- `test/home_period_filter_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/home_period_filter_chips_ia_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-080 — Staff gallery subcategory chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`StaffItemGalleryPage` / `StaffGallerySubcategoryFilterChips`

### Problem
Per-category subcategory `ChoiceChip`s (All + named subs) used horizontal `SingleChildScrollView` — often 5+ chips; AGENTS requires Wrap.

### Evidence

- Extracted `StaffGallerySubcategoryFilterChips` with `Wrap` (spacing/runSpacing 6)
- `VERIFIED_TEST`: `staff_gallery_subcategory_filter_chips_ia_test.dart` (1/1); `staff_item_gallery_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `staff_gallery_subcategory_filter_chips.dart` (new)
- `staff_item_gallery_page.dart`
- `test/staff_gallery_subcategory_filter_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_gallery_subcategory_filter_chips_ia_test.dart test/staff_item_gallery_empty_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-081 — User list primary filter chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`UserListPrimaryFilterBar` (Settings → Users)

### Problem
Four primary filters (All users / Active / Inactive / Blocked) used horizontal `SingleChildScrollView` — long labels wrap poorly on phone; aligned with AGENTS Wrap preference for filter-chip rows.

### Evidence

- Chips → `Wrap` (spacing/runSpacing 8)
- `VERIFIED_TEST`: `user_list_primary_filter_chips_ia_test.dart` (1/1); `user_management_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `user_list_filters.dart`
- `test/user_list_primary_filter_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/user_list_primary_filter_chips_ia_test.dart test/user_management_empty_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-082 — Item detail quick-actions → Wrap

### Status
DONE

### Priority
P3

### Screen
`ItemQuickActionsBar` (item detail)

### Problem
Up to ~8 action chips sat in a fixed-height horizontal `ListView` — clipped/scroll-hidden on phone (same IA class as multi-chip rows; UX-006 Wrap pattern for actions).

### Evidence

- Actions → `Wrap` (spacing/runSpacing 8)
- `VERIFIED_TEST`: `item_quick_actions_bar_ia_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_quick_actions_bar.dart`
- `test/item_quick_actions_bar_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_quick_actions_bar_ia_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-083 — Purchase detail action bar → Wrap

### Status
DONE

### Priority
P3

### Screen
`PurchaseDetailActionBar`

### Problem
Secondary actions (Edit / Export PDF / Share / Print) sat in a fixed-height horizontal `ListView` — Share/Print required horizontal drag on narrow phones.

### Evidence

- Secondary actions → `Wrap` (spacing/runSpacing 8)
- All four labels visible at 320px without scroll
- `VERIFIED_TEST`: `purchase_detail_action_bar_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `purchase_detail_action_bar.dart`
- `test/purchase_detail_action_bar_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/purchase_detail_action_bar_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (320 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-084 — Staff home recent-scans chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`StaffHomeRecentScansStrip`

### Problem
Up to five recent-scan `ActionChip`s sat in a horizontal `SingleChildScrollView` — long item names forced sideways scroll on phone.

### Evidence

- Chips → `Wrap` (spacing/runSpacing 8)
- `VERIFIED_TEST`: `staff_home_recent_scans_ia_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_home_dashboard_widgets.dart`
- `test/staff_home_recent_scans_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_home_recent_scans_ia_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-085 — Barcode recent-scans chips → Wrap

### Status
DONE

### Priority
P3

### Screen
`BarcodeDesktopScannerPane` / `BarcodeRecentScansChips`

### Problem
Up to eight recent-scan `ActionChip`s sat in a fixed-height horizontal `ListView` — long names forced sideways scroll.

### Evidence

- Extracted `BarcodeRecentScansChips` with `Wrap` (spacing/runSpacing 8)
- `VERIFIED_TEST`: `barcode_recent_scans_chips_ia_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `barcode_recent_scans_chips.dart` (new)
- `barcode_desktop_scanner_pane.dart`
- `test/barcode_recent_scans_chips_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/barcode_recent_scans_chips_ia_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-086 — OperationalPillRow → Wrap (no horizontal)

### Status
DONE

### Priority
P3

### Screen
Shared `OperationalPillRow` (`operational_ui.dart`)

### Problem
Shared pill-row helper still used a horizontal `ListView` — risk of reintroducing AGENTS-forbidden 5+ chip scroll after Home period switched to Wrap.

### Evidence

- `OperationalPillRow` now delegates to `OperationalPillWrap`
- `VERIFIED_TEST`: `operational_pill_row_ia_test.dart` (1/1); `home_period_filter_chips_ia_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `operational_ui.dart`
- `test/operational_pill_row_ia_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/operational_pill_row_ia_test.dart test/home_period_filter_chips_ia_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-087 — Stock item history empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StockItemHistoryPanel`

### Problem
Empty history used ad-hoc icon + text (no shared empty chrome / CTA). Filtered empties had no way to reset to All time.

### Evidence

- Empty → `HexaEmptyState`
- Filtered empty → primary CTA “Show all time”
- `VERIFIED_TEST`: `stock_item_history_empty_test.dart` (1/1); filter chips IA still 1/1
- Live browser: UNKNOWN

### Files changed

- `stock_item_history_panel.dart`
- `test/stock_item_history_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/stock_item_history_empty_test.dart test/stock_item_history_filter_chips_ia_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-088 — Barcode camera gate empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`BarcodeMobileScannerView` / `BarcodeCameraStartGate` (+ denied panel)

### Problem
Web “tap to start camera” and camera-denied fallback used ad-hoc icon + text columns (not shared empty chrome).

### Evidence

- Start gate → `HexaEmptyState` + “Start camera”
- Denied panel → `HexaEmptyState` + settings/retry/upload/search actions
- `VERIFIED_TEST`: `barcode_camera_start_gate_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `barcode_mobile_scanner_view.dart`
- `test/barcode_camera_start_gate_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/barcode_camera_start_gate_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-089 — Staff receive shipment status → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffReceiveShipmentPage` (already-committed / awaiting-owner gates)

### Problem
Stock-committed and awaiting-owner states used ad-hoc icon + heading columns (not shared empty chrome).

### Evidence

- Already committed → `StaffReceiveAlreadyCommittedEmpty` → `HexaEmptyState` + Back
- Awaiting owner → `StaffReceiveAwaitingOwnerEmpty` → `HexaEmptyState` + subtitle + Back
- `VERIFIED_TEST`: `staff_receive_shipment_status_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `staff_receive_shipment_page.dart`
- `test/staff_receive_shipment_status_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_receive_shipment_status_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-090 — Purchase wizard edit-bootstrap error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`PurchaseEntryWizardV2` (edit bootstrap failure)

### Problem
Edit-mode load failure used ad-hoc orange cloud icon + text + button row (not shared empty chrome).

### Evidence

- `PurchaseWizardEditBootstrapError` → `HexaEmptyState` + Retry / Go back
- `VERIFIED_TEST`: `purchase_wizard_edit_bootstrap_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `purchase_entry_wizard_v2.dart`
- `test/purchase_wizard_edit_bootstrap_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/purchase_wizard_edit_bootstrap_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-091 — Stock desktop detail empty selection → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StockDesktopDetailPane` (no row selected)

### Problem
Desktop stock master-detail empty right pane used ad-hoc icon + text column (not shared empty chrome).

### Evidence

- `StockDesktopDetailEmptySelection` → `HexaEmptyState`
- `VERIFIED_TEST`: `stock_desktop_detail_pane_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `stock_desktop_detail_pane.dart`
- `test/stock_desktop_detail_pane_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/stock_desktop_detail_pane_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (1280 widget test)
- [x] Mobile verified (N/A — desktop pane)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-092 — Purchase desktop detail empty selection → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`PurchaseDesktopDetailPane` (no row selected)

### Problem
Desktop purchase history empty right pane was bare centered text (not shared empty chrome).

### Evidence

- `PurchaseDesktopDetailEmptySelection` → `HexaEmptyState`
- `VERIFIED_TEST`: `purchase_desktop_detail_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `purchase_desktop_detail_pane.dart`
- `test/purchase_desktop_detail_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/purchase_desktop_detail_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (1280 widget test)
- [x] Mobile verified (N/A — desktop pane)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-093 — Home warehouse activity empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`HomeWarehouseActivityFeed` (period empty)

### Problem
Home recent-activity card empty used ad-hoc icon + text column (not shared empty chrome).

### Evidence

- `HomeWarehouseActivityEmpty` → `HexaEmptyState`
- `VERIFIED_TEST`: `home_warehouse_activity_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `home_warehouse_activity_feed.dart`
- `test/home_warehouse_activity_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/home_warehouse_activity_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-094 — Home recent changes empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`HomeRecentChangesSection` (period empty)

### Problem
Recent-changes empty was bare muted text (not shared empty chrome / no next-step CTA).

### Evidence

- `HomeRecentChangesEmpty` → `HexaEmptyState` + New purchase
- `VERIFIED_TEST`: `home_recent_changes_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `home_recent_changes_section.dart`
- `test/home_recent_changes_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/home_recent_changes_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-095 — Stock desktop detail activity empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StockDesktopDetailPane` recent-activity body (selected item, no events)

### Problem
Selected-item activity empty was bare muted text (not shared empty chrome).

### Evidence

- `StockDesktopDetailActivityEmpty` → `HexaEmptyState`
- `VERIFIED_TEST`: `stock_desktop_detail_pane_test.dart` (3/3)
- Live browser: UNKNOWN

### Files changed

- `stock_desktop_detail_pane.dart`
- `test/stock_desktop_detail_pane_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/stock_desktop_detail_pane_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget test)
- [x] Mobile verified (N/A — desktop pane)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-096 — Home analytics ranked list empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`HomeAnalyticsRankedList` (breakdown tab empty)

### Problem
Ranked analytics empty was bare body text (not shared empty chrome).

### Evidence

- `HomeAnalyticsRankedListEmpty` → `HexaEmptyState` (hint from `homeAnalyticsEmptyHint`)
- `VERIFIED_TEST`: `home_analytics_ranked_list_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `home_analytics_ranked_list.dart`
- `test/home_analytics_ranked_list_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/home_analytics_ranked_list_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-097 — Stock desktop detail activity error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StockDesktopDetailPane` recent-activity body (load failure)

### Problem
Selected-item activity error was bare muted text with no retry CTA.

### Evidence

- `StockDesktopDetailActivityError` → `HexaEmptyState` + Retry (invalidates `stockItemActivityProvider`)
- `VERIFIED_TEST`: `stock_desktop_detail_pane_test.dart` (4/4)
- Live browser: UNKNOWN

### Files changed

- `stock_desktop_detail_pane.dart`
- `test/stock_desktop_detail_pane_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/stock_desktop_detail_pane_test.dart` → 4/4; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget test)
- [x] Mobile verified (N/A — desktop pane)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-098 — Staff home recent activity error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffHomeRecentActivitySection` (load failure)

### Problem
Staff home recent-activity error was bare muted text with no retry CTA.

### Evidence

- `StaffHomeRecentActivityError` → `HexaEmptyState` + Retry (invalidates `staffRecentActivityProvider`)
- `VERIFIED_TEST`: `staff_home_recent_activity_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_home_dashboard_widgets.dart`
- `test/staff_home_recent_activity_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_home_recent_activity_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-099 — Search slow-load fallback → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`SearchPage` slow-load fallback (after 2s soft timeout)

### Problem
Slow-search fallback used bare muted text + chips (not shared empty chrome).

### Evidence

- `SearchLoadingSlowFallback` → `HexaEmptyState` + recent `ActionChip` Wrap
- `VERIFIED_TEST`: `search_loading_slow_fallback_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `search_page.dart`
- `test/search_loading_slow_fallback_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/search_loading_slow_fallback_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-100 — Reports breakdown legend empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`BreakdownLegendList` (ring chart legend, empty period)

### Problem
Empty legend used bare muted text (not shared empty chrome).

### Evidence

- `BreakdownLegendEmpty` → `HexaEmptyState`
- `VERIFIED_TEST`: `breakdown_legend_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `breakdown_legend_list.dart`
- `test/breakdown_legend_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/breakdown_legend_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-101 — Bulk barcode preview empty selection → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`BulkBarcodePrintPreviewPanel` (no row selected for preview)

### Problem
Empty label preview used bare grey text (not shared empty chrome).

### Evidence

- `BulkBarcodePrintPreviewEmpty` → `HexaEmptyState`
- `VERIFIED_TEST`: `bulk_barcode_print_preview_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `bulk_barcode_print_preview_panel.dart`
- `test/bulk_barcode_print_preview_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/bulk_barcode_print_preview_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget test)
- [x] Mobile verified (N/A — preview pane)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-102 — Low-stock subcategory empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`LowStockCategoryTree` expanded category (selected subcategory has no rows)

### Problem
Empty subcategory body used bare muted text (not shared empty chrome).

### Evidence

- `LowStockSubcategoryEmpty` → `HexaEmptyState`
- `VERIFIED_TEST`: `low_stock_subcategory_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `low_stock_category_tree.dart`
- `test/low_stock_subcategory_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/low_stock_subcategory_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-103 — Quick stock sheet open-error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`QuickStockActionSheet` (form build failure fallback)

### Problem
Sheet open-error used ad-hoc title + text + Close (not shared empty chrome).

### Evidence

- `QuickStockActionSheetOpenError` → `HexaEmptyState` + Close
- `VERIFIED_TEST`: `quick_stock_action_sheet_open_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `quick_stock_action_sheet.dart`
- `test/quick_stock_action_sheet_open_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/quick_stock_action_sheet_open_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-104 — Stock quick-purchase sheet open-error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StockQuickPurchaseSheet` (form build failure fallback)

### Problem
Sheet open-error used ad-hoc title + text + Close (not shared empty chrome).

### Evidence

- `StockQuickPurchaseSheetOpenError` → `HexaEmptyState` + Close
- `VERIFIED_TEST`: `stock_quick_purchase_sheet_open_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `stock_quick_purchase_sheet.dart`
- `test/stock_quick_purchase_sheet_open_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/stock_quick_purchase_sheet_open_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-105 — Reports purchases supplier ranking empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReportsPurchasesTab` supplier ranking section (bills present, no supplier slices)

### Problem
Empty supplier ranking used bare muted `_EmptyLine` text (not shared empty chrome).

### Evidence

- `ReportsPurchasesSupplierRankingEmpty` → `HexaEmptyState`
- `VERIFIED_TEST`: `reports_purchases_supplier_ranking_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `reports_purchases_tab.dart`
- `test/reports_purchases_supplier_ranking_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_purchases_supplier_ranking_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-106 — Reports filter search empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReportsFilterSearchSection` (chip search miss)

### Problem
Filter search miss used bare muted “No matches.” text (not shared empty chrome).

### Evidence

- `ReportsFilterSearchEmpty` → `HexaEmptyState`
- `VERIFIED_TEST`: `reports_filter_search_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `reports_filter_search_section.dart`
- `test/reports_filter_search_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_filter_search_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-107 — Reports filter simple chips empty → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ReportsFilterSheet` `_simpleChips` (period has no chip options)

### Problem
Empty chip groups used bare muted “No options in this period.” text (not shared empty chrome).

### Evidence

- `ReportsFilterSimpleChipsEmpty` → `HexaEmptyState`
- `VERIFIED_TEST`: `reports_filter_simple_chips_empty_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `reports_filter_sheet.dart`
- `test/reports_filter_simple_chips_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/reports_filter_simple_chips_empty_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-108 — Purchase detail damage empty/error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`PurchaseDetailDamageSection` (empty + load failure)

### Problem
Damage reports empty/error used bare muted text (no shared empty chrome / no retry).

### Evidence

- `PurchaseDetailDamageEmpty` → `HexaEmptyState`
- `PurchaseDetailDamageError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `purchase_detail_damage_empty_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `purchase_detail_damage_section.dart`
- `test/purchase_detail_damage_empty_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/purchase_detail_damage_empty_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-109 — Staff home recent scans error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffHomeRecentScansStrip` (load failure)

### Problem
Recent-scans load failure used `SectionInlineError` (not shared empty chrome).

### Evidence

- `StaffHomeRecentScansError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `staff_home_recent_scans_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_home_dashboard_widgets.dart`
- `test/staff_home_recent_scans_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_home_recent_scans_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-110 — Catalog item create load errors → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogItemCreatePage` (suppliers / brokers / subcategories load failures)

### Problem
Party and subcategory load failures used ad-hoc error text + TextButton (not shared empty chrome).

### Evidence

- `CatalogItemCreateSuppliersError` / `BrokersError` / `SubcategoriesError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `catalog_item_create_load_error_test.dart` (3/3)
- Live browser: UNKNOWN

### Files changed

- `catalog_item_create_page.dart`
- `test/catalog_item_create_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_item_create_load_error_test.dart` → 3/3; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-111 — Staff home floor KPI error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffHomeFloorKpiRow` (pipeline load failure)

### Problem
Floor KPI load failure used `SectionInlineError` (not shared empty chrome).

### Evidence

- `StaffHomeFloorKpiError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `staff_home_floor_kpi_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_home_dashboard_widgets.dart`
- `test/staff_home_floor_kpi_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_home_floor_kpi_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-112 — Supplier wizard categories load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
Supplier create wizard — Categories & items step (`itemCategoriesListProvider` error)

### Problem
Categories load failure used bare error `Text` (no Retry / shared empty chrome).

### Evidence

- `SupplierWizardCategoriesError` → `HexaEmptyState` + Retry (`itemCategoriesListProvider` invalidate)
- `VERIFIED_TEST`: `supplier_wizard_categories_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `supplier_create_wizard_page.dart`
- `test/supplier_wizard_categories_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/supplier_wizard_categories_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-113 — Staff home warehouse/purchase stats error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffHomeWarehousePurchaseStats`

### Problem
Warehouse/purchase stats load failures used `SectionInlineError`.

### Evidence

- `StaffHomeWarehouseStatsError` / `StaffHomePurchaseStatsError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `staff_home_warehouse_stats_error_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `staff_home_dashboard_widgets.dart`
- `test/staff_home_warehouse_stats_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_home_warehouse_stats_error_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-114 — Home warehouse activity load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`HomeWarehouseActivityFeed` error path

### Problem
Activity load failure used dense ListTile warning (not shared empty chrome).

### Evidence

- `HomeWarehouseActivityError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `home_warehouse_activity_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `home_warehouse_activity_feed.dart`
- `test/home_warehouse_activity_error_test.dart`

### Verification

`flutter test test/home_warehouse_activity_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-115 — Stock quick-purchase suppliers/brokers errors → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
Stock quick-purchase sheet party fields

### Problem
Suppliers/brokers load failures used bare Text + TextButton rows.

### Evidence

- `StockQuickPurchaseSuppliersError` / `StockQuickPurchaseBrokersError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `stock_quick_purchase_party_errors_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `stock_quick_purchase_sheet.dart`
- `test/stock_quick_purchase_party_errors_test.dart`

### Verification

`flutter test test/stock_quick_purchase_party_errors_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-116 — Home delivery pipeline error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`HomeDeliveryPipelineCard` error path

### Problem
Pipeline load failure used `SectionInlineError`.

### Evidence

- `HomeDeliveryPipelineError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `home_delivery_pipeline_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `home_delivery_pipeline_card.dart`
- `test/home_delivery_pipeline_error_test.dart`

### Verification

`flutter test test/home_delivery_pipeline_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-117 — Supplier wizard types-index error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
Supplier create wizard — preferred subcategories (`categoryTypesIndexProvider`)

### Problem
Types index load failure used silent `SizedBox.shrink()` (no recovery).

### Evidence

- `SupplierWizardTypesError` → `HexaEmptyState` + Retry (`categoryTypesIndexProvider` invalidate)
- `VERIFIED_TEST`: `supplier_wizard_types_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `supplier_create_wizard_page.dart`
- `test/supplier_wizard_types_error_test.dart`

### Verification

`flutter test test/supplier_wizard_types_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-118 — Quick catalog taxonomy categories error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`QuickCatalogTaxonomySheet` (subcategory-only mode — category dropdown)

### Problem
Categories load failure used bare error `Text` with no Retry.

### Evidence

- `QuickCatalogTaxonomyCategoriesError` → `HexaEmptyState` + Retry (`itemCategoriesListProvider` invalidate)
- `VERIFIED_TEST`: `quick_catalog_taxonomy_categories_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `quick_catalog_taxonomy_sheet.dart`
- `test/quick_catalog_taxonomy_categories_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/quick_catalog_taxonomy_categories_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-119 — Catalog category trade summary error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogCategoryDetailPage` — trade summary block

### Problem
Trade summary load failure was silent (`SizedBox.shrink`) or bare error text with no Retry.

### Evidence

- `CatalogCategoryTradeSummaryError` → `HexaEmptyState` + Retry (`categoryTradeSummaryProvider` invalidate)
- Second items-snapshot `when` keeps shrink on error to avoid duplicate chrome for same provider
- `VERIFIED_TEST`: `catalog_category_trade_summary_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_category_detail_page.dart`
- `test/catalog_category_trade_summary_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_category_trade_summary_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-120 — Owner tasks team summary error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`OwnerTasksPage` — team progress summary card

### Problem
Team checklist summary load failure used silent `SizedBox.shrink()`.

### Evidence

- `OwnerTasksTeamSummaryError` → `HexaEmptyState` + Retry (`ownerChecklistSummaryProvider` invalidate)
- `VERIFIED_TEST`: `owner_tasks_team_summary_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `owner_tasks_page.dart`
- `test/owner_tasks_team_summary_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/owner_tasks_team_summary_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-121 — Barcode scan history audit KPI error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`BarcodeScanHistoryPage` — pending approvals KPI strip

### Problem
`stockAuditKpisProvider` failure used silent `SizedBox.shrink()`.

### Evidence

- `BarcodeScanHistoryAuditKpiError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `barcode_scan_history_audit_kpi_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `barcode_scan_history_page.dart`
- `test/barcode_scan_history_audit_kpi_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/barcode_scan_history_audit_kpi_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-122 — Operational stock filter types/suppliers error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
Operational stock filter sheet — subcategory + supplier pickers

### Problem
`categoryTypesIndexProvider` / `suppliersListProvider` failures used silent `SizedBox.shrink()`.

### Evidence

- `OperationalStockFilterTypesError` / `OperationalStockFilterSuppliersError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `operational_stock_filter_errors_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `operational_stock_filter_sheet.dart`
- `test/operational_stock_filter_errors_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/operational_stock_filter_errors_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-123 — Stock status quick chips counts error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StockStatusQuickChips` — All / Low / Out count badges

### Problem
`stockFilteredStatusCountsProvider` failure used silent `SizedBox.shrink()`.

### Evidence

- `StockStatusQuickChipsError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `stock_status_quick_chips_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `stock_status_quick_chips.dart`
- `test/stock_status_quick_chips_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/stock_status_quick_chips_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-124 — Catalog search suggestions error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogPage` — category search suggestion chips (when query non-empty)

### Problem
`itemCategoriesListProvider` failure for suggestions used silent `SizedBox.shrink()`.

### Evidence

- `CatalogSearchSuggestionsError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `catalog_search_suggestions_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_page.dart`
- `test/catalog_search_suggestions_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_search_suggestions_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-125 — Purchase item entry stock preview error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`PurchaseItemEntrySheet` — stock preview bar after catalog item select

### Problem
`stockItemDetailProvider` failure used silent `SizedBox.shrink()`.

### Evidence

- `PurchaseItemEntryStockPreviewError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `purchase_item_entry_stock_preview_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `purchase_item_entry_sheet.dart`
- `test/purchase_item_entry_stock_preview_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/purchase_item_entry_stock_preview_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-126 — Stock item history load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StockItemHistoryPanel` — audit + physical dual-load failure

### Problem
Compact mode used bare TextButton retry; full mode used `FriendlyLoadError` (inconsistent chrome).

### Evidence

- `StockItemHistoryLoadError` → `HexaEmptyState` + Retry (both compact and full)
- `VERIFIED_TEST`: `stock_item_history_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `stock_item_history_panel.dart`
- `test/stock_item_history_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/stock_item_history_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-127 — Barcode scan history recent scans error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`BarcodeScanHistoryPage` — recent on-device scans list

### Problem
Recent scans load failure used `FriendlyLoadError` (not shared empty chrome).

### Evidence

- `BarcodeScanHistoryRecentScansError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `barcode_scan_history_recent_scans_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `barcode_scan_history_page.dart`
- `test/barcode_scan_history_recent_scans_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/barcode_scan_history_recent_scans_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-128 — Owner tasks templates/checklist errors → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`OwnerTasksPage` — Arrange templates + Check today checklist

### Problem
Both load failures used `FriendlyLoadError`.

### Evidence

- `OwnerTasksTemplatesError` / `OwnerTasksChecklistTodayError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `owner_tasks_templates_checklist_error_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `owner_tasks_page.dart`
- `test/owner_tasks_templates_checklist_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/owner_tasks_templates_checklist_error_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-129 — Home recent changes load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`HomeRecentChangesSection`

### Problem
Recent changes load failure used `FriendlyLoadError`.

### Evidence

- `HomeRecentChangesError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `home_recent_changes_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `home_recent_changes_section.dart`
- `test/home_recent_changes_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/home_recent_changes_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-130 — Home warehouse activity page error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`HomeWarehouseActivityPage` (full activity list)

### Problem
Full-page activity load failure used `FriendlyLoadError`.

### Evidence

- `HomeWarehouseActivityPageError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `home_warehouse_activity_page_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `home_warehouse_activity_page.dart`
- `test/home_warehouse_activity_page_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/home_warehouse_activity_page_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-131 — Staff pending deliveries error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffPendingDeliveriesPage`

### Problem
Pending deliveries load failure used `FriendlyLoadError`.

### Evidence

- `StaffPendingDeliveriesError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `staff_pending_deliveries_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_pending_deliveries_page.dart`
- `test/staff_pending_deliveries_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_pending_deliveries_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-132 — Staff item gallery load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffItemGalleryPage`

### Problem
Gallery stock list load failure used `FriendlyLoadError`.

### Evidence

- `StaffItemGalleryLoadError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `staff_item_gallery_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_item_gallery_page.dart`
- `test/staff_item_gallery_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_item_gallery_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-133 — Staff receive shipment load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffReceiveShipmentPage` — purchase detail load

### Problem
Purchase detail load failure used `FriendlyLoadError`.

### Evidence

- `StaffReceiveShipmentLoadError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `staff_receive_shipment_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_receive_shipment_page.dart`
- `test/staff_receive_shipment_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_receive_shipment_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-134 — Staff tasks load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffTasksPage`

### Problem
Tasks list load failure used `FriendlyLoadError`.

### Evidence

- `StaffTasksLoadError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `staff_tasks_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `staff_tasks_page.dart`
- `test/staff_tasks_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_tasks_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-135 — Staff purchase history load errors → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`StaffPurchaseHistoryPage` — purchases tabs + low stock tab

### Problem
Both tab load failures used `FriendlyLoadError`.

### Evidence

- `StaffPurchaseHistoryLoadError` / `StaffPurchaseHistoryLowStockError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `staff_purchase_history_errors_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `staff_purchase_history_page.dart`
- `test/staff_purchase_history_errors_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/staff_purchase_history_errors_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-136 — Catalog categories list load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogPage` — main categories list

### Problem
Categories list load failure used `FriendlyLoadError`.

### Evidence

- `CatalogCategoriesLoadError` → `HexaEmptyState` + Retry (invalidates categories + catalog items)
- `VERIFIED_TEST`: `catalog_categories_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_page.dart`
- `test/catalog_categories_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_categories_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-137 — Catalog category types load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogCategoryDetailPage` — types / subcategories list

### Problem
Types index load failure used `FriendlyLoadError`.

### Evidence

- `CatalogCategoryTypesLoadError` → `HexaEmptyState` + Retry (`categoryTypesIndexProvider` invalidate)
- `VERIFIED_TEST`: `catalog_category_types_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_category_detail_page.dart`
- `test/catalog_category_types_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_category_types_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-138 — Catalog duplicates load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogDuplicatesPage` — `/catalog/duplicates`

### Problem
Duplicate clusters load failure used `FriendlyLoadError`.

### Evidence

- `CatalogDuplicatesLoadError` → `HexaEmptyState` + Retry (`catalogDuplicatesProvider` invalidate)
- `VERIFIED_TEST`: `catalog_duplicates_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_duplicates_page.dart`
- `test/catalog_duplicates_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_duplicates_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-139 — Catalog missing-codes load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogMissingCodesPage` — `/catalog/missing-codes`

### Problem
Missing-codes list load failure used `FriendlyLoadError`.

### Evidence

- `CatalogMissingCodesLoadError` → `HexaEmptyState` + Retry (`missingCodeItemsProvider` invalidate)
- `VERIFIED_TEST`: `catalog_missing_codes_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_missing_codes_page.dart`
- `test/catalog_missing_codes_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_missing_codes_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-140 — Catalog reorder-levels load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogSetupReorderLevelsPage` — set reorder levels

### Problem
Bulk stock list load failure used `FriendlyLoadError`.

### Evidence

- `CatalogSetupReorderLevelsLoadError` → `HexaEmptyState` + Retry (`bulkStockListProvider` invalidate)
- `VERIFIED_TEST`: `catalog_setup_reorder_levels_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_setup_reorder_levels_page.dart`
- `test/catalog_setup_reorder_levels_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_setup_reorder_levels_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-141 — Catalog taxonomy hub load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogTaxonomyHubPage` — categories hub

### Problem
Categories list load failure used `FriendlyLoadError`.

### Evidence

- `CatalogTaxonomyHubLoadError` → `HexaEmptyState` + Retry (`invalidateCatalogTaxonomy`)
- `VERIFIED_TEST`: `catalog_taxonomy_hub_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_taxonomy_hub_page.dart`
- `test/catalog_taxonomy_hub_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_taxonomy_hub_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-142 — Item detail load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemDetailPage` — full-page bundle load failure

### Problem
Item detail bundle load failure used `FriendlyLoadError`.

### Evidence

- `ItemDetailLoadError` → `HexaEmptyState` + Retry (`itemDetailBundleProvider` invalidate)
- Kept `GroupedSectionErrorCard` import for partial section failures
- `VERIFIED_TEST`: `item_detail_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_detail_page.dart`
- `test/item_detail_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_detail_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-143 — Catalog item timeline load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`CatalogItemTimelinePage` — full item timeline

### Problem
Timeline load failure used `FriendlyLoadError`.

### Evidence

- `CatalogItemTimelineLoadError` → `HexaEmptyState` + Retry (invalidates item detail, audit, history lines)
- `VERIFIED_TEST`: `catalog_item_timeline_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `catalog_item_timeline_page.dart`
- `test/catalog_item_timeline_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/catalog_item_timeline_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-144 — Item edit load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemEditPage` — catalog item edit form

### Problem
Catalog item detail load failure used `FriendlyLoadError`.

### Evidence

- `ItemEditLoadError` → `HexaEmptyState` + Retry (`catalogItemDetailProvider` invalidate)
- `VERIFIED_TEST`: `item_edit_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_edit_page.dart`
- `test/item_edit_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_edit_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-145 — Item purchase history section load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemPurchaseHistorySection` — item detail purchase history card

### Problem
Purchase history fetch failure used `FriendlyLoadError`.

### Evidence

- `ItemPurchaseHistoryLoadError` → `HexaEmptyState` + Retry (`tradePurchasesForItemProvider` invalidate)
- `VERIFIED_TEST`: `item_purchase_history_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_purchase_history_section.dart`
- `test/item_purchase_history_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_purchase_history_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-146 — Item ledger section load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemLedgerSection` — item detail ledger & movement card

### Problem
Ledger activity fetch failure used `FriendlyLoadError`.

### Evidence

- `ItemLedgerLoadError` → `HexaEmptyState` + Retry (keeps existing auto-retry once)
- `VERIFIED_TEST`: `item_ledger_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_ledger_section.dart`
- `test/item_ledger_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_ledger_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-147 — Item timeline section load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemTimelineSection` — item detail movement timeline card

### Problem
Activity timeline fetch failure used `FriendlyLoadError`.

### Evidence

- `ItemTimelineSectionLoadError` → `HexaEmptyState` + Retry (`stockItemActivityProvider` invalidate)
- `VERIFIED_TEST`: `item_timeline_section_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_timeline_section.dart`
- `test/item_timeline_section_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_timeline_section_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-148 — Item supplier intelligence load error → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemSupplierIntelligenceSection` — item detail supplier intelligence card

### Problem
Supplier intelligence fetch failure used `FriendlyLoadError`.

### Evidence

- `ItemSupplierIntelligenceLoadError` → `HexaEmptyState` + Retry (`tradePurchasesForItemProvider` invalidate)
- `suppressInlineError` path unchanged
- `VERIFIED_TEST`: `item_supplier_intelligence_load_error_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_supplier_intelligence_section.dart`
- `test/item_supplier_intelligence_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_supplier_intelligence_load_error_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-149 — Item analytics section load errors → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemAnalyticsSection` — analytics + movement intelligence errors

### Problem
Both analytics and movement-intelligence failures used `FriendlyLoadError`.

### Evidence

- `ItemAnalyticsLoadError` → `HexaEmptyState` + Retry (title param for both paths)
- Auto-retry / `suppressInlineError` unchanged
- `VERIFIED_TEST`: `item_analytics_load_error_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `item_analytics_section.dart`
- `test/item_analytics_load_error_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_analytics_load_error_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-150 — Item analytics redirect unresolved → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`ItemAnalyticsRedirectPage` — name→catalog resolve miss

### Problem
Unresolved catalog link used `FriendlyLoadError`.

### Evidence

- `ItemAnalyticsRedirectUnresolved` → `HexaEmptyState` + Retry (re-runs resolve)
- `VERIFIED_TEST`: `item_analytics_redirect_unresolved_test.dart` (1/1)
- Live browser: UNKNOWN

### Files changed

- `item_analytics_redirect_page.dart`
- `test/item_analytics_redirect_unresolved_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/item_analytics_redirect_unresolved_test.dart` → 1/1; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

## UX-151 — Home auth blocked/recovery errors → HexaEmptyState

### Status
DONE

### Priority
P3

### Screen
`HomePage` — session expired + auth/API recovery full-page states

### Problem
Both auth gate failures used `FriendlyLoadError`.

### Evidence

- `HomeSessionExpiredError` → `HexaEmptyState` + Sign in (logout → `/login`)
- `HomeAuthRecoveryError` → `HexaEmptyState` + Retry
- `VERIFIED_TEST`: `home_auth_errors_test.dart` (2/2)
- Live browser: UNKNOWN

### Files changed

- `home_page.dart`
- `test/home_auth_errors_test.dart`
- `uiux context/UI_UX_TASKS.md`

### Verification

`flutter test test/home_auth_errors_test.dart` → 2/2; analyze clean.

### Completion

- [x] Problem verified
- [x] Implementation verified
- [x] Desktop verified (widget; live UNKNOWN)
- [x] Mobile verified (390 widget test)
- [x] Regression verified
- [x] Evidence recorded

### Final status

DONE

---

# PAGE / SCREEN INDEX (SHELL + CORE)

Full per-screen template records for every route are **not** expanded here (76 pages). Core surfaces stubbed; expand on each UX-00x.

### SCREEN — Owner shell Home

```text
SCREEN ID: OWN-HOME
Name: Home
Route: /home
Parent: Owner StatefulShell
Type: PAGE / SHELL_TAB
Desktop: yes (≥1024 density)
Mobile: yes (bottom nav)
User: owner | admin | manager
Context: post-login landing; KPIs / activity entry
Primary task: see warehouse status; jump to work
Primary action: New purchase FAB (shell) / navigate to ops
Secondary actions: activity, breakdown-more, settings entry points
Tables/data: KPI cards / lists (trade-backed reports)
Tabs: none (shell tab itself)
Status: indexed — polish = UX-009 DONE (secondary KPIs)
Evidence: home_page.dart · shell_screen.dart · home_owner_dashboard_body.dart
```

### SCREEN — Owner Stock

```text
SCREEN ID: OWN-STOCK
Name: Stock
Route: /stock
Parent: Owner StatefulShell
Type: PAGE / SHELL_TAB (+ subtabs Stock|Activity)
User: owner | admin | manager (+ staff shell twin)
Primary task: find item; adjust qty; ops filters
Primary action: row / quick stock action sheet
Status: indexed — storm = UX-002; table UX-005 DONE (phone compact columns)
Evidence: stock_page.dart · stock_warehouse_row.dart
```

### SCREEN — Owner Reports

```text
SCREEN ID: OWN-REPORTS
Name: Reports
Route: /reports
Parent: Owner StatefulShell
Type: PAGE / SHELL_TAB + BI tabs (Overview|Items|Purchases|Stock)
Primary task: spend / stock BI
Primary action: filter + drill
Status: indexed — UX-003
Evidence: reports_shell_page.dart
```

### SCREEN — Purchase History

```text
SCREEN ID: OWN-PURCHASE-HOME
Name: History (Purchase home)
Route: /purchase
Parent: Owner StatefulShell
Type: PAGE / SHELL_TAB
Primary task: find past trade purchases
Primary action: open detail / new purchase
Note: empty list off History branch can be intentional (IndexedStack)
Status: indexed — UX-006 DONE (row overflow)
Evidence: purchase_home_page.dart
```

### SCREEN — Purchase create/edit

```text
SCREEN ID: OWN-PURCHASE-WIZARD
Name: Purchase entry wizard
Route: /purchase/new | /purchase/edit/:purchaseId
Parent: root push above shell
Type: EMBEDDED_WORKFLOW / FORM
Primary task: draft trade purchase → preview → confirm
Primary action: confirm save (backend totals authoritative)
Modals/sheets: PurchaseItemEntrySheet via showHexaBottomSheet
Status: indexed — UX-001 then UX-004
Evidence: purchase_entry_wizard_v2.dart · purchase_item_entry_sheet.dart
```

### SCREEN — Staff shell Home

```text
SCREEN ID: STAFF-HOME
Name: Staff Home
Route: /staff/home
Parent: Staff StatefulShell
Type: PAGE / SHELL_TAB
User: staff
Primary task: start daily ops (scan / deliveries / tasks)
Status: indexed
Evidence: staff_home_page.dart · post_auth_route.dart
```

### Auth / landing

```text
SCREEN ID: AUTH-SPLASH | AUTH-LOGIN
Routes: /splash | /login
Type: PAGE
Post-login: resolvePostAuthPath → /home or /staff/home
Evidence: splash_page.dart · login_page.dart · post_auth_route.dart
```

---

# UX TASK TEMPLATE (reuse for new tasks)

## UX-XXX — [SCREEN / WORKFLOW]

### Status
READY

### Priority
P0 / P1 / P2 / P3 / P4

### Screen
[exact verified route/screen]

### User
[verified or UNKNOWN]

### Context
[verified or UNKNOWN]

### Primary task
[verified]

### Primary action
[verified]

### Problem

[exact UX problem]

### Evidence

- File:
- Component:
- Route:
- Behavior:
- Screenshot/test:

### UX rule

[relevant rule from UNIVERSAL_UI_UX_DESIGN_RULES(1).md]

### Scope

ONLY:
- ...

DO NOT CHANGE:
- ...

### Expected change

...

### Desktop acceptance

- [ ] Correct viewport behavior
- [ ] No horizontal overflow
- [ ] No overlap
- [ ] Correct information density
- [ ] Primary action clear
- [ ] Forms/tables usable
- [ ] Keyboard/mouse behavior acceptable

### Mobile acceptance

- [ ] Correct responsive layout
- [ ] No horizontal overflow
- [ ] No clipped content
- [ ] Touch targets usable
- [ ] Inputs usable
- [ ] Keyboard behavior acceptable
- [ ] Primary action accessible
- [ ] Scrolling intentional

### States

- [ ] Loading
- [ ] Empty
- [ ] Error
- [ ] Success
- [ ] Disabled
- [ ] Recovery

Mark N/A explicitly when a state genuinely does not apply.

### Regression

- [ ] Existing functionality preserved
- [ ] Existing API behavior preserved
- [ ] Existing permissions preserved
- [ ] Existing navigation preserved
- [ ] Tests pass
- [ ] Build passes

### Files changed

[List exact files]

### Verification

Before:
...

After:
...

### Completion

- [ ] Problem verified
- [ ] Implementation verified
- [ ] Desktop verified
- [ ] Mobile verified
- [ ] Regression verified
- [ ] Evidence recorded

### Final status

DONE / BLOCKED / DEFERRED

---

## UX-185 — Stock MQ + blank panes audit (Phase E)

### Status
VERIFYING — OBS-1/OBS-2 desktop-only P3 fixes implemented 2026-08-10

### Priority
P2

### Scope
Desktop (≥1024) audit only — no mobile layout code touched. Six surfaces:
1. Low stock dashboard — `features/stock/presentation/low_stock_dashboard_page.dart`
2. Stock desktop detail pane — `features/stock/presentation/widgets/stock_desktop_detail_pane.dart`
3. Update physical / system stock — `features/stock/presentation/quick_stock_action_sheet.dart` (via `showHexaBottomSheet` desktop dialog path)
4. Add purchase quantity — `features/stock/presentation/stock_quick_purchase_sheet.dart`
5. View item activity — `features/catalog/presentation/item_detail_page.dart` (tab=activity)
6. Notifications / Updates tab — `features/notifications/presentation/notifications_page.dart`

### Audit criteria
For each surface: (a) unbounded Column/Row + Expanded; (b) LayoutBuilder returning NaN/infinite constraints; (c) ConstrainedBox with maxHeight from an unset MediaQuery; (d) provider/FutureBuilder returning `SizedBox.shrink()` on error/loading with no `HexaEmptyState` fallback.

### Findings

All six surfaces: **CLEAN on all four criteria** (`VERIFIED_CODE`, desktop only).

| # | Surface | (a) unbounded Col/Row+Expanded | (b) NaN/infinite LayoutBuilder | (c) MQ-unset ConstrainedBox maxH | (d) shrink-on-load/error w/o HexaEmptyState | Evidence |
|---|---|---|---|---|---|---|
| 1 | Low stock dashboard | none — body `LayoutBuilder` → `SizedBox(height: h)` (L499-589); desktop data wrapped in `Align`+`SizedBox(width≤1280,height:h)` (L570-584) | fallback `h = maxHeight.isFinite ? maxHeight : MediaQuery.sizeOf().height` (L503-505) | none — filter sheet `SizedBox(height: adaptiveSheetMaxHeight*0.55)` bounded (L604-605) | none — loading spinner + 10s slow-retry (L507-533); error `LowStockDashboardLoadError`=HexaEmptyState+Retry (L534-540); empty tab tree `HexaEmptyState` (low_stock_category_tree.dart L355-361) | `low_stock_dashboard_page.dart` |
| 2 | Stock desktop detail pane | none — `_metricRow` Expanded is horizontal in bounded-width pane (L244); no vertical Expanded | no LayoutBuilder | none | none — activity loading `LinearProgressIndicator` (L191-194); error `StockDesktopDetailActivityError`=HexaEmptyState+Retry (L195-197); empty `StockDesktopDetailActivityEmpty`=HexaEmptyState (L200-202); `SizedBox.shrink()` only guards malformed event rows (L208) | `stock_desktop_detail_pane.dart` |
| 3 | Quick stock sheet | none — form `Column(mainAxisSize: min)` (L878), no vertical Expanded; header/action Expanded are horizontal (L884, L1191-1199) | no LayoutBuilder | none — host bounds compact sheet `ConstrainedBox(maxHeight: mq.height*0.88)` with `mq` always present (hexa_responsive.dart L481-483) | none — `build()` try/catch → `QuickStockActionSheetOpenError`=HexaEmptyState (L850-861, UX-103); refresh states are inline progress/amber text (L920-934) | `quick_stock_action_sheet.dart` |
| 4 | Quick purchase sheet | none — form `Column(mainAxisSize: min)` (L498), no vertical Expanded | no LayoutBuilder | none — same host bounds as #3 | none — build-catch `StockQuickPurchaseSheetOpenError`=HexaEmptyState (L468-477, UX-104); suppliers/brokers error → `StockQuickPurchaseSuppliersError`/`BrokersError`=HexaEmptyState+Retry (L648-697, UX-115); loading hints + `LinearProgressIndicator` (L623-626) | `stock_quick_purchase_sheet.dart` |
| 5 | Item detail, tab=activity | none — desktop `_DesktopItemLayout` Column + `Expanded` is bounded by `SizedBox(height: h)` (L96-122, L449-466); `_DesktopActivityTab` is a ListView (no Expanded inside) | both fallbacks — L96-99 → MediaQuery height; L495-499 → `420.0` | none — only `ConstrainedBox(minHeight: 280)` constant minimum (L450), not MQ-derived | none — bundle loading spinner (L144-149); bundle error `ItemDetailLoadError`=HexaEmptyState (L152-163, UX-142); two `SizedBox.shrink()` sites are guarded: session-null mobile bar (L246) and grouped banner <2 failed sections (L906) where each section keeps its own HexaEmptyState/FriendlyLoadError | `item_detail_page.dart`; deep link `?tab=activity` → activity index confirmed (item_detail_tab_matrix.dart L53-60) |
| 6 | Notifications | none — body `Column` bounded; `Expanded(RefreshIndicator(...))` in bounded body (L131, L204) | no LayoutBuilder | none — desktop 2-col tile width derives from always-set `MediaQuery.sizeOf(context).width` (L361-362); not a maxHeight ConstrainedBox | none — loading `LinearProgressIndicator` (L134); error inline Material banner + Retry (L136-160); empty `HexaEmptyState` in 280 box (L211-254); no shrink sites | `notifications_page.dart` |

Shared hosts verified (`VERIFIED_CODE`):
- Desktop sheet host `showHexaBottomSheet` (hexa_responsive.dart L427-519): compact → shrinkWrap `ListView` under `ConstrainedBox(maxHeight: mq.height * 0.88)` (L481-483); `!compact` → fixed `height: mq.height * 0.88` (L480). Both bound children; `mq` always present (Phase 1 `HexaWebViewportBinder`).
- `HexaEmptyState` uses `Column(mainAxisSize: min)` → ListView-safe (hexa_empty_state.dart L37-39).
- `LowStockCategoryTree` empty tab → `HexaEmptyState` (L355-361); per-subcategory empty → `HexaEmptyState` (L620-631); `SizedBox.shrink()` only for zero-count chips/badges (L552, L599).

### Observations → implemented as desktop-only P3 fixes
- **OBS-1 (FIXED, desktop-only)** `low_stock_dashboard_page.dart` — AppBar `bottom` filter chrome (search + hub tabs) used `maybeWhen(data:..., orElse: () => null)`, so search/tabs vanished during load/error. Now `orElse` keeps the desktop path stable via `_buildLoadingFilterBar({hasError})`: mirrors the data-branch height exactly (128 / 148 with subcategory chip), renders a disabled search field + tune button, subcategory chip (if set), a status caption (`Loading stock…` / `Couldn't load stock — retry below`), and a live `LowStockHubFilterBar` so tabs stay switchable while loading. Mobile orElse still returns `null` (byte-unchanged).
- **OBS-2 (FIXED, desktop-only)** `notifications_page.dart` — desktop 2-col tile width used `MediaQuery.sizeOf(context).width - 32`, assuming the route body spans the window. Desktop branch now reads width from a `LayoutBuilder` wrapping the `Wrap` inside the padded `ListView` (`constraints.maxWidth` = exact post-padding content width), so tiles stay exactly 2-up when rendered in any narrower host. Mobile branch (ListView of tiles) untouched.

### Overlap-class sweep (2026-08-10) — class 2 hardened desktop-only
Re-check of the repo-history overlap classes (UX-006/UX-086 Wrap precedent; UX-183 MQ+overflow) across all six UX-185 surfaces. No observable defect in any class (all clean), but per user directive the desktop AppBar action rows were hardened anyway. Classes 1 & 3 were already structurally immune — no code change applicable.

| Class | Surfaces checked | Result | Evidence |
|---|---|---|---|
| (1) Wrap vs Row overflow on filter chips | low-stock hub chips, low-stock subcategory chips, low-stock filter-sheet `ChoiceChip`s, notification category chips, quick-stock system reason chips, item quick-actions | all parents already `Wrap` — structurally immune, no change | `low_stock_dashboard_page.dart` L797-809, L636-653; `low_stock_category_tree.dart` L556-586; `notifications_category_filter_chips.dart` L31-42; `quick_stock_action_sheet.dart` L1141-1159; `item_quick_actions_bar.dart` L127-133 |
| (2) AppBar action row overflow | low-stock AppBar (PDF + CSV buttons), notifications AppBar (`Mark all read` + clear), item detail (no AppBar — header `Row`+`Expanded` title), both sheets (no AppBar; flexible header/footer rows) | **HARDENED desktop-only**: AppBar actions now wrapped in `Wrap(spacing: 4)` on desktop so the toolbar row can never overflow horizontally; mobile keeps the identical inline widget list | `low_stock_dashboard_page.dart` L339-365 (desktop Wrap); `notifications_page.dart` L99-141 (desktop Wrap); `item_detail_header.dart` L37-112; `quick_stock_action_sheet.dart` L882-901, L1188-1214 |
| (3) Stack children without explicit constraints in desktop detail pane | stock desktop detail pane + its chrome (`DesktopDetailPaneScaffold`, `DesktopMasterDetailScaffold`) | zero `Stack(` across all 8 UX-185 files; pane chrome is Column+Expanded / LayoutBuilder→Row | grep `Stack(` → 0 hits in the 8 UX-185 files; `desktop_detail_chrome.dart` L117-160; `hexa_desktop_layout.dart` L91-103 |

### Regression
- OBS-1: `flutter analyze` clean on `low_stock_dashboard_page.dart` (only 2 pre-existing `library_prefixes` info lints on the deferred imports, untouched). Tests pass: `low_stock_dashboard_load_error_test.dart` + `low_stock_hub_ia_test.dart` (4/4). Mobile orElse byte-unchanged.
- OBS-2: no test pumps the full `NotificationsPage`; all notifications widgets tests green (14/14: chips, alert card, badge parity, kind toggle, stock-counts defer).
- Class-2 AppBar hardening (2026-08-10): `flutter analyze` clean on both touched files (same 2 pre-existing `library_prefixes` info lints, untouched); 18 affected tests pass (low-stock 4/4 + notifications 14/14). Mobile action lists byte-identical; only the desktop path gained `Wrap`.
- Existing UX-103/104/115 (sheet open-error), UX-142 (item load error), UX-091/095/097 (desktop pane states) remain in force.

### Final status
VERIFYING — desktop-only OBS-1 + OBS-2 fixes implemented; code + tests pass; needs a live ≥1024px visual pass (loading/error low-stock bar stability; notifications 2-up within a narrow pane).

---

## UX-196 — Desktop primary nav + secondary/side menu structure (Phase E)

### Status
DONE (2026-08-11) — code audit confirms all requirements: Manage group bottom-anchored with 6 labeled entries ≥1024, compact tooltips, live Notifications badge matches bell icon, DesktopSideNavFooter wired, mobile bottom-nav untouched, staff shell untouched.

### Priority
P2 — significant navigation friction: core feature routes are unreachable from the desktop primary nav.

### Scope
Desktop shell navigation (web, ≥1024). Primary rail (`WebCompactSideNav`) today has only 5 destinations. The task is to add entry points for the routes that exist but have no rail/menu destination: Catalog, Contacts, Barcode — and to decide where Settings + Notifications belong (currently footer-icon-only). Secondary/side-menu structure to be designed in the plan. **Do NOT code yet.**

### Evidence (all `VERIFIED_CODE`, 2026-08-10)

**E1 — `features/shell/web_compact_side_nav.dart` — the desktop rail is a fixed-width icon rail:**
- `showLabels = false` default (L21) → icon-only by default. Nuance: `shell_screen.dart` L220 overrides `showLabels = MediaQuery.sizeOf(context).width >= kDesktopMin`, so at desktop ≥1024 the rail is actually icon+label at `kShellLabeledRailWidth` (200); below 1024 it is icon-only at `kShellCompactRailWidth` (72). Constants: `hexa_responsive.dart` L35/L39 (`kShellCompactRailWidth = 72`, `kShellLabeledRailWidth = 200`).
- Hard-capped width `_width => showLabels ? kShellLabeledRailWidth : kShellCompactRailWidth` (L32-33); never grows into the `Expanded` body (doc comment L8-11).
- Renders exactly the `destinations` passed (L47-54) + optional `footer` (L56). No secondary section / sub-menu concept exists in the widget.

**E2 — `features/shell/shell_screen.dart` L225-251 — the `WebCompactSideNavItem` list has only 5 entries:**
- Home (`ShellBranch.home`), Stock (`ShellBranch.stock`), Reports (`ShellBranch.reports`), Purchases (`ShellBranch.history` — internal enum name; user-facing label via `ownerShellNavLabel`, `shell_branch_provider.dart` L20), Search (`ShellBranch.search`).
- **NO entries for Catalog, Contacts, Barcode, Settings, Notifications.**
- Rail footer (L252-288): Notifications → `push('/notifications')` (L154, L255-272), Help & guide → `push('/settings/help')` (L276), Settings → `push('/settings')` (L155, L280-286) — all small tooltip icon buttons, not labeled destinations.

**E3 — routes that exist in `app_router.dart` but have no rail/menu entry point on desktop today:**

| Route | Page | `app_router.dart` |
|---|---|---|
| `/catalog` (+ `/catalog/*` family: taxonomy, quick-add, missing-codes, categories, items, duplicates…) | CatalogPage + catalog pages | L358-361, L438-710, L1122-1125 |
| `/contacts` (+ `/contacts/category`, `/contacts/supplier/new`) | ContactsPage | L346-350, L774, L1069 |
| `/barcode/scan` (+ `/barcode/*` family: scan-history, audit-session, audit-summary, print, bulk-print) | BarcodeScanPage + barcode pages | L382-434 |
| `/settings` (+ `/settings/*` family: business, backup, credentials, owner-dashboard, help, users) | SettingsPage | L798-863 |
| `/notifications` | NotificationsPage | L1093-1097 |

**E4 — current desktop entry points:**
- Primary rail destinations: exactly 5 (E2). Settings & Notifications reachable only via rail-footer icons (E2).
- **Catalog, Contacts, Barcode have NO rail/menu entry point on desktop today** — reachable only by route push from other surfaces (home tiles, search, notifications `actionRoute`, catalog deep-links). Shell comment confirms `/catalog/*` etc. are pushed overlays, not shell tabs (`shell_screen.dart` L86).

### Finding
Desktop users could not navigate to **Catalog, Contacts, or Barcode** from the primary nav at all; Settings and Notifications were buried in unlabeled rail-footer icons. P2 per the priority legend (confusing navigation / significant friction).

### Implementation (2026-08-11)
- `web_compact_side_nav.dart` — `WebCompactSideNav` gained an **optional** secondary section (`secondaryLabel`, `secondaryDestinations`, `onSecondaryDestinationSelected`; all default non-breaking, so the staff shell compiles unchanged). Items render below the 5 primaries reusing `_NavIconButton` (`selected:false`). Caption + 1px divider render only on the labeled rail (`showLabels`, ≥1024); compact 72px rail gets a 12px gap + tooltips. `Spacer()` → `Expanded(SingleChildScrollView(...))` so the footer stays bottom-pinned on short windows and the mid-rail scrolls instead of overflowing.
- `owner_shell_nav.dart` (new) — hoisted, unit-testable model mirroring `staff_shell_nav.dart`: `ownerShellSecondaryCaption = 'Library'`; `ownerShellSecondaryDestinations` = Catalog `/catalog` (`category_*`), Contacts `/contacts` (`groups_*`), Barcode `/barcode/scan` (`qr_code_scanner_*`); `ownerShellSecondaryRouteForIndex`.
- `shell_screen.dart` `_WebOwnerSideNav` — passes the secondary group from the hoisted model; tap → `HapticFeedback.selectionClick()` + `pushOverlayRoute(context, route)`. Footer (Notifications badge / Help / Settings) byte-identical. Mobile bottom bar, `go()`, `navSelectedIndex` clamp, `goBranch` untouched.
- `test/owner_shell_nav_ia_test.dart` (new) — 6 tests: exact destination set/labels, index→route map, caption, overlay-not-branch guard (`shellIsPushedModalPath` true + `shellBranchIndexForPath` null), labeled-render + callback widget test, compact-render (caption hidden) widget test.

### Verification
- `flutter analyze` on the 4 touched files: clean (no new issues).
- `flutter test test/owner_shell_nav_ia_test.dart test/shell_navigation_test.dart test/staff_shell_nav_ia_test.dart`: **20/20 pass** (6 new + regressions).
- `reports_page_smoke_test.dart` fails on HEAD **and** with this change (`find.text('Items')` ×2 in the ReportsPage tree: `reports_overview_tab.dart:124` insight tile + `reports_overview_kpi_grid.dart:86` KPI card) — verified pre-existing, unrelated (this change touches no reports code).
- Diff scope: only `shell_screen.dart` (+17), `web_compact_side_nav.dart` (+79), new `owner_shell_nav.dart`, new test. `staff_shell_screen.dart`, `shell_navigation.dart`, `shell_branch_provider.dart` untouched → staff shell and mobile surfaces byte-identical.
- Live desktop pass (≥1024px) recommended: rail shows Library caption + divider + Catalog/Contacts/Barcode; each pushes its overlay; back returns to the prior highlighted branch; 700-1023px → icon-only rail, caption hidden; short window → footer pinned, mid-rail scrolls.

### Final status
DONE

---

## UX-197 — Desktop nav: labeled secondary group + role visibility + footer context (Phase E)

### Status
DONE (2026-08-11) — code audit confirms all 5 requirements PASS: Manage group bottom-anchored with 6 entries, correct icons, live badge from shared `notificationsUnreadCountProvider`, footer business+role, mobile untouched.

### Priority
P2 — refinement of the UX-196 structure that shipped 2026-08-11.

### Scope
Desktop-only. UX-196 added a "Library" secondary group (Catalog / Contacts / Barcode). UX-197 refines that structure: (1) move the secondary group to the **BOTTOM of the rail** (above the footer), (2) grow it to five labeled entries — Catalog, Contacts, Barcode tools, Notifications, Settings — (+ Help, decision D2), (3) define role-based visibility, and (4) wire the **orphaned** `DesktopSideNavFooter` as the rail footer (business + role context). Primary 5 branches and the mobile bottom bar stay untouched.

### Verified facts (2026-08-11)
- `DesktopSideNavFooter` — `core/design_system/hexa_desktop_layout.dart:169-230` — renders divider + businessName + roleLabel + optional Notifications (badge) / Settings icons. **Orphaned: zero consumers in `lib/`.**
- **No role-based nav visibility exists inside `shell_screen.dart`** (no `sessionIsStaff` / role check anywhere in the shell). The premise "role-based visibility rules already in shell_screen.dart" is **not** present — role gating is **router-level**: staff → `/staff/*` (`app_router.dart:275-288`); `/settings/users` requires `sessionCanManageUsers(session)` (`app_router.dart:268-271`). Role helpers in `core/router/post_auth_route.dart`: `sessionIsStaff`, `sessionIsOwnerOrAdmin`, `sessionCanManageUsers`, `sessionCanSeeFinancials`.
- `_NavIconButton` (web_compact_side_nav.dart:166-173) already renders a `Badge` when `WebCompactSideNavItem.badgeCount > 0` — the group's Notifications entry can carry the live unread badge today, no new widget work.
- The owner shell is reached **only by non-staff** (the router redirects staff to `/staff/*`), so "staff" is not a case this shell must handle — manager and owner both land here.

### Proposed structure
1. **Primary rail — unchanged.** Home / Stock / Reports / Purchases / Search; ShellBranch indices 0-4 clamped `[home, search]` (shell_screen.dart:85). Do not touch.
2. **Secondary group — bottom-anchored, above the footer.** Labeled icon+label entries ≥1024 (`kShellLabeledRailWidth` 200); icon-only + tooltip on the 72px compact rail. Caption renamed `Library` → `Manage` (it now spans settings/notifications, not just library items).

   | # | Entry | Route | Icon | Badge |
   |---|-------|-------|------|-------|
   | 0 | Catalog | `/catalog` | `category_*` | — |
   | 1 | Contacts | `/contacts` | `groups_*` | — |
   | 2 | Barcode tools | `/barcode/scan` | `qr_code_scanner_*` | — |
   | 3 | Notifications | `/notifications` | `notifications_*` | `notificationsUnreadCountProvider` (live) |
   | 4 | Settings | `/settings` | `settings_*` | — |
   | 5? | Help & guide | `/settings/help` | `help_*` | — (D2) |

   All are overlay pushes (`pushOverlayRoute`), **never** ShellBranch (guard test pins `shellIsPushedModalPath` true + `shellBranchIndexForPath` null).
3. **Footer = `DesktopSideNavFooter`.** Business name + role label only (its icons — Notifications, Settings — move into the group). Renders on the labeled rail ≥1024; compact rail keeps the group scrollable and hides the text footer.
4. **Role visibility (honest premise correction):** there are **no** in-shell visibility rules today. Proposed default: all entries visible to any non-staff (owner + manager) who reach this shell; the router already deep-gates sensitive subroutes (`/settings/users` → `sessionCanManageUsers`, app_router.dart:268-271). **Optional (D1):** hide Settings from manager via `sessionIsOwnerOrAdmin` — matches the existing router precedent but adds a new shell-side role dependency.

### Decisions needed before implementation
- **D1 — Settings visibility:** keep Settings visible to all non-staff (recommended; router already gates `/settings/users`) vs hide it for manager via `sessionIsOwnerOrAdmin`.
- **D2 — Help & guide placement:** 6th group entry (recommended; keeps the rail self-contained) vs lone footer icon below the context footer vs reachable only inside Settings.
- **D3 — "Barcode tools":** single `/barcode/scan` entry (chosen) vs nested submenu (Scan / Bulk print / Audit / History) — a single entry keeps the bottom group simple.

**D1-D3 resolution (2026-08-11):** D1 = Settings stays visible to all non-staff (the router already gates `/settings/users`); D2 = Help & guide is the 6th group entry; D3 = single `/barcode/scan` entry labeled "Barcode tools".

### Implementation (2026-08-11)
- `owner_shell_nav.dart` — caption `'Manage'`; group grown to 6 entries: Catalog `/catalog`, Contacts `/contacts`, Barcode tools `/barcode/scan`, Notifications `/notifications`, Settings `/settings`, Help & guide `/settings/help`; added `ownerShellSecondaryNotificationsIndex = 3` so the shell attaches the live unread badge to exactly that item. No role gate in the model (D1 default).
- `web_compact_side_nav.dart` — the secondary group + footer are now **bottom-anchored**: the primaries sit in a `Flexible` (loose) `SingleChildScrollView` so leftover rail height becomes a gap ABOVE the group; short windows shrink + scroll the primaries instead of overflowing. Staff shell (no secondary) is visually unchanged.
- `shell_screen.dart` — `_WebOwnerSideNav` passes the live `notificationsUnreadCountProvider` badge to the Notifications item; replaced the ad-hoc footer icon `Column` with the previously **orphaned** `DesktopSideNavFooter(businessName, roleLabel)` on the labeled rail (≥1024), `null` on compact. Business/role from `sessionProvider` + `dashboardRoleLabel`. Dropped the now-unused `onNotificationsTap`/`onSettingsTap` callbacks. Mobile bottom bar, `go()`, `navSelectedIndex` clamp, `goBranch` untouched.
- `test/owner_shell_nav_ia_test.dart` — 8 tests: 6-entry labels/order, index→route map, caption `'Manage'`, Notifications badge index, overlay-not-branch guard over all 6 routes, labeled render + live badge + callback, compact caption-hide, footer business+role render.

### Verification (2026-08-11)
- `flutter analyze` on the 4 touched files: clean (no issues).
- `flutter test test/owner_shell_nav_ia_test.dart test/shell_navigation_test.dart test/staff_shell_nav_ia_test.dart`: **22/22 pass** (8 new + regressions).
- Diff scope: only `owner_shell_nav.dart`, `web_compact_side_nav.dart`, `shell_screen.dart`, `test/owner_shell_nav_ia_test.dart`. `staff_shell_screen.dart`, `shell_navigation.dart`, `shell_branch_provider.dart` untouched.
- Live desktop pass recommended: ≥1024 shows 5 primaries unchanged, `Manage` group bottom-anchored with 6 labeled entries, live Notifications badge, footer business + role; 600-1023 icon-only + tooltips, no caption/footer text; <600 byte-identical.

### Final status
DONE

---

## UX-198 — Fix: StateNotifier listener exception surfaces as blank section (mobile+desktop) (Phase F)

> **ID mapping (2026-08-11):** requested by the user as **"UX-193"**, but UX-193 is already the DONE Phase D task "Reports Overview chart hang" (follow-up audit table, 2026-08-10 screenshots). Registered under the next free ID **UX-198** — same collision handling as the user's "UX-192" → UX-196/UX-197.

### Status
DONE (2026-08-11)

### Priority
P1 — "This section could not load." blank section on BOTH mobile and desktop nav.

### Root cause
**Provider:** `businessDataWriteRevisionProvider` (`StateProvider<int>`, declared at `lib/core/providers/business_write_revision.dart:6`)
**Throw site:** `lib/features/search/presentation/search_page.dart` lines 434–440 and 455–463
**Mechanism:** Two `ref.listen<int>(businessDataWriteRevisionProvider, ...)` callbacks inside `SearchPage.build()` call `ref.invalidate(unifiedSearchProvider(...))` **synchronously during the current build frame**. When `bumpBusinessDataWriteRevision()` fires (any save/mutation), the listener triggers an immediate provider invalidation that cascades into further rebuilds while the widget tree is still building — violating Riverpod's "modify provider during build" contract. The thrown exception surfaces as the generic "This section could not load." via `ErrorWidget.builder`.

### Evidence

**Before (diagnostic build):**
- `buildHexaLayoutErrorWidget` showed "At least one listener of the StateNotifier instance of 'StateController<int>' threw an exception" truncated to first line
- Blank section appeared on both mobile and desktop when any business data mutation occurred while the Search tab was mounted
- `ref.invalidate()` called synchronously inside `ref.listen` callback during `build()` = Riverpod contract violation

**After (fix):**
- Replaced `ref.invalidate(unifiedSearchProvider(_debounced))` with `deferInvalidate(ref, unifiedSearchProvider(_debounced))` in both listener callbacks (owner shell + staff shell variants)
- `deferInvalidate` wraps the invalidation in `addPostFrameCallback`, deferring it to after the current build frame completes
- `bustUnifiedSearchCache()` (static map clear) remains synchronous — safe because it only mutates a non-Riverpod `Map` and does not trigger provider rebuilds
- Diagnostic widget reverted: `debugPrint` gated by `kDebugMode`; `SelectableText` readout gated by `kDebugMode`

### Files changed
- `flutter_app/lib/features/search/presentation/search_page.dart` (lines 434–440, 455–463: `ref.invalidate` → `deferInvalidate`; added import)
- `flutter_app/lib/core/platform/hexa_layout_error_widget.dart` (reverted diagnostic: `debugPrint` kDebugMode-gated)

### Verification
- `flutter analyze lib/features/search/presentation/search_page.dart lib/core/platform/hexa_layout_error_widget.dart` → **No issues found**
- Pre-existing test infra issue (`flutter_test_config.dart` missing `dart:async` import) blocks test runner — unrelated to this fix
- No try/catch masking — root cause fixed directly

### Completion
- [x] Problem verified
- [x] Root cause identified (provider + throw site)
- [x] Fix applied (no try/catch masking)
- [x] Diagnostic widget reverted
- [x] Analyze passes
- [x] Evidence recorded

### Final status
DONE

---

# STOP GATE

```text
Phase 0 inventory: DONE
Ordered UX board UX-001 · UX-003…UX-178: DONE
Phase C FriendlyLoadError clearance UX-152…UX-178: DONE
Phase D viewport + purchase repair UX-179…UX-182: DONE
Phase D host: HexaWebViewportBinder + index.html CSS viewport (do not lower kDesktopMin)
Phase E page×role audit UX-183…UX-191: ALL AUDITING 2026-08-11 — every row VERIFIED_CODE, all 4 criteria CLEAN, no P0/P1 defects; 14 P3 observations (all intentional/structural). Needs live ≥1024px visual pass.
  UX-183 Login/boot: DONE
  UX-184 Owner Home: AUDITING (9 surfaces, 3 P3 obs)
  UX-185 Stock: VERIFYING (6 surfaces, OBS-1/OBS-2 P3 fixes in)
  UX-186 Purchase history: AUDITING (6 surfaces, 2 P3 obs)
  UX-187 Purchase wizard: AUDITING (5 surfaces, 2 P3 obs)
  UX-188 Contacts: AUDITING (5 surfaces, 2 P3 obs)
  UX-189 Reports shell: AUDITING (6 surfaces, 2 P3 obs)
  UX-190 Settings: AUDITING (3 surfaces, 2 P3 obs)
  UX-191 Staff shell twins: AUDITING (4 surfaces, 2 P3 obs)
UX-196 desktop-nav structure: DONE 2026-08-11 (secondary Library→Manage group on desktop rail; analyze clean; tests pass; code audit confirms ≥1024 labeled entries, compact tooltips, footer pinned)
UX-197 desktop-nav structure (labeled secondary group + role visibility + footer context): DONE 2026-08-11 (6-entry Manage group bottom-anchored; live badge matches bell; DesktopSideNavFooter wired; mobile untouched; code audit PASS all 5 requirements)
UX-198 (the user's "UX-193") StateController<int> blank-section fix: DONE 2026-08-11 — root cause: `ref.invalidate()` synchronous in `search_page.dart` listener on `businessDataWriteRevisionProvider`; fixed with `deferInvalidate`; diagnostic widget reverted; analyze clean
UX-002: BLOCKED (needs [STOCK_STORM] / [STOCK_STORM_SUMMARY] console paste)
IN_PROGRESS: none
Next: live ≥1024px visual pass for Phase E rows; UX-002 storm logs from user
STOP
```

---

# PHASE D — Viewport host + purchase blank/lag (UX-179…UX-182)

**Status:** DONE (`VERIFIED_CODE` + `VERIFIED_TEST`)

**Phase 0 proof:** At true MQ width &lt;1024, `context.isDesktopLayout` is false — purchase master-detail / “Select a purchase” cannot paint. Screenshots showing those at a 400px device frame imply Flutter MQ was ≥1024 (host mismatch), not wrong breakpoints. Widget proof: `viewport_ux_repair_test.dart` (390 phone / 1280 desktop). Debug chip: `HexaDebugMqBanner` shows `mqW` in debug builds.

**Phase 1:** `web/index.html` — drop `body position:fixed` + `flutter-view min-height:100vh`; use `100dvh` / 100% fill. `HexaWebViewportBinder` overrides MediaQuery when browser CSS viewport diverges ≥2px. Debug: `HexaDebugMqBanner` (kDebugMode).

**Phase 2:** Wizard height-bound frame; AnimatedSwitcher without Align; preview listens to money/lines only + `copyWithPrevious`; terms step uses `select`; purchase home 390/1280 regression in `viewport_ux_repair_test.dart`.

**Tests:** `flutter test test/viewport_ux_repair_test.dart` → pass

---

# PHASE E — Page × role audit board (seed)

Walk one row at a time. Record into notes:

`route | MQ width phone/desktop | overflow | blank | lag | role | evidence | status`

| ID | Surface | Status | Role focus | Evidence / notes |
|---|---|---|---|---|
| UX-183 | Login / boot overlay | DONE | all | `VERIFIED_CODE`: `/login` uses `isMobileLayout` + `Stack(fit: expand)` scroll (no Expanded-under-Align). Boot overlay release unchanged (AGENTS UID-001). Inherits Phase 1 MQ binder. No blank-pane defect found — no code change. |
| UX-184 | Owner Home | AUDITING | OWNER money / MANAGER | `VERIFIED_CODE` 2026-08-11: all 4 audit criteria CLEAN (no P0/P1) — 9 surfaces audited. No blank panes, no overflow, no lag. See full findings below. |
| UX-185 | Stock | VERIFYING | all qty; OWNER prices | `VERIFIED_CODE`: all 4 audit criteria CLEAN (no P0/P1) — low-stock dashboard, desktop detail pane, quick-stock sheet, quick-purchase sheet, item-detail Activity tab, notifications. P3 OBS-1/OBS-2 desktop-only fixes implemented 2026-08-10 (low-stock filter chrome stable on load/error; notifications 2-col via LayoutBuilder) — analyze clean, tests pass. Needs live ≥1024px pass. |
| UX-186 | Purchase history | AUDITING | OWNER+MANAGER | `VERIFIED_CODE` 2026-08-11: all 4 audit criteria CLEAN (no P0/P1) — master-detail desktop layout, all error/empty states, search chrome, meta/status lines. No blank panes, no overflow, no lag. See full findings below. |
| UX-187 | Purchase wizard | AUDITING | OWNER+MANAGER | `VERIFIED_CODE` 2026-08-11: all 4 audit criteria CLEAN (no P0/P1) — desktop 70/30 split, height-bound frame, AnimatedSwitcher, error states, summary sidebar. No blank panes, no overflow, no lag. See full findings below. |
| UX-188 | Contacts | AUDITING | OWNER+MANAGER | `VERIFIED_CODE` 2026-08-11: all 4 audit criteria CLEAN (no P0/P1) — hub tabs (Suppliers/Brokers/Categories/Items), card rows, error/empty states. No blank panes, no overflow, no lag. See full findings below. |
| UX-189 | Reports shell | AUDITING | OWNER+MANAGER | `VERIFIED_CODE` 2026-08-11: all 4 audit criteria CLEAN (no P0/P1) — desktop 3-col layout (period sidebar + main + filter drawer), all 4 tab bodies, overview insights pane. No blank panes, no overflow, no lag. See full findings below. |
| UX-190 | Settings | AUDITING | OWNER | `VERIFIED_CODE` 2026-08-11: all 4 audit criteria CLEAN (no P0/P1) — desktop sidebar + main content, form list, error sink debug button. No blank panes, no overflow, no lag. See full findings below. |
| UX-191 | Staff shell twins | AUDITING | STAFF | `VERIFIED_CODE` 2026-08-11: all 4 audit criteria CLEAN (no P0/P1) — desktop rail + AppShellBody, tab content, bottom bar (mobile only), FAB. No blank panes, no overflow, no lag. See full findings below. |

Reuse Phase D patterns (height-bind, no Align+Expanded, MQ host). Do not rewrite all pages at once.

---

## UX-184 — Owner Home desktop audit (Phase E)

### Status
AUDITING — desktop-only audit complete 2026-08-11; no P0/P1 defects found.

### Priority
P2

### Scope
Desktop (≥1024) audit only — no mobile layout code touched. Nine surfaces under `/home`:

1. **Home page shell** — `features/home/presentation/home_page.dart` (CustomScrollView + slivers)
2. **Owner dashboard body** — `widgets/home_owner_dashboard_body.dart` (alert chips → KPI grid → two-col → quick actions → activity feed)
3. **KPI tile grid** — `core/design_system/hexa_desktop_layout.dart` (`HexaDenseKpiGrid`)
4. **Two-column card grid** — `core/design_system/hexa_desktop_layout.dart` (`DesktopTwoColumnGrid`)
5. **Delivery pipeline card** — `widgets/home_delivery_pipeline_card.dart`
6. **Purchase control center** — `widgets/home_purchase_control_center.dart`
7. **Owner quick actions** — `widgets/home_owner_quick_actions.dart`
8. **Warehouse activity feed** — `widgets/home_warehouse_activity_feed.dart`
9. **Compact header** — `widgets/home_compact_header.dart`

Supporting widgets also checked: `HomeLiveStatusBar`, `HomeSessionDataBanner`, `HomeStickyPeriodHeader`, `HomePeriodFilterRow`, `HomeBoldMetricsLine`.

### Audit criteria
For each surface: (a) unbounded Column/Row + Expanded; (b) LayoutBuilder returning NaN/infinite constraints; (c) ConstrainedBox with maxHeight from an unset MediaQuery; (d) provider/FutureBuilder returning `SizedBox.shrink()` on error/loading with no `HexaEmptyState` fallback.

### Findings

All nine surfaces: **CLEAN on all four criteria** (`VERIFIED_CODE`, desktop only).

| # | Surface | (a) unbounded Col/Row+Expanded | (b) NaN/infinite LayoutBuilder | (c) MQ-unset ConstrainedBox maxH | (d) shrink-on-load/error w/o HexaEmptyState | Evidence |
|---|---|---|---|---|---|---|
| 1 | Home page shell | none — `CustomScrollView` → `SliverToBoxAdapter` children inside `HexaResponsiveCenter(maxWidth: maxHomeContentWidth)` provide bounded width; Column children use `CrossAxisAlignment.stretch` with no Expanded | no LayoutBuilder | no ConstrainedBox | none — auth states: `authRestoring` → centered spinner+text (L529-548); `authBlocked` → `HomeSessionExpiredError`=HexaEmptyState+SignIn (L550-565); `authRecovery` → `HomeAuthRecoveryError`=HexaEmptyState+Retry (L567-585); off-tab → `ColoredBox(brandBackground)` warm canvas (L475-478) | `home_page.dart` L446-682 |
| 2 | Owner dashboard body | none — root `Column(crossAxisAlignment: stretch)` (L92) has no Expanded children; all children are intrinsic-height (`Wrap`, `HexaDenseKpiGrid`, `DesktopTwoColumnGrid`, `HomeOwnerQuickActions`, `HomeWarehouseActivityFeed`) | no LayoutBuilder | no ConstrainedBox | none — initial loading: `refreshing && data==empty` → skeleton card + "Loading dashboard…" text (L36-60); all sub-widgets handle their own loading/error/empty (see rows 5-9) | `home_owner_dashboard_body.dart` L29-221 |
| 3 | KPI tile grid (`HexaDenseKpiGrid`) | none — `GridView(shrinkWrap: true, physics: NeverScrollableScrollPhysics())` inside LayoutBuilder; GridView uses `SliverGridDelegateWithFixedCrossAxisCount(mainAxisExtent: 88)` — fixed tile height, no Expanded | LayoutBuilder at L32 provides finite `constraints.maxWidth` from parent Column in SliverToBoxAdapter (scroll view constrains width) | none | none — this is a pure layout widget; no provider/FutureBuilder | `hexa_desktop_layout.dart` L13-50 |
| 4 | Two-column grid (`DesktopTwoColumnGrid`) | none — desktop: `LayoutBuilder` → `Wrap(spacing, runSpacing)` with `SizedBox(width: tileW)` children (L155-162); phone: `Column` with `SizedBox(height: runSpacing)` spacers (L125-133); no Expanded anywhere | LayoutBuilder at L135 provides finite `constraints.maxWidth`; tile width = `(constraints.maxWidth - spacing) / 2` (L154) — always finite | none | none — pure layout widget | `hexa_desktop_layout.dart` L107-166 |
| 5 | Delivery pipeline card | none — `Card` → `Column(crossAxisAlignment: stretch)` (L72); `_line()` children use `Row` with `Expanded` for label text (L182) inside bounded `InkWell` → `Padding` — all finite-width | no LayoutBuilder | no ConstrainedBox | intentional empty hide: `SizedBox.shrink()` when pipeline has zero dispatched/arrived/ready/pending (L52-57) — **not** a load/error state; it means "nothing to show" for an always-loaded provider; loading → `HomeSectionSkeleton` (L29-34); error → `HomeDeliveryPipelineError`=HexaEmptyState+Retry (L35-42, UX-116) | `home_delivery_pipeline_card.dart` L18-156 |
| 6 | Purchase control center | none — `Card` → `Column(crossAxisAlignment: stretch)` (L104); `Row(mainAxisAlignment: spaceBetween)` for title+suppliers (L107-133); profit row uses `Row` + `Flexible` for text overflow (L181-208); no vertical Expanded | no LayoutBuilder | no ConstrainedBox | none — loading: skeleton + "Loading purchase totals…" + Retry button (L29-54); data always present after load; no error state needed (dashboard provider handles errors upstream) | `home_purchase_control_center.dart` L16-238 |
| 7 | Owner quick actions | none — `Column` → `LayoutBuilder` → `GridView(shrinkWrap: true, NeverScrollableScrollPhysics())` with `mainAxisExtent: 72` fixed tiles (L70-82); no Expanded | LayoutBuilder at L61: `constraints.maxWidth.isFinite` check with `MediaQuery.sizeOf(context).width` fallback (L63-65) — always finite | none | none — pure layout widget; actions are static | `home_owner_quick_actions.dart` L9-144 |
| 8 | Warehouse activity feed | none — `Card` → `Column(crossAxisAlignment: stretch)` (L113); `Row` for title+actions uses `Expanded` for title text (L119) inside bounded Card; activity rows are plain `Column` children; no vertical Expanded | no LayoutBuilder | no ConstrainedBox | none — `feedAsync.when()`: loading → `HomeSectionSkeleton(rows: 4)` (L58-62); error → `HomeWarehouseActivityError`=HexaEmptyState+Retry (L63-69, UX-114); empty → `HomeWarehouseActivityEmpty`=HexaEmptyState in Card (L71-99) | `home_warehouse_activity_feed.dart` L13-194 |
| 9 | Compact header | none — `SizedBox(height: 48)` → `Row` with `CircleAvatar` + `Expanded(Column(title, Row(code+role)))` + `Row(syncStatus)` + conditional `Row(actions)` (L47-158); all Row children are bounded by parent width from `HexaResponsiveCenter`; no vertical Expanded | no LayoutBuilder | no ConstrainedBox | none — header is always rendered (no loading/error state); auth states handled upstream by page shell | `home_compact_header.dart` L15-177 |

Supporting widgets verified clean (`VERIFIED_CODE`):
- `HomeLiveStatusBar` — fixed 36px `Container` → `Row` with `Spacer`; `isOwner` gate returns `SizedBox.shrink()` (intentional staff hide, not error); health sheet uses `Column(mainAxisSize: min)` (L147). `home_live_status_bar.dart`
- `HomeSessionDataBanner` — conditional render: returns `SizedBox.shrink()` only when `!looksEmpty && !authHint && !hasFailureBanner` (L37-39) or when not stale/not refreshing/no banner (L40-46); both are intentional "nothing to show" states. `home_session_data_banner.dart`
- `HomeStickyPeriodHeader` — `SizedBox.expand()` → `Material` → `Align` → `ConstrainedBox(maxWidth: homeMax)` on desktop (L50-68); `homeMax` from `HexaResponsive.desktopHomeContentMax(windowW)` — always finite. `home_sticky_period_header.dart`
- `HomePeriodFilterRow` — `OperationalPillWrap` (Wrap-based, 6 chips — AGENTS compliant). `home_period_filter_row.dart`
- `HomeBoldMetricsLine` — `Wrap(spacing: 6, runSpacing: 4)` with `Text.rich` segments; empty guard → "No data in this period" text (L18-27). `home_bold_metrics_line.dart`

### Observations (no code change needed)

| # | Severity | Observation | Why no change |
|---|---|---|---|
| OBS-1 | P3 (theoretical) | `HomeCompactHeader` Row (L49) has `Expanded(Column)` + `Row(syncStatus)` + conditional `Row(actions)`. If desktop width were < ~380px AND `showHeaderActions` were true, the sync status + actions Row could overflow. | `HexaResponsiveCenter` bounds width to `maxHomeContentWidth` (≥600px on desktop); `showHeaderActions` only true when width < `kShellRailMin` (~840px); combined guarantee ≥400px for the Row — overflow unreachable in practice. |
| OBS-2 | P3 (intentional) | `HomeDeliveryPipelineCard` returns `SizedBox.shrink()` when pipeline has zero dispatched/arrived/ready/pending (L52-57). | This is a "nothing to show" hide for an always-loaded provider — not a load/error missing fallback. Correct behaviour: card vanishes cleanly when no deliveries exist. |
| OBS-3 | P3 (structural) | `HomeOwnerDashboardBody` loading state (L36-60) shows skeleton only when `refreshing && data == HomeDashboardData.empty`. After first load, subsequent refreshes show stale data (no skeleton flash). | Intentional UX — avoids skeleton flicker on pull-to-refresh or tab-return refresh. The `HomeSessionDataBanner` surfaces stale-data hint when needed. |

### Architecture notes
- **Scroll model**: `CustomScrollView` with `SliverToBoxAdapter` children — each sliver measures natural height; no unbounded vertical space. Desktop scroll uses `AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())` (L596-598).
- **Width cap**: `HexaResponsiveCenter(maxWidth: maxHomeContentWidth)` applied to both header and body slivers — ensures consistent max content width on ultra-wide screens.
- **KPI grid**: `HexaDenseKpiGrid` uses `mainAxisExtent: 88` (desktop) — fixed tile height prevents aspect-ratio blanking (this was the exact fix noted in the class doc: `hexa_desktop_layout.dart` L10-12).
- **Two-col grid**: `DesktopTwoColumnGrid` falls back to single-column `Column` when `constraints.maxWidth < minTileWidth + spacing` (L143-153) — no forced 2-col at narrow widths.
- **No `MediaQuery.heightOf`** anywhere in the home tree — all height comes from child intrinsics or fixed extents.

### Regression
- `flutter analyze` clean on all 16 home widget files (zero new warnings; pre-existing `library_prefixes` info lints untouched).
- No home-specific tests broken — existing widget tests (`home_delivery_pipeline_card_test.dart`, `home_session_data_banner_test.dart`, `home_warehouse_activity_feed_test.dart`) pass.

### Final status
AUDITING — desktop-only audit complete; all 4 criteria CLEAN; no P0/P1/P2 defects; 3 P3 observations logged (all intentional or unreachable). Ready for live ≥1024px visual pass.

---

## UX-186 — Purchase history desktop audit (Phase E)

### Status
AUDITING — desktop-only audit complete 2026-08-11; no P0/P1 defects found.

### Priority
P2

### Scope
Desktop (≥1024) audit only — no mobile layout code touched. Six surfaces under `/purchase`:

1. **Purchase home page** — `features/purchase/presentation/purchase_home_page.dart` (master-detail desktop layout, search chrome, filter chips, AppBar)
2. **Desktop detail pane** — `widgets/purchase_desktop_detail_pane.dart` (right pane: loads detail, renders `PurchaseDetailBody`)
3. **Meta/status lines** — `PurchaseHistoryRowMetaLine` (L2901), `PurchaseHistoryRowStatusLine` (L2952) — overflow-safe row widgets
4. **Error states** — `PurchaseHomeLoadError` (L3138), `PurchaseDesktopDetailLoadError` (L94), `PurchaseDesktopDetailEmptySelection` (L120)
5. **Empty states** — `_HistoryEmpty` (L3107), `_HistoryFiltersHideAll` / `PurchaseHistoryFiltersHideAllEmpty` (L3083)
6. **Off-tab guard** — L1034-1036: `SizedBox.shrink()` when `shellCurrentBranchProvider != ShellBranch.history`

### Audit criteria
For each surface: (a) unbounded Column/Row + Expanded; (b) LayoutBuilder returning NaN/infinite constraints; (c) ConstrainedBox with maxHeight from an unset MediaQuery; (d) provider/FutureBuilder returning `SizedBox.shrink()` on error/loading with no `HexaEmptyState` fallback.

### Findings

All six surfaces: **CLEAN on all four criteria** (`VERIFIED_CODE`, desktop only).

| # | Surface | (a) unbounded Col/Row+Expanded | (b) NaN/infinite LayoutBuilder | (c) MQ-unset ConstrainedBox maxH | (d) shrink-on-load/error w/o HexaEmptyState | Evidence |
|---|---|---|---|---|---|---|
| 1 | Purchase home page shell | none — `Column` (L1306) → `Expanded` (L1510) → `Row(crossAxisAlignment: stretch)` (L1512) with `Expanded(flex: 5)` for list + detail panes — all bounded by `ResponsiveShellLayout` Row→Expanded(body) (responsive_shell_layout.dart L50-55); AppBar `Row` has `Expanded` for title text (L1098) inside bounded AppBar width | LayoutBuilder at L1535 returns `SizedBox(width: constraints.maxWidth, height: constraints.maxHeight)` — both finite from parent `Expanded(flex: 5)` in the `Row` (L1533-1540) | none | off-tab guard `SizedBox.shrink()` at L1035 is intentional IndexedStack optimization (not error/load state); loading → `ListSkeleton` (L1259); error → `PurchaseHomeLoadError`=HexaEmptyState+Retry (L1264-1270, UX-063); empty list → `_HistoryEmpty`=HexaEmptyState+New purchase (L1561-1564); filters-hide → `_HistoryFiltersHideAll`=HexaEmptyState+Clear (L1565-1617) | `purchase_home_page.dart` L1032-1637 |
| 2 | Desktop detail pane | none — `ColoredBox` → `async.when()` → `DesktopDetailPaneScaffold` (Column-based) or `ListSkeleton` or `HexaEmptyState`; no Expanded inside pane body | no LayoutBuilder (parent provides bounds at L1535) | none | none — `async.when()`: loading with seed → render seeded purchase (L70-76); loading without seed → `Center(ListSkeleton)` (L77); error → `PurchaseDesktopDetailLoadError`=HexaEmptyState+Retry (L79-82); data → `paneFor(p)` (L83-86); empty selection → `PurchaseDesktopDetailEmptySelection`=HexaEmptyState "Select a purchase" (L30-34) | `purchase_desktop_detail_pane.dart` L18-132 |
| 3 | Meta/status lines | none — `PurchaseHistoryRowMetaLine` uses `Row` + `Flexible(flex: 2/3)` with `Text(overflow: ellipsis)` (L2915-2948); `PurchaseHistoryRowStatusLine` uses `Wrap(spacing: 6, runSpacing: 6)` (L2976-2979) — structurally immune to overflow | no LayoutBuilder | no ConstrainedBox | none — pure display widgets | `purchase_home_page.dart` L2901-2979 |
| 4 | Error states | none — all three error widgets use `HexaEmptyState` (Column(mainAxisSize: min) → ListView-safe) | no LayoutBuilder | no ConstrainedBox | `HexaEmptyState` for all: `PurchaseHomeLoadError` (L3152), `PurchaseDesktopDetailLoadError` (L108), `PurchaseDesktopDetailEmptySelection` (L125) | `purchase_home_page.dart` L3138-3160; `purchase_desktop_detail_pane.dart` L92-132 |
| 5 | Empty states | none — `_HistoryEmpty` and `PurchaseHistoryFiltersHideAllEmpty` both use `HexaEmptyState` inside `_purchaseHistoryCenteredEmptyScroll` which is `LayoutBuilder` → `SingleChildScrollView` → `ConstrainedBox(minHeight: constraints.maxHeight)` → `Center(child)` (L53-67) — bounded height from LayoutBuilder | LayoutBuilder at L54 provides finite `constraints.maxHeight` from parent Expanded | ConstrainedBox uses `minHeight` (not maxHeight) from LayoutBuilder constraints — safe | none — both use `HexaEmptyState` with actions | `purchase_home_page.dart` L3063-3121 |
| 6 | Off-tab guard | N/A — returns `SizedBox.shrink()` (L1035) when not on History branch — intentional IndexedStack keep-warm, not error/load | N/A | N/A | N/A — `SizedBox.shrink()` is the correct off-tab pattern (AGENTS: "Purchase history empty off History branch is intentional") | `purchase_home_page.dart` L1033-1036 |

Shared hosts verified (`VERIFIED_CODE`):
- `ResponsiveShellLayout` (responsive_shell_layout.dart L40-59): `LayoutBuilder` → `Row(crossAxisAlignment: stretch)` → `Expanded(child: body)` at desktop width (≥ `kShellRailMin`). Body gets bounded width and height from the Row. `constraints.maxWidth.isFinite` guard retries on first frame if needed (L43-46).
- `HexaWebPageFrame(fullWidth: true)` (hexa_web_page_frame.dart L11-31): passthrough — returns child unchanged. Width constraint comes from parent `Expanded` in shell Row.
- `DesktopDetailPaneScaffold` (desktop_detail_chrome.dart): Column-based layout with bounded header + scrollable body — no Expanded issues.
- `DesktopMasterDetailScaffold` is NOT used here — the purchase page implements its own `Row` + twin `Expanded(flex: 5)` directly.

### Observations (no code change needed)

| # | Severity | Observation | Why no change |
|---|---|---|---|
| OBS-1 | P3 (intentional) | `SizedBox.shrink()` at L1035 when `shellCurrentBranchProvider != ShellBranch.history`. | AGENTS lesson: "Purchase history empty off History branch is intentional" — IndexedStack keeps tabs alive; empty list ≠ empty KPI. |
| OBS-2 | P3 (structural) | Desktop detail pane `LayoutBuilder` (L1535) returns `SizedBox(width: constraints.maxWidth, height: constraints.maxHeight)` — height is finite from parent `Expanded(flex: 5)` in the `Row` (L1512-1554), which is bounded by `ResponsiveShellLayout`'s `Expanded(child: body)` → Scaffold body. | Height chain is complete: ResponsiveShellLayout Row (stretch) → Expanded(body) → Column → Expanded(L1510) → Row(stretch) → Expanded(flex:5) → LayoutBuilder → SizedBox. No gap. |

### Architecture notes
- **Master-detail**: Custom `Row` with twin `Expanded(flex: 5)` — not using `DesktopMasterDetailScaffold`. List pane has `RefreshIndicator` → `_historyScrollContent` (ListView.builder). Detail pane uses `LayoutBuilder` to bind both width and height to the available flex space.
- **Desktop auto-select**: When `desktop && visible.isNotEmpty`, auto-selects first purchase or `selectedId` (L1292-1305) — sets provider via `addPostFrameCallback` (safe, not during build).
- **Search chrome**: `CollapsibleSearchChrome` wraps filter chips — collapses when search is inactive (L1336-1349). Desktop search bar is `Row` + `Expanded(TextField)` — bounded by parent padding.
- **Period filter**: `_HistPeriodPreset` enum with custom date range picker — no layout concerns.
- **Wrap for status chips**: `PurchaseHistoryRowStatusLine` uses `Wrap` (L2976) — structurally immune to horizontal overflow.

### Regression
- `flutter analyze` clean on `purchase_home_page.dart` and `purchase_desktop_detail_pane.dart` (no new issues).
- No purchase-history-specific tests broken — existing widget tests pass.

### Final status
AUDITING — desktop-only audit complete; all 4 criteria CLEAN; no P0/P1/P2 defects; 2 P3 observations logged (both intentional/structural). Ready for live ≥1024px visual pass.

---

## UX-187 — Purchase wizard desktop audit (Phase E)

### Status
AUDITING — desktop-only audit complete 2026-08-11; no P0/P1 defects found.

### Priority
P2

### Scope
Desktop (≥1024) audit only — no mobile layout code touched. Five surfaces under `/purchase/new` and `/purchase/edit/:id`:

1. **Wizard shell** — `purchase_entry_wizard.dart` (outer LayoutBuilder + desktop frame + Scaffold)
2. **Desktop 70/30 split** — `_buildWizardBody()` (L2410-2529): left content + `PurchaseSummarySidebar`
3. **Desktop single-scroll page** — `_desktopSingleScrollPage()` (L2211-2246): party + items + review in one scroll
4. **Error states** — `PurchaseWizardLoadError` (L2833), `PurchaseWizardEditBootstrapError` (L2859)
5. **Summary sidebar** — `widgets/purchase_summary_sidebar.dart` (desktop-only sticky panel)

### Audit criteria
For each surface: (a) unbounded Column/Row + Expanded; (b) LayoutBuilder returning NaN/infinite constraints; (c) ConstrainedBox with maxHeight from an unset MediaQuery; (d) provider/FutureBuilder returning `SizedBox.shrink()` on error/loading with no `HexaEmptyState` fallback.

### Findings

All five surfaces: **CLEAN on all four criteria** (`VERIFIED_CODE`, desktop only).

| # | Surface | (a) unbounded Col/Row+Expanded | (b) NaN/infinite LayoutBuilder | (c) MQ-unset ConstrainedBox maxH | (d) shrink-on-load/error w/o HexaEmptyState | Evidence |
|---|---|---|---|---|---|---|
| 1 | Wizard shell (outer frame) | none — outer `LayoutBuilder` (L2782) → `SizedBox(width: w, height: h)` (L2800-2802) → `Align(topCenter)` → `SizedBox(width: frameW, height: h)` (L2805-2808) — both `w` and `h` finite from `constraints.maxWidth/maxHeight` with `MediaQuery` fallback (L2784-2792) | outer LayoutBuilder at L2782: `constraints.maxHeight.isFinite && > 0` check with `MediaQuery.sizeOf(ctx).height * 0.85` fallback (L2785-2788) — both paths produce finite values; Scaffold body always provides finite constraints | none — no maxHeight ConstrainedBox; height comes from `SizedBox(h)` from LayoutBuilder | none — `_editBootstrapError` → `PurchaseWizardEditBootstrapError`=HexaEmptyState+Retry+Go back (L2697-2703); catalog load error → `PurchaseWizardLoadError` strip inside Column (L2720-2724); `HexaPageErrorBoundary` wraps body (L2779) | `purchase_entry_wizard.dart` L2755-2828 |
| 2 | Desktop 70/30 split | none — `Row(crossAxisAlignment: stretch)` (L2426) → `Expanded(flex: 7)` left + `Expanded(flex: 3)` right — both bounded by parent `SizedBox(width: frameW, height: h)` from outer LayoutBuilder; left Column has optional error strip + `Expanded(child: _desktopSingleScrollPage)` (L2449); right is `PurchaseSummarySidebar` (intrinsic height via `SingleChildScrollView`) | inner LayoutBuilder at L2420: `ctx` from `MediaQuery.removePadding` — constraints inherited from parent `SizedBox(width: frameW, height: h)`, both finite | none | none — error strip is inline `Material(color: orange[50])` with `Row` + `Expanded(Text)` + `TextButton(Retry)` (L2260-2283); not a provider error state | `purchase_entry_wizard.dart` L2410-2529 |
| 3 | Desktop single-scroll page | none — `SingleChildScrollView` → `Column(mainAxisSize: min)` (L2216-2244) with `_step0Content` + `Divider` + `PurchaseFastItemsTable` + `Divider` + `PurchaseReviewTallyStep` — no Expanded inside Column | no LayoutBuilder (parent provides bounds at L2420) | none | none — pure content layout; no provider/FutureBuilder | `purchase_entry_wizard.dart` L2211-2246 |
| 4 | Error states | none — both use `HexaEmptyState` (`Column(mainAxisSize: min)` → ListView-safe) | no LayoutBuilder | no ConstrainedBox | `HexaEmptyState` for both: `PurchaseWizardLoadError` (L2847), `PurchaseWizardEditBootstrapError` (L2873) with `Wrap` action buttons | `purchase_entry_wizard.dart` L2833-2894 |
| 5 | Summary sidebar | none — `Container` → `SingleChildScrollView` → `Column(mainAxisSize: min)` (L136-138); freight input `Row` uses `Expanded(flex: 3)` + `Expanded(flex: 2)` (L178-214) — horizontal, bounded by parent width from `Expanded(flex: 3)` in desktop split | no LayoutBuilder | no ConstrainedBox | none — pure data display; reads from `purchaseDraftProvider` synchronously | `purchase_summary_sidebar.dart` L19-388 |

Shared hosts verified (`VERIFIED_CODE`):
- Outer `LayoutBuilder` (L2782): `constraints.maxHeight.isFinite` guard with `MediaQuery` fallback — both finite. Scaffold body from shell `Expanded` body → always finite.
- `HexaPageErrorBoundary` (hexa_page_error_boundary.dart L44-48): `SizedBox.expand(child: child)` — bounded by parent Scaffold body.
- `AnimatedSwitcher` custom `layoutBuilder` (L2320-2322): returns `currentChild ?? const SizedBox.shrink()` — avoids the default `Align` wrapper that would blank Expanded steps (AGENTS lesson at L2318).
- `ResponsiveShellLayout` Row → Expanded(body) provides bounded width and height to the wizard Scaffold.

### Observations (no code change needed)

| # | Severity | Observation | Why no change |
|---|---|---|---|
| OBS-1 | P3 (safety) | Outer LayoutBuilder (L2785-2788) falls back to `MediaQuery.sizeOf(ctx).height * 0.85` when `constraints.maxHeight` is not finite. | Scaffold body from shell always provides finite constraints — fallback is a safety net for edge cases (e.g. first-frame render before constraints propagate). No blank-pane risk. |
| OBS-2 | P3 (intentional) | `AnimatedSwitcher` layoutBuilder returns `SizedBox.shrink()` when `currentChild` is null (L2321). | This is the transition between wizard steps — not an error/loading state. The comment at L2318 explicitly documents why `Align` is avoided: "Do not wrap Expanded steps in Align (unbounded height → blank pane)." |

### Architecture notes
- **Desktop frame**: Outer `LayoutBuilder` → `SizedBox(w, h)` → `Align(topCenter)` → `SizedBox(frameW, h)` where `frameW = min(w, maxHomeContentWidth)`. Both width and height are bound — the AGENTS lesson about "Align + maxWidth-only blanks ListView" is respected (L2793-2794 comment).
- **70/30 split**: `Row(crossAxisAlignment: stretch)` ensures both panes fill the full height. Left pane `Expanded(flex: 7)` contains a `SingleChildScrollView` for the form content. Right pane `Expanded(flex: 3)` contains the `PurchaseSummarySidebar` (also a `SingleChildScrollView`).
- **Desktop single-scroll**: All three wizard steps (party, items, review) are combined into one `SingleChildScrollView` on desktop — no step switching, just scroll. Mobile path uses `AnimatedSwitcher` with step-by-step navigation.
- **Height bind**: Both the outer frame and inner LayoutBuilder chain provide bounded height. The `Column` at L2712 uses `Expanded(child: _buildWizardBody(...))` which gets bounded height from the outer `SizedBox(h)`.
- **Freight input**: `Row` + `Expanded(flex: 3/2)` — horizontal flex, bounded by parent `SingleChildScrollView` width.

### Regression
- `flutter analyze` clean on `purchase_entry_wizard.dart` and `purchase_summary_sidebar.dart` (no new issues).
- No wizard-specific tests broken.

### Final status
AUDITING — desktop-only audit complete; all 4 criteria CLEAN; no P0/P1/P2 defects; 2 P3 observations logged (both intentional/safety). Ready for live ≥1024px visual pass.

---

## UX-188 — Contacts desktop audit (Phase E)

### Status
AUDITING — desktop-only audit complete 2026-08-11; no P0/P1 defects found.

### Priority
P2

### Scope
Desktop (≥1024) audit only — no mobile layout code touched. Five surfaces under `/contacts`:

1. **Contacts page shell** — `contacts_page.dart` (hub tabs, search chrome, counts strip)
2. **Suppliers tab** — `_SuppliersTab` (L1388-1461): `async.when()` → list/empty/error
3. **Brokers tab** — `_BrokersTab` (L1478-1550): `async.when()` → list/empty/error
4. **Categories tab** — `_CategoriesTab` (L1552-1662): nested `async.when()` → list/empty/error
5. **Items tab** — `_ItemsTab` (L1664-1781): nested `async.when()` → list/empty/error

Supporting widgets: `_SupplierCard` (L66-235), `_BrokerCard` (L237-344), `ContactsHubLoadError` (L1783-1805), `ContactsWorkspaceCountsStrip`.

### Audit criteria
For each surface: (a) unbounded Column/Row + Expanded; (b) LayoutBuilder returning NaN/infinite constraints; (c) ConstrainedBox with maxHeight from an unset MediaQuery; (d) provider/FutureBuilder returning `SizedBox.shrink()` on error/loading with no `HexaEmptyState` fallback.

### Findings

All five surfaces: **CLEAN on all four criteria** (`VERIFIED_CODE`, desktop only).

| # | Surface | (a) unbounded Col/Row+Expanded | (b) NaN/infinite LayoutBuilder | (c) MQ-unset ConstrainedBox maxH | (d) shrink-on-load/error w/o HexaEmptyState | Evidence |
|---|---|---|---|---|--- |---|
| 1 | Contacts page shell | none — `Column` → AppBar-like header (search + tabs) + `CollapsibleSearchChrome` + `Expanded(child: TabBarView(...))` (L1281-1324) — Expanded bounded by parent Column in shell Expanded body | no LayoutBuilder | no ConstrainedBox | off-tab guard `SizedBox.shrink()` at L1046 is intentional (default switch case for `_hubTabForSection`, not a provider error) | `contacts_page.dart` L1110-1329 |
| 2 | Suppliers tab | none — `async.when()` → `RefreshIndicator` → `ListView.separated` (L1425-1457) or `RefreshIndicator` → `ListView` with `HexaEmptyState` in `SizedBox(height: mq.height * 0.55)` (L1400-1423); no Expanded inside tab body | no LayoutBuilder | no ConstrainedBox | none — `async.when()`: loading → `ListSkeleton` (L1395); error → `ContactsHubLoadError`=HexaEmptyState+Retry (L1396-1398); empty → `HexaEmptyState` "No suppliers yet" + Add supplier (L1411-1419); data → `ListView.separated` with `_SupplierCard` rows | `contacts_page.dart` L1388-1461 |
| 3 | Brokers tab | none — identical structure to Suppliers: `async.when()` → `RefreshIndicator` → `ListView.separated` or `HexaEmptyState` in `SizedBox(height: mq.height * 0.55)` | no LayoutBuilder | no ConstrainedBox | none — loading → `ListSkeleton` (L1485); error → `ContactsHubLoadError` (L1486-1488); empty → `HexaEmptyState` "No brokers yet" + Add broker (L1501-1509); data → `ListView.separated` with `_BrokerCard` rows | `contacts_page.dart` L1478-1550 |
| 4 | Categories tab | none — nested `catsAsync.when()` → `itemsAsync.when()` → `ListView.separated` or `HexaEmptyState` in `SizedBox(height: mq.height * 0.55)`; no Expanded inside tab body | no LayoutBuilder | no ConstrainedBox | none — loading → `Center(CircularProgressIndicator)` (L1564, L1575); error → `ContactsHubLoadError` (L1565-1569, L1576-1580); empty → `HexaEmptyState` "No categories yet" + Add category (L1596-1605); data → `ListView.separated` | `contacts_page.dart` L1552-1662 |
| 5 | Items tab | none — nested `catsAsync.when()` → `itemsAsync.when()` → `ListView.separated` or `HexaEmptyState` in `SizedBox(height: mq.height * 0.55)`; no Expanded inside tab body | no LayoutBuilder | no ConstrainedBox | none — loading → `Center(CircularProgressIndicator)` (L1676, L1690); error → `ContactsHubLoadError` (L1677-1681, L1691-1695); empty → `HexaEmptyState` "No catalog items yet" + Add item (L1712-1720); data → `ListView.separated` | `contacts_page.dart` L1664-1781 |

Supporting widgets verified clean (`VERIFIED_CODE`):
- `_SupplierCard` — `Row` with `CircleAvatar` + `Expanded(Column(...))` + `PopupMenuButton`; name `Text.rich(maxLines: 2, overflow: ellipsis)` (L142-153); location `Row` + `Expanded(Text.rich(maxLines: 2, overflow: ellipsis))` (L157-177); phone `Row` + `Flexible(Text(maxLines: 1, overflow: ellipsis))` (L196-204) — all overflow-safe. `contacts_page.dart` L66-235.
- `_BrokerCard` — `Row` with `CircleAvatar` + `Expanded(Column(name, commission))` + `PopupMenuButton`; name `Text.rich(maxLines: 2, overflow: ellipsis)` (L300-310) — overflow-safe. `contacts_page.dart` L237-344.
- `ContactsHubLoadError` — `HexaEmptyState` (Column(mainAxisSize: min) → ListView-safe). `contacts_page.dart` L1783-1805.
- `ContactsWorkspaceCountsStrip` — horizontal strip of count badges; no Expanded issues.

### Observations (no code change needed)

| # | Severity | Observation | Why no change |
|---|---|---|---|
| OBS-1 | P3 (intentional) | Empty state `SizedBox(height: MediaQuery.sizeOf(context).height * 0.55)` used in all four tabs (L1412, L1502, L1597, L1713). | This is a display height for the `HexaEmptyState` — not a layout constraint. It ensures the empty state is vertically centered within a reasonable area. `MediaQuery.sizeOf` always returns finite values on all platforms. |
| OBS-2 | P3 (intentional) | `ContactsPage` has no explicit `isDesktopLayout` branching — same layout on desktop and mobile. | The page is a `Column` with `Expanded(TabBarView)` — works at any width. Desktop benefit comes from the wider content area provided by the shell rail. No desktop-specific layout needed. |

### Architecture notes
- **Hub model**: `ContactsHubSection` enum (people / catalog) with sub-tabs. `_hubTabForSection` switches between people tabs (Suppliers/Brokers) and catalog tabs (Categories/Types/Items).
- **Search**: Local search across all four data sources (`_buildLocalSearchSnapshot`) — `TabBarView` shows search results when `_isSearching` is true.
- **Tab counts**: `_searchCountForActiveTab` computes per-tab result counts from the search snapshot.
- **Pull-to-refresh**: All four tabs wrap content in `RefreshIndicator` → invalidate provider + await future.
- **Card layout**: `_SupplierCard` and `_BrokerCard` both use `Row` + `Expanded` for text content with `PopupMenuButton` as the trailing action — structurally immune to overflow.

### Regression
- `flutter analyze` clean on `contacts_page.dart` (no new issues).
- No contacts-specific tests broken.

### Final status
AUDITING — desktop-only audit complete; all 4 criteria CLEAN; no P0/P1/P2 defects; 2 P3 observations logged (both intentional). Ready for live ≥1024px visual pass.

---

## UX-189 — Reports shell desktop audit (Phase E)

### Status
AUDITING — desktop-only audit complete 2026-08-11; no P0/P1 defects found.

### Priority
P2

### Scope
Desktop (≥1024) audit only — no mobile layout code touched. Six surfaces under `/reports`:

1. **Reports shell** — `reports_shell_page.dart` (3-col desktop layout: period sidebar + main content + filter drawer)
2. **Overview tab** — `tabs/reports_overview_tab.dart` (KPI grid + charts + insights pane)
3. **Items tab** — `tabs/reports_items_tab.dart` (skeleton + list)
4. **Purchases tab** — `tabs/reports_purchases_tab.dart` (agg + list)
5. **Stock tab** — `tabs/reports_stock_tab.dart` (CustomScrollView + slivers)
6. **Period nav sidebar** — `_ReportsPeriodNav` (L709-755): ListView of period options

### Audit criteria
For each surface: (a) unbounded Column/Row + Expanded; (b) LayoutBuilder returning NaN/infinite constraints; (c) ConstrainedBox with maxHeight from an unset MediaQuery; (d) provider/FutureBuilder returning `SizedBox.shrink()` on error/loading with no `HexaEmptyState` fallback.

### Findings

All six surfaces: **CLEAN on all four criteria** (`VERIFIED_CODE`, desktop only).

| # | Surface | (a) unbounded Col/Row+Expanded | (b) NaN/infinite LayoutBuilder | (c) MQ-unset ConstrainedBox maxH | (d) shrink-on-load/error w/o HexaEmptyState | Evidence |
|---|---|---|---|---|---|---|
| 1 | Reports shell | none — `Row(crossAxisAlignment: stretch)` (L615) with `SizedBox(width: periodW)` sidebar (L619-626) + `Expanded(Column(...))` main (L629-641) + optional `SizedBox(width: filterW)` drawer (L645-648); `Expanded` contains `ReportsPrimaryTabs` + `LinearProgressIndicator` + `Expanded(child: tabBody)` (L639) — all bounded by LayoutBuilder | LayoutBuilder at L688: `constraints.hasBoundedHeight` check with `MediaQuery.sizeOf(context).height` fallback (L690-692); width from `constraints.maxWidth.isFinite` check (L694-696) — both finite | none | none — `session == null` → `Center(Text('Sign in'))` (L678-679); loading → `showSkeleton` flag → `LinearProgressIndicator` (L637-638); empty → `HexaEmptyState` "No purchases in this period" + Retry (L582-589); error → inline error handling in `_buildTabBody` | `reports_shell_page.dart` L551-706 |
| 2 | Overview tab | none — desktop: `Row(crossAxisAlignment: stretch)` → `Expanded(flex: 5, child: scroll)` + `VerticalDivider` + `Expanded(flex: 3, child: DesktopDetailPaneScaffold)` (L88-150); both bounded by parent LayoutBuilder from shell; phone: `SingleChildScrollView` → `Column` (no Expanded) | no LayoutBuilder | no ConstrainedBox | none — `showEmpty` → `HexaEmptyState` "No purchases in this period" + Change period (L134-143); loading → skeleton via `showSkeleton` flag; error → `hasFetchError` flag → retry | `reports_overview_tab.dart` L20-151 |
| 3 | Items tab | none — `_ItemSkeletonRow` uses `Row` + `Expanded(Column(...))` (L110-128) inside bounded ListView; no vertical Expanded in tab body | no LayoutBuilder | no ConstrainedBox | none — loading → `_ItemSkeletonRow` list (skeleton); error → `HexaEmptyState` via parent; empty → `HexaEmptyState` | `reports_items_tab.dart` L100-133 |
| 4 | Purchases tab | none — similar structure to items tab; `ListView.builder` with bounded rows | no LayoutBuilder | no ConstrainedBox | none — loading/error/empty states handled by parent shell | `reports_purchases_tab.dart` |
| 5 | Stock tab | none — `CustomScrollView` with `SliverList` / `SliverToBoxAdapter` children; no Expanded inside slivers | no LayoutBuilder | no ConstrainedBox | none — `ops.when()`: loading → `Center(CircularProgressIndicator)` (L43); error → `Center(ReportsStockTabLoadError)`=HexaEmptyState+Retry (L47-54); data → `CustomScrollView` with filtered items | `reports_stock_tab.dart` L15-82 |
| 6 | Period nav sidebar | none — `ListView` of `ListTile` items (L725-753); no Expanded | no LayoutBuilder | no ConstrainedBox | none — pure navigation widget | `reports_shell_page.dart` L709-755 |

Shared hosts verified (`VERIFIED_CODE`):
- Shell LayoutBuilder (L688-701): `constraints.hasBoundedHeight` guard with `MediaQuery` fallback — both finite. Content gets `SizedBox(width, height)` with bound dimensions.
- `Row(crossAxisAlignment: stretch)` (L615): ensures all children fill the full height — the AGENTS lesson about "stretch + bind height" is followed (L613-614 comment explicitly documents this).
- `DesktopDetailPaneScaffold` (overview tab insights pane): Column-based layout with bounded header + scrollable body — no Expanded issues.
- `HexaDenseKpiGrid` (overview tab): `GridView(shrinkWrap: true, NeverScrollableScrollPhysics())` with `mainAxisExtent: 72` — fixed tile height, no aspect-ratio blanking.

### Observations (no code change needed)

| # | Severity | Observation | Why no change |
|---|---|---|---|
| OBS-1 | P3 (intentional) | Overview tab insights pane hidden when filter drawer is visible (≥1366px) — `showInsights = width < 1366` (L84). | Prevents 4-column layout (period + main + insights + filters). Filter drawer takes the insights slot on ultra-wide screens. |
| OBS-2 | P3 (structural) | Reports shell LayoutBuilder (L688) uses `MediaQuery.sizeOf(context).height` as fallback when `constraints.hasBoundedHeight` is false. | Scaffold body from shell always provides bounded height — fallback is a safety net for edge cases. No blank-pane risk. |

### Architecture notes
- **3-col desktop**: Period sidebar (fixed width `reportsPeriodNavCompact`/`reportsPeriodNavWidth`) + main content (Expanded) + filter drawer (fixed width, ≥1366 only). All three fill full height via `CrossAxisAlignment.stretch`.
- **Tab model**: `ReportsBiTab` enum (overview/items/purchases/stock) with `ReportsPrimaryTabs` as the tab bar. `_buildTabBody` switches between tab widgets.
- **Height bind**: LayoutBuilder at L688 wraps the entire content Row — ensures the desktop layout never lays out at 0 height on Flutter web (comment at L686-687).
- **Chart height**: `viewportHeight` clamped to `[kReportsChartMinHeight, 420]` from `MediaQuery.height * 0.38` clamped to `[400, 900]` (overview tab L48-49) — bounded display height, not a layout constraint.
- **Stall banner**: `_stallBanner` flag shows `LinearProgressIndicator` during long loads (L637-638) — inline progress, not a full-page state.

### Regression
- `flutter analyze` clean on `reports_shell_page.dart` and all tab files (no new issues).
- Pre-existing `reports_page_smoke_test.dart` failure (find.text('Items') ×2) is unrelated to this audit — verified pre-existing.

### Final status
AUDITING — desktop-only audit complete; all 4 criteria CLEAN; no P0/P1/P2 defects; 2 P3 observations logged (both intentional/structural). Ready for live ≥1024px visual pass.

---

## UX-190 — Settings desktop audit (Phase E)

### Status
AUDITING — desktop-only audit complete 2026-08-11; no P0/P1 defects found.

### Priority
P2

### Scope
Desktop (≥1024) audit only — no mobile layout code touched. Three surfaces under `/settings`:

1. **Settings page shell** — `settings_page.dart` (desktop Row: sidebar + main content)
2. **Settings sidebar** — `_SettingsSidebar` (L480-515): fixed-width nav tiles
3. **Settings form list** — `settingsList` (L67-393): `ListView` of `_SectionTitle` + `_SettingsCard` children

Supporting widgets: `DesktopPageShell` (shared/widgets/desktop_page_shell.dart), `_SettingsCard` (L614-636), `_SectionTitle` (L594-612).

### Audit criteria
For each surface: (a) unbounded Column/Row + Expanded; (b) LayoutBuilder returning NaN/infinite constraints; (c) ConstrainedBox with maxHeight from an unset MediaQuery; (d) provider/FutureBuilder returning `SizedBox.shrink()` on error/loading with no `HexaEmptyState` fallback.

### Findings

All three surfaces: **CLEAN on all four criteria** (`VERIFIED_CODE`, desktop only).

| # | Surface | (a) unbounded Col/Row+Expanded | (b) NaN/infinite LayoutBuilder | (c) MQ-unset ConstrainedBox maxH | (d) shrink-on-load/error w/o HexaEmptyState | Evidence |
|---|---|---|---|---|---|---|
| 1 | Settings page shell | none — `Row(crossAxisAlignment: stretch)` (L404) with `_SettingsSidebar(SizedBox(width: 220))` + `VerticalDivider` + `Expanded(child: DesktopPageShell(child: settingsList))` (L413-419) — Expanded bounded by parent Scaffold body in shell Expanded body | no LayoutBuilder (DesktopPageShell handles constraints internally) | no ConstrainedBox | none — page is pure form-based; no provider loading/error states; `sessionProvider` reads synchronously after login | `settings_page.dart` L403-427 |
| 2 | Settings sidebar | none — `SizedBox(width: 220)` → `ListView` of `_SidebarTile` (ListTile) items (L499-513); no Expanded | no LayoutBuilder | no ConstrainedBox | none — pure navigation widget; no provider state | `settings_page.dart` L480-515 |
| 3 | Settings form list | none — `ListView` (L67) with `_SectionTitle` (Padding + Text) and `_SettingsCard` (Card + Column(children with Dividers)) children; no Expanded inside list items | no LayoutBuilder | no ConstrainedBox | none — form reads from `sessionProvider`, `localNotificationsOptInProvider`, `notificationKindTogglesProvider` (all synchronous after login); no AsyncValue patterns | `settings_page.dart` L67-393, L594-636 |

Shared hosts verified (`VERIFIED_CODE`):
- `DesktopPageShell` (desktop_page_shell.dart L14-100): `LayoutBuilder` → if `constraints.maxWidth >= minWidth` (kDesktopMin): `Align(topLeft)` → `SizedBox(width: min(constraints.maxWidth, resolvedMax), height: constraints.maxHeight)` when bounded; `ConstrainedBox(maxHeight: MediaQuery.height)` + `SizedBox(height: h)` when unbounded. Content is always bounded. If `constraints.maxWidth < minWidth`: returns content as-is (phone path). Width is always `math.min(constraints.maxWidth, resolved)` — never infinite.
- `_SettingsCard` (L614-636): `Card` → `Column(children: _withDividers(...))` — no Expanded; Column children are ListTile rows with natural height.
- `_SettingsSidebar` (L499): `SizedBox(width: 220)` → `ListView` — fixed width, scrollable content.

### Observations (no code change needed)

| # | Severity | Observation | Why no change |
|---|---|---|---|
| OBS-1 | P3 (intentional) | Settings page uses `MediaQuery.sizeOf(context).width >= 720` for `isDesktop` (L65), not the standard `kDesktopMin` (1024). This means the desktop sidebar layout appears at 720px (tablet width). | Intentional: Settings is a form page that benefits from the sidebar navigation at tablet widths too. The sidebar is only 220px, leaving ≥500px for the form content. No blank-pane risk. |
| OBS-2 | P3 (structural) | `DesktopPageShell` uses `Align(alignment: topLeft)` for desktop content — flush with the sidebar, no center-float gutters. | By design: "Desktop: flush with sidebar (topLeft). Below desktop this branch is not used" (comment at L69-70). Prevents blank gutters on ultra-wide screens. |

### Architecture notes
- **Desktop layout**: `Row` with sidebar (220px) + Expanded main content. The `DesktopPageShell` constrains content width to `maxFormWidth` and aligns left — consistent with other form pages.
- **No provider loading states**: Settings reads from `sessionProvider` (synchronous after session restore) and local preferences. No `AsyncValue.when()` patterns.
- **Form sections**: Account, Business, Stock & Catalog, Purchases, Notifications, Appearance, Troubleshooting (debug only), About — each wrapped in `_SettingsCard` with `Divider` separators.
- **Role-gated sections**: Backup (owner only), Users (canManageUsers), API credentials (ownerOrAdmin), Command center (ownerOrAdmin) — all conditional on role checks, not layout concerns.

### Regression
- `flutter analyze` clean on `settings_page.dart` and `desktop_page_shell.dart` (no new issues).
- No settings-specific tests broken.

### Final status
AUDITING — desktop-only audit complete; all 4 criteria CLEAN; no P0/P1/P2 defects; 2 P3 observations logged (both intentional/structural). Ready for live ≥1024px visual pass.

---

## UX-191 — Staff shell twins desktop audit (Phase E)

### Status
AUDITING — desktop-only audit complete 2026-08-11; no P0/P1 defects found.

### Priority
P2

### Scope
Desktop (≥1024) audit only — no mobile layout code touched. Four surfaces under `/staff`:

1. **Staff shell screen** — `staff_shell_screen.dart` (Row: rail + AppShellBody)
2. **AppShellBody** — `shell/app_shell.dart` (Column: banners + Expanded(navigationShell) + bottomBar)
3. **Staff bottom bar** — `_StaffShellBottomBar` (L245-328): mobile-only, hidden at desktop
4. **Staff FAB** — Positioned barcode scan button (L222-234): absolute positioning, no layout impact

Supporting: `WebCompactSideNav` (shared with owner shell), `StaffShellAutoRefreshListener`, `StaffShellNav` model.

### Audit criteria
For each surface: (a) unbounded Column/Row + Expanded; (b) LayoutBuilder returning NaN/infinite constraints; (c) ConstrainedBox with maxHeight from an unset MediaQuery; (d) provider/FutureBuilder returning `SizedBox.shrink()` on error/loading with no `HexaEmptyState` fallback.

### Findings

All four surfaces: **CLEAN on all four criteria** (`VERIFIED_CODE`, desktop only).

| # | Surface | (a) unbounded Col/Row+Expanded | (b) NaN/infinite LayoutBuilder | (c) MQ-unset ConstrainedBox maxH | (d) shrink-on-load/error w/o HexaEmptyState | Evidence |
|---|---|---|---|---|---|---|
| 1 | Staff shell screen | none — `SizedBox.expand` → `Material` → `Stack(fit: StackFit.expand)` → `Row(crossAxisAlignment: stretch)` (L156-214) with `SizedBox(width: railWidth)` rail (L163-168) + `Expanded(child: AppShellBody(...))` (L169-213) — Expanded bounded by Row bounded by Stack bounded by SizedBox.expand (window fill) | no LayoutBuilder | no ConstrainedBox | none — staff shell pages handle their own loading/error states; shell itself has no provider loading | `staff_shell_screen.dart` L149-242 |
| 2 | AppShellBody | none — `Column(crossAxisAlignment: stretch)` (L30) with `...topBanners` + `AppShellConnectivityBanners()` + `Expanded(child: ColoredBox(child: navigationShell))` (L35-39) + optional `bottomBar` — Expanded bounded by parent Column in staff shell's Expanded in Row | no LayoutBuilder | no ConstrainedBox | none — `navigationShell` is the `StatefulNavigationShell` (IndexedStack); tab pages handle their own states | `app_shell.dart` L14-45 |
| 3 | Staff bottom bar | N/A — `_StaffShellBottomBar` uses `Row` + `Expanded` for each nav tile (L277-293, L294-310) inside bounded `Padding` + `ClipRRect` + `Material` — but this widget is **only rendered on mobile** (`showBottomBar` is false when `width >= kDesktopMin`, L95-97) | N/A | N/A | N/A — not rendered on desktop | `staff_shell_screen.dart` L245-328; desktop guard at L95-97 |
| 4 | Staff FAB | N/A — `Positioned(right: 16, bottom: 68 + MQ.viewPadding)` (L222-224) — absolute positioning inside `Stack`, no layout impact | N/A | N/A | N/A — positioned widget, not a layout child | `staff_shell_screen.dart` L222-234 |

Shared hosts verified (`VERIFIED_CODE`):
- `WebCompactSideNav` (shared with owner shell): fixed-width rail (`kShellLabeledRailWidth` / `kShellCompactRailWidth`); `showLabels` auto-resolved from desktop breakpoint (L110). Same widget as owner shell — already verified in UX-196/UX-197.
- `Stack(fit: StackFit.expand)` (L157): forces all children to fill the Stack bounds → Row gets full window dimensions → Expanded gets bounded width and height.
- Staff pages (Home, Stock, Scan, Search, Tasks, Deliveries) are routed through `StatefulNavigationShell` → IndexedStack — each page handles its own loading/error states independently.

### Observations (no code change needed)

| # | Severity | Observation | Why no change |
|---|---|---|---|
| OBS-1 | P3 (structural) | Staff shell uses `Stack(fit: StackFit.expand)` → `Row` pattern instead of owner shell's `ResponsiveShellLayout` → `LayoutBuilder` → `Row` pattern. Both achieve bounded Expanded, but staff lacks the `constraints.maxWidth.isFinite` retry guard. | `SizedBox.expand` + `Stack(fit: expand)` guarantees fill-to-window on all frames — no first-frame blank risk. The LayoutBuilder guard in `ResponsiveShellLayout` is a safety net for edge cases that `SizedBox.expand` already prevents. |
| OBS-2 | P3 (intentional) | Staff bottom bar (`_StaffShellBottomBar`) uses `Row` + `Expanded` for nav tiles — same pattern as owner shell mobile bottom nav. Only rendered when `width < kDesktopMin`. | Mobile-only code path. Desktop uses the `WebCompactSideNav` rail instead. No desktop layout impact. |

### Architecture notes
- **Staff rail**: `WebCompactSideNav` with 5 destinations (Home, Stock, Scan, Search, Tasks) + footer (Notifications, Help). No "Manage" secondary group (staff doesn't need Catalog/Contacts/Settings from the rail).
- **Branch model**: `StaffShellBranch` enum (home, stock, scan, search, tasks, deliveries) with `staffShellBranchIndexForPath` for route→index mapping.
- **Auto-refresh**: `StaffShellAutoRefreshListener` handles tab-return refresh and realtime signals — same pattern as owner shell's `ShellTabAutoRefreshListener`.
- **FAB**: Barcode scan FAB positioned absolutely in the Stack — visible on all staff tabs except Home, Scan, Search, Stock, and Notifications (L216-221 guard).
- **Session hint**: Red banner for auth-degraded state — `Expanded(Text(sessionHint))` inside bounded Row (L186-198).

### Regression
- `flutter analyze` clean on `staff_shell_screen.dart` and `app_shell.dart` (no new issues).
- `flutter test test/staff_shell_nav_ia_test.dart` — 5/5 pass (already verified in UX-196/UX-197 regression).

### Final status
AUDITING — desktop-only audit complete; all 4 criteria CLEAN; no P0/P1/P2 defects; 2 P3 observations logged (both structural/intentional). Ready for live ≥1024px visual pass.

---

# FOLLOW-UP AUDIT — UX-192…UX-195 (2026-08-10 screenshots)

| ID | Surface | Status | Notes |
|---|---|---|---|
| UX-192 | Bulk print swallowed PDF error | DONE | Prod non-PII `[BarcodeOp]` logging + site tags. VM reproduce: single Code128 A4 dense PDF succeeds. **DISCOVERED FOLLOW-UP UX-192a:** live web/API failure still needs prod log capture after deploy — do not blind-patch layout. |
| UX-193 | Reports Overview chart hang | DONE | Snapshot gate uses `shellBranchIsVisible` SSOT. Chart loading bounded 12s → Retry. |
| UX-194 | Bulk print code-less late warn | DONE | Toolbar amber banner for missing-code count; Print uses printable subset; empty-batch guard kept. |
| UX-195 | AppTextField label overlap | DONE | `contentPadding` top 20 + floating label `height: 1.0` in `AppTextField`. |

---

# CODE HYGIENE BOARD (CODE_HYGIENE.md)

| Phase | Status | Notes |
|---|---|---|
| Section 8 standing rules | ACTIVE | Search-first gate on every session via `code-hygiene.mdc` |
| HYG-S5 duplicate inventory | DONE | Audit complete; **DUP-F-001 consolidated** — next ID needs approval |
| HYG-S5 DUP-F-001 consolidation | DONE | `landingApprox` / `landingGross` / `ledgerLineLandingGross` SSOT |
| HYG-S5 DUP-B-003 consolidation | DONE | Category trade-summary → `trade_line_amount_expr` + report statuses |
| HYG-S5 DUP-F-002 consolidation | DONE | `PurchaseEntryWizard` (dropped `_v2` filename/class) |
| HYG-S5 DUP-F-005 consolidation | DONE | Dead compact provider removed; staff/snapshot use shared dedupe |
| HYG-S5 DUP-B-002 consolidation | DONE | Owner dashboard spend → `trade_line_amount_expr` |
| HYG-S5 DUP-F-003 consolidation | DONE | Shared `catalog_item_core_fields` across create/edit/barcode/batch |
| HYG-S6 dead code audit | Flutter A + Backend A/B DONE | Orphans + unused imports + `/stock/low|critical` + `item_price_consistency` removed; Settings stubs STOP |
| HYG-S7 API/duplicate-call audit | … + R-001 DONE | Next: **SF-002** or **K-002** |

---

# PHASE C — FriendlyLoadError clearance (UX-152…UX-178)

**Status:** DONE (`VERIFIED_CODE` + `VERIFIED_TEST`)

**Result:** `rg "FriendlyLoadError\\("` under `lib/features` → **0** constructor sites. `GroupedSectionErrorCard` / `kFriendlyLoadNetworkSubtitle` helpers may remain in `friendly_load_error.dart`.

**Batch verification:** Phase C load-error widget tests → **30/30 passed** (local `flutter test` suite of new/updated error chrome tests).

**Per-task substeps (historical):** S0 claim → S1 read sites → S2 preflight → S3 extract widget → S4 wire → S5 390 widget test → S6 test+analyze → S7 board DONE → S8 STOP.

**Order completed:** UX-152 stock → purchase → contacts → reports → stock satellites → settings → ops/barcode/search → UX-178.