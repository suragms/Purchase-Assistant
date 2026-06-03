# UX Rebuild Plan (Operational Clarity)

**Date:** 2026-06-02  
**Status:** Partial — blocking fixes done; enhancements backlog below

## Completed in recovery

| Issue | UX fix |
|-------|--------|
| Staff verify confusion | Message: verification saved; stock after commit |
| Purchase save blocked silently | Wizard shows inline `_inlineSaveError` + step block reasons |
| Barcode scan no feedback | Fixed lookup race; loading overlay on camera |
| Staff deliveries dead link | Home tile → `/staff/deliveries` |

## First-time user flow (recommended copy)

1. **Catalog** — Add item (set unit, kg/bag if bag product)
2. **Purchase** — Select supplier → add line from catalog → Save purchase
3. **Delivery** — Dispatch → Arrive → Staff verification counts
4. **Stock** — Owner **Commit stock** → check Stock tab

Place a one-time banner on purchase wizard step 0 (supplier) linking to Help — *not implemented in code this sprint*.

## Inline validation (purchase)

- Item sheet: red inline under item/qty/unit/kg/rate fields
- Wizard footer: Continue always enabled; shows `purchaseStepBlockReasonsProvider` message

## Mobile / desktop parity

- Item entry `fullPage: true` in wizard (works on desktop width)
- Shell uses `StatefulShellRoute` — preserve tab state

## Backlog (non-blocking)

- Onboarding coach marks for first purchase
- Empty state on stock when `needs_unit_setup` after commit
- Consolidate duplicate "Save" labels on item sheet footer (Add another vs Save)
- Help guide section for bag vs kg quantity mode

## PDF / display

- Company fallback: **NEW HARISREE AGENCY** (no emoji in PDF body)
