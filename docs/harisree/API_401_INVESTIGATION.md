# API 401 INVESTIGATION

## Root Causes
- Refresh failure path treated transient errors as session-expired and forced logout.
- Mixed `401/403` handling across providers caused inconsistent behavior (logout on some surfaces, degraded on others).
- Early provider calls during cold start increased chance of auth race symptoms.

## Implemented Fixes
- In `session_notifier.dart`, logout now occurs only for invalid refresh (`401/403`) in interceptor refresh path.
- Transient refresh failures now surface degraded banner and keep session/tokens intact.
- Reports fetch path now avoids forced logout and uses degraded recovery messaging.

## Next Hardening
- Add bounded retry/backoff for `_plain` refresh endpoint call.
- Add explicit auth-state gate (`restoring/authenticated/unauthenticated`) for heavy providers.
- Consolidate auth error policy in one shared helper to avoid drift.
