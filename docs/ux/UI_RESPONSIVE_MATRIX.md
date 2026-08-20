# UI Responsive Matrix — PurchaseAssistant

This document details the responsive layout audit across all target viewport sizes, identifying layout bugs, overflow, clipping, and touch/mouse interaction issues.

---

## Viewport Breakpoints & Device Classification

- **Compact Mobile:** 320x800, 360x800
- **Standard Mobile:** 390x844, 430x932
- **Small Tablet (Portrait):** 600x900, 768x1024
- **Large Tablet / Foldable:** 820x1180, 900x1200, 1023x768 (Landscape Tablet)
- **Desktop (Standard & HD):** 1024x768, 1280x720, 1366x768, 1440x900
- **Ultra-Wide Desktop:** 1600x900, 1920x1080

---

## Detailed Audit Matrix by Viewport Category

### 1. Compact & Standard Mobile (320px – 430px)

| Component / Screen | Key Responsive Behavior | Identified Issues & Deficiencies | Required Corrective Action |
|---|---|---|---|
| **App Navigation** | Bottom Navigation Bar (5 tabs on Owner shell, 4 tabs on Staff shell). | Bottom bar consumes vertical height on short screens (320x800). Floating action buttons or sheets can overlap bottom navigation if padding is missing. | Ensure bottom padding accounts for `MediaQuery.viewPaddingOf(context).bottom` + safe area. Hide bottom bar when fullscreen modal sheet or keyboard is active. |
| **Purchase Entry Wizard** | Step 1 (Party), Step 2 (Fast Items), Step 3 (Review/Tally). | Fast items table wraps onto mobile cards, but line item unit selector and weight/qty inputs can squeeze when error messages trigger. | Use single-column stacked inputs on mobile (`width < 600`) for item entry; preserve `minTouchTarget = 48dp`. |
| **Stock Table / List** | Switches from data table to card list view on mobile. | Row action buttons (Quick Update, Quick Purchase, History) can wrap onto a second line or clip if item names are long. | Force item name to max 2 lines with `TextOverflow.ellipsis`; place action buttons in a trailing `Wrap` or right-aligned menu. |
| **Modal Sheets (`showHexaBottomSheet`)** | Bottom sheet with rounded top corners, swipe-to-dismiss drag handle. | When soft keyboard opens, forms inside `compact: true` sheets can push header content off-screen or create double scroll bounce if `viewInsets` is applied twice. | Enforce single keyboard owner: `Scaffold` owns `resizeToAvoidBottomInset: true`; sheet body uses `KeyboardSafeFormViewport` without manual `viewInsets` padding. |
| **Global Search Page** | Full-width search bar + chip filters + result list. | Search input field auto-focuses on open, invoking soft keyboard immediately and shrinking viewport height to ~300px. | Remove automatic autofocus on search route navigation on mobile; require explicit tap to focus search field. |
| **Catalog & Contacts Cards** | Responsive grid (1 col on 320px, 2 col on 390px+). | 2-column grid on 360px screen causes supplier phone numbers and category counts to clip horizontally. | Use 1 column grid for width < 380px, 2 columns for 380px–600px. Wrap card subtitles in `FittedBox` or clip with ellipsis. |

---

### 2. Tablets (600px – 1023px)

| Component / Screen | Key Responsive Behavior | Identified Issues & Deficiencies | Required Corrective Action |
|---|---|---|---|
| **Navigation Shell** | Switches from bottom navigation bar to 72px compact navigation rail on left. | Compact rail icons lack visible text labels, making primary navigation reliant on icon recognition. | Add explicit tooltips to all compact navigation rail items. On tablet landscape (≥900px), expand rail to 200px labeled sidebar. |
| **Home Dashboard** | 2-column KPI card grid + recent activity feed. | Quick action buttons stretch unnaturally across 800px width if unconstrained. | Wrap dashboard body in `HexaResponsiveCenter` with `maxWidth = 900px` for tablet viewports. |
| **Purchase Entry Wizard** | 2-column layout (form on left 65%, summary sidebar on right 35%). | Summary sidebar on right is tight at 768px width, causing totals text to wrap onto 2 lines. | Convert summary sidebar to a sticky bottom bar or top banner when viewport width is < 900px. |
| **Reports Shell** | Full analytics dashboard with period filter top bar. | Filter drawer opens over report content, obscuring key charts. | Convert filter drawer to a collapsible top accordion panel or compact inline toolbar for tablet sizes (600px–1023px). |
| **Master-Detail Panes** | Applied on Stock and Purchase pages. | 50/50 split at 768px leaves detail pane too narrow for line-item tables. | Use 40/60 split (40% list, 60% detail) or collapse to single-page navigation below 900px width. |

---

### 3. Desktop & Ultra-Wide (1024px – 1920px+)

| Component / Screen | Key Responsive Behavior | Identified Issues & Deficiencies | Required Corrective Action |
|---|---|---|---|
| **Navigation Sidebar** | 200px labeled side navigation rail on left. | On ultra-wide screens (1920px), content area expands, leaving massive empty white space on the right side if unconstrained. | Constrain max content width using `HexaResponsive.desktopContentMax` (1280px–1520px) with centered or flush-left alignment. |
| **Purchase Detail Pane** | Embedded master-detail detail pane on history page. | Detail view uses full-window breakpoint rules (`width >= 1024px`), rendering 2-column layout inside a 500px pane, causing severe horizontal squeezing. | Inspect pane's local `BoxConstraints` rather than `MediaQuery.sizeOf(context)` using `LayoutBuilder` inside master-detail panes. |
| **Catalog & Stock Tables** | Multi-column dense data table with hover states. | Mouse cursor remains `SystemMouseCursors.basic` on table rows instead of `SystemMouseCursors.click`. Hover highlighting is weak. | Wrap table rows in `InkWell` or `MouseRegion` with `cursor: SystemMouseCursors.click` and explicit `hoverColor: HexaColors.gray100`. |
| **Form Screens (Settings, Quick Add)** | Single-column form centered on desktop. | Form fields expand to 100% width on 1920px monitors if `HexaResponsiveCenter` is missing, making text fields 1600px wide. | Wrap all standalone form pages in `HexaResponsiveCenter(maxWidth: HexaResponsive.maxFormWidth)` (720px). |
| **Dialogs (`showDialog`)** | Centered dialog popups on desktop. | `showHexaBottomSheet` dialog mode uses fixed 0.88 height, rendering empty white space for short 2-field form dialogs. | Enforce `compact: true` on `showHexaBottomSheet` for short forms, enabling shrink-wrap height via `ListView(shrinkWrap: true)`. |

---

## Specific Breakpoint Testing Deficiencies

### Breakpoint Summary Matrix

| Viewport Width | Navigation Mode | Form Layout | Table / List Mode | Max Content Width |
|---|---|---|---|---|
| **< 600px (Phone)** | Bottom Nav (5 items) | 1 Column Stacked | Card / Compact List | 100% (Padding 12–16px) |
| **600px – 899px (Tablet Portrait)** | 72px Icon Rail | 1 Column / 2 Column | Compact Table / Card List | 720px – 840px |
| **900px – 1023px (Tablet Landscape)** | 200px Labeled Rail | 2 Column Grid | Master-Detail / Full Table | 880px – 960px |
| **1024px – 1599px (Desktop)** | 200px Labeled Sidebar | 2 Column Grid / Master-Detail | Full Dense Table | 1120px – 1400px |
| **≥ 1600px (Ultra-Wide)** | 240px Expanded Sidebar | 2 Column Grid / Master-Detail | Full Dense Table + Actions | 1520px – 1680px |
