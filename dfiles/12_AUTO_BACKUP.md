# AGENT PROMPT 12 — AUTO BACKUP

Status: deferred after manual backup.

## Scope

Auto backup is not required for the current stable cut. Keep manual backup working first.

## Future Requirements

- Daily backup schedule with local notification reminder.
- Backup outputs: monthly ledger PDF, stock snapshot PDF, purchase summary PDF.
- Platform-aware storage:
  - Android Downloads / HarisreeWarehouse
  - iOS app documents
  - Desktop or web browser download
- In-app backup history for the last 30 runs.

## Before Implementation

- Confirm Android storage permissions and target SDK behavior.
- Confirm web download limitations.
- Confirm owner wants scheduled local backups rather than server-side scheduled exports.

