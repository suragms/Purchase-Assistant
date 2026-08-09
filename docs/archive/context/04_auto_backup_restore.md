# FEATURE: Automatic Backup + Restore

## Context
Current state: `backend/app/routers/exports.py` has `POST /exports/backup` (ZIP, capped at 400 purchases) and `GET /exports/backup/export` (JSON) — both manual, admin-triggered only. **No restore/import path exists anywhere in the codebase.** APScheduler already runs in `main.py` (due-soon scan @8am, physical-count reminder @6pm, DB keepalive every 48h) — add to this, don't build a parallel scheduler.

Server constraint: 70–100GB total storage on the backend box. Backup retention must be bounded, not open-ended.

## Part A — Automatic Backup

### Task
1. New scheduled job in the existing APScheduler block, e.g. 2am IST daily (off-peak, staggered against other jobs to avoid CPU/IO contention on 2 cores).
2. Reuse the existing `GET /exports/backup/export` JSON-generation logic as the underlying data pull — don't duplicate that query code. For the scheduled full backup, remove the 400-purchase cap (or chunk into multiple files if a single run gets too large for available memory on an 8GB box).
3. Write backups to a dedicated directory on the Windows server — confirm the actual filesystem path (Windows path conventions, not Linux) before implementing.
4. Retention policy: keep last 14 daily + last 6 monthly, delete older automatically. Log every deletion.
5. New table `backup_log`: `id, run_type (scheduled/manual), status (success/fail), file_path, size_bytes, row_counts (jsonb), duration_ms, error_message, created_at`. This feeds the owner dashboard.
6. Alert threshold: if cumulative backup storage exceeds a configurable percentage of the 70–100GB budget, log a warning visible in the owner dashboard (not silent).

## Part B — Restore (new, does not exist today — highest-risk item in this whole build)

### Task
1. New endpoint `POST /exports/restore`, owner-role-gated only.
2. **Default to dry-run mode.** First call validates the backup file (schema version check, structural integrity) and returns a diff summary: what would be added/changed/conflicted, row counts by table — without writing anything.
3. Second, explicit call (separate endpoint or a `confirm: true` flag plus a fresh confirmation token from the dry-run response) actually performs the restore, wrapped in a single DB transaction. Any failure mid-transaction rolls back completely — never leave the DB in a partial state.
4. Schema-version mismatch (backup taken from an older DB schema) must be detected and blocked, not silently attempted.
5. Every restore (dry-run and real) is written to the audit log: who, when, source file, dry-run vs committed, before/after row counts per table.
6. UI: owner-only screen, clearly separated from any "quick action" area — this should not be a one-click button next to routine settings. Require typing a confirmation phrase or similar friction before the committing call fires.

### Edge cases to test explicitly
- Restore into a completely empty DB (disaster recovery scenario)
- Restore over an existing DB with conflicting IDs
- Restore from a corrupted/truncated backup file
- Restore from a backup with a mismatched schema version
- Restore interrupted mid-transaction (simulate a crash) — confirm rollback leaves DB in pre-restore state

## Deliverable
- Migration for `backup_log` table
- Scheduled job wired into existing `main.py` scheduler block
- `POST /exports/restore` (dry-run + commit modes)
- Retention/cleanup job
- Owner-facing backup status + restore screen (read `backup_log`, trigger restore flow)

## Risk
High for restore specifically — this is the one feature in the whole build where a bug can destroy real business data. Do not ship restore without: (a) dry-run-by-default, (b) full transaction wrapping, (c) a tested rollback path, (d) sign-off after testing against a copy of production data, not just synthetic test data.

## Tests
- Backup: scheduled job runs, produces valid file, respects retention, logs correctly, handles a mid-run failure without corrupting the log.
- Restore: all five edge cases above, plus a full round-trip test (backup → wipe test DB → restore → verify data matches original) as the baseline sanity check before this ever touches production.
