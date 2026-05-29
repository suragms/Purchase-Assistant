# STOCK TABLE REDESIGN

## Required Canonical Columns
- Item
- System stock
- Physical stock
- Pending delivery
- Difference
- Verification status

## Current Progress
- Difference semantics aligned backend and Flutter row rendering.
- Recent-sort strategy remains default to move newly-updated items to top.

## Next Work
- Collapse duplicate action columns and normalize action icons.
- Ensure mobile table density without horizontal overflow.
