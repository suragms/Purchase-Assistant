# Spec Template — copy this pattern per feature

Copied from the pattern OpenHands/agent-canvas uses internally (`specs/*.md`). The point: every
feature gets an ID-numbered, checkbox-tracked list of atomic "shall" requirements — not a vague
prose description. This is what actually fixes "agent said it's done but a feature got lost" —
there's now a literal checklist the agent (and you) can verify line by line against the code,
instead of trusting a summary.

## Why this fixes your specific problem

Your recurring issue (per your own workflow notes) is: Cursor/OpenCode agents scope-creep, silently
fail to persist edits, and you have to `git diff` every commit to catch it. A prose prompt like
"add delivery-date auto-calc from supplier lead time" gives the agent room to interpret, half-finish,
or quietly drop a sub-requirement. A numbered spec doesn't — every `[ ]` is either true in the diff
or it isn't. It also gives *you* a fast verification pass: read the spec, `git diff`, check each
box, done — instead of re-reading the whole feature from scratch each time.

## Template

```markdown
# <Feature Name> Specs

---

### <PREFIX>-001: <short imperative title>
- [ ] <One atomic, testable "shall" statement. One behavior per line, not a paragraph.>
- [ ] <Another atomic requirement, if the same numbered item genuinely has multiple parts.>

### <PREFIX>-002: <next requirement>
- [ ] <...>

### Why this exists
<1–3 sentences: the actual bug or business rule that made this requirement necessary. Future
agents (and future you) need the "why", not just the "what" — otherwise someone "simplifies" the
code back into the bug it was fixing.>
```

## Rules for writing specs

1. **Pick a short prefix per feature/module** (e.g. `PO` for Purchase Order, `VAT` for VAT/TED
   logic, `POS` for the HexaBill Enterprise V2 screen) and number sequentially — never reuse or
   renumber an ID once it ships, even if the requirement is later removed (mark it `~~strikethrough~~`
   instead, so history stays traceable in git blame).
2. **One behavior per checkbox.** "The form shall validate VAT and TED and calculate the taxable
   amount" is three requirements wearing a trenchcoat — split it into three checkboxes so partial
   completion is visible.
3. **"Shall" statements, not descriptions.** Write requirements the way a test assertion would read
   ("the system shall reject...", "the field shall default to..."), not implementation narration
   ("we use a regex to check...").
4. **Check the box only when it's true in the actual diff**, not when the agent claims it's done.
   This is the same discipline as your existing `git diff` verification habit — the spec file just
   gives that habit a checklist to verify against instead of re-reading the whole feature.
5. **Keep specs in the repo** (`specs/<feature>.md` or `docs/specs/<feature>.md`), committed
   alongside the code they describe — not in a separate prompt file that gets thrown away after
   the Cursor session ends. The spec is a durable artifact; the prompt file you feed to Cursor can
   be generated *from* the spec each session.

## How this plugs into your existing prompt-file workflow

You already generate scoped `.md` prompt files for Cursor with exact paths, root-cause analysis,
and scope-lock rules. Add one step: before generating that prompt file, write (or update) the
feature's spec file first. Then the Cursor prompt references the spec IDs directly
("implement PO-004 and PO-005 only, do not touch PO-001–003"), and your post-run verification is
"read the diff against these specific IDs" instead of "read the whole diff and hope I remember
what was supposed to change."
