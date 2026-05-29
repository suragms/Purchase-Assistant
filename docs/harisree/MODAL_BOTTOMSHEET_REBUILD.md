# MODAL / BOTTOM SHEET REBUILD

## Problems
- Oversized sheets with excessive whitespace.
- Suggestion row tap race causing unreliable selection.
- Inconsistent keyboard-safe behavior across search/picker overlays.

## Implemented Fixes
- `search_picker_sheet` max height constrained to 55%.
- `smart_search_field` result sheet max height constrained to 55%.
- Removed duplicate tap-down commit in party suggestion row, leaving single tap commit path.

## Remaining
- Apply shared compact sheet constraints to all stock/purchase operation sheets.
- Enforce sticky footer action bar pattern for submit/cancel in critical sheets.
