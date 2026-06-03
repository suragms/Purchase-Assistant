"""Purchase damage / short-delivery reports."""

from __future__ import annotations

import uuid
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import TradePurchase, User
from app.models.purchase_damage_report import PurchaseDamageReport
from app.models.contacts import Supplier
from app.services.notification_emitter import (
    CATEGORY_PURCHASE,
    PRIORITY_HIGH,
    emit_notification,
)

_DAMAGE_LABELS = {
    "damaged": "damaged",
    "short": "short-delivered",
    "missing": "missing",
    "returned": "returned",
}


async def create_damage_report(
    db: AsyncSession,
    *,
    business_id: uuid.UUID,
    purchase_id: uuid.UUID,
    user: User,
    item_name: str,
    qty_damaged: Decimal,
    damage_type: str,
    notes: str | None,
) -> PurchaseDamageReport:
    dt = damage_type.strip().lower()
    if dt not in _DAMAGE_LABELS:
        raise ValueError("Invalid damage_type")

    tp = (
        await db.execute(
            select(TradePurchase).where(
                TradePurchase.id == purchase_id,
                TradePurchase.business_id == business_id,
            )
        )
    ).scalar_one_or_none()
    if tp is None:
        raise LookupError("Purchase not found")

    row = PurchaseDamageReport(
        id=uuid.uuid4(),
        business_id=business_id,
        purchase_id=purchase_id,
        item_name=item_name.strip()[:500],
        qty_damaged=qty_damaged,
        damage_type=dt,
        notes=(notes or "").strip()[:4000] or None,
        reported_by_user_id=user.id,
    )
    db.add(row)

    supplier_name = "supplier"
    if tp.supplier_id:
        sup = (
            await db.execute(select(Supplier.name).where(Supplier.id == tp.supplier_id))
        ).scalar_one_or_none()
        if sup:
            supplier_name = str(sup)

    staff_name = (user.name or user.email or "Staff").strip()
    dmg_label = _DAMAGE_LABELS[dt]
    qty_s = f"{qty_damaged:g}"
    body = (
        f"{staff_name} reported {qty_s} {item_name.strip()} {dmg_label} "
        f"in purchase from {supplier_name}"
    )
    await emit_notification(
        db,
        business_id=business_id,
        kind="damage_report",
        title="Damage / short delivery reported",
        body=body,
        priority=PRIORITY_HIGH,
        category=CATEGORY_PURCHASE,
        dedupe_key=f"damage_report:{purchase_id}:{row.id}",
        action_route=f"/purchase/detail/{purchase_id}",
        triggered_by_user_id=user.id,
        related_purchase_id=purchase_id,
        target_roles=["owner", "admin", "manager"],
        payload={"damage_type": dt, "item_name": item_name.strip()},
    )
    await db.commit()
    await db.refresh(row)
    return row


async def list_damage_reports(
    db: AsyncSession,
    *,
    business_id: uuid.UUID,
    purchase_id: uuid.UUID,
) -> list[tuple[PurchaseDamageReport, str | None]]:
    tp = (
        await db.execute(
            select(TradePurchase.id).where(
                TradePurchase.id == purchase_id,
                TradePurchase.business_id == business_id,
            )
        )
    ).scalar_one_or_none()
    if tp is None:
        raise LookupError("Purchase not found")

    r = await db.execute(
        select(PurchaseDamageReport, User.name)
        .outerjoin(User, PurchaseDamageReport.reported_by_user_id == User.id)
        .where(
            PurchaseDamageReport.business_id == business_id,
            PurchaseDamageReport.purchase_id == purchase_id,
        )
        .order_by(PurchaseDamageReport.created_at.desc())
    )
    return list(r.all())
