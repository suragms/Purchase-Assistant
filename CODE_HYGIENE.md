# PURCHASE PROJECT — CODE HYGIENE, DUPLICATION, DEAD CODE & SPEED — STRICT AGENT PROMPT

**Binding:** `AGENTS.md` (authoritative contract) · `PURCHASE_UI_UX_STRICT_AGENT_PROMPT.md` · `uiux context/UI_UX_TASKS.md` · `UX_FIX_PLAN_192-198.md` (may be absent — check repo)

**Why this file exists:** Cursor/agent sessions on this repo have been creating new files and new implementations for functionality that already exists elsewhere in the codebase, instead of finding and extending it. Result: multiple files doing the same job, dead code nobody removes, duplicate API calls hitting the backend, and the app getting slower as the codebase grows instead of staying fast. This file is the standing rule that stops that pattern. It applies to **every** session on this repo — feature work, bug fixes, and UX fix plans — not just a one-time cleanup.

Always-loaded via `.cursor/rules/code-hygiene.mdc` (same tier as `AGENTS.md` pointers).

---

# 1. THE ABSOLUTE RULE

**You may not write a new file, a new provider, a new service, a new widget, or a new API method until you have proven — with a search, not a guess — that nothing already does this job.**

"Proven" means: you ran a real search (grep/ripgrep across `flutter_app/lib` and `backend/app`, not a mental guess from training data or the file tree glance) for the feature/behavior by name, by likely function names, and by the data it touches (model names, endpoint paths, provider names). You paste or summarize what the search returned before writing new code.

If the search finds an existing implementation:

- **Extend or fix it in place.** Do not fork it "to be safe." Do not create `_v2`, `_new`, `_fixed`, `_updated`, `_final` file or symbol names — these are duplication with extra steps and are explicitly banned.
- If the existing implementation is genuinely wrong for the new need, say so explicitly (why it can't be extended) before creating anything new — this is a judgment call that needs a stated reason, not a default.

If the search finds nothing: say so explicitly ("searched for X, Y, Z — nothing found") before creating new code. An unstated or skipped search is treated as a rule violation even if the resulting code works.

---

# 2. WHY THIS KEEPS HAPPENING (do not repeat these patterns)

Name the failure mode before you can avoid it. These are the concrete ways duplication has entered this repo:

- **Session amnesia** — a new Cursor session doesn't remember what a previous session built two weeks ago, so it rebuilds it under a new name.
- **Narrow search** — searching for the exact new task's wording ("edit item overlap") instead of the underlying mechanism ("floating label," "InputDecoration," "AppTextField") — the search misses the shared component because it's not phrased the same way the task is.
- **"Just to be safe" forking** — copying a working file and modifying the copy instead of editing the original, to avoid breaking something. This doubles maintenance forever and the two copies drift.
- **Feature-flag-by-duplication** — instead of branching logic inside one file, a whole new file/route/provider is created for "the new version," and the old one is never deleted because nobody's sure if something still depends on it.
- **API duplication via re-fetch** — a new screen/widget needs data that's already fetched elsewhere (shared provider, cached snapshot) but the agent writes a fresh Dio call instead of reading the existing provider, because it didn't search for one.

If you catch yourself about to do any of the above mid-task: stop, search properly, then decide.

---

# 3. PRE-WRITE CHECKLIST — run before every new file or new symbol

```text
BEFORE creating any new file / class / provider / widget / API method:

1. What is this thing FOR (in one sentence, business terms)?
2. What would it plausibly be CALLED if it already exists?
   - Search 3-5 plausible names/terms, not just the task's own wording.
3. What DATA does it touch (model, endpoint, table)?
   - Search for that model/endpoint name across both flutter_app/ and backend/.
4. Does an existing FILE in the relevant feature/ or core/ folder already
   own this responsibility, even partially?
   - Check the feature's existing directory tree, not just filename search.
5. Does an existing PROVIDER/service already fetch or hold this data?
   - Grep for the model type, not just a provider name guess.

RESULT:
- Found existing owner → edit it. State the file path you're editing and why
  it's the right one.
- Found a NEAR-miss (does something adjacent but not quite this) → state
  explicitly why it can't be extended before writing anything new.
- Found nothing → state the searches you ran and their (empty) result,
  THEN create the new file.

Skipping this checklist is not "moving fast" — it is the direct cause of the
current duplication problem. Every duplicate file in this repo right now
skipped this checklist.
```

---

# 4. FILE CREATION IS A GATE, NOT A DEFAULT

Before `create_file` / a new `class` / a new `final xProvider = ...`:

- State the exact existing file(s) you searched and did not find ownership in.
- State why extending the nearest existing file is wrong (not just "cleaner this way" — cleaner is not a reason to duplicate).
- Naming: if you are about to name something with a suffix like `_v2`, `_new`, `_updated`, `_fixed`, `_alt`, `_clean`, `_final`, `_refactored` — **stop**. That naming pattern means you're duplicating, not building. Either you're replacing the old one (delete/rename the old one in the same change, don't leave both) or you shouldn't be creating a new file.

This mirrors the doc-ownership rule already in `AGENTS.md` ("Do not duplicate rules across `.cursorrules`, always-apply `.mdc` files, and this file") — the same discipline now applies to code, not just docs.

---

# 5. DUPLICATE-CODE AUDIT PROTOCOL (run as its own task, read-only first)

This is a standalone audit — **inventory before touching anything.**

## Step 1 — Find literal and near-literal duplicates

- Search for repeated function/class bodies across `flutter_app/lib/features/**`.
- Search for repeated business logic copy-pasted with minor variable renames — feature-by-feature.
- Search `backend/app/routers` and `backend/app/services` the same way.

## Step 2 — Record findings, do not fix yet

For each duplicate found, record:

```text
DUPLICATE-ID
Files involved: [list]
What they both do:
Which one is actually used (check imports/call sites — an unused one is
  dead code, see section 6):
Which one is more correct/complete:
Proposed consolidation: keep X, delete Y, migrate call sites from Y to X
Call sites to update: [list — grep for every import of the file being
  removed before touching it]
Risk: [what could break — business logic differences between the copies,
  not just "some risk"]
```

## Step 3 — Consolidate one at a time

Same one-task-at-a-time discipline as `UI_UX_TASKS.md`:

- Pick ONE duplicate-ID.
- Confirm the "keep" file is genuinely the correct/complete one.
- Update every call site found in Step 2 to point at the kept file.
- Delete the removed file entirely — do not leave it "just in case."
- Run `flutter analyze` (and `pytest` if backend touched).
- Mark DONE with before/after before moving to the next DUPLICATE-ID.

---

# 6. DEAD CODE AUDIT PROTOCOL

Separate from duplication — code that has **no callers at all**.

## What counts as dead

- Files/classes/functions with zero imports/references anywhere in `flutter_app/lib` or `backend/app`.
- Routes registered in the router that no UI element navigates to.
- API endpoints that no frontend Dio call hits (verify external callers before deleting backend routes).
- Feature flags / conditional branches where the flag is permanently on or off.
- Commented-out code blocks — remove or explain why kept.

## Protocol

```text
1. For each candidate, grep the ENTIRE repo (not just the feature folder)
   for references before declaring it dead.
2. Record: file, symbol, last-touched date if available (git blame),
   grep command used, result (0 references found = confirmed dead).
3. Delete confirmed-dead code in small batches, run flutter analyze / pytest
   after each batch.
4. If genuinely unsure (e.g. dynamic string-based routing) — mark UNKNOWN,
   do not delete, flag for a human decision.
```

Never delete code based on "it looks unused" without the grep evidence.

---

# 7. API / NETWORK DISCIPLINE (duplicate calls, slow endpoints)

This repo already has some good patterns (request dedupe via in-flight maps, `.timeout()`, `autoDispose` + `keepAlive` providers — see `trade_report_snapshot_provider.dart`). Extend the same discipline; don't reinvent it per-feature.

## Before adding any new API call

1. Search for an existing provider/service that already fetches this data (by model name).
2. If one exists but doesn't cover the new need, **extend that provider's parameters** — do not add a second overlapping fetch.
3. If genuinely new: prefer joining an existing batch (`Future.wait`) over a lone new request.

## Duplicate-request sweep / slow endpoints

- Inventory-first (same shape as sections 5/6); measure before guessing.
- Fix the named cause (pagination, N+1, missing index, over-serialization) — do not hide slowness with a spinner or cache-only workaround.

See also: `docs/perf_duplicate_measurement.md` for prior measurements.

---

# 8. SCALABILITY & SUSTAINABILITY — standing rules

- **One feature = one owner file/module.** Add behavior to existing feature files unless there is a stated architectural reason for a new one.
- **Growing lists/tables get pagination or virtualization** once they can plausibly exceed ~200 rows.
- **Shared data = shared provider.** Two screens that need the same period's purchases use one provider.
- **No silent duplication as a migration strategy.** Old code removed in the same change that ships the replacement, or temporary duplication has a stated removal date in the task.
- **Every new backend endpoint states expected data volume** so pagination/indexing is decided at creation time.

---

# 9. WORKING PROTOCOL FOR THIS FILE

Do not run all of sections 5/6/7 at once:

```text
1. Run section 5 (duplicate audit) as a READ-ONLY inventory pass first.
   Output: a numbered DUPLICATE-ID list. Do not fix anything yet. STOP.
2. Get it reviewed/approved.
3. Consolidate one DUPLICATE-ID at a time.
4. Repeat for section 6 (dead code), then section 7 (API/speed).
5. Section 8 rules apply continuously to ALL future work.
```

Output evidence style matches `AGENTS.md`: `VERIFIED_CODE` / `ASSUMPTION` / `UNKNOWN/BLOCKED`.

---

# 10. STOP GATE

```text
Phase: Section 7 inventory complete — see uiux context/CODE_HYGIENE_AUDIT.md §7
Section 5 (duplicate audit): DONE (approved consolidations)
Section 6 (dead code audit): Flutter A + Backend A/B DONE (Settings stubs STOP)
Section 7 (API/duplicate-call audit): INVENTORY DONE — STOP for fix approval
Section 8 (standing rules): ACTIVE for all work
IN_PROGRESS: none (awaiting human pick of first API-DUP-ID)
Next after inventory: fix one approved API-DUP-ID only (recommended: API-DUP-H-004).
```
