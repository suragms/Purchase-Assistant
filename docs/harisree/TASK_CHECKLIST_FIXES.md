# TASK CHECKLIST FIXES

## Issues
- Checkbox states could feel delayed or inconsistent under optimistic updates.

## Implemented
- Finalization now removes `_busy` and `_optimisticDone` markers together to prevent stale optimistic completion markers.
- Existing 409 conflict handling retained with provider invalidation fallback.

## Follow-up
- Add widget test for rapid-tap completion and conflict response handling.
