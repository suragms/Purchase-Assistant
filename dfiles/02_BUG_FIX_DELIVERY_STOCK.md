# AGENT PROMPT 02 — FIX BUG: DELIVERY CONFIRMATION MUST UPDATE STOCK
**Priority:** CRITICAL — without this fix, stock is NEVER updated when deliveries are confirmed.

---

## ROOT CAUSE (confirmed by code analysis)

**File:** `backend/app/services/trade_purchase_service.py`
**Function:** `patch_trade_purchase_delivery()` at approximately line 1170

The function sets `is_delivered = True` and commits, but NEVER calls `apply_confirmed_purchase_stock()`.

Compare to `create_trade_purchase()` (line ~940) and `update_trade_purchase()` (line ~1090) which both call `apply_confirmed_purchase_stock()` correctly.

**Current broken code:**
```python
async def patch_trade_purchase_delivery(
    db: AsyncSession,
    business_id: uuid.UUID,
    purchase_id: uuid.UUID,
    body: TradePurchaseDeliveryPatch,
) -> TradePurchaseOut | None:
    res = await db.execute(
        select(TradePurchase)
        .where(...)
        .options(*_trade_purchase_load_opts())
    )
    tp = res.scalar_one_or_none()
    if not tp:
        return None
    st = (tp.status or "").lower()
    if st == "deleted":
        return None
    tp.is_delivered = body.is_delivered
    if body.is_delivered:
        tp.delivered_at = body.delivered_at or utcnow()
    else:
        tp.delivered_at = None
    if body.delivery_notes is not None:
        notes = body.delivery_notes.strip()
        tp.delivery_notes = notes or None
    tp.updated_at = utcnow()
    await db.commit()                          # ← commits without updating stock!
    bump_trade_read_caches_for_business(business_id)
    return await get_trade_purchase(db, business_id, purchase_id)
```

---

## BACKEND FIX

### Fix 1: `patch_trade_purchase_delivery()` in `trade_purchase_service.py`

Replace the function with this corrected version:

```python
async def patch_trade_purchase_delivery(
    db: AsyncSession,
    business_id: uuid.UUID,
    purchase_id: uuid.UUID,
    body: TradePurchaseDeliveryPatch,
) -> TradePurchaseOut | None:
    res = await db.execute(
        select(TradePurchase)
        .where(
            TradePurchase.business_id == business_id,
            TradePurchase.id == purchase_id,
        )
        .options(*_trade_purchase_load_opts())
    )
    tp = res.scalar_one_or_none()
    if not tp:
        return None
    st = (tp.status or "").lower()
    if st == "deleted":
        return None

    was_delivered = bool(tp.is_delivered)
    now_delivered = bool(body.is_delivered)

    tp.is_delivered = body.is_delivered
    if body.is_delivered:
        tp.delivered_at = body.delivered_at or utcnow()
    else:
        tp.delivered_at = None
    if body.delivery_notes is not None:
        notes = body.delivery_notes.strip()
        tp.delivery_notes = notes or None
    tp.updated_at = utcnow()

    stock_updates: list[dict] = []

    # ─── STOCK UPDATE LOGIC ───────────────────────────────────────────
    # Case 1: marking as delivered for the first time → apply stock
    if not was_delivered and now_delivered:
        stock_updates = await apply_confirmed_purchase_stock(
            db, business_id, purchase_id
        )
    # Case 2: un-marking delivery (rare but possible) → revert stock
    elif was_delivered and not now_delivered:
        stock_updates = await revert_confirmed_purchase_stock(
            db, business_id, purchase_id
        )
    # Case 3: already delivered, still delivered (notes update only) → no stock change
    # ─────────────────────────────────────────────────────────────────

    await db.commit()
    bump_trade_read_caches_for_business(business_id)

    # Refresh cache keys for affected items
    if stock_updates:
        item_ids = [u.get("item_id") for u in stock_updates if u.get("item_id")]
        for iid in item_ids:
            _log.info(
                "delivery confirmed stock update: item_id=%s qty_delta=%s",
                iid,
                next((u.get("delta") for u in stock_updates if u.get("item_id") == iid), "?"),
            )

    return await get_trade_purchase(db, business_id, purchase_id)
```

**Imports needed** — confirm these are already imported at top of `trade_purchase_service.py`:
```python
from app.services.stock_inventory import (
    apply_confirmed_purchase_stock,
    revert_confirmed_purchase_stock,
    sync_confirmed_purchase_stock_diff,
)
```
They are already imported at lines 36–38. No new imports needed.

---

### Fix 2: Add staff_received_by field to delivery patch

**Schema:** `backend/app/schemas/trade_purchases.py`

Find `TradePurchaseDeliveryPatch` and add the `received_by_user_id` field:

```python
class TradePurchaseDeliveryPatch(BaseModel):
    is_delivered: bool
    delivered_at: datetime | None = None
    delivery_notes: str | None = None
    received_by_user_id: uuid.UUID | None = None  # ← ADD THIS
```

**Model:** `backend/app/models/trade_purchase.py`

Check if `delivered_by` or `received_by` column exists. If not, add migration 033_delivery_received_by.py:

```python
# backend/alembic/versions/033_delivery_received_by.py
from alembic import op
import sqlalchemy as sa

revision = "033"
down_revision = "032"
branch_labels = None
depends_on = None

def upgrade():
    op.add_column("trade_purchases", sa.Column(
        "received_by_user_id",
        sa.UUID(as_uuid=True),
        sa.ForeignKey("users.id"),
        nullable=True,
    ))

def downgrade():
    op.drop_column("trade_purchases", "received_by_user_id")
```

**Service:** In `patch_trade_purchase_delivery()`, after `tp.is_delivered = body.is_delivered`, add:
```python
if body.received_by_user_id is not None:
    tp.received_by_user_id = body.received_by_user_id
```

---

## FLUTTER FIX: Staff Receive Shipment Page

**File:** `flutter_app/lib/features/staff/presentation/staff_receive_shipment_page.dart`

### Current problem
The page calls PATCH `/{purchase_id}/delivery` with `is_delivered: true` but the API was silently not updating stock. Now that the backend is fixed, the Flutter side needs to:
1. Invalidate `stockListProvider` and `stockAlertCountsProvider` after delivery confirmation
2. Show a success message that includes what stock was updated
3. Show the staff user's name as the receiver

### Fix: After successful delivery confirmation, invalidate all stock providers

Find the method that calls the delivery PATCH (look for `is_delivered: true` in the file). After the API call succeeds, add:

```dart
// After successful delivery confirmation:
ref.invalidate(stockListProvider);
ref.invalidate(stockAlertCountsProvider);
ref.invalidate(stockLowCountProvider);
ref.invalidate(stockCriticalCountProvider);
// If you watch tradePurchasesProvider, invalidate that too:
ref.invalidate(tradePurchasesProvider);
```

Also add a clear success snackbar:
```dart
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Delivery confirmed. Stock updated for ${items.length} item(s).',
      ),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 4),
    ),
  );
}
```

---

## FLUTTER FIX: Purchase Detail Page — Delivery Button

**File:** `flutter_app/lib/features/purchase/presentation/purchase_detail_page.dart`

Find the "Confirm Delivery" button (or "Mark Delivered" button). After the PATCH succeeds:

```dart
// Add these invalidations:
ref.invalidate(stockListProvider);
ref.invalidate(stockAlertCountsProvider);
```

---

## FLUTTER FIX: Show Pending Deliveries on Staff Home

**File:** `flutter_app/lib/features/staff/presentation/staff_home_page.dart`

Ensure `staffPendingDeliveriesProvider` is properly invalidated after a delivery is confirmed. The provider should re-fetch automatically via `autoDispose`, but explicitly call `ref.invalidate(staffPendingDeliveriesProvider)` after confirmation.

---

## BUSINESS LOGIC RULES (DO NOT VIOLATE)

1. Stock is updated ONLY when `is_delivered` transitions from `false` → `true`.
2. A purchase created by owner has `is_delivered = false` by default. Stock is NOT added at creation.
3. When staff confirms receipt (`is_delivered = true`), stock for ALL line items is added.
4. If staff physically counted fewer items (e.g. PO says 100 bags, counted 48), the actual delivered qty should be stored in the delivery confirmation. For now, use the PO line qty (the `received_by` shortfall can be noted in `delivery_notes`).
5. If delivery is un-confirmed (`is_delivered: true → false`), stock is REVERTED. This is a rare operation — add an owner-only confirmation dialog in Flutter.

---

## VERIFICATION

After applying these fixes:

**Backend test:**
```bash
# Create a purchase via API (owner)
# Check stock: should NOT change
# Call PATCH /{purchase_id}/delivery with is_delivered=true
# Check stock: should INCREASE by the line item qty
# Call PATCH /{purchase_id}/delivery with is_delivered=false
# Check stock: should DECREASE back
```

**Database check:**
```sql
SELECT ci.name, ci.current_stock, sa.adjustment_type, sa.old_qty, sa.new_qty, sa.updated_at
FROM stock_adjustments sa
JOIN catalog_items ci ON ci.id = sa.catalog_item_id
WHERE sa.adjustment_type = 'purchase'
ORDER BY sa.updated_at DESC
LIMIT 10;
```
After marking delivered, you should see new rows with `adjustment_type = 'purchase'`.
