---
name: Harisree Warehouse
colors:
  primary: "#0E4F46"
  secondary: "#065F4F"
  accent: "#159A8A"
  gold: "#D4AF37"
  background: "#F7F9F6"
  card: "#FFFFFF"
  border: "#E2E8E6"
  textPrimary: "#0F172A"
  textBody: "#475569"
  textMuted: "#64748B"
  success: "#059669"
  error: "#DC2626"
  warning: "#F0A500"
typography:
  h1:
    fontFamily: Plus Jakarta Sans
    fontWeight: 700
    fontSize: 1.375rem
  h2:
    fontFamily: Plus Jakarta Sans
    fontWeight: 600
    fontSize: 1.125rem
  body:
    fontFamily: Plus Jakarta Sans
    fontWeight: 400
    fontSize: 0.875rem
  label:
    fontFamily: Plus Jakarta Sans
    fontWeight: 600
    fontSize: 0.75rem
  metric:
    fontFamily: Plus Jakarta Sans
    fontWeight: 900
    fontSize: 1.375rem
rounded:
  sm: 10px
  md: 12px
  lg: 16px
  xl: 20px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
breakpoints:
  # Aligned with hexa_responsive.dart (code = truth). See also root DESIGN.md.
  compactPhone: 360px
  phoneMax: 599px
  tabletMin: 600px
  navigationRailLabels: 900px
  desktopMin: 1024px
  ultraWideMin: 1600px
  maxFormWidth: 720px
  maxSheetWidth: 640px
---

## Overview

**Premium green + gold fintech-warehouse hybrid.** The palette reads as a serious financial /
ERP tool (deep teal-green primary, generous white space, restrained gold accent for
profit/premium moments) rather than a generic Material app. Plus Jakarta Sans throughout, at a
fairly heavy weight scale (buttons and metrics go all the way to w900) — the app leans confident
and dense, appropriate for warehouse staff scanning numbers quickly, not a consumer social app.

This file was extracted from the app's actual source tokens (`core/design_system/hexa_ds_tokens.dart`
and `core/theme/hexa_colors.dart`) — it describes what's already built, not a new direction. Its
purpose is to give any coding agent (Cursor, Claude Code, etc.) a portable, framework-agnostic
description of the system so a screen built from a prompt alone still lands on-brand.

## Colors

- **Primary (#0E4F46):** Deep teal-green. Primary buttons, headers, brand moments.
- **Secondary (#065F4F):** Slightly deeper green, used for gradient stops and hover states.
- **Accent (#159A8A):** Brighter teal — the interactive/CTA driver, gradient end-stop.
- **Gold (#D4AF37):** Reserved for profit/premium badges and highlight gradients. Sparingly —
  it's a signal color, not a decoration.
- **Background (#F7F9F6):** Warm off-white canvas, not pure white — softer than a stark white app.
- **Card (#FFFFFF):** Pure white for elevated surfaces on top of the warm canvas.
- **Success/Error/Warning:** Standard semantic greens/reds/ambers — kept separate from the brand
  green so "success" state and "brand primary" never get confused at a glance.

## Typography

Plus Jakarta Sans is the only typeface — no secondary display font. Hierarchy comes from weight
and size, not font-switching: headings sit at w700, metrics/big numbers punch up to w900, body
copy sits at a comfortable w400–500, labels/overlines are w600–700 with slight letter-spacing.
Money and quantity figures on purchase/report screens get their own dedicated styles
(`purchaseLineMoney`, `reportTableMoney`) at w800 in the brand primary color — numbers should
always look intentional, never like leftover body text.

## Spacing & layout

8px grid throughout (`HexaDsSpace`). Page gutter is 24px, section gaps 24px, block gaps 16px,
inline gaps 8px. Warehouse-dense screens (stock lists) get a tighter variant
(`HexaDsWarehouse`: 12px card padding, 10px gaps, 52px min list-row height, 48px min touch
target) — this is a deliberate two-speed system: spacious for dashboards/reports, dense for
high-frequency scan/list operations. Don't blend the two inside one screen.

## Radius & elevation

Minimum 12px radius everywhere — nothing sharp-cornered. Cards go up to 20px (`HexaDsRadii.card`)
for a soft, premium feel. Shadows are deliberately soft and layered (two stacked low-opacity
shadows per card) rather than a single hard drop shadow — reinforces the "premium SaaS" read over
a flat/utilitarian one.

## Breakpoints

Phone &lt;600 (`kTabletMin`), tablet 600–1023, desktop ≥1024 (`kDesktopMin`), ultra ≥1600
(`kUltraWideMin`). Rail label break at 900. Max content ~1180 (home up to 1440), forms 720,
sheets 640. Min touch 48px, min readable font 11px. Full device table: root `DESIGN.md`.

## How to use this file

Point any agent at root `DESIGN.md` (or this pack twin) before UI edits. Never invent hex/font/
spacing — add named tokens in `hexa_ds_tokens.dart` / `hexa_colors.dart` first. Enforceable
checklist: `.cursor/skills/design-quality/SKILL.md`.
