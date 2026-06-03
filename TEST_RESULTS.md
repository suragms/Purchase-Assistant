# Test Results — Production Recovery

**Date:** 2026-06-02

## Backend (pytest)

**Command:**
```bash
python -m pytest tests/test_trade_purchases.py tests/test_purchase_stock_increment.py tests/test_stock_workflow_rebuild.py -q --tb=short
```

**Result:** **36 passed** in ~15s  
**Warnings:** Pydantic `json_encoders` deprecation (pre-existing, 91 warnings)

### Coverage areas

- Trade purchase CRUD and permissions
- Staff delivery verify without financial edits
- Stock increment on commit workflow
- Stock workflow rebuild scenarios

## Flutter (analyze)

**Command:**
```bash
flutter analyze lib/features/purchase lib/features/barcode lib/core/providers/stock_providers.dart lib/core/auth/session_notifier.dart
```

**Result:** **0 errors**

| Severity | Count | Notes |
|----------|-------|-------|
| warning | 2 | Unused imports in `purchase_home_page.dart` (pre-existing) |
| info | 2 | `dart:html` deprecation in barcode web helper (pre-existing) |

## Manual QA matrix (recommended before release)

| Case | Platform | Expected |
|------|----------|----------|
| Quick-add item → purchase bag 30kg | Web + Android | Save succeeds |
| Barcode scan in warehouse | iOS + Android | Lookup < 8s |
| Staff verify → owner commit | Any | Stock increases after commit only |
| Staff home → Deliveries | Desktop | Route loads |

## CI alignment

Per `.cursorrules` Phase 7: PR should run full `flutter test`, `flutter analyze`, `pytest`.

## Sign-off

Automated targeted suites **PASS** for recovery scope. Device smoke remains operator responsibility (camera permissions, offline queue).
