# STOCK UIUX REBUILD

## UX Goals
- Dense warehouse-safe data layout.
- Immediate understanding of system vs physical vs pending.
- Minimal tap path to corrective action.

## Implemented In This Pass
- Canonical stock diff semantics aligned API + UI.
- Route clean-up to avoid ambiguous intelligence/detail navigation.
- Low-stock desktop category fallback prevents false blank result panes.

## Remaining
- Standardize stock row action model to remove duplicated actions across owner/staff variants.
- Add explicit pending delivery + verification columns in one canonical table layout.
