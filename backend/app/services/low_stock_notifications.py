"""Hourly-ish job: insert in-app notifications for catalog items below reorder level."""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import CatalogItem, Membership
from app.services.notification_emitter import (
    CATEGORY_WAREHOUSE,
    PRIORITY_HIGH,
    emit_notification,
)

logger = logging.getLogger(__name__)


async def run_low_stock_notification_scan(db: AsyncSession) -> int:
    """Create deduped low-stock notifications for all members of affected businesses."""
    now = datetime.now(timezone.utc)
    day = now.strftime("%Y-%m-%d")

    q = await db.execute(
        select(
            CatalogItem.id,
            CatalogItem.business_id,
            CatalogItem.name,
            CatalogItem.current_stock,
            CatalogItem.reorder_level,
            CatalogItem.stock_unit,
            CatalogItem.default_unit,
        ).where(
            CatalogItem.deleted_at.is_(None),
            CatalogItem.archived_at.is_(None),
            CatalogItem.reorder_level.isnot(None),
            CatalogItem.reorder_level > 0,
            CatalogItem.current_stock.isnot(None),
            CatalogItem.current_stock < CatalogItem.reorder_level,
        )
    )
    low_rows = q.all()
    if not low_rows:
        return 0

    inserted = 0
    for item_id, business_id, name, cur, reorder, stock_unit, default_unit in low_rows:
        mems = await db.execute(
            select(Membership.user_id).where(Membership.business_id == business_id)
        )
        user_ids = [row[0] for row in mems.all()]
        unit = (stock_unit or default_unit or "units").strip()
        n = await emit_notification(
            db,
            business_id=business_id,
            user_ids=user_ids,
            kind="low_stock",
            title=f"Low stock: {name}",
            body=f"{cur} {unit} left (reorder at {reorder})",
            priority=PRIORITY_HIGH,
            category=CATEGORY_WAREHOUSE,
            dedupe_key=f"low_stock:{item_id}:{day}",
            action_route=f"/catalog/item/{item_id}",
            related_item_id=item_id,
            payload={
                "item_id": str(item_id),
                "current_stock": float(cur) if cur is not None else None,
                "reorder_level": float(reorder) if reorder is not None else None,
            },
        )
        inserted += n

    if inserted:
        await db.commit()
    return inserted
