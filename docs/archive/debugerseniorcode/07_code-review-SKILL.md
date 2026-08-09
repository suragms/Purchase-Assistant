---
name: code-review
description: "Repo-agnostic code review pass focused on catching AI-agent slop: incomplete features, silently-dropped scope, cross-file logic bugs, and persistence bugs. Trigger with /codereview or when the user asks to review/verify a Cursor agent's changes before committing."
triggers:
  - /codereview
  - review this
  - check this diff
  - did the agent actually finish
---

# Code Review — anti-slop pass

Adapted from OpenHands/agent-canvas's internal review skill, generalized for any stack. This is
not a style/lint pass — it exists to catch the specific failure modes of AI-coding-agent output:
claimed-done-but-isn't, scope creep, and bugs that only show up at the boundary between files.

## Before anything else: does the diff match the spec?

If a spec file exists for this feature (see `06_SPEC_TEMPLATE.md`), go through it ID by ID against
the actual diff. A requirement is only "done" if you can point to the specific lines that satisfy
it. Do not accept the agent's own summary of what it did — summaries are exactly where scope creep
and silently-dropped requirements hide. If no spec exists, reconstruct the intended requirements
from the original prompt/task description before reviewing, and note that a spec should have
existed.

## Core checks, in order

1. **Did every stated requirement actually land?** Check each one against real code, not the
   agent's changelog message. This is the single most common failure: an agent reports 5/5 done
   when 3/5 landed and 2 were quietly skipped or half-implemented.
2. **Persistence check.** If the task involved writing to a database, file, or any persisted
   state: verify the write path is actually reached and actually commits (not just constructed).
   This matches a documented failure mode — agents that edit code but the edit never gets written
   to disk, or a write path that's built but never called. Trace it from the trigger (button press,
   API call) to the actual `INSERT`/`UPDATE`/file write, not just "the function that should do it
   exists."
3. **Cross-file data flow.** When new code calls an existing function/API/constructor, trace 1–2
   levels into what it calls. Bugs hide at layer boundaries where the caller's assumptions don't
   match the callee's actual behavior (e.g. a caller passing a full path to something that already
   appends a suffix, doubling it).
4. **Business-logic correctness over syntax correctness.** Code that compiles and runs can still
   compute the wrong number. For calculation-heavy logic (tax, totals, conversions, thresholds):
   re-derive the expected result by hand for at least one concrete example and compare.
5. **Scope check.** Did the diff touch files outside what was asked? Cursor/agent scope creep is a
   known failure mode — flag any file changed that wasn't part of the stated task, even if the
   change looks harmless. Ask "why did this file change" before accepting it.
6. **Error handling, not just happy path.** Does the new code handle the failure case (network
   error, empty result, invalid input) or does it only work when everything goes right? Silent
   failures (caught exception, nothing shown to the user, nothing logged) are worse than crashes.
7. **Duplicate/dead logic.** Did the agent solve a problem that was already solved elsewhere in the
   codebase, instead of reusing it? Duplicated business logic (e.g. a second VAT calculation
   implementation) is a common agent failure — it doesn't search hard enough for the existing one.
8. **State/concurrency.** If shared/mutable state is touched, verify it's accessed the same way the
   rest of the codebase accesses it (locks, providers, whatever the project's pattern is) — new
   code that bypasses the existing safety pattern is a silent bug waiting for concurrent use.

## What NOT to flag

Don't comment on: minor style preferences, "nice to have" suggestions that don't affect
correctness, or praise for code that's simply fine. Noise in a review makes the real findings
easier to miss. If the diff is genuinely complete and correct, say so plainly and stop.

## Output format

For each issue found: what's wrong, why it matters (what breaks, when), and the specific fix — not
a vague "consider improving this." End with one of:
- **Ready to commit** — spec requirements all verified, no blocking issues.
- **Blocking issues found** — list them, ranked by what breaks first in production.

## Turning a caught bug into a permanent rule

When a review catches a real bug class (not a typo — an actual logic/architecture mistake), add it
to the project's `AGENTS.md` (or `.cursor/rules/`) as a named rule, the way OpenHands does in its own
`AGENTS.md` ("Persistence Path Construction", "Concurrency — LocalConversation State Lock" — each
one explicitly notes "learned from a real bug"). The goal is that the same class of bug never has
to be caught by review twice — it becomes a rule the agent reads before writing code, not just a
comment after.
