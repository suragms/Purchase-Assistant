# FEATURE: Deployment Fit-Check Against Real Server Specs

## Context
This isn't a new feature — it's a constraint check that every other file in this set must be validated against before being called "done." Real infra:
- Backend: 2 vCPU, 8GB RAM, 70–100GB storage, domain `harisreeagency.online`
- Frontend: Vercel (already deployed)
- Database: PostgreSQL on a separate Windows 10 machine

## Task
### Step 1 — Confirm APScheduler is sufficient (it is, don't second-guess this)
Current jobs: due-soon payment scan (8am), evening physical-count reminder (6pm), DB keepalive (every 48h). New jobs being added across this feature set: nightly backup (file 04), dashboard aggregation refresh (file 06), retention cleanup (file 04). All of these fit comfortably in-process via APScheduler on this hardware — do not introduce Celery/Redis/a separate worker process unless a specific job is measured to genuinely block the main event loop for an unacceptable duration.

### Step 2 — Stagger scheduled jobs
List every scheduled job (existing + new) with its run time. Confirm no two heavy jobs (backup, dashboard aggregation) are scheduled to overlap — stagger them across the low-traffic window (e.g. backup 2am, dashboard refresh 3am) so 2 cores aren't contended simultaneously.

### Step 3 — Cross-machine DB latency check
The backend (`harisreeagency.online`) and Postgres (separate Windows 10 machine) are on different hosts. Measure actual round-trip latency for a representative query under realistic load — this is a strong candidate for where "slow" complaints originate, more likely than application code in many cases. If latency is high, investigate: network path between the two machines, connection pooling configuration, whether queries are chatty (many round trips per request) vs batched.

### Step 4 — Storage budget tracking
70–100GB total. Track: application data growth rate, backup retention footprint (file 04's 14-daily + 6-monthly policy), logs, PDF/media storage (POs, statements). Build this into the owner dashboard's infrastructure panel (file 06) as a real number, not an afterthought — this is a hard ceiling, not a soft target.

### Step 5 — Load-test critical paths under this specific hardware profile
Before considering any feature in this set "done," run it against the actual 2-core/8GB profile (or an equivalent local constraint) under realistic concurrent staff usage (multiple staff members hitting stock/PO endpoints simultaneously), not just single-user dev testing. Specifically load-test:
- Owner dashboard endpoint (file 06) — this aggregates the most data.
- Nightly backup job (file 04) — check it doesn't degrade concurrent request handling if it overruns into active hours.
- AI Tier-1 calls (file 03) under burst load — OpenRouter latency/rate limits under real concurrent extraction requests.

## Deliverable
A short infra report: scheduled-job timeline (no overlaps), measured cross-machine DB latency with a verdict (fine / needs attention), current + projected storage usage against the 70–100GB ceiling, and load-test results for the three critical paths above.

## Risk
Low as a standalone task, but it's the check that determines whether the rest of this build is actually production-ready on this hardware — treat it as a gate before rollout, not an optional nice-to-have at the end.

## Tests
Not unit tests — this is operational verification: measured numbers (latency, storage, job duration under load) compared against the actual constraints, with a clear pass/fail per constraint.
