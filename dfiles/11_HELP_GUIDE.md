# AGENT PROMPT 11 — HELP GUIDE AND MANUAL BACKUP

Status: Help page and manual backup are implemented. Auto backup schedule/history is deferred.

## Scope

- Help & Guide must be available from Settings without internet.
- Help content explains delivery stock truth, physical counts, opening stock, offline mode, and backup.
- Backup & export remains manual first.

## Key Files

- `flutter_app/lib/features/settings/presentation/help_guide_page.dart`
- `flutter_app/lib/features/settings/presentation/backup_page.dart`
- `flutter_app/lib/features/settings/presentation/settings_page.dart`
- `flutter_app/lib/core/router/app_router.dart`

## Deferred

- Daily auto backup schedule.
- Backup history list.
- Automatic generation of all monthly backup PDFs.

## Verification

- Settings opens Help & Guide.
- Help page links to Backup & export.
- Manual backup ZIP flow remains available.

