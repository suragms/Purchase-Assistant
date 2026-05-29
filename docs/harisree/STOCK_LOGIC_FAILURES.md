# STOCK LOGIC FAILURES

## Confirmed Mismatches
- `warehouse_diff_qty` backend formula was opposite of Flutter row semantics.
- Supplier filtering in low-stock ops route used UUID-as-search approximation.
- Delivery verification flow does not yet apply partial received/damaged/return stock deltas.

## Implemented Fixes
- Unified stock diff to `current_stock - period_purchased_qty` in stock row API builder.
- Updated backend test expectation (`test_stock_list_columns`) to match canonical formula.
- Implemented true supplier-id filtering in low-stock operations endpoint.

## Pending Critical Refactor
- Shift delivery stock truth to explicit verification/approval movement events while preserving idempotency.
