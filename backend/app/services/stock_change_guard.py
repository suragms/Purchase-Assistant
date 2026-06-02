"""Block routine stock writes while a warehouse audit is open."""

from __future__ import annotations

import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.stock_audit import StockAudit

_OPEN_AUDIT_STATUSES = ("draft", "pending_review")

_AUDIT_MOVEMENT_KINDS = frozenset(
    {
        "physical_count",
        "correction",
    }
)

_AUDIT_SOURCE_TYPES = frozenset({"stock_audit", "audit_session"})


async def business_has_open_stock_audit(
    db: AsyncSession,
    business_id: uuid.UUID,
) -> bool:
    r = await db.execute(
        select(StockAudit.id)
        .where(
            StockAudit.business_id == business_id,
            StockAudit.status.in_(_OPEN_AUDIT_STATUSES),
        )
        .limit(1)
    )
    return r.scalar_one_or_none() is not None


async def assert_stock_changes_allowed(
    db: AsyncSession,
    *,
    business_id: uuid.UUID,
    movement_kind: str,
    source_type: str | None,
) -> None:
    if not await business_has_open_stock_audit(db, business_id):
        return
    kind = (movement_kind or "").strip().lower()
    src = (source_type or "").strip().lower()
    if kind in _AUDIT_MOVEMENT_KINDS or src in _AUDIT_SOURCE_TYPES:
        return
    raise ValueError(
        "A stock audit is in progress. Finish or submit the audit before other stock changes."
    )
