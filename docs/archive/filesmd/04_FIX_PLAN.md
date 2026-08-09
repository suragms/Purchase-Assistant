# 04 — Fix Plan

Ordered by dependency, not just severity — the lint rule (step 1) should land *before* the sweeps,
or the sweeps will just get re-diluted by the next batch of Cursor-agent-generated screens.

## Step 1 — Stop the bleeding (P0, do first, ~3 hrs)

Install the `design-quality` Cursor skill (`.cursor/skills/design-quality/SKILL.md`, generated
alongside this plan) and add it to `alwaysApply` scope for `flutter_app/lib/**`. This makes every
future Cursor agent run check its own output against the token rules before finishing, instead of
you catching drift after the fact.

**Dependency:** none. **Risk:** none (pure addition, no code touched).

## Step 2 — High-traffic, high-LOC modules (P0, ~4–5 days)

1. `stock` (59 files, 35 hardcoded-color files) — start here, it's the single largest offender and
   the highest-frequency screen for warehouse staff.
2. `purchase` (45 files, 20 hardcoded-color files) — do immediately after `stock`; this is your
   daily client-facing flow and the one most likely to get a support ticket if something looks off.

**Dependency:** Step 1 done first, so re-sweeping doesn't fight new drift.
**Risk:** Medium — these are the modules with active client bug reports (per your Enterprise V2
POS / PO work), so re-tokenizing needs a visual diff per screen, not a blind find/replace. Do it
file-by-file with `git diff` review before commit — same discipline you already use for Cursor
agent verification.

## Step 3 — Confirm and clean dead scaffolding (P0, 30 min)

`dashboard` (1 line) and `item` (355 LOC, 1 file) — confirm whether these are live routes or
leftovers from an earlier refactor (likely superseded by `home` and `catalog`). If dead, remove;
if live, document why they're thin in a one-line comment so the next agent doesn't "helpfully"
delete them.

**Dependency:** none, can run in parallel with Step 2.

## Step 4 — Mid-tier modules (P1, ~4 days)

`reports`, `home`, `catalog`, `auth` — same sweep pattern as Step 2, lower urgency because these
have fewer active bug reports right now, but `home` is the first screen every user sees so don't
let it slip too far down the queue.

**Dependency:** Step 1.

## Step 5 — Remaining modules (P2, ~2–3 days)

`contacts` (consider splitting the 2–3 largest files while you're in there), `barcode` (manually
classify overlay-geometry values vs. real token violations before touching anything), `staff`.

**Dependency:** Step 1.

## Step 6 — Visual verification pass (needs your input)

Everything above is code-level. To close the loop on the original checklist (overflow, clipping,
overlapping components, z-index, modal sizing, empty/loading/error states, actual WCAG contrast on
rendered screens, keyboard navigation) I need either:
- Screenshots of the 6–8 highest-traffic screens (home, stock list, stock detail, purchase entry,
  reports, settings) at phone + desktop width, or
- A way to run the app so I can inspect it directly.

Once I have either, I can produce the visual-bug-specific punch list your original checklist asked
for (blank pages, broken routes, overlapping components, etc.) with actual confidence instead of
guessing from source.

## Summary table

| Step | What | Priority | Est. effort | Depends on |
|---|---|---|---|---|
| 1 | Install `design-quality` skill/rule | P0 | 3 hrs | — |
| 2 | Sweep `stock`, `purchase` | P0 | 4–5 days | Step 1 |
| 3 | Confirm/remove `dashboard`, `item` | P0 | 30 min | — |
| 4 | Sweep `reports`, `home`, `catalog`, `auth` | P1 | 4 days | Step 1 |
| 5 | Sweep `contacts`, `barcode`, `staff` | P2 | 2–3 days | Step 1 |
| 6 | Visual/runtime bug pass | Needs input | TBD | Screenshots or live app |
