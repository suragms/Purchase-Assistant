# AGENT PROMPT 01 — REMOVE ALL UNWANTED FEATURES
**Stack:** FastAPI backend + Flutter frontend
**Run this FIRST before any other prompt.**

---

## YOUR TASK

Remove every trace of the following dead/unwanted features from the codebase. Do NOT break any existing import that references something you delete — fix the import too.

---

## BACKEND DELETIONS

### Step 1: Delete backend router files entirely
```
backend/app/routers/ai_chat.py
backend/app/routers/whatsapp_reports.py
backend/app/routers/cloud_expense.py
backend/app/routers/razorpay_webhook.py
backend/app/routers/billing.py
```

### Step 2: Delete backend service files entirely
```
backend/app/services/app_assistant_chat.py
backend/app/services/assistant_business_context.py
backend/app/services/assistant_entity.py
```

### Step 3: Delete backend model files entirely
```
backend/app/models/whatsapp_report_schedule.py
backend/app/models/ai_engine.py
backend/app/models/cloud_expense.py
backend/app/models/platform_integration.py
backend/app/models/platform_monthly_expense.py
backend/app/models/billing_payment.py
backend/app/models/business_subscription.py
backend/app/models/feature_flag.py
```

### Step 4: Edit `backend/app/main.py`
Remove these import lines:
```python
# DELETE these lines:
from app.routers import ai_chat
from app.routers import whatsapp_reports
from app.routers import cloud_expense
from app.routers import billing
from app.routers import razorpay_webhook
```

Remove these `app.include_router(...)` lines:
```python
# DELETE these lines:
app.include_router(whatsapp_reports.router)
app.include_router(whatsapp_reports.internal_router)
app.include_router(ai_chat.router)
app.include_router(cloud_expense.router)
app.include_router(billing.router)
app.include_router(razorpay_webhook.router)
```

### Step 5: Edit `backend/app/models/__init__.py`
Remove all imports for deleted model classes:
- `WhatsappReportSchedule`
- `AiEngine` (or whatever the ai_engine model exports)
- `CloudExpense`
- `PlatformIntegration`
- `PlatformMonthlyExpense`
- `BillingPayment`
- `BusinessSubscription`
- `FeatureFlag`

### Step 6: Delete unused Alembic migration files
These migrations are for removed features. Delete them:
```
backend/alembic/versions/004_cloud_expenses.py
backend/alembic/versions/006_cloud_payment_metadata.py
```
**DO NOT delete any other migration files** — they are needed for existing production data.

### Step 7: Remove `price_intelligence` router if it depends on AI
Check `backend/app/routers/price_intelligence.py`. If it imports from `app_assistant_chat` or any AI service, remove those imports only. Keep the router itself if it has non-AI endpoints.

---

## FLUTTER DELETIONS

### Step 1: Delete Flutter feature files entirely
```
flutter_app/lib/features/voice/presentation/voice_page.dart
flutter_app/lib/features/voice/  (entire folder)
flutter_app/lib/features/reports/presentation/reports_whatsapp_sheet.dart
```

### Step 2: Edit `flutter_app/pubspec.yaml`
Remove these dependency lines completely:
```yaml
# DELETE:
razorpay_flutter: ^1.4.4
speech_to_text: ^7.0.0
```
Keep all other dependencies unchanged.

### Step 3: Edit `flutter_app/lib/features/settings/presentation/settings_page.dart`
Remove all Razorpay code:
```dart
// DELETE this import:
import 'package:razorpay_flutter/razorpay_flutter.dart';

// DELETE these class members:
Razorpay? _razorpay;

// DELETE initState code that creates Razorpay:
_razorpay = Razorpay();
_razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, ...);
_razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, ...);

// DELETE dispose code:
_razorpay?.clear();

// DELETE any UI widgets that launch Razorpay payment
// DELETE any methods that reference razorpayOrderId, razorpayPaymentId, razorpaySignature
```

### Step 4: Delete cloud expense provider
```
flutter_app/lib/core/providers/cloud_expense_provider.dart
```

### Step 5: Edit `flutter_app/lib/core/providers/notifications_provider.dart`
Remove these imports and references:
```dart
// DELETE import:
import 'cloud_expense_provider.dart';

// DELETE from mergedNotificationFeedProvider:
final cloudItems = ref.watch(cloudCostNotificationItemsProvider);

// DELETE from the byId merge loop:
...cloudItems,

// DELETE these providers entirely:
final cloudCostAlertCountProvider = Provider<int>(...);
final cloudCostNotificationItemsProvider = Provider<List<NotificationItem>>(...);
```

Also remove `maintenanceNotificationItemsProvider` and `maintenanceAlertCountProvider` — these are for SaaS billing, not for Harisree warehouse use.

Remove `maintenance_payment_provider.dart` import and the `maintItems` reference from `mergedNotificationFeedProvider`.

### Step 6: Edit `flutter_app/lib/core/router/app_router.dart`
Remove routes for:
```dart
// DELETE routes for:
GoRoute(path: '/voice', ...)
GoRoute(path: '/ai-chat', ...)
GoRoute(path: '/reports/whatsapp', ...)
```

### Step 7: Edit any shell/nav files that show Voice or AI Chatbot buttons
Search for references to `/voice` route and `/ai-chat` route in:
- `flutter_app/lib/features/shell/shell_screen.dart`
- `flutter_app/lib/shared/widgets/shell_quick_ref_actions.dart`
- Any FAB or nav button that opens voice

Remove those navigation items.

### Step 8: Edit `flutter_app/lib/features/settings/presentation/settings_page.dart`
Remove the AI Usage section:
```dart
// DELETE the entire ai_usage_page reference and navigation entry
```

Remove the `ai_usage_page.dart` file:
```
flutter_app/lib/features/settings/presentation/ai_usage_page.dart
```

---

## VERIFICATION CHECKLIST

After completing all deletions, verify:

- [ ] `flutter pub get` completes without errors
- [ ] `python -c "from app.main import app"` runs without ImportError
- [ ] No remaining references to `Razorpay` in any `.dart` file
- [ ] No remaining references to `speech_to_text` in any `.dart` file
- [ ] No remaining references to `ai_chat` in `main.py`
- [ ] No remaining references to `whatsapp_reports` in `main.py`
- [ ] No remaining references to `cloud_expense` in `main.py`
- [ ] `flutter_app/pubspec.yaml` does NOT contain `razorpay_flutter` or `speech_to_text`
- [ ] `backend/app/routers/` does NOT contain `ai_chat.py`, `whatsapp_reports.py`, `cloud_expense.py`, `billing.py`, `razorpay_webhook.py`
- [ ] Notifications provider still compiles (cloud/maintenance items removed, server + stock + trade alerts remain)

---

## DO NOT DELETE

- `google_sign_in` from pubspec (used for login)
- `admin_web/` folder (developer tool, keep as-is)
- `flutter_local_notifications` (needed for backup scheduling)
- `mobile_scanner` (needed for barcode)
- Any migration file not listed above for deletion
- `backend/app/routers/me.py` (user profile — keep)
- `backend/app/routers/users.py` (user management — keep)
- `backend/app/routers/analytics.py` (reports — keep)
- `backend/app/routers/reports_trade.py` (purchase reports — keep)
