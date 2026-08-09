# FEATURE: Staff Management Module

## Context
`backend/app/routers/users.py` already registers both `users.router` and `users.activity_router` in `main.py` — some user/activity infrastructure already exists. Check exactly what `activity_router` currently logs before adding anything new; extend, don't duplicate. `flutter_app/lib/features/staff` already exists as a feature folder — check its current scope first.

This module's data is the direct input to the owner dashboard's staff-performance panel (`06_owner_command_center.md`) — design the schema with that consumer in mind so it isn't built twice.

## Task
### Step 1 — Audit existing user/role infrastructure
- Read `models/enums.py` for existing role definitions (OWNER/MANAGER/SALES/WAREHOUSE/DELIVERY/etc. — confirm what's already modeled vs what needs adding).
- Read `models/user.py` for existing fields (owner flag, role, business association).
- Read what `users.activity_router` currently exposes — login events? action logs? Confirm before extending.

### Step 2 — Extend (not rebuild) the data model
Likely additions, only where genuinely missing after Step 1:
- `staff_task` table: `id, business_id, staff_id, task_type (po/stock_audit/stock_entry/etc.), reference_id, assigned_at, accepted_at, completed_at, status, rejected/corrected (bool), correction_note`.
- Derived metrics (computed, not stored redundantly): response time = `accepted_at - assigned_at`; completion time = `completed_at - accepted_at`.

### Step 3 — Role-based access
Confirm role enforcement pattern already used elsewhere in the app (likely a FastAPI dependency) and apply the same pattern here — owner sees all staff data, staff see only their own tasks. Do not introduce a second, different permission-checking mechanism.

### Step 4 — Endpoints
- `GET /v1/businesses/{business_id}/staff/{staff_id}/tasks` — staff's own view
- `GET /v1/businesses/{business_id}/staff/tasks` — owner/manager view, filterable by staff, status, date range, task type
- `POST /v1/businesses/{business_id}/staff/tasks/{task_id}/accept`
- `POST /v1/businesses/{business_id}/staff/tasks/{task_id}/complete`
- `GET /v1/businesses/{business_id}/staff/performance-summary` — owner-only, aggregated (feeds dashboard directly, pre-aggregated not computed live on every dashboard load)

### Step 5 — Flutter
Extend `features/staff` with: task list (mine vs assigned-by-me depending on role), accept/complete actions, and — for owner role — the performance summary view (or hand this off to the owner dashboard app screen described in file 06, don't build two separate staff-performance UIs).

## Explicit non-goal
This is workflow visibility and bottleneck detection, not surveillance-first tooling. Design the UI/reporting framing around "where are tasks stuck" rather than "who is slow" — same principle the original master prompt already established for this project.

## Deliverable
Migration(s) for `staff_task` (if not adequately covered by existing `activity_router` data), new endpoints, Flutter screens, role-gated access wired through the existing permission pattern.

## Risk
Low-medium. Main risk is duplicating data already captured by the existing `activity_router` — Step 1 must be genuinely completed (not skipped) before adding new tables.

## Tests
- Role enforcement: staff cannot see another staff member's tasks or the aggregated performance summary.
- Task lifecycle: assign → accept → complete, with timestamps correctly recorded.
- Rejection/correction path recorded and reflected in the performance summary aggregation.
- Performance summary endpoint returns correct pre-aggregated numbers under realistic data volume (check query cost, this feeds a dashboard that must stay fast on a 2-core backend).
