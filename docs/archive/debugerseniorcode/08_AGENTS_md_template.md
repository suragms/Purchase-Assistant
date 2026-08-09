# AGENTS.md — how to write one (and why it's the missing piece)

OpenHands/agent-canvas keeps a root `AGENTS.md` that Cursor/Claude/any agent reads automatically.
Most of it is architecture notes, but the valuable part for your problem is the pattern under
their "SDK Architecture Conventions" section: **every entry explicitly says which real bug it was
learned from**, e.g.:

> ### Persistence Path Construction
> ...**Rule:** Callers that pass `persistence_dir` to `LocalConversation()` must pass only the
> **base directory**... Passing a pre-constructed full path causes double-appending.

That's not a style guide — it's a bug that happened once, got root-caused, and got turned into a
rule so it structurally can't happen again silently. This is exactly what's missing from a pure
"Cursor prompt file per task" workflow: each prompt file is disposable, so a lesson learned on
Monday can get re-broken by a different Cursor session on Friday unless it's written down
somewhere the agent reads *every* session.

## What to put in your own AGENTS.md

Create (or extend) `AGENTS.md` at the root of each project (PurchaseAssistant, YSG PO, HexaBill).
Cursor and Claude Code both read this automatically without being told to.

```markdown
# AGENTS.md

## Architecture notes
<Short, current facts about the stack — same as your existing .mdc "stack truth" sections.>

## Lessons learned (each one is a real bug — do not remove, only add)

### <Short name for the pattern>
**Rule:** <the one-sentence rule, imperative>
**Why:** <2-3 sentences: what the actual bug was, what broke, how it was found>
**Check:** <how a reviewer or future agent verifies this rule is being followed>
```

## Concrete example, using your own documented history

You already have a real, recurring bug class: *Cursor/OpenCode agents silently fail to persist
edits to disk, requiring `git diff` verification before every commit.* That belongs in
`AGENTS.md` as a standing rule, not just something you personally remember to check:

```markdown
### Verify agent edits actually persisted
**Rule:** After any Cursor/OpenCode agent run, run `git diff` before trusting the agent's own
summary of what changed. Do not commit based on the agent's changelog message alone.
**Why:** Cursor agents on this project have repeatedly reported a change as complete when the
edit never actually wrote to disk. The agent's own summary is not reliable evidence of a
completed change.
**Check:** `git diff --stat` shows the expected files touched; open each changed file and confirm
the specific lines match what was asked.
```

Do the same for your VAT/TED taxable-amount bugs, the race conditions from Cursor agent
scope-creep, and any other recurring class you've already root-caused — each one becomes a
permanent line item instead of tribal knowledge you have to re-apply manually every session.

## How the three pieces fit together

1. **`AGENTS.md`** — always-loaded context. Architecture facts + lessons-learned rules. Read by
   every agent, every session, automatically.
2. **`specs/<feature>.md`** (see `06_SPEC_TEMPLATE.md`) — per-feature numbered requirements,
   checked off against the real diff, not the agent's claim.
3. **`.cursor/skills/code-review/SKILL.md`** (see `07_code-review-SKILL.md`) — the verification
   pass that checks the diff against the spec, and is the mechanism that turns a newly-caught bug
   into a new `AGENTS.md` entry.

## Where to put this, concretely, in your repos

- `AGENTS.md` → repo root (PurchaseAssistant already has `TASKS.md` and `docs/harisree/` — add
  `AGENTS.md` alongside, don't merge into the existing docs since agents specifically look for
  this filename).
- `.cursor/skills/code-review/SKILL.md` → same as the `design-quality` skill installed earlier;
  Cursor picks it up automatically.
- `specs/` → new top-level folder, one file per feature/module.

None of this replaces your existing `.cursor/rules/*.mdc` files or your prompt-file workflow — it
sits underneath them: the `.mdc` rules are "how to build," `AGENTS.md` is "what we already learned
the hard way," and `specs/` is "what this specific feature must do, checkable."
