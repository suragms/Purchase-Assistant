# Cursor quick rules — Harisree Purchase Assistant

Read with `.cursor/rules/purchase-assistant-master.mdc` and `context/rules/MASTER_CURSOR_RULES.md`.

## Never

- Duplicate `calc_engine.dart` logic on the client for money totals.
- Show raw exception text to users — use `FriendlyLoadError` / `friendlyApiError()`.
- Use `DropdownButtonFormField` for 500+ suppliers — use bottom sheet search.
- Call `listTradePurchases` more than ~2× per home screen load without reason.
- Let AI scan finalize purchases without explicit confirm + backend totals.

## Always

- Run `flutter analyze` after Flutter edits.
- Retry button on error states; shimmer on loading.
- `if (!mounted) return;` after `await` in `State` methods.
- Backend is source of truth for financial totals.
- Update `TASKS.md` after meaningful sessions.

## Architecture anchors

- `calc_engine.dart` — calculations SSOT
- `purchase_draft_provider.dart` — purchase draft state
- `session_notifier.dart` — auth + role
- `app_router.dart` — routes
- `hexa_api.dart` — API client
