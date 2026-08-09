# FEATURE: Duplicate & Dead-Code Sweep — PurchaseAssistant

## Context
FastAPI backend (`backend/app`, 133 `.py` files) + Flutter frontend (`flutter_app/lib`, 556 `.dart` files, 63 provider files). Codebase has grown incrementally across multiple builds. Before any new feature is added, the codebase must be mapped cleanly — this is prep work that de-risks every later feature.

## Verified findings (already confirmed — build on these, don't re-discover)
- `routers/stock_audits.py` (full audit-session CRUD, top-level mount) vs `routers/stock/stock_audit.py` (adjustment feed + variance, mounted under `/stock`) — functionally different but confusingly named. Any future AI coding agent or new dev is likely to edit the wrong file.
- `backend/scripts/archive/` contains stale ops scripts referencing the old Render hosting (e.g. `apply_render_env_cleanup.py`) — dead post-migration to the Windows server.
- 63 Flutter provider files — high for this app's scope, likely contains overlapping/duplicate data-fetching providers.

## Task
### Step 1 — Backend route map
Generate a flat table from every `@router.get/post/put/patch/delete` across `backend/app/routers/**`:
```
METHOD | FULL PATH (with prefix resolved) | FILE:LINE | AUTH DEPENDENCY
```
Flag: (a) any two routes resolving to the identical effective path, (b) any router registered but never imported anywhere else, (c) any endpoint with no auth dependency that clearly should have one.

### Step 2 — Resolve the stock_audits naming collision
Rename `routers/stock/stock_audit.py` → `routers/stock/stock_adjustments.py`. Update the import in `routers/stock/__init__.py` and anywhere else referenced. **Do not change any route paths** — this is a file/module rename only, zero frontend impact. Confirm with a full-text search for `stock_audit` (not `stock_audits`) after the rename to catch stragglers.

### Step 3 — Archive cleanup
List every file under `backend/scripts/archive/`. For each: confirm it's genuinely unused (grep for any import or invocation elsewhere). Move confirmed-dead files to a clearly labeled `_deprecated/` folder outside the deployed app path (or delete, if Anandu confirms), rather than leaving them ambiguously in `scripts/archive`.

### Step 4 — Orphaned file scan
Backend: for every `.py` under `app/`, check it's imported/referenced somewhere (excluding `__init__.py`, `main.py`, test files, alembic migrations). List orphans — do not delete without explicit sign-off, some may be intentionally dynamic-imported.
Flutter: same for `.dart` files under `lib/` — check for files with zero import references outside themselves.

### Step 5 — Provider audit (Flutter)
List all 63 provider files with: name, what backend endpoint(s) it calls, what widgets consume it. Specifically flag:
- Two+ providers independently calling the same endpoint (should share one provider + repository).
- Providers that re-fetch on every widget rebuild instead of caching/invalidating deliberately.
- Providers with unclear ownership (nothing consumes them, or consumed by only one throwaway widget — candidate for inlining).

## Deliverable
A single markdown report (not code changes) with the four tables above. Get explicit sign-off before deleting or merging anything — this sweep produces a plan, not a diff.

## Risk
Low if done as read-only analysis first. Risk only appears at the deletion/merge step — always confirm zero references before removing a file, and keep changes to one file/module at a time so a bad removal is trivially revertible.

## Tests
No new tests needed for the mapping step. For the `stock_audit.py` rename: run the existing test suite for that router unchanged (path/behavior didn't change, only the filename) — this should pass with zero modifications, which is the confirmation the rename was safe.
