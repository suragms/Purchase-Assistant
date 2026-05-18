# 🏭 HARISREE AGENCY — MASTER BUILD TASK LIST
## One Task at a Time · Paste into Cursor · Wait · Verify · Next

> **RULES BEFORE YOU START:**
> - Paste ONE task block into Cursor at a time
> - Wait for Cursor to finish completely
> - Run `flutter analyze` after every Flutter task
> - Run `python -m pytest` after every backend task
> - Only move to next task after current one passes
> - Never skip a task — each one builds on the previous
> - If Cursor breaks something, fix it before continuing

---

## 📊 PROGRESS TRACKER

| # | Task | Status | Notes |
|---|------|--------|-------|
| 01 | Home page ref-after-dispose crash fix | ✅ DONE | ProviderScope.containerOf + mounted guards |
| 02 | Remove /signup public route | ✅ DONE | No public route; `/signup` → login; API register disabled |
| 03 | DatePickerButton widget | ✅ DONE | `shared/widgets/date_picker_button.dart` |
| 04 | KeyboardAwareSuggestionOverlay | ✅ DONE | Overlay + typeahead scroll 220px |
| 05 | Stock audit DB table + API | ✅ DONE | `/v1/businesses/{id}/stock/*` + SQL 021 |
| 06 | User management DB + API | ✅ DONE | SQL 022 + `routers/users.py` |
| 07 | Role guard FastAPI dependency | ✅ DONE | `require_role` in `deps.py` |
| 08 | Login page — remove Google, role redirect | ✅ DONE | Branding + staff → `/staff/home` |
| 09 | Owner shell — add Stock tab | ✅ DONE | 5 tabs; FAB action sheet |
| 10 | Staff shell screen | ✅ DONE | `staff_shell_screen.dart` |
| 11 | Barcode scan page | ✅ DONE | `features/stock/barcode_scan_page.dart` |
| 12 | Item detail page redesign | ✅ DONE | Warehouse layout + barcodes |
| 13 | Update stock sheet | ✅ DONE | `update_stock_sheet.dart` |
| 14 | Stock page (warehouse viewport) | ✅ DONE | Dense table + filters |
| 15 | Owner home dashboard redesign | ✅ DONE | Quick actions + stock stats |
| 16 | Staff home dashboard | ✅ DONE | Scan-first `staff_home_page.dart` |
| 17 | Tax mode toggle in purchase entry | ✅ DONE | TaxMode in calc_engine + item sheet |
| 18 | User management page (owner) | ✅ DONE | Owner-only **create**; managers view list |
| 19 | Barcode print — single item PDF | ✅ DONE | `barcode_print_page.dart` |
| 20 | Barcode label — last purchase data | ✅ DONE | PDF + API last purchase |
| 21 | Item create — reduce steps | ✅ DONE | Session prefs + no broker on catalog |
| 22 | Duplicate detection engine | ✅ DONE | Fuzzy check + warning banner |
| 23 | Smart unit auto-detection | ✅ DONE | `smart_unit_service.dart` |
| 24 | Bulk barcode print page | ✅ DONE | `/barcode/bulk-print` |
| 25 | Low stock notifications | ✅ DONE | Hourly job + in-app notifications |
| 26 | Notifications page | ✅ DONE | API + bell badge |
| 27 | Real-time Supabase subscriptions | ❌ BLOCKED | 30s poll fallback on home; realtime deferred |
| 28 | Staff activity log page | ✅ DONE | `/staff/activity` |
| 29 | User detail + reset password | ✅ DONE | `user_detail_page.dart` |
| 30 | Super admin panel | 🔄 IN PROGRESS | Scaffold at `/admin`; full platform TBD |

**Status key:** ⬜ TODO · 🔄 IN PROGRESS · ✅ DONE · ❌ BLOCKED

---

---

## 🔴 PHASE 1 — CRASH FIXES (Do These First, App Is Broken)

---

### TASK 01 — Fix Home Page Crash (ref-after-dispose)

**File:** `flutter_app/lib/features/home/presentation/home_page.dart`

**Verify before starting:** Run app → go to Home → save a purchase → confirm it doesn't crash or go blank.

```
TASK: Fix 3 timer/ref bugs in home_page.dart that cause "Bad state: Cannot use ref after widget was disposed" and blank home screen.

FILE: flutter_app/lib/features/home/presentation/home_page.dart

FIX 1 — _handlePurchasePostSave method:
Find the WidgetsBinding.instance.addPostFrameCallback inside _handlePurchasePostSave.
Replace the direct ref.invalidate calls with:
  final container = ProviderScope.containerOf(context, listen: false);
  container.invalidate(homeDashboardDataProvider);
  container.invalidate(homeShellReportsProvider);
  container.invalidate(reportsPurchasesPayloadProvider);
  invalidateTradePurchaseCachesFromContainer(container);
  container.read(purchasePostSaveProvider.notifier).state = null;
  _handlingPurchasePostSave = false;
  if (!mounted) return;
Add if (!mounted) return; check after every await in this method.

FIX 2 — _loadCapTimer callback:
Find: _loadCapTimer ??= Timer(const Duration(seconds: 6), () {
Replace the callback body with:
  if (!mounted) {
    _loadCapTimer = null;
    return;
  }
  ref.read(homeDashboardDataProvider.notifier).forceStopRefreshing();
  if (!mounted) return;
  setState(() {
    _loadCapReached = true;
    _loadCapTimer = null;
  });

FIX 3 — _resumeRefreshDebounce callback:
Find the _resumeRefreshDebounce Timer callback.
Add if (!mounted) { _resumeRefreshDebounce = null; return; } at the very start of the callback body.
Null out _resumeRefreshDebounce before calling setState.

After all 3 fixes: run flutter analyze. Zero errors required.
```

**✅ Verify:** Hot restart → go to Home → save a purchase → home refreshes without crash.

---

### TASK 02 — Remove Signup Public Route

**File:** `flutter_app/lib/core/router/app_router.dart`

```
TASK: Remove self-registration from the app. Staff should NOT be able to create their own accounts.

FILE: flutter_app/lib/core/router/app_router.dart

CHANGE 1: In the redirect function, remove '/signup' from the public routes list.
  Find: final public = loc == '/splash' || loc == '/get-started' || loc == '/login' || loc == '/signup' ...
  Remove: loc == '/signup' from this list.

CHANGE 2: Remove the GoRoute for /signup entirely from the routes list.

CHANGE 3: Remove the import for signup_page.dart if it becomes unused.

FILE: flutter_app/lib/features/get_started/presentation/get_started_page.dart
CHANGE: Remove any button or TextButton that navigates to /signup or SignupPage.
  Replace with nothing (just remove the widget — no replacement needed).

Do NOT delete signup_page.dart file yet — just remove all navigation to it.

Run flutter analyze after. Zero errors required.
```

**✅ Verify:** Launch app → Get Started page → confirm no "Create Account" button exists.

---

### TASK 03 — Build DatePickerButton Widget

**New file:** `flutter_app/lib/shared/widgets/date_picker_button.dart`

```
TASK: Create a reusable DatePickerButton widget that solves the date-field-behind-keyboard bug.

CREATE FILE: flutter_app/lib/shared/widgets/date_picker_button.dart

Widget spec:
  class DatePickerButton extends StatelessWidget
  Required params: DateTime? value, ValueChanged<DateTime> onChanged, String label
  Optional params: DateTime? firstDate, DateTime? lastDate, bool enabled = true

  Visual: Shows selected date as a tappable row:
    - Left: calendar icon (Icons.calendar_today_rounded)
    - Middle: label text (e.g. "Purchase Date") in grey if no value, formatted date if value set
    - Right: chevron icon
    - Border: rounded rectangle, 1px border, same style as existing app text fields
    - Use HexaColors and HexaDsTokens for all colors/spacing

  On tap: calls showDatePicker() with:
    context: context
    initialDate: value ?? DateTime.now()
    firstDate: firstDate ?? DateTime(2020)
    lastDate: lastDate ?? DateTime.now().add(Duration(days: 365))
    builder: wrap in Theme to match app colors

  IMPORTANT: This uses showDatePicker() modal — NEVER an inline date field.
  The modal always appears above keyboard regardless of scroll position.

THEN modify: flutter_app/lib/features/purchase/presentation/wizard/purchase_party_step.dart
  Find any TextField used for date input.
  Replace with DatePickerButton widget.
  Connect to existing date state in purchaseDraftProvider.

Run flutter analyze. Zero errors.
```

**✅ Verify:** Go to New Purchase → party step → tap date field → system date picker opens (not behind keyboard).

---

### TASK 04 — Fix Keyboard-Hiding Dropdown Suggestions

**New file:** `flutter_app/lib/shared/widgets/keyboard_aware_suggestion_overlay.dart`

```
TASK: Fix the critical bug where supplier/broker/item suggestion dropdowns hide behind the keyboard.

CREATE FILE: flutter_app/lib/shared/widgets/keyboard_aware_suggestion_overlay.dart

Build a KeyboardAwareSuggestionOverlay widget using Flutter's OverlayPortal:

  class KeyboardAwareSuggestionOverlay extends StatefulWidget
  Params: controller (OverlayPortalController), child (Widget), overlayChild (Widget builder)

  Logic:
    - Use OverlayPortal to render the suggestion list in the overlay layer (above keyboard)
    - On build: measure field's GlobalKey position using RenderBox.localToGlobal
    - Get keyboard height: MediaQuery.viewInsetsOf(context).bottom
    - Get screen height: MediaQuery.sizeOf(context).height
    - If field bottom y-position > screenHeight * 0.55:
        anchor list ABOVE the field (field.top - listHeight - 8px)
      Else:
        anchor list BELOW the field (field.bottom + 4px)
    - Suggestion list: fixed max height 220px, internal SingleChildScrollView
    - Dismiss: tap outside closes overlay (GestureDetector with HitTestBehavior.translucent on barrier)

MODIFY: flutter_app/lib/shared/widgets/typeahead_suggestions_card.dart
  Wrap the existing suggestions list in SingleChildScrollView with maxHeight 220px constraint.
  This fixes the no-scroll bug on its own even before full overlay refactor.

MODIFY: flutter_app/lib/features/purchase/presentation/widgets/party_inline_suggest_field.dart
  Wrap the suggestion dropdown trigger with KeyboardAwareSuggestionOverlay.
  Pass the suggestions list as overlayChild.

Run flutter analyze. Zero errors.
```

**✅ Verify:** New Purchase → tap Supplier field → type something → keyboard opens → suggestions visible ABOVE keyboard, scrollable.

---

---

## 🟠 PHASE 2 — BACKEND: DB + API FOUNDATION

---

### TASK 05 — Stock Audit Table + Stock API

**Files:** `backend/app/` (FastAPI)

```
TASK: Create stock_audit database table and stock management API endpoints.

STEP 1 — Create migration SQL file: backend/sql/021_stock_audit.sql

CREATE TABLE IF NOT EXISTS stock_audit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID NOT NULL REFERENCES catalog(id) ON DELETE CASCADE,
  old_qty DECIMAL(12,3) NOT NULL DEFAULT 0,
  new_qty DECIMAL(12,3) NOT NULL DEFAULT 0,
  adjustment_type VARCHAR(50) NOT NULL 
    CHECK (adjustment_type IN ('purchase','manual','damaged','expired','correction','verification')),
  reason TEXT,
  updated_by UUID REFERENCES users(id),
  updated_by_name VARCHAR(255),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_stock_audit_item_id ON stock_audit(item_id);
CREATE INDEX idx_stock_audit_updated_at ON stock_audit(updated_at DESC);
CREATE INDEX idx_stock_audit_updated_by ON stock_audit(updated_by);

Also add to catalog table if not exists:
  ALTER TABLE catalog ADD COLUMN IF NOT EXISTS current_stock DECIMAL(12,3) DEFAULT 0;
  ALTER TABLE catalog ADD COLUMN IF NOT EXISTS reorder_level DECIMAL(12,3) DEFAULT 0;
  ALTER TABLE catalog ADD COLUMN IF NOT EXISTS rack_location VARCHAR(100);
  ALTER TABLE catalog ADD COLUMN IF NOT EXISTS last_stock_updated_at TIMESTAMPTZ;
  ALTER TABLE catalog ADD COLUMN IF NOT EXISTS last_stock_updated_by VARCHAR(255);

STEP 2 — Create router: backend/app/routers/stock.py

Endpoints:
  GET  /api/stock/list
    Params: page (int=1), per_page (int=50), q (str=''), category (str=''), 
            subcategory (str=''), status (str='all')
    status values: 'all' | 'low' | 'critical' | 'out'
    Returns: { items: [...], total: int, page: int, per_page: int }
    Each item: { id, item_code, name, category_name, subcategory_name, 
                 current_stock, reorder_level, unit, rack_location, supplier_name,
                 stock_status, last_stock_updated_at, last_stock_updated_by }
    stock_status logic:
      'out' if current_stock == 0
      'critical' if 0 < current_stock <= reorder_level * 0.5
      'low' if current_stock < reorder_level
      'healthy' otherwise

  GET  /api/stock/search  (same params as list, optimized for search)

  GET  /api/stock/{item_id}  (full item detail)

  PATCH  /api/stock/{item_id}
    Body: { new_qty: float, adjustment_type: str, reason: str }
    Role guard: staff, manager, owner, super_admin
    Actions:
      1. Insert row into stock_audit (old_qty, new_qty, type, reason, user)
      2. UPDATE catalog SET current_stock=new_qty, last_stock_updated_at=now(), last_stock_updated_by=user_name
      3. Return updated item

  GET  /api/stock/audit/{item_id}
    Returns last 50 audit entries for item, newest first

  GET  /api/stock/low
    Returns all items where current_stock < reorder_level, ordered by (current_stock/reorder_level) ASC

  GET  /api/stock/critical  
    Returns items where current_stock <= reorder_level * 0.5

STEP 3 — Register router in backend/app/main.py:
  from app.routers import stock
  app.include_router(stock.router, prefix="/api")

Run: python -m pytest backend/tests/ -x
```

**✅ Verify:** `curl http://localhost:8000/api/stock/list` returns JSON with items array.

---

### TASK 06 — User Management DB + API

```
TASK: Create user management system in backend.

STEP 1 — Migration SQL: backend/sql/022_user_management.sql

ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'staff' 
  CHECK (role IN ('owner','manager','staff','super_admin'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS device_info JSONB;
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES users(id);

CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  login_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  logout_at TIMESTAMPTZ,
  device_info JSONB,
  is_active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS staff_activity_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  user_name VARCHAR(255),
  action_type VARCHAR(50) NOT NULL 
    CHECK (action_type IN ('SCAN','STOCK_UPDATE','ITEM_CREATE','PURCHASE_SAVE','VERIFICATION','LOGIN','LOGOUT')),
  item_id UUID REFERENCES catalog(id),
  item_name VARCHAR(255),
  details JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_staff_activity_user ON staff_activity_log(user_id, created_at DESC);
CREATE INDEX idx_sessions_user ON user_sessions(user_id, is_active);

STEP 2 — Create router: backend/app/routers/users.py

Endpoints:
  POST /api/users
    Role guard: owner, super_admin only
    Body: { full_name, phone, role, password (optional — auto-generate if empty), is_active }
    Auto-generate password: 8 chars, mix of letters+numbers, readable (no confusing chars like 0/O)
    Returns: { user, generated_password (shown once) }

  GET /api/users
    Role guard: owner, manager, super_admin
    Returns all users with: id, name, phone, role, is_active, last_login_at, last_active_at
    Include today_stats: { scans, stock_updates, items_created } from staff_activity_log

  GET /api/users/active-sessions
    Role guard: owner, manager, super_admin
    Returns users active in last 5 minutes (last_active_at > now() - interval '5 min')

  GET /api/users/{user_id}
    Role guard: owner, manager, super_admin
    Returns user detail + last 20 activity log entries

  PATCH /api/users/{user_id}
    Role guard: owner, super_admin
    Body: { full_name?, phone?, role?, is_active? }

  POST /api/users/{user_id}/reset-password
    Role guard: owner, super_admin
    Generates new 8-char password, hashes it, saves it
    Returns: { new_password } (plain text, shown once)

  POST /api/auth/login  (MODIFY existing login endpoint)
    On successful login:
      UPDATE users SET last_login_at=now(), last_active_at=now()
      INSERT INTO user_sessions (user_id, device_info)
    JWT payload must include: { user_id, role, business_id, name, phone }

  POST /api/activity-log  (internal — called by Flutter after key actions)
    Body: { action_type, item_id?, item_name?, details? }
    Auth required (any role)
    Inserts to staff_activity_log

Register router in main.py.
Run: python -m pytest -x
```

**✅ Verify:** `POST /api/users` with owner token → creates user + returns generated password.

---

### TASK 07 — Role Guard FastAPI Dependency

```
TASK: Add role-based access control to all existing and new FastAPI endpoints.

FILE: backend/app/deps.py  (modify existing)

ADD this function:

def require_role(*roles: str):
    """
    Usage: user=Depends(require_role('owner', 'manager'))
    Raises 403 if current user's role is not in allowed roles.
    """
    async def _dep(current_user: dict = Depends(get_current_user)):
        if current_user.get('role') not in roles:
            raise HTTPException(
                status_code=403,
                detail=f"Access denied. Required roles: {list(roles)}"
            )
        return current_user
    return _dep

Also add: def get_current_user_role(current_user: dict = Depends(get_current_user)) -> str:
    return current_user.get('role', 'staff')

Now apply role guards to these existing endpoints:
  - Any DELETE endpoint → require_role('owner', 'manager', 'super_admin')
  - Any settings/config endpoint → require_role('owner', 'super_admin')
  - Business profile update → require_role('owner', 'super_admin')
  - Any user creation → require_role('owner', 'super_admin')
  - Purchase reports → require_role('owner', 'manager', 'super_admin')

IMPORTANT: Do NOT break existing working endpoints.
Only ADD the Depends() guard — do not change any logic.

Run: python -m pytest -x  All existing tests must still pass.
```

**✅ Verify:** Call a protected endpoint without token → 401. Call with staff token on owner-only endpoint → 403. Call with owner token → 200.

---

---

## 🟡 PHASE 3 — FLUTTER: AUTH + NAVIGATION

---

### TASK 08 — Login Page Improvements

**File:** `flutter_app/lib/features/auth/presentation/login_page.dart`

```
TASK: Improve login page — remove Google sign-in, add role-aware redirect, show business branding.

FILE: flutter_app/lib/features/auth/presentation/login_page.dart

CHANGE 1 — Remove Google Sign-In:
  Find and remove the Google sign-in button widget entirely.
  Remove google_sign_in_helper.dart import if it becomes unused on this page.
  Keep the regular username/password login form intact.

CHANGE 2 — Business branding at top:
  Add at top of the form (above username field):
    - App/business logo (use existing business_profile_provider to load logo, fallback to warehouse icon)
    - Text: 'Harisree Agency' in bold 24px  (hardcode for now, can be dynamic later)
    - Subtext: 'Warehouse Management' in grey 14px

CHANGE 3 — Role-aware redirect after login:
  Find where successful login navigates.
  After login success, read the role from the JWT response or sessionProvider.
  Redirect logic:
    if role == 'staff' → context.go('/staff/home')
    if role == 'owner' || role == 'manager' || role == 'super_admin' → context.go('/home')
  
  NOTE: /staff/home route does not exist yet (Task 10 will create it).
  For now, redirect staff to /home temporarily with a TODO comment.

CHANGE 4 — Minimal forgot password:
  Keep 'Forgot Password?' text link but make it smaller (12px, grey).
  Add note below: 'Contact your manager to reset password' in small grey text.

Run flutter analyze. Zero errors.
```

**✅ Verify:** Login page loads → no Google button visible → business name shows at top.

---

### TASK 09 — Owner Shell: Add Stock Tab

**File:** `flutter_app/lib/features/shell/shell_screen.dart`

```
TASK: Add Stock tab to the owner/manager bottom navigation bar.

FILE: flutter_app/lib/features/shell/shell_screen.dart

CHANGE 1 — Add Stock as tab index 1:
  Current tabs: Home(0) | Reports(1) | History(2) | Search(3)
  New tabs:     Home(0) | Stock(1) | Reports(2) | History(3) | Search(4)

  Add Stock tab with:
    icon: Icons.inventory_2_outlined
    selectedIcon: Icons.inventory_2_rounded
    label: 'Stock'

CHANGE 2 — Update ShellBranch constants:
  FILE: flutter_app/lib/features/shell/shell_branch_provider.dart
  Update all ShellBranch.* integer constants to match new indices:
    home = 0
    stock = 1    ← NEW
    reports = 2  ← was 1
    history = 3  ← was 2
    search = 4   ← was 3

CHANGE 3 — Update switch statements in ShellScreen._ShellScreenState.build():
  Find the switch(idx) that invalidates providers on tab change.
  Add case for ShellBranch.stock:
    ref.invalidate(stockListProvider);  // provider doesn't exist yet, add TODO comment

CHANGE 4 — Update app_router.dart:
  FILE: flutter_app/lib/core/router/app_router.dart
  Add a new StatefulShellBranch for /stock with a placeholder page (just a Scaffold with 'Stock coming soon' text).
  This placeholder will be replaced in Task 14.

CHANGE 5 — FAB button:
  The existing FAB in shell opens /purchase/new.
  Change it to open a role-dependent bottom sheet with options:
    [🛒 New Purchase]
    [📷 Scan Barcode]
    [➕ Add Item]
  Each option navigates to its respective route.
  Use a simple showModalBottomSheet with ListTile options.

Run flutter analyze. Zero errors.
```

**✅ Verify:** App loads → bottom nav shows 5 tabs → Stock tab navigates → FAB shows 3 options.

---

### TASK 10 — Staff Shell Screen

**New file:** `flutter_app/lib/features/staff/presentation/staff_shell_screen.dart`

```
TASK: Build a separate navigation shell for staff role with scan-first design.

CREATE FILE: flutter_app/lib/features/staff/presentation/staff_shell_screen.dart

Build StaffShellScreen (same pattern as ShellScreen but 4 tabs):

Tabs: Home(0) | Stock(1) | Scan(2) | Search(3)
  Home:   icon=Icons.home_outlined, selected=Icons.home_rounded, label='Home'
  Stock:  icon=Icons.inventory_2_outlined, selected=Icons.inventory_2_rounded, label='Stock'
  Scan:   icon=Icons.qr_code_scanner_outlined, selected=Icons.qr_code_scanner_rounded, label='Scan'
  Search: icon=Icons.search_rounded, selected=Icons.manage_search_rounded, label='Search'

FAB: Large single button — [📷 SCAN] — opens /barcode/scan directly (no chooser sheet).
FAB styling: full gradient like existing FAB but with qr_code_scanner icon.

IMPORTANT styling rules:
  - Use same HexaColors, HexaDsTokens as owner ShellScreen
  - Copy offline banner logic from ShellScreen
  - Copy SafeArea handling exactly

Modify flutter_app/lib/core/router/app_router.dart:
  Add staff shell as a separate GoRouter route with its own StatefulNavigationShell.
  Routes under staff shell:
    /staff/home → StaffHomePage (placeholder Scaffold for now — Task 16 builds it)
    /stock → StockPage (shared with owner — same page)
    /barcode/scan → BarcodeScanPage (Task 11 builds it)
    /search → SearchPage (reuse existing)

Modify login redirect (from Task 08):
  Now that /staff/home exists, update the TODO comment to actually route staff here.

Modify app.dart or session_notifier.dart:
  After login, the app must check role and show the correct shell:
    role == 'staff' → StaffShellScreen (routes under /staff/*)
    otherwise → existing ShellScreen (routes under /*)

Run flutter analyze. Zero errors.
```

**✅ Verify:** Login as staff → sees 4-tab staff shell. Login as owner → sees 5-tab owner shell.

---

---

## 🟠 PHASE 4 — BARCODE SYSTEM

---

### TASK 11 — Barcode Scan Page

**New file:** `flutter_app/lib/features/barcode/presentation/barcode_scan_page.dart`

```
TASK: Build the barcode scan page — the most critical staff workflow entry point.

FIRST: Add mobile_scanner to pubspec.yaml if not already present:
  mobile_scanner: ^5.2.3
Run: flutter pub get

CREATE FILE: flutter_app/lib/features/barcode/presentation/barcode_scan_page.dart

Page spec:

1. CAMERA VIEW (takes up ~65% of screen height)
   Use MobileScannerController with:
     autoStart: true
     detectionSpeed: DetectionSpeed.normal
     formats: [BarcodeFormat.code128, BarcodeFormat.qrCode]
   
   Overlay on camera:
     - Dark semi-transparent background around the scan rect
     - Center rect: 280w x 160h, white border 2px, rounded corners 8px
     - Animated scan line: red horizontal line that moves top→bottom, loops every 2 seconds
     - Text below rect: 'Align barcode within the frame' in white 13px

2. TOP BAR
   - Back button (left)
   - Title: 'Scan Barcode' 
   - Torch toggle button (right): Icons.flashlight_on_rounded / Icons.flashlight_off_rounded
     Calls: controller.toggleTorch()

3. SCAN RESULT HANDLING
   In MobileScanner onDetect callback:
     - Debounce: if same code scanned within 1500ms, ignore
     - On valid scan:
         HapticFeedback.mediumImpact()
         controller.stop()
         Show loading overlay on scan rect (CircularProgressIndicator white)
         Call GET /api/barcode/lookup?code={scannedCode}
         
     On API response:
       FOUND → context.pushReplacement('/catalog/item/${item.id}?source=scan')
       NOT FOUND → showModalBottomSheet with:
           Title: 'Item not found'
           Subtitle: 'Code: ${scannedCode}'
           [➕ Create New Item] → context.push('/catalog/add?item_code=${scannedCode}&source=scan')
           [🔁 Scan Again] → controller.start()  dismiss sheet
           [✖ Close] → Navigator.pop
       ERROR → show SnackBar: 'Network error. Try again.' → controller.start()

4. MANUAL ENTRY FALLBACK (bottom of screen, above keyboard)
   TextField with:
     hint: 'Enter item code manually (e.g. ITM1022)'
     keyboardType: TextInputType.text
     textCapitalization: TextCapitalization.characters
     suffix: [Search] button
   On submit: same API call as scan result

5. RECENT SCANS (between camera and manual entry)
   Load from SharedPreferences key 'recent_scans' — list of {item_id, name, timestamp}
   Show as horizontal scrollable chips (max 8 shown)
   Chip: item name truncated to 15 chars
   Tap chip: context.push('/catalog/item/${item.id}')
   On each successful scan: prepend to list, keep max 10, save back

6. BACKEND ENDPOINT (add to backend/app/routers/stock.py):
   GET /api/barcode/lookup?code={item_code}
   Query: SELECT id, name, item_code, current_stock, reorder_level, unit FROM catalog WHERE item_code = :code
   Returns 200 with item or 404 if not found

Add /barcode/scan route to app_router.dart (outside both shells — accessible from anywhere).

Add to android/app/src/main/AndroidManifest.xml:
  <uses-permission android:name="android.permission.CAMERA"/>

Add to ios/Runner/Info.plist:
  <key>NSCameraUsageDescription</key>
  <string>Camera is used to scan item barcodes in the warehouse</string>

Run flutter analyze. Zero errors.
```

**✅ Verify:** Tap Scan from staff home → camera opens → scan a Code128 barcode with ITM code → navigates to item.

---

### TASK 12 — Item Detail Page Redesign

**File:** `flutter_app/lib/features/catalog/presentation/catalog_item_detail_page.dart`

```
TASK: Completely redesign the item detail page for warehouse use. This is the most important page — staff sees it after every scan.

FILE: flutter_app/lib/features/catalog/presentation/catalog_item_detail_page.dart

Accept optional query param: ?source=scan (shows scan banner if true)

PAGE LAYOUT (scrollable, SingleChildScrollView):

─── SECTION 1: HEADER ───
Row:
  Left: Item image 72x72 rounded (if exists), else grey box with Icons.inventory_2
  Right column:
    Item name — bold 20px, max 2 lines
    Item code chip — monospace, grey background, e.g. [ITM1022]
    Status badge:
      🟢 Healthy (green)  if stock >= reorder_level
      🟠 Low Stock (orange)  if 0 < stock < reorder_level  
      🔴 Critical (red)  if 0 < stock <= reorder_level * 0.5
      ⚫ Out of Stock (black)  if stock == 0

─── SECTION 2: INFO GRID (2-column, compact) ───
Use a GridView or custom Row layout with 2 columns, 4 rows:
  [Current Stock: 45 BAG]    [Reorder Level: 20 BAG]
  [Unit: BAG]                [Category: Grains]
  [Subcategory: Rice]        [Rack: B-04]
  [Supplier: Everest Traders][Last Purchase: 12 May 2026]

Each cell: label in grey 11px above, value in black bold 15px below. Thin border separating cells.

─── SECTION 3: ACTION BUTTONS (4 large buttons in 2x2 grid) ───
All buttons use HexaColors, minimum 48px height, bold text:
  [📦 Update Stock]    [📋 View History]
  [✏ Quick Edit]       [🔔 Notify Owner]  ← only visible if low/critical stock AND role != owner

─── SECTION 4: BARCODE SECTION ───
Row with two side-by-side boxes:
  Left box: Code128 barcode image generated from item_code
    Use: barcode package (add to pubspec if not present: barcode: ^2.2.5)
    Barcode.code128().toSvg(item_code) → render as SvgPicture
  Right box: QR code image
    Barcode.qrCode().toSvg(item_code) → render as SvgPicture

Below barcode boxes:
  Row: [🖨 Print Label] [📤 Share Barcode]
  Print → navigates to /barcode/print/${item.id}
  Share → shares barcode image via share_plus package

─── SECTION 5: RECENT PURCHASES TABLE ───
Title: 'Recent Purchases'
Table header: Date | Qty | Unit | Rate | Supplier
Show last 5 rows from API (GET /api/stock/{item_id} should include recent_purchases array)
  Each row: compact, 13px text, alternating row background
  If no purchases: 'No purchases yet' empty state
[View All Purchases →] text link → navigates to item purchase history

─── SECTION 6: STOCK HISTORY TIMELINE ───
Title: 'Stock History'
Show last 8 entries from stock_audit:
  Each entry as a timeline row:
    Left: colored dot (green=increase, red=decrease, grey=correction)
    Middle: '{+15 BAG}  Physical Verification' 
    Right: '2h ago  by Ravi'
[View Full History →] → navigates to /stock/{item_id}/history

─── ALSO: Quick Edit inline (Task 03 will connect this) ───
When [Quick Edit] tapped:
  Show an inline edit section (expand/collapse):
    Fields: Name (text), Reorder Level (number), Rack Location (text)
    [Save Changes] button → PATCH /api/catalog/{id}

Add barcode package to pubspec.yaml:
  barcode: ^2.2.5
  flutter_svg: ^2.0.10 (if not already present)

Run flutter analyze. Zero errors.
```

**✅ Verify:** Scan item → item detail loads → barcode visible → stock info visible → all 4 action buttons visible.

---

### TASK 13 — Update Stock Sheet

**New file:** `flutter_app/lib/features/stock/presentation/update_stock_sheet.dart`

```
TASK: Build the UpdateStockSheet bottom sheet used from item detail and stock page.

CREATE FILE: flutter_app/lib/features/stock/presentation/update_stock_sheet.dart

class UpdateStockSheet extends ConsumerStatefulWidget
Required params: String itemId, String itemName, double currentStock, String unit

Design (bottom sheet, drag handle at top, resizeToAvoidBottomInset: true):

SECTION 1 — Current info (read-only display):
  'Updating stock for: [itemName]' in bold 16px
  Current Stock row: large number + unit, grey background chip

SECTION 2 — Input:
  Label: 'Physical Count'
  TextField: numericDecimal keyboard, autofocus: true
  Hint: 'Enter actual stock count'
  IMPORTANT: This field must be above keyboard always — use KeyboardSafeFormViewport or 
  wrap in SingleChildScrollView that auto-scrolls to focused field

SECTION 3 — Live diff preview (shows as user types):
  If new value entered:
    Show: 'Stock will change from [current] to [new] ([+/-diff])'
    Color: green if increase, red if decrease, grey if same
  If nothing typed yet: hide this section

SECTION 4 — Adjustment Reason dropdown:
  Label: 'Reason'
  Dropdown options:
    Physical Verification (default)
    Purchase Received
    Damaged / Expired
    Counting Error Correction
    Transfer Out
    Other
  Use a custom dropdown chip row (not a system dropdown — better mobile UX)

SECTION 5 — Save button (full width, gradient):
  [📦 Save Stock Update]
  On tap:
    Validate: new qty required, >= 0
    Call PATCH /api/stock/{itemId} with { new_qty, adjustment_type, reason }
    On success:
      HapticFeedback.mediumImpact()
      Show SnackBar: 'Stock updated for [itemName]'
      Call ref.invalidate on item detail provider
      Navigator.pop(context, true)  ← true = updated flag
    On error:
      Show error SnackBar with message from API

Add helper function to catalog_item_detail_page.dart:
  void _openUpdateStock() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,  // IMPORTANT: allows sheet to resize with keyboard
      builder: (_) => UpdateStockSheet(
        itemId: item.id,
        itemName: item.name,
        currentStock: item.currentStock,
        unit: item.unit,
      ),
    );
  }
Connect [📦 Update Stock] button on item detail page to this.

Run flutter analyze. Zero errors.
```

**✅ Verify:** Open item detail → tap Update Stock → sheet opens above keyboard → enter number → diff preview shows → save → stock updates → sheet closes.

---

### TASK 14 — Stock Page (Warehouse Viewport)

**New file:** `flutter_app/lib/features/stock/presentation/stock_page.dart`

```
TASK: Build the full-page warehouse stock viewport. Dense table design. NOT cards.

CREATE FILE: flutter_app/lib/features/stock/presentation/stock_page.dart

ALSO CREATE: flutter_app/lib/core/providers/stock_providers.dart
  stockListProvider — FutureProvider that calls GET /api/stock/list
  stockSearchProvider — StateNotifierProvider for search/filter state
  stockLowCountProvider — FutureProvider for GET /api/stock/low count

PAGE STRUCTURE:

─── TOP SEARCH + FILTER BAR (pinned at top) ───
Row 1: Full-width search TextField
  hint: 'Search items, codes, suppliers...'
  prefix: search icon
  suffix: clear button (X) when text entered
  onChange: debounce 300ms → update stockSearchProvider

Row 2: Horizontal scroll chips (status filters):
  [All ✓] [🟠 Low Stock] [🔴 Critical] [⚫ Out of Stock] [🔄 Recently Updated]
  Active chip: filled background. Only one active at a time.

Row 3: Category dropdown (full width, compact)
  'All Categories' default → filters stockListProvider

Info row: 'Showing 124 / 504 items' right-aligned, 12px grey

─── STOCK TABLE (ListView.builder) ───
Table header row (sticky-ish — use SliverPersistentHeader or just pin with Column):
  [Item Name | Stock | Reorder | Unit | Last Updated By]
  Header background: dark blue (HexaColors.brandPrimary), white text, bold 12px

Each item row (50px height, thin bottom border):
  Background color by status:
    healthy → white
    low → Color(0xFFFFF8E1)  (very light orange)
    critical → Color(0xFFFFEBEE)  (very light red)
    out → Color(0xFFF5F5F5)  (grey)
  
  Columns:
    [Item Name] — bold 13px, max 1 line, overflow ellipsis, width: flex 2
    [Stock Qty] — bold 14px, color-coded (green/orange/red/grey), width: 70px
    [Reorder] — 12px grey, width: 60px
    [Unit] — 12px, width: 45px
    [Updated By] — 11px grey, truncated to 8 chars, width: 65px

  Row interactions:
    Tap → context.push('/catalog/item/${item.id}')
    Long press → show bottom sheet with: 
      'Update Stock', 'Print Barcode', 'View History' options

─── PAGINATION ───
Load 50 items initially.
When user scrolls to bottom (use NotificationListener<ScrollEndNotification>):
  If more items available: load next 50 and append to list.
  Show loading spinner at bottom while fetching.

─── EMPTY STATE ───
If no items match filter: show hexa_empty_state.dart widget with 'No items found'

─── PERFORMANCE ───
ListView.builder — never use ListView with all items built at once.
stockListProvider should cache results for 30 seconds.
Use keep_alive on the tab so page doesn't rebuild every time tab is tapped.

Replace the placeholder /stock route in app_router.dart with this real page.

Run flutter analyze. Zero errors.
```

**✅ Verify:** Tap Stock tab → table loads → search filters items → status chips work → tap row → goes to item detail → long press → shows action sheet.

---

### TASK 15 — Owner Home Dashboard Redesign

**File:** `flutter_app/lib/features/home/presentation/home_page.dart`

```
TASK: Redesign the owner home dashboard. Remove AI chatbot, add operational stock cards.

FILE: flutter_app/lib/features/home/presentation/home_page.dart

REMOVE entirely (find and delete these widget trees):
  1. Any FloatingActionButton or widget referencing AssistantChatPage or /assistant route
  2. The SpendRingChart widget (Widget spend_ring_chart.dart usage on home)
  3. Any cloud_expense_provider related cards/widgets
  4. Any WhatsApp auto-report widget cards
  5. Any 'AI' or 'Assistant' labeled cards or buttons

KEEP:
  - Offline banner (already works perfectly)
  - Recent purchases list (tighten spacing)
  - Notification icon in app bar
  - The existing homeDashboardDataProvider data loading

ADD these new sections (add at top of page body, above existing recent purchases):

SECTION A — Header Row:
  Row(mainAxisAlignment: spaceBetween):
    Column: 'Harisree Agency' bold 18px + today's date 'Mon, 18 May' in grey 13px
    Row: notification bell IconButton (with badge if unread count > 0) + 
         CircleAvatar (initials of logged-in user name, tap = show logout option)

SECTION B — Quick Action Grid (2 rows x 3 buttons):
  GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: NeverScrollableScrollPhysics):
    Each button: Card with InkWell, Icon (32px) + Text label below
    Buttons:
      [📷 Scan] → /barcode/scan
      [📦 Add Stock] → shows item search then UpdateStockSheet  
      [🛒 Purchase] → /purchase/new
      [📊 Reports] → /reports  (tab navigation)
      [🏷 Barcode] → /barcode/bulk-print
      [👥 Users] → /settings/users  (only show if role == owner)

SECTION C — Stats Row (4 compact cards):
  Load from homeDashboardDataProvider (already exists) + new stockLowCountProvider
  Row of 4 equal-width cards:
    [Today: X purchases | ₹XX,XXX]  (existing data)
    [🟠 X Low Stock]  from GET /api/stock/low count — orange color
    [🔴 X Critical]   from GET /api/stock/critical count — red color
    [👤 X Online]      from GET /api/users/active-sessions count

SECTION D — Low Stock Alert Table (inline):
  Title: '⚠ Needs Attention' in orange bold
  Only show if low stock count > 0
  Show top 6 items from GET /api/stock/low:
    Each row: item name | stock qty | reorder level | status badge
  [View All Low Stock →] → navigates to Stock tab with Low filter active

SECTION E — Recent Stock Updates (new):
  Title: 'Recent Stock Updates'
  Load from GET /api/stock/audit — last 5 entries across all items
  Each row: item name | change (+/-X unit) | who did it | time ago
  If empty: hide this section

The existing SECTION F — Recent Purchases:
  Keep but reduce card height/padding to be more compact.
  Reduce whitespace between items.

Run flutter analyze. Zero errors.
```

**✅ Verify:** Owner home loads → no AI button visible → 6 quick actions visible → stock stats show → low stock section shows if items are low.

---

### TASK 16 — Staff Home Dashboard

**New file:** `flutter_app/lib/features/staff/presentation/staff_home_page.dart`

```
TASK: Build the staff home page — scan-first, bold, simple.

CREATE FILE: flutter_app/lib/features/staff/presentation/staff_home_page.dart

PAGE DESIGN (bold, high contrast, large touch targets):

─── HEADER ───
'Hello, [staffName]!' — bold 22px, uses sessionProvider for name
Row: Role badge [STAFF] in blue chip | Today's date | Notifications bell

─── BIG SCAN BUTTON (full width, 80px height) ───
Container(
  height: 80,
  decoration: BoxDecoration(gradient: HexaColors.ctaGradient, borderRadius: BorderRadius.circular(16))
  child: Row: [qr_code_scanner icon 32px] + ['SCAN BARCODE' bold 20px white]
  onTap: context.push('/barcode/scan')
)
This must be the FIRST thing users see after header. ONE TAP to camera.

─── QUICK ACTIONS (2x2 grid) ───
GridView.count(crossAxisCount: 2, childAspectRatio: 2.2, shrinkWrap: true):
  Each button: 56px height, border 1.5px, rounded 12px, icon + text
  [🔍 Search Item] → /search
  [➕ Add New Item] → /catalog/add
  [📦 Update Stock] → shows item search first, then UpdateStockSheet  
  [⚠ Low Stock] → /stock with low filter

─── TODAY'S ACTIVITY (3 compact stat cards in a Row) ───
Load from GET /api/activity-log?user_id=me&date=today
  [✓ X Verified]  [📦 X Updated]  [📷 X Scanned]
  Small cards, 12px labels, 20px bold numbers

─── RECENT SCANS ───
Title: 'Recent Scans' in 14px bold
Load from SharedPreferences 'recent_scans' (set by barcode scan page in Task 11)
Horizontal scroll row of chips:
  Each chip: item name (max 12 chars) + tap → /catalog/item/{id}
  Empty state: 'No recent scans' in grey

─── LOW STOCK ALERTS (conditional section) ───
Load from GET /api/stock/low (count only — or reuse stockLowCountProvider)
Only show if count > 0:
  Red container with '⚠ [X] items need attention'
  expandable → shows list of top 5 low items
  Each row: item name | stock qty | [Update] button → UpdateStockSheet

Route: Replace placeholder /staff/home with this page in app_router.dart.

Run flutter analyze. Zero errors.
```

**✅ Verify:** Login as staff → staff home loads → big SCAN button visible → tap it → camera opens.

---

---

## 🟡 PHASE 5 — PURCHASE FIXES

---

### TASK 17 — Tax Mode Toggle in Purchase Entry

**Files:** `purchase_item_entry_sheet.dart`, `purchase_tax_prefs.dart`, `calc_engine.dart`

```
TASK: Add tax mode toggle to purchase item entry. Three modes: Base+GST, Inclusive, No Tax.

STEP 1 — Extend TaxMode enum:
  FILE: flutter_app/lib/features/purchase/pricing/purchase_tax_prefs.dart
  Add: enum TaxMode { exclusive, inclusive, none }
  Add TaxMode to PurchaseTaxPrefs model if it doesn't exist.

STEP 2 — Update calc_engine.dart:
  FILE: flutter_app/lib/core/calc_engine.dart
  Find the function that calculates line totals.
  Add taxMode parameter (TaxMode, default: TaxMode.exclusive).
  
  Switch logic:
    TaxMode.exclusive:
      lineTotal = qty * rate * (1 + taxPct/100)
      baseAmount = qty * rate
      taxAmount = baseAmount * taxPct / 100
    
    TaxMode.inclusive:
      lineTotal = qty * rate  (rate already includes tax)
      baseAmount = (qty * rate) / (1 + taxPct/100)
      taxAmount = lineTotal - baseAmount
    
    TaxMode.none:
      lineTotal = qty * rate
      baseAmount = qty * rate
      taxAmount = 0

  IMPORTANT: Do NOT change function signature in a breaking way.
  Add taxMode as optional named param with default TaxMode.exclusive.
  All existing callers continue to work unchanged.

STEP 3 — Add toggle UI to item entry sheet:
  FILE: flutter_app/lib/features/purchase/presentation/widgets/purchase_item_entry_sheet.dart
  
  Find the tax% field section.
  Add ABOVE or BESIDE the tax% field:
    Row of 3 toggle chips: [Base + GST] [Incl. GST] [No Tax]
    Active chip: filled background (use HexaColors.brandPrimary for active)
    Inactive: bordered chip, transparent background
    
  State: _taxMode (TaxMode, default: TaxMode.exclusive)
  On chip tap: setState(() { _taxMode = selected; }) → triggers live calculation update

  Below the rate + qty fields, add a live calculation preview box:
    Small grey container, padding 8px, rounded corners
    Show only when rate > 0:
      TaxMode.exclusive:  'Base ₹[base] + [pct]% GST = ₹[total] landed'
      TaxMode.inclusive:  'Landed ₹[total] → Base ₹[base] + GST ₹[tax]'
      TaxMode.none:       'Rate ₹[total] (no tax)'
    Update live as user types rate or changes tax%

STEP 4 — Pass taxMode to existing line payload:
  In ItemEntryPayload or wherever the line data is assembled:
  Add taxMode field.
  Ensure it's sent to the API and stored (backend: add tax_mode column to trade_purchase_lines if it doesn't exist).

Run flutter analyze. Zero errors.
```

**✅ Verify:** New purchase → add item → toggle between 3 tax modes → live calculation preview updates correctly.

---

---

## 🟡 PHASE 6 — USER MANAGEMENT UI

---

### TASK 18 — User Management Page

**New file:** `flutter_app/lib/features/settings/presentation/user_management_page.dart`

```
TASK: Build the owner-only user management page with create user + share credentials.

CREATE FILE: flutter_app/lib/features/settings/presentation/user_management_page.dart

PAGE: UserManagementPage (role guard: only owner + super_admin can reach this)
Add role check at page init: if role != owner && role != super_admin → pop with snackbar 'Access denied'

─── APP BAR ───
Title: 'Users'
Action: [+ Add User] text button

─── FILTER TABS ───
TabBar: All | Active | Staff | Managers
Each tab filters the user list

─── USER LIST ───
Load from GET /api/users
Each user row (ListTile style, 64px height):
  Leading: CircleAvatar with initials + role-color background
    owner=blue, manager=orange, staff=grey
  Title: Full name + role badge chip inline
  Subtitle: phone number + 'Last seen X ago'
  Trailing: 
    Green dot (●) if last_active_at < 5 minutes ago (online now)
    Active/Inactive toggle switch

Tap row → UserDetailPage (Task 29 builds this — for now push a placeholder)

─── ADD USER FLOW ───
showModalBottomSheet(isScrollControlled: true) with CreateUserSheet:

CreateUserSheet fields:
  1. Full Name (required, text field)
  2. Phone / Username (required)
  3. Role (segmented button: Manager | Staff)  — owner role not shown
  4. Password (optional text field + 'Auto-generate' button that fills random 8-char password)
     Password field: show/hide toggle eye icon
  5. Active toggle (default ON)

[Create User] full-width button at bottom.

On submit:
  POST /api/users with data
  Show loading indicator on button
  On success: 
    Close the sheet
    Show CREDENTIAL SHARE MODAL (see below)
    Refresh user list

─── CREDENTIAL SHARE MODAL ───
showDialog (not dismissable by tapping outside):
  Title: '✅ User Created'
  Content box (bordered, light grey background):
    Name: [full name]
    Username: [phone]
    Password: [plaintext password] (large, bold, monospace font)
    
  Warning text: '⚠ Save this password now. It cannot be shown again.'
  
  Buttons (full width):
    [📋 Copy Credentials] → Clipboard.setData with formatted text:
      'Harisree App Login\nUsername: XXXX\nPassword: XXXX'
      Show SnackBar: 'Copied!'
    [📤 Share via WhatsApp] → url_launcher to:
      'https://wa.me/?text=Harisree App Login%0AUsername: XXXX%0APassword: XXXX'
    [✖ Done] → dismiss modal

Add /settings/users route to app_router.dart (role guarded in router redirect OR in page itself).
Add 'Users' option to existing settings_page.dart (only show if role == owner).

Run flutter analyze. Zero errors.
```

**✅ Verify:** Owner → Settings → Users → see user list → Add User → fill form → generate password → credential modal shows → copy button works.

---

---

## 🟡 PHASE 7 — BARCODE PRINT

---

### TASK 19 — Single Barcode Print Page + PDF

**New files:** `barcode_print_page.dart`, `barcode_pdf_service.dart`

```
TASK: Build single item barcode print page with PDF generation.

FIRST: Add packages to pubspec.yaml if not present:
  pdf: ^3.11.0
  printing: ^5.13.2
  barcode: ^2.2.5
  flutter_svg: ^2.0.10
Run: flutter pub get

CREATE FILE: flutter_app/lib/features/barcode/services/barcode_pdf_service.dart

class BarcodeLabelData {
  final String itemCode;
  final String itemName;
  final String? categoryName;
  final String unit;
  final double? currentStock;
  final DateTime? lastPurchaseDate;
  final double? lastPurchaseQty;
  final String? lastPurchaseUnit;
  final double? lastPurchaseRate;
}

class BarcodePdfService {
  static Future<Uint8List> generateSingleLabel({
    required BarcodeLabelData data,
    required LabelSize size,
    required int copies,
  }) async {
    return compute(_buildPdf, {'data': data, 'size': size, 'copies': copies});
  }
  
  static Uint8List _buildPdf(Map args) {
    // Use pdf package to generate label
    // Label layout per size:
    
    // SMALL (38x19mm): item_name (7pt) + barcode + item_code (6pt)
    // MEDIUM (57x32mm): item_name (8pt) + barcode + item_code (7pt) + 
    //   last purchase line: 'Last: [date]  [qty] [unit]  ₹[rate]' (6pt)
    // LARGE (100x50mm): item_name (10pt) + barcode + QR side by side +
    //   item_code (8pt) + last purchase (7pt) + current stock (7pt)
    
    // Barcode: use barcode package
    //   final svg = Barcode.code128().toSvg(data.itemCode, width: labelWidth, height: barcodeHeight)
    //   Add as SvgImage in pdf
    
    // For medium/large, add below barcode:
    //   If lastPurchaseDate != null:
    //     'Last: ${DateFormat('dd MMM yy').format(lastPurchaseDate!)}  ${lastPurchaseQty} ${lastPurchaseUnit}  ₹${lastPurchaseRate?.toStringAsFixed(0)}'
    //   Else:
    //     'No purchase yet'
    
    // Generate `copies` pages of the label
  }
}

enum LabelSize { small, medium, large }

CREATE FILE: flutter_app/lib/features/barcode/presentation/barcode_print_page.dart

ROUTE: /barcode/print/:item_id

Page loads BarcodeLabelData from GET /api/barcode/{item_id} (Task 11 added this — extend to include last purchase data):

BACKEND UPDATE — Extend GET /api/barcode/{item_id} to return:
  SELECT c.id, c.item_code, c.name, c.unit, c.current_stock,
    tp.purchase_date as last_purchase_date,
    tpl.qty as last_purchase_qty, tpl.unit as last_purchase_unit, tpl.rate as last_purchase_rate
  FROM catalog c
  LEFT JOIN LATERAL (
    SELECT tpl.qty, tpl.unit, tpl.rate, tp.purchase_date
    FROM trade_purchase_lines tpl
    JOIN trade_purchases tp ON tp.id = tpl.purchase_id
    WHERE tpl.catalog_item_id = c.id
    ORDER BY tp.purchase_date DESC
    LIMIT 1
  ) tpl ON true
  WHERE c.id = :item_id

PAGE LAYOUT:
  
  Top: Item name + item code in app bar subtitle
  
  LABEL PREVIEW (live preview that updates as options change):
    Show a scaled visual of the label (not actual PDF — just a Flutter Container that mimics it)
    Update instantly when size or options change
    
  LABEL SIZE PICKER (segmented button or chips):
    [Small 38x19mm] [Medium 57x32mm] [Large 100x50mm]
    
  COPIES field:
    Label: 'Number of copies'
    Row with [-] [number] [+] stepper, min 1 max 100
    
  SHOW LAST PURCHASE toggle (on by default for medium/large):
    Only visible when size != small
    'Show last purchase info on label' switch
    
  ACTION BUTTONS:
    [🖨 Print Now] → generates PDF → calls Printing.layoutPdf() → opens system print dialog
    [📥 Download PDF] → generates PDF → saves to Downloads folder using path_provider + io.File
    
  Both buttons: show CircularProgressIndicator while generating PDF (it takes 0.5-2 seconds)

Run flutter analyze. Zero errors.
```

**✅ Verify:** Item detail → Print Label → barcode print page loads → select Medium → preview shows barcode + last purchase info → Print → system print dialog opens.

---

### TASK 20 — Bulk Barcode Print Page

**New file:** `flutter_app/lib/features/barcode/presentation/bulk_barcode_print_page.dart`

```
TASK: Build the bulk barcode print page — print all items or selected category.

CREATE FILE: flutter_app/lib/features/barcode/presentation/bulk_barcode_print_page.dart

ROUTE: /barcode/bulk-print

BACKEND: Add batch endpoint to backend/app/routers/stock.py:
  POST /api/barcode/batch
  Body: { item_ids: [uuid, uuid, ...] }
  Returns: array of BarcodeLabelData objects (same fields as single item endpoint)
  Single SQL query with WHERE id = ANY(:item_ids) — no N+1 queries

PAGE:

─── TOP FILTER BAR ───
Row: Category dropdown (All Categories) | Status filter chips

─── SELECTION CONTROLS ───
Row: [☑ Select All] [☐ Deselect All] [Select by Category...]
Count text: 'X items selected'

─── ITEM LIST (checkbox list) ───
ListView.builder of all catalog items (paginated 50 at a time):
  Each row: Checkbox | item_name | item_code | current_stock | unit
  Tap row = toggle checkbox

─── PRINT OPTIONS PANEL (bottom, sticky) ───
  Row 1: Label size picker [Small] [Medium] [Large]
  Row 2: Copies per item [1] / [2] / [3] / [Custom]
  Row 3: Layout [2 per row] [3 per row] (on A4 sheet)
  
  [🖨 Print X Labels] button (shows count of total labels)
  [📥 Download PDF]

─── PDF GENERATION ───
  On print/download:
    1. Show full-screen progress dialog: 'Generating PDF... X/Y items'
    2. Fetch batch data: POST /api/barcode/batch with selected item_ids
    3. Run PDF generation in compute() isolate
    4. Generate A4 pages with label grid (2 or 3 per row)
    5. Each label: same as single print medium/large layout
    6. Open print dialog OR save to Downloads

Run flutter analyze. Zero errors.
```

**✅ Verify:** Bulk print page → select 5 items → Generate PDF → progress shown → PDF opens/downloads with correct labels.

---

---

## 🟢 PHASE 8 — POLISH & ADVANCED FEATURES

---

### TASK 21 — Item Create: Reduce Steps

```
TASK: Reduce item creation steps. Stop asking supplier/broker every time. Pre-fill from context.

FILE: flutter_app/lib/features/catalog/presentation/catalog_add_item_page.dart

CHANGE 1 — Accept defaultSupplierId param:
  Add optional String? defaultSupplierId and String? defaultSupplierName to the page constructor.
  If provided: pre-fill supplier field and show as a collapsed chip: 
    [✓ Everest Traders  ×]  (tap × to clear and pick different supplier)

CHANGE 2 — SharedPreferences memory for last used:
  On item save success: store in SharedPreferences:
    'last_used_category_id' 
    'last_used_subcategory_id'
    'last_used_supplier_id'
    'last_used_supplier_name'
  
  On page init: load these values and pre-fill the corresponding fields.

CHANGE 3 — Reorder the form fields (per master plan order):
  1. Item Name (autofocus, large input)
  2. Duplicate warning banner (auto-appears — Task 22 builds the engine)
  3. Category (pre-filled chip, tap to change)
  4. Subcategory (pre-filled chip, tap to change)
  5. Unit Type (auto-detected chip, tap to override — Task 23 builds detection)
  6. Supplier (pre-filled chip or inline search)
  7. Stock Qty (numericDecimal keyboard)
  8. Reorder Level (numericDecimal keyboard)
  9. Rack Location (text, optional, at the end)
  10. [+ More Details] expander for: HSN code, description, image

CHANGE 4 — Remove Broker from item create:
  Broker is only relevant at the PURCHASE level, not the item catalog level.
  Remove broker field from catalog_add_item_page.dart entirely.
  Broker stays in purchase_party_step.dart.

CHANGE 5 — Pass default supplier from purchase flow:
  In purchase_items_step.dart (or wherever 'Add New Item' is triggered during purchase):
  Pass the current purchase's supplier as defaultSupplierId to catalog_add_item_page.

Run flutter analyze. Zero errors.
```

**✅ Verify:** During a purchase with Everest Traders → tap Add New Item → supplier pre-filled → category pre-filled from last time → form takes < 15 seconds to complete.

---

### TASK 22 — Duplicate Detection Engine

```
TASK: Build duplicate detection — warn staff before creating duplicate items.

CREATE FILE: flutter_app/lib/core/services/duplicate_detection_service.dart

class DuplicateDetectionService {
  static Future<List<DuplicateMatch>> checkForDuplicates({
    required String itemName,
    String? supplierId,
    String? categoryId,
    required Ref ref,
  });
}

class DuplicateMatch {
  final String itemId;
  final String itemName;
  final double currentStock;
  final String unit;
  final String supplierName;
  final double similarityScore;
}

BACKEND: Add endpoint to existing catalog router:
  GET /api/catalog/fuzzy-check?name=Sugar+50KG&supplier_id=...&category_id=...
  
  SQL using pg_trgm (extension must be enabled: CREATE EXTENSION IF NOT EXISTS pg_trgm):
    SELECT id, name, current_stock, unit, supplier_name,
      similarity(name, :search_name) as score
    FROM catalog
    WHERE similarity(name, :search_name) > 0.35
      AND is_deleted = false
    ORDER BY 
      CASE WHEN supplier_id = :supplier_id THEN 0 ELSE 1 END,
      score DESC
    LIMIT 5
  
  Returns list of matches with similarity scores.

FLUTTER INTEGRATION — catalog_add_item_page.dart:
  In item name field onChange:
    Debounce 400ms
    If name length >= 3: call DuplicateDetectionService.checkForDuplicates
    
  If results returned with score >= 0.7:
    Show yellow warning box BELOW item name field:
      '⚠ Similar items already exist:'
      List each match: name | stock qty | supplier (compact rows)
      Buttons: [Use Existing Item] [Ignore, Create New]
    
    [Use Existing Item] → context.push('/catalog/item/${match.itemId}'), pop form
    [Ignore, Create New] → dismiss warning, allow continue

Run flutter analyze. Zero errors.
```

**✅ Verify:** Catalog add → type 'Sugar 50KG' → within 400ms yellow warning appears showing existing Sugar items → Use Existing opens that item.

---

### TASK 23 — Smart Unit Auto-Detection

```
TASK: Auto-detect item unit from item name. Extend existing unit_classifier.dart.

FILE: flutter_app/lib/core/utils/unit_classifier.dart  (EXTEND, do not rewrite)

Add function: String? detectUnitFromName(String itemName)

Rules (in priority order — check top to bottom, return first match):
  if name contains ' x ' AND (ends with 'pcs' OR contains 'pack'):
    → 'CASE'  (e.g. 'Soap 100g x 4', 'Maggi 70g x 12')
  
  if ends with 'KG' OR ends with 'kg' OR contains ' KG ' (ignore case):
    → 'BAG'   (e.g. 'Sugar 50KG', 'Rice 25Kg')
  
  if ends with 'GM' OR ends with 'G' OR ends with 'gram' (ignore case, word boundary):
    → 'PKT'   (e.g. 'Jeerakam 100GM', 'Chilli 500G')
  
  if ends with 'L' OR ends with 'LTR' OR ends with 'litre' (ignore case):
    → 'BOX'   (e.g. 'Ruchi 1L', 'Coconut Oil 5LTR')
  
  if ends with 'ML' OR ends with 'ml':
    → 'PKT'   (e.g. 'Milk 500ML')
  
  return null  (no detection — keep user's choice or existing value)

Also add: String? detectUnitDisplayHint(String itemName)
  Returns human-readable hint: 'Detected from name: BAG' or null

INTEGRATION — catalog_add_item_page.dart:
  In item name field onChange:
    After duplicate check debounce, also call detectUnitFromName
    If detected unit != current unit selection:
      Show info chip below unit picker: 
        ℹ 'Detected: BAG (from name)'  with x to dismiss
      Auto-set the unit dropdown to detected unit
      User can still override by tapping the unit dropdown

Run flutter analyze. Zero errors.
```

**✅ Verify:** Add item → type 'Sugar 50KG' → unit auto-changes to BAG → info chip shows → change to 'Pepsi 1L' → unit changes to BOX.

---

### TASK 24 — Low Stock Notifications + Notifications Page

```
TASK: Set up low stock alert system and improve notifications page.

PART A — BACKEND:

FILE: backend/app/routers/notifications.py (create new)

CREATE notifications table (add to a new migration SQL):
  CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL,
    user_id UUID,  -- NULL = broadcast to all owners/managers
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    message TEXT,
    item_id UUID REFERENCES catalog(id),
    priority VARCHAR(20) DEFAULT 'normal',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
  );
  CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
  CREATE INDEX idx_notifications_business ON notifications(business_id, created_at DESC);

Endpoints:
  GET /api/notifications?unread_only=false
    Returns notifications for current user, newest first, last 50
  
  PATCH /api/notifications/{id}/read
  PATCH /api/notifications/read-all
  GET /api/notifications/unread-count

Background task (add to main.py startup with asyncio):
  Every 60 minutes: scan catalog for items where current_stock < reorder_level
  For each found item: if no notification in last 12 hours for this item:
    INSERT INTO notifications (business_id, type='LOW_STOCK', title='Low Stock Alert',
      message='{name}: only {stock} {unit} remaining (reorder level: {reorder})',
      item_id, priority='high' if critical else 'normal')

PART B — FLUTTER:

FILE: flutter_app/lib/features/notifications/presentation/notifications_page.dart (MODIFY existing)

ADD:
  - Load from GET /api/notifications using Riverpod FutureProvider
  - Group notifications: 'Today' and 'Earlier' sections (SliverStickyHeader or simple Column headers)
  - Each notification row:
      Left: icon by type (inventory=stock, shopping_cart=purchase, person=user_action)
      Middle: title bold + message 2 lines
      Right: time ago + unread blue dot
      Background: white if read, light blue if unread
  - Mark as read on tap
  - [Mark all read] button in app bar
  - Pull to refresh

ADD badge to notification bell in home/staff header:
  Show unread count badge if count > 0
  Load from GET /api/notifications/unread-count, poll every 2 minutes

Run flutter analyze. Zero errors.
```

**✅ Verify:** Low stock item exists → notification appears in notifications page → bell shows badge count → tap notification → marks as read → badge updates.

---

### TASK 25 — Staff Activity Log Page

```
TASK: Build staff activity log page.

CREATE FILE: flutter_app/lib/features/staff/presentation/staff_activity_page.dart

ROUTE: /staff/activity

Load from GET /api/activity-log?user_id=me
Supports filter: today / this_week / this_month

PAGE:
  App bar: 'My Activity'
  Filter chips row: [Today] [This Week] [This Month]
  
  Activity list (ListView.builder):
    Each entry (48px row):
      Left: icon by action_type:
        SCAN → Icons.qr_code_scanner_rounded (blue)
        STOCK_UPDATE → Icons.inventory_2_rounded (green)
        ITEM_CREATE → Icons.add_box_rounded (purple)
        PURCHASE_SAVE → Icons.receipt_rounded (orange)
        VERIFICATION → Icons.check_circle_rounded (teal)
      Middle: 
        Title: human-readable action text (e.g. 'Updated stock for Sugar 50KG')
        Subtitle: details (e.g. '45 → 60 BAG (+15)')
      Right: time (e.g. '2:34 PM' for today, 'May 12' for older)
  
  Empty state: 'No activity yet' with icon
  
Add link to this page from staff home (small 'View My Activity' text link at bottom of today's activity section).

BACKEND: Add endpoint to routers/users.py:
  GET /api/activity-log
  Params: user_id (default: current user), period ('today'|'week'|'month'), page
  Query staff_activity_log table for this user, newest first

Run flutter analyze. Zero errors.
```

**✅ Verify:** Staff home → View My Activity → list of scans/updates shown → filter works.

---

### TASK 26 — Super Admin Panel

```
TASK: Build hidden super admin panel for HexaStack internal use.

CREATE FILE: flutter_app/lib/features/admin/presentation/super_admin_page.dart

ROUTE: /admin  (only reachable if role == super_admin)

ENTRY POINT — settings_page.dart:
  Find the app version text/widget in settings.
  Add GestureDetector with:
    onLongPress counter: track consecutive long presses
    After 3 consecutive long presses within 2 seconds:
      if role == super_admin → context.push('/admin')
      else → show SnackBar 'Super admin access required'

SUPER ADMIN PAGE SECTIONS:

1. System Health
   GET /api/admin/health → API status, DB connection, Supabase status
   Show as green/red indicators with last check time

2. Business List
   GET /api/admin/businesses → list of all businesses with user count, active status
   Each row: business name | owner | users | last activity | status toggle

3. Active Sessions (all businesses)
   GET /api/admin/sessions → all currently active sessions across all clients

4. Error Log
   GET /api/admin/errors?limit=50 → last 50 API errors with user context
   Each row: timestamp | endpoint | error | user | business

5. Feature Flags
   GET/PATCH /api/admin/features/{business_id} → toggle features per business

BACKEND: Add admin router at backend/app/routers/admin.py
  All endpoints require role == super_admin
  Use require_role('super_admin') on all routes

Run flutter analyze. Zero errors.
```

**✅ Verify:** Login as super_admin → Settings → long press version 3x → super admin page opens → system health shows.

---

### TASK 27 — Real-Time Supabase Subscriptions

```
TASK: Add live data to owner dashboard using Supabase Realtime.

FILE: flutter_app/lib/features/home/presentation/home_page.dart
FILE: flutter_app/lib/features/stock/presentation/stock_page.dart

PART A — Home dashboard live stats:

Add to home_page.dart _HomePageState.initState():
  // Subscribe to new purchases
  final purchaseSub = Supabase.instance.client
    .from('trade_purchases')
    .stream(primaryKey: ['id'])
    .order('created_at', ascending: false)
    .limit(1)
    .listen((_) {
      if (!mounted) return;
      ref.invalidate(homeDashboardDataProvider);
    });
  
  // Subscribe to stock_audit changes
  final stockSub = Supabase.instance.client
    .from('stock_audit')
    .stream(primaryKey: ['id'])
    .order('updated_at', ascending: false)
    .limit(1)
    .listen((_) {
      if (!mounted) return;
      ref.invalidate(stockLowCountProvider);
    });
  
  // Cancel on dispose:
  @override void dispose() {
    purchaseSub.cancel();
    stockSub.cancel();
    super.dispose();
  }

Add 'Live' green dot indicator next to the stats section title:
  Row: [Stats title] + [● LIVE] (green dot, 8px, pulsing animation)
  If Supabase disconnected: show [○ OFFLINE] grey dot instead

PART B — Stock page live row highlight:

When a stock_audit event comes in for an item currently visible in stock list:
  Update that item's row data in-place (don't reload full list)
  Flash that row with a brief green/orange highlight animation (200ms):
    AnimatedContainer background color → flash → return to normal

FALLBACK: If Supabase Realtime is unavailable, fall back to Timer.periodic(Duration(seconds: 30)) polling.

Run flutter analyze. Zero errors.
```

**✅ Verify:** Open owner home → update a stock from another device/browser → home dashboard refreshes within 3 seconds → LIVE indicator visible.

---

---

## ✅ FINAL VERIFICATION CHECKLIST

Run these after all tasks complete:

```bash
# Flutter analysis
cd flutter_app && flutter analyze

# Flutter tests  
cd flutter_app && flutter test

# Backend tests
cd backend && python -m pytest -v

# Backend lint
cd backend && ruff check app/

# Test on real iOS device (iPhone)
flutter run --release -d {your_iphone_udid}
```

**Manual test scenarios:**
1. Login as owner → full shell (5 tabs) → all quick actions work
2. Login as staff → staff shell (4 tabs) → scan button one tap → camera opens
3. Scan a barcode → item detail loads with all sections
4. Update stock → diff preview → save → audit log entry created
5. Add new item → supplier pre-filled → duplicate detection works → barcode auto-assigned
6. New purchase → tax mode toggle → all 3 modes calculate correctly
7. Owner → create user → share credentials modal → copy works
8. Print label (medium) → barcode + last purchase date visible
9. Bulk print → select items → PDF generates → downloads
10. Low stock notification → appears in notification bell

---

*Built by Claude (Anthropic) for Anandu — HexaStack Solutions, Thrissur, Kerala*
*Harisree Agency — Purchase + Stock + Barcode Operations System v4.0*
