---
name: design-quality
description: "Enforces design-token discipline and anti-AI-slop UI hygiene on every screen/component the agent touches. Use for any UI work: new screens, edits to existing screens, component creation, or when the user says 'audit', 'redesign', or 'clean up the UI'. Drop this same file into any project's .cursor/skills/design-quality/ — it self-adapts to whatever token file it finds."
version: 1.0.0
---

# Design Quality

A standing discipline check for UI work, distilled from two sources: the `DESIGN.md` token-spec
format (google/design.md) and the Hallmark anti-AI-slop rule set. This is intentionally short —
it's a checklist an agent runs against its own output, not a design generator.

## 0. Find the source of truth first

Before writing or editing any UI code, look for — in this order:
1. A `DESIGN.md` at the repo root or in `docs/` — if present, its YAML front matter is the token
   source of truth.
2. A design-tokens file in code (e.g. this project's `flutter_app/lib/core/design_system/hexa_ds_tokens.dart`
   + `hexa_colors.dart` — check the equivalent path for whatever stack you're in: `tailwind.config.*`,
   `tokens.css`, a `theme/` folder, etc.).
3. If neither exists, say so before proceeding and ask whether to establish one — don't invent
   colors/fonts/spacing ad hoc and call it done.

## 1. Never bypass a token that already exists

- No raw hex/`Color(0x...)`/`rgb()` values in feature code if a named token covers that role.
  Reference the token, don't restate its value.
- No raw font-size / font-weight literals if a named text style exists for that role.
- No raw spacing numbers (padding/margin/gap) if a spacing scale exists — use the nearest scale
  step, don't split the difference with a one-off number.
- If a genuinely new value is needed, add it to the token file as a named token first, then
  reference it. Never leave an inline override sitting next to the token system.

## 2. Structural / interaction non-negotiables

- Every interactive element ships all applicable states: default, hover (where relevant),
  focus-visible, active/pressed, disabled, loading, error, success. Missing focus-visible styling
  is an accessibility bug, not a style choice.
- Minimum touch target ~48px, minimum readable body text ~11–12px, unless the project's own
  tokens specify otherwise — treat project tokens as authoritative over this default.
- No horizontal scroll and no two-line clickable text (buttons, nav links, CTAs) at narrow
  viewports. Verify against the project's own breakpoint list if one exists.
- Empty states get an icon + message + action, never a blank surface. Error states never leak raw
  exceptions/stack traces/HTTP codes to the user — route through the project's existing
  error-display component if one exists (check first, don't build a second one).
- Headings stay upright (`font-style: normal` / no italic). Carry emphasis with weight or color,
  not italics — italic display type is a common tell that a screen was template-generated rather
  than designed.

## 3. Honesty check

- No fabricated metrics, stats, or counts in UI copy ("+47% faster", "10,000+ users") unless the
  user supplied that number. Use a placeholder or omit the claim.
- No re-drawn fake browser chrome, fake phone frames, or fake OS window chrome — the real
  environment already provides it.

## 4. Before finishing any UI task

Self-check against this list. If more than one item fails, fix it before handing back the result
rather than flagging it as a known issue — these are cheap to fix inline and expensive to
re-sweep later (see this project's `docs/ai/04_FIX_PLAN.md` for what happens when they pile up).

## Reusing this skill in another project

This file has no project-specific values baked in — it's safe to copy as-is into
`.cursor/skills/design-quality/SKILL.md` in any other repo. On first use in a new project it will
look for that project's own token source (§0) rather than assuming this project's palette. To get
full value, also generate that project's own `DESIGN.md` once (ask Claude to extract one from the
existing theme/token files, the same way `docs/ai/03_DESIGN.md` was generated here) so the skill
has something concrete to enforce against from day one.
