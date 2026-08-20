# UI Edge Case Matrix — PurchaseAssistant

This document details the handling of runtime edge cases, data boundary conditions, network resilience, and viewport state changes across all application modules.

---

## Data Boundary & Empty/Extreme State Handling

| Edge Case Condition | Trigger Scenario | Current Failure Mode / Risk | Expected UI Behavior & Resilience Standard |
|---|---|---|---|
| **Empty Data Set** | Business has zero products, zero purchases, or search returns no hits. | Blank white screen or missing empty state message. | Render `HexaEmptyState` containing a descriptive icon, clear message ("No items found"), and primary action CTA ("Add First Item" or "Clear Filters"). Never display a blank white panel. |
| **Single Item** | Search or filter yields exactly 1 result. | List layout stretches single item to fill full screen height or looks misaligned. | Fixed height card or table row; list container maintains standard padding and max-width constraints. |
| **Large Data Set (1000+ Items)** | Unfiltered catalog or stock list loaded. | UI freezes or web CanvasKit crashes due to rendering 1000 DOM nodes simultaneously. | Use paginated or virtualized list views (`ListView.builder`) with server-side limit/offset or local virtual windowing. |
| **Very Long Text / Item Names** | Product name contains 150+ characters (e.g. "Suraj Brand Premium Basmati Rice Double Polished 25kg Bag Non-GMO Export Grade Batch #88291"). | Text overflows card boundary, causing red-and-black pixel overflow warning or pushing buttons off-screen. | Wrap text in `Text(name, maxLines: 2, overflow: TextOverflow.ellipsis)`. Expand detail on tap or tooltip hover. |
| **Extreme Financial Numbers** | Purchase total exceeds ₹10,00,00,000 (10 Crores) or rate has 4 decimal places. | Number text clips or wraps onto two lines in KPI cards and tables. | Format numbers via `NumberFormat.currency(locale: 'en_IN', symbol: '₹')`. Auto-fit font size using `FittedBox` or `clampedFont` for financial KPI cards. |
| **Missing Images / Broken Assets** | Catalog item image URL 404s or local asset missing. | Gray image box or unhandled Image error widget. | `Image.network` / `Image.asset` with `errorBuilder` fallback displaying category icon on `HexaColors.brandBackground`. |
| **Null / Missing Fields** | Optional HSN code, GST number, or broker ID is null. | "null" or "N/A" rendered as raw string in UI. | Display clean placeholder (e.g., "Not specified" in gray italic text or dash "—"). Never print "null". |

---

## Network & Async Error Resilience

| Edge Case Condition | Trigger Scenario | Current Failure Mode / Risk | Expected UI Behavior & Resilience Standard |
|---|---|---|---|
| **Slow API Response (High Latency)** | Poor 3G network or backend server under heavy query load (> 2s). | User thinks app froze and clicks submit button multiple times, creating duplicate purchases. | Show `ListSkeleton` or section `LinearProgressIndicator`. Disable primary submit buttons with spinner overlay during request. |
| **API Timeout / Connection Error** | Server unreachable or offline (`DioException.connectionTimeout`). | Displaying raw `DioException` stack trace or HTTP 500 error code in a SnackBar. | Show `FriendlyLoadError` or `HexaErrorCard` with user-friendly text ("Unable to connect to server. Please check your connection.") + "Retry" button. Never expose raw stack traces. |
| **Stale Session / Token Expired** | JWT access token expires during active session or 401 response from backend. | Silent white screen or unhandled exception during route change. | Router interceptor automatically saves current route location via `saveIntendedProtectedRoute`, redirects user to `/login` with friendly session expired banner, and restores location post-login. |
| **Concurrent Edit / Stale Record** | Two users edit the same stock quantity or purchase order simultaneously. | Overwriting remote state without warning or silent backend validation error. | Backend validates version/timestamp. UI catches conflict and displays modal: "This record was updated by another user. Reload latest data?" |
| **Permission Failure (RBAC)** | Staff user attempts to view financial totals or profit reports. | White screen or crash due to missing permissions. | Server-side authorization blocks route; UI hides financial numbers (rates, totals, profit) for staff roles and replaces with "Hidden (Owner Only)" badge or redirects to `/staff/home`. |

---

## Viewport & Device State Edge Cases

| Edge Case Condition | Trigger Scenario | Current Failure Mode / Risk | Expected UI Behavior & Resilience Standard |
|---|---|---|---|
| **Window Resize (Desktop)** | User resizes browser window from 1920px down to 800px while editing a form. | Layout breaks, controls overflow, or text fields lose focus and clear typed text. | Layout rebuilds adaptively using `LayoutBuilder`. Form state resides in Riverpod providers or `StatefulWidget` controllers outside `build()`, preserving all typed input. |
| **Soft Keyboard Open (Mobile)** | Soft keyboard slides up on mobile web, reducing viewport height from 840px to 350px. | Form content is shoved off-screen, or header content clips under top bar (`headerTopDy < 0`). | `Scaffold` manages keyboard inset via `resizeToAvoidBottomInset: true`. Forms inside sheets use `compact: true` mode, compacting brand headers so form inputs remain centered and visible. |
| **Orientation Change (Tablet)** | Rotating tablet from Portrait (768x1024) to Landscape (1024x768). | Navigation bar does not adapt, leaving mobile bottom bar on desktop layout. | Shell listens to `MediaQuery.sizeOf(context).width` changes and dynamically switches between bottom navigation bar (<600px) and left navigation rail (≥600px). |
| **Rapid Double Click** | User rapidly double-clicks "Save Purchase" or "Confirm Audit". | Duplicate purchase records created in database. | Disable CTA button immediately on first tap (`_loading = true`); enforce idempotency key on backend API payload. |
