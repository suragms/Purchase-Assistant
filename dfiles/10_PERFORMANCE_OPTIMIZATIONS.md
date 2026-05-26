# AGENT PROMPT 10 — PERFORMANCE OPTIMIZATIONS

Status: focused pass implemented; production timing must still be measured.

## Scope

- Keep stock-critical list data warm briefly across navigation.
- Preserve explicit invalidation after stock mutations.
- Avoid duplicate loading states where a previous page of data exists.
- Keep API warmup cadence active after session bootstrap.

## Key Files

- `flutter_app/lib/core/providers/stock_providers.dart`
- `flutter_app/lib/core/api/api_warmup.dart`
- `flutter_app/lib/main.dart`

## Verification

- Returning to Stock should not show a full blank spinner when fresh data is cached.
- Stock mutations invalidate stock list, low counts, and alert providers.
- `ApiWarmupService.startPeriodicHealth` remains enabled.
- Real device and production timing still need final QA.

