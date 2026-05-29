# NAVIGATION BUGS

## Confirmed
- Intelligence and item detail routes had overlapping intent.
- Edit action behavior felt like reopening old duplicate detail state.

## Implemented
- `/stock/intelligence/:itemId` now redirects to canonical catalog item detail route with source query.
- Item detail top-right edit action routes to dedicated edit path.
- Edit mode hides non-edit quick actions for clearer workflow.

## Remaining
- Remove deprecated/parallel route surfaces after reference sweep.
- Add route contract tests for owner/staff deep links.
