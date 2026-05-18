"""Hourly-ish job: insert in-app notifications for catalog items below reorder level."""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import CatalogItem, Membership
from app.models.notification import AppNotification

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
    for item_id, business_id, name, cur, reorder in low_rows:
        mems = await db.execute(select(Membership.user_id).where(Membership.business_id == business_id))
        user_ids = [row[0] for row in mems.all()]
        for uid in user_ids:
            dedupe = f"low_stock:{item_id}:{day}:{uid}"
            ex = await db.execute(
                select(AppNotification.id).where(
                    AppNotification.business_id == business_id,
                    AppNotification.dedupe_key == dedupe,
                ).limit(1)
            )
            if ex.scalar_one_or_none() is not None:
                continue
            db.add(
                AppNotification(
                    id=uuid.uuid4(),
                    business_id=business_id,
                    user_id=uid,
                    kind="low_stock",
                    title="Low stock",
                    body=f"{name}: {cur} left (reorder at {reorder})",
                    payload={
                        "item_id": str(item_id),
                        "current_stock": float(cur) if cur is not None else None,
                        "reorder_level": float(reorder) if reorder is not None else None,
                    },
                    dedupe_key=dedupe,
                )
            )
            inserted += 1

    if inserted:
        await db.commit()
    return inserted
