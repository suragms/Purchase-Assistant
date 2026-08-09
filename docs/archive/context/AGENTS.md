# AGENTS.md — PurchaseAssiastant / New Harisree Agency

## Mission

This repository is a production-oriented wholesale/distribution operations system for New Harisree Agency. It contains a Flutter web/PWA client, a FastAPI backend, PostgreSQL migrations/models, operational services, reports, stock and purchase workflows, authentication/RBAC, and deployment automation.

The goal is **reliable business operations with the least necessary code**. Preserve verified working behavior. Improve only with evidence.

## Absolute execution rule

> **Do not code until the audit and plan are complete and explicitly approved.**

Every agent must first inspect the actual repository, current branch/commit, working tree, relevant files, API routes, models, migrations, tests, design tokens, and runtime configuration. No agent may infer that a feature exists from a filename, comment, README claim, wireframe, prompt, or task list alone.

## Evidence protocol

Every finding must use one of these labels:

| Label | Meaning |
|---|---|
| `VERIFIED_CODE` | Directly confirmed in the current source files. |
| `VERIFIED_TEST` | Confirmed by a test that was actually run and recorded. |
| `VERIFIED_RUNTIME` | Confirmed against a running local/staging/live environment. |
| `DOCUMENTATION_CLAIM` | Stated in a document but not independently verified. |
| `DESIGN_REFERENCE` | Present in supplied design assets/tokens; not proof of implementation. |
| `BUSINESS_REQUIREMENT` | Requested or required by the business; not proof that it exists. |
| `ASSUMPTION` | Temporary assumption; must not be implemented without approval. |
| `UNKNOWN/BLOCKED` | Cannot be verified with available files, tools, credentials, or assets. |

Do not convert `DOCUMENTATION_CLAIM`, `DESIGN_REFERENCE`, `BUSINESS_REQUIREMENT`, or `ASSUMPTION` into implementation facts.

## No-guessing rule

If a file, API, database table, design, screenshot, wireframe, user flow, role rule, integration contract, or business rule is not available, write `UNKNOWN/BLOCKED`, state exactly what is missing, and ask for the smallest required input. Never invent endpoints, fields, screens, colors, copy, permissions, ERP behavior, AI behavior, or acceptance criteria.

## No creative AI slop

Do not add decorative AI-generated copy, speculative dashboards, invented metrics, fake customer data, invented product aliases, arbitrary animations, motivational text, generic chatbot features, “smart” automation without a business rule, or visual novelty that is not grounded in a supplied design or verified business need.

AI may parse, normalize, classify, summarize, explain, and recommend only within an approved schema and permission boundary. AI may not be the source of truth for stock, price, tax, invoice totals, payment balance, profit, permissions, approvals, or workflow state.

## Repository safety

1. Read `README.md`, `ARCHITECTURE.md`, `DEPLOYMENT.md`, `DESIGN.md`, `TASKS.md`, this file, `.cursor/rules/`, `.cursor/skills/`, and relevant specs before changing code.
2. Inspect `git status`, branch, commit, and diff before and after every task.
3. Never commit secrets, production data, tokens, private keys, or unredacted customer messages.
4. Never push, deploy, migrate production, delete data, delete branches, or send external messages without explicit approval.
5. Do not modify unrelated files.
6. Do not rewrite the project or replace the architecture without an evidence-backed decision record.
7. Before destructive migrations or data repair, create a verified backup/rollback plan and stop for approval.
8. Do not trust an agent summary; inspect the actual diff and run the required checks.

## Canonical architecture rules

- Frontend: Flutter web/PWA under `flutter_app/`.
- State: existing Riverpod patterns; do not introduce a second state system without approval.
- Navigation: existing GoRouter configuration; do not add parallel navigation.
- API: existing Dio client/providers and FastAPI routers; reuse existing contracts before adding routes.
- Backend: FastAPI services and SQLAlchemy/PostgreSQL models; calculations belong on the backend/database.
- Purchases: current trade purchase flow is the canonical direction unless the audit proves otherwise.
- Reports: trade-backed reports must not be mixed with legacy entry analytics.
- Database: reuse existing tables and migrations where safe. Do not create duplicate business entities.
- Auth/RBAC: authorization must be enforced server-side and scoped to the business/membership.
- Design: use existing `HexaColors`, `HexaDsColors`, `HexaDsType`, spacing, radii, responsive, sheet, and page-shell tokens. Do not invent a second visual system.
- Sheets: use the existing `showHexaBottomSheet` contract; do not add ad-hoc app-chrome modal sheets.
- Errors: user-facing errors must use the existing friendly error components. Do not display raw exceptions, HTTP codes, or stack traces outside debug-only diagnostics.

## Mandatory audit before implementation

Before coding, produce:

1. Current page/route inventory from the actual GoRouter source.
2. Frontend API-call inventory from actual Dart code.
3. Backend route inventory from actual FastAPI decorators and router registration.
4. Service/model/schema/table/migration map.
5. Current feature status: verified working, incomplete, broken, deprecated, duplicate, or unknown.
6. Design-token and responsive-layout inventory.
7. Desktop and mobile state matrix for every current page.
8. Future-feature traceability matrix: requirement → evidence → current support → proposed files/API/DB → permission → tests.
9. Security, performance, deployment, and rollback findings.
10. File-level implementation plan and explicit approval gate.

## Page audit rule

For every current or proposed page, record:

`page_id | route | source_file | role | purpose | entry_points | API_calls | provider/state | DB/service | design_tokens | desktop_behavior | mobile_behavior | loading | empty | error | permission_denied | offline/degraded | tests | status | evidence`

A page is not “complete” because it renders. It must have verified API behavior, permission behavior, loading/empty/error states, responsive behavior, and tests appropriate to its risk.

## Feature audit rule

Every future feature must be written as:

`PROBLEM → BUSINESS_OWNER → VERIFIED_EVIDENCE → USER_FLOW → PAGE/COMPONENT → EXISTING_FILE_REUSE → API → SERVICE → DB/MIGRATION → PERMISSION → EDGE_CASES → TESTS → OBSERVABILITY → ROLLBACK → ACCEPTANCE`

If any link is missing, mark the feature `PLANNING_ONLY` and do not code it.

## Testing and reporting

Never claim “works” without running the relevant command. Report exact commands, exit status, test count, warnings, skipped tests, and environment limitations. At minimum, use the available backend tests, Flutter analyze/tests/build, migration checks, API contract checks, and responsive UI checks. If Flutter, PostgreSQL, or external credentials are unavailable, report the limitation rather than fabricating results.

## Stop conditions

Stop and ask for approval when:

- a requirement conflicts with current data ownership;
- a migration is destructive or has multiple heads/unknown production state;
- an external API contract is missing;
- a screenshot/wireframe is referenced but not supplied;
- a role or permission is unclear;
- a user-facing number cannot be traced to a backend/database source;
- an AI output would affect an authoritative business value;
- a change would delete or rename existing routes/tables/files;
- tests fail for unrelated reasons and scope is uncertain.

## Required response format

Every agent response must contain:

1. **Scope inspected.**
2. **Verified facts.**
3. **Unknowns/blockers.**
4. **Files and APIs involved.**
5. **Risks and regressions.**
6. **Tests run and exact results.**
7. **Next action.**
8. **Approval required: yes/no.**

No unsupported confidence, no invented completion, and no creative filler.
