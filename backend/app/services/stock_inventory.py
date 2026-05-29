import uuid
from collections import defaultdict
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import CatalogItem, User
from app.models.stock_adjustment import StockAdjustmentLog
from app.models.stock_movement import StockMovement
from app.services.unit_normalization import fetch_catalog_items_map, line_qty_in_stock_unit


def stock_status(current: Decimal | None, reorder: Decimal | None) -> str:
    cur = Decimal(current or 0)
    ro = Decimal(reorder or 0)
    if cur <= 0:
        return "out"
    if ro > 0:
        if cur <= ro * Decimal("0.5"):
            return "critical"
        if cur < ro:
            return "low"
    return "healthy"


def catalog_stock_qty(item: CatalogItem) -> Decimal:
    return Decimal(item.current_stock or 0)


def catalog_reorder(item: CatalogItem) -> Decimal:
    return Decimal(item.reorder_level or 0)


def catalog_landing_rate(item: CatalogItem) -> Decimal:
    """Valuation rate for on-hand stock: landing cost only (never selling)."""
    for raw in (item.default_landing_cost, item.last_purchase_price):
        if raw is not None:
            rate = Decimal(raw)
            if rate > 0:
                return rate
    return Decimal(0)


def compute_expected_system_qty(
    opening_stock_qty: Decimal | None,
    total_delivered_qty: Decimal | None,
) -> Decimal:
    """Opening + lifetime verified deliveries (audit stock formula)."""
    return Decimal(opening_stock_qty or 0) + Decimal(total_delivered_qty or 0)


def catalog_unit_key(item: CatalogItem) -> str:
    """Bucket on-hand qty into bags | boxes | tins | kg for dashboard totals."""
    unit = (
        (item.stock_unit or item.default_unit or item.selling_unit or "") or ""
    ).strip().lower()
    if "bag" in unit:
        return "bags"
    if "box" in unit:
        return "boxes"
    if "tin" in unit:
        return "tins"
    return "kg"


async def movement_delivered_qty_map(
    db: AsyncSession,
    business_id: uuid.UUID,
    item_ids: list[uuid.UUID],
) -> dict[uuid.UUID, Decimal]:
    """Lifetime qty added via committed PO deliveries (stock_movements.delivery_receive)."""
    if not item_ids:
        return {}
    r = await db.execute(
        select(
            StockMovement.item_id,
            func.coalesce(func.sum(StockMovement.delta_qty), 0),
        )
        .where(
            StockMovement.business_id == business_id,
            StockMovement.item_id.in_(item_ids),
            StockMovement.movement_kind == "delivery_receive",
        )
        .group_by(StockMovement.item_id)
    )
    return {row[0]: Decimal(row[1] or 0) for row in r.all()}


async def compute_inventory_summary(
    db: AsyncSession,
    business_id: uuid.UUID,
) -> dict[str, float | int]:
    """
    Point-in-time warehouse totals: sum(current_stock * landing rate) and unit buckets.
    Items without a landing rate still count toward unit buckets but not total_value_inr.
    """
    r = await db.execute(
        select(CatalogItem).where(
            CatalogItem.business_id == business_id,
            CatalogItem.deleted_at.is_(None),
        )
    )
    items = list(r.scalars().all())
    bags = boxes = tins = kg = Decimal(0)
    total_value = Decimal(0)
    for item in items:
        qty = catalog_stock_qty(item)
        if qty <= 0:
            continue
        bucket = catalog_unit_key(item)
        if bucket == "bags":
            bags += qty
        elif bucket == "boxes":
            boxes += qty
        elif bucket == "tins":
            tins += qty
        else:
            kg += qty
        rate = catalog_landing_rate(item)
        if rate > 0:
            total_value += qty * rate
    return {
        "total_value_inr": float(total_value),
        "bags": float(bags),
        "boxes": float(boxes),
        "tins": float(tins),
        "kg": float(kg),
        "item_count": len(items),
    }


async def _qty_by_catalog_item(
    db: AsyncSession,
    business_id: uuid.UUID,
    lines: list,
) -> dict[uuid.UUID, Decimal]:
    """Sum normalized line qty per catalog_item_id (stock unit)."""
    totals: dict[uuid.UUID, Decimal] = defaultdict(lambda: Decimal(0))
    item_ids: set[uuid.UUID] = set()
    for li in lines:
        cid = getattr(li, "catalog_item_id", None)
        if cid is not None:
            item_ids.add(uuid.UUID(str(cid)))
    items = await fetch_catalog_items_map(db, business_id, item_ids)
    for li in lines:
        cid = getattr(li, "catalog_item_id", None)
        if cid is None:
            continue
        cid_u = uuid.UUID(str(cid))
        item = items.get(cid_u)
        if not item:
            continue
        qty = line_qty_in_stock_unit(li, item)
        if qty <= 0:
            continue
        totals[cid_u] += qty
    return dict(totals)


async def _apply_catalog_stock_deltas(
    db: AsyncSession,
    business_id: uuid.UUID,
    user_id: uuid.UUID,
    deltas: dict[uuid.UUID, Decimal],
    *,
    reason: str,
    adjustment_type: str = "purchase",
    touch_last_purchase_at: bool = False,
) -> list[dict]:
    """Apply signed qty deltas; rejects if on-hand would go negative."""
    if not deltas:
        return []
    ur = await db.execute(select(User).where(User.id == user_id))
    user = ur.scalar_one_or_none()
    display = (user.name or user.username or user.email) if user else "System"
    updates: list[dict] = []
    for cid, delta in deltas.items():
        if delta == 0:
            continue
        r = await db.execute(
            select(CatalogItem).where(
                CatalogItem.id == cid,
                CatalogItem.business_id == business_id,
                CatalogItem.deleted_at.is_(None),
            )
        )
        item = r.scalar_one_or_none()
        if not item:
            continue
        old_qty = catalog_stock_qty(item)
        new_qty = old_qty + delta
        if new_qty < 0:
            raise ValueError(
                f"Stock cannot be negative for {item.name or item.id} "
                f"(on hand {old_qty}, adjustment {delta})"
            )
        unit = item.stock_unit or item.default_unit or item.selling_unit
        db.add(
            StockAdjustmentLog(
                business_id=business_id,
                item_id=item.id,
                old_qty=old_qty,
                new_qty=new_qty,
                adjustment_type=adjustment_type,
                reason=reason,
                updated_by=user_id,
                updated_by_name=display,
            )
        )
        item.current_stock = new_qty
        item.last_stock_updated_at = datetime.now(timezone.utc)
        item.last_stock_updated_by = display
        if touch_last_purchase_at and delta > 0:
            item.last_purchase_at = datetime.now(timezone.utc)
        updates.append(
            {
                "catalog_item_id": item.id,
                "name": item.name,
                "unit": unit,
                "old_qty": old_qty,
                "new_qty": new_qty,
                "delta": delta,
            }
        )
    return updates


async def purchase_delivery_stock_already_applied(
    db: AsyncSession,
    business_id: uuid.UUID,
    purchase_id: uuid.UUID,
) -> bool:
    """True if stock was already incremented for this purchase (idempotent delivery).

    Checks legacy adjustment-log marker and stock_movements idempotency keys.
    """
    marker = f"trade_purchase:{purchase_id}"
    r = await db.execute(
        select(func.count())
        .select_from(StockAdjustmentLog)
        .where(
            StockAdjustmentLog.business_id == business_id,
            StockAdjustmentLog.adjustment_type == "purchase",
            StockAdjustmentLog.reason.contains(marker),
        )
    )
    if int(r.scalar_one() or 0) > 0:
        return True
    r2 = await db.execute(
        select(func.count())
        .select_from(StockMovement)
        .where(
            StockMovement.business_id == business_id,
            StockMovement.idempotency_key.like(f"{marker}:%"),
        )
    )
    return int(r2.scalar_one() or 0) > 0


async def apply_confirmed_purchase_stock(
    db: AsyncSession,
    business_id: uuid.UUID,
    user_id: uuid.UUID,
    lines: list,
    *,
    purchase_human_id: str | None = None,
    purchase_id: uuid.UUID | None = None,
    actor: User | None = None,
) -> list[dict]:
    """Increment catalog stock when a purchase delivery is committed.

    When [purchase_id] and [actor] are set, uses stock_movements (delivery_receive)
    with idempotency_key trade_purchase:{purchase_id}:{catalog_item_id} so quick_purchase
    cannot double-apply the same PO line.
    """
    if purchase_id is not None and await purchase_delivery_stock_already_applied(
        db, business_id, purchase_id
    ):
        return []

    by_item = await _qty_by_catalog_item(db, business_id, lines)
    if not by_item:
        return []

    label = purchase_human_id or (str(purchase_id) if purchase_id else "")
    reason = f"Purchase received ({label})".strip()

    if purchase_id is not None and actor is not None:
        from app.services.stock_movement_service import apply_stock_movement

        updates: list[dict] = []
        for cid, delta in by_item.items():
            if delta <= 0:
                continue
            idem = f"trade_purchase:{purchase_id}:{cid}"
            result = await apply_stock_movement(
                db,
                business_id=business_id,
                item_id=cid,
                user=actor,
                movement_kind="delivery_receive",
                mode="delta",
                qty=delta,
                reason=reason,
                source_type="trade_purchase",
                source_id=purchase_id,
                idempotency_key=idem,
                metadata={"purchase_id": str(purchase_id), "human_id": label},
            )
            item = result.item
            unit = item.stock_unit or item.default_unit or item.selling_unit
            if result.duplicate:
                continue
            if delta > 0:
                item.last_purchase_at = datetime.now(timezone.utc)
            updates.append(
                {
                    "catalog_item_id": item.id,
                    "name": item.name,
                    "unit": unit,
                    "old_qty": result.movement.qty_before,
                    "new_qty": result.movement.qty_after,
                    "delta": delta,
                }
            )
        return updates

    marker = f" trade_purchase:{purchase_id}" if purchase_id else ""
    reason_legacy = f"{reason}{marker}".strip()
    return await _apply_catalog_stock_deltas(
        db,
        business_id,
        user_id,
        by_item,
        reason=reason_legacy,
        adjustment_type="purchase",
        touch_last_purchase_at=True,
    )


async def revert_confirmed_purchase_stock(
    db: AsyncSession,
    business_id: uuid.UUID,
    user_id: uuid.UUID,
    lines: list,
    *,
    purchase_human_id: str | None = None,
) -> list[dict]:
    """Decrement stock for a previously delivered purchase."""
    by_item = await _qty_by_catalog_item(db, business_id, lines)
    if not by_item:
        return []
    deltas = {cid: -qty for cid, qty in by_item.items()}
    reason = f"Purchase reversed{f' ({purchase_human_id})' if purchase_human_id else ''}"
    return await _apply_catalog_stock_deltas(
        db,
        business_id,
        user_id,
        deltas,
        reason=reason,
        adjustment_type="purchase_reversal",
        touch_last_purchase_at=False,
    )


async def sync_confirmed_purchase_stock_diff(
    db: AsyncSession,
    business_id: uuid.UUID,
    user_id: uuid.UUID,
    old_lines: list,
    new_lines: list,
    *,
    purchase_human_id: str | None = None,
) -> list[dict]:
    """Apply qty delta when editing an already-delivered purchase."""
    old_map = await _qty_by_catalog_item(db, business_id, old_lines)
    new_map = await _qty_by_catalog_item(db, business_id, new_lines)
    all_ids = set(old_map) | set(new_map)
    deltas: dict[uuid.UUID, Decimal] = {}
    for cid in all_ids:
        delta = new_map.get(cid, Decimal(0)) - old_map.get(cid, Decimal(0))
        if delta != 0:
            deltas[cid] = delta
    if not deltas:
        return []
    reason = f"Purchase adjusted{f' ({purchase_human_id})' if purchase_human_id else ''}"
    return await _apply_catalog_stock_deltas(
        db,
        business_id,
        user_id,
        deltas,
        reason=reason,
        adjustment_type="purchase_adjustment",
        touch_last_purchase_at=any(d > 0 for d in deltas.values()),
    )
