"""WhatsApp PO delivery after purchase approval (idempotent, real Graph media)."""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone
from typing import Any

import httpx
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.config import get_settings
from app.models.business import Business
from app.models.owner_ops import WhatsAppDeliveryLog
from app.models.trade_purchase import TradePurchase, TradePurchaseLine
from app.services.export_files import build_purchase_order_pdf
from app.services.provider_credentials import resolve_key

logger = logging.getLogger(__name__)


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def delivery_to_dict(row: WhatsAppDeliveryLog) -> dict[str, Any]:
    return {
        "id": str(row.id),
        "business_id": str(row.business_id),
        "po_id": str(row.po_id),
        "staff_id": str(row.staff_id) if row.staff_id else None,
        "recipient_number": row.recipient_number,
        "status": row.status,
        "attempt_count": row.attempt_count,
        "last_attempted_at": (
            row.last_attempted_at.isoformat() if row.last_attempted_at else None
        ),
        "error_message": row.error_message,
        "created_at": row.created_at.isoformat() if row.created_at else None,
    }


async def _existing_success(
    db: AsyncSession, business_id: uuid.UUID, po_id: uuid.UUID
) -> WhatsAppDeliveryLog | None:
    return (
        await db.execute(
            select(WhatsAppDeliveryLog)
            .where(
                WhatsAppDeliveryLog.business_id == business_id,
                WhatsAppDeliveryLog.po_id == po_id,
                WhatsAppDeliveryLog.status == "sent",
            )
            .order_by(WhatsAppDeliveryLog.created_at.desc())
            .limit(1)
        )
    ).scalar_one_or_none()


async def _upload_pdf_media(
    client: httpx.AsyncClient,
    *,
    phone_id: str,
    api_key: str,
    pdf_bytes: bytes,
    filename: str,
) -> str:
    """Upload PDF to Meta Graph; return media id."""
    url = f"https://graph.facebook.com/v19.0/{phone_id}/media"
    files = {
        "file": (filename, pdf_bytes, "application/pdf"),
        "messaging_product": (None, "whatsapp"),
        "type": (None, "application/pdf"),
    }
    headers = {"Authorization": f"Bearer {api_key}"}
    res = await client.post(url, headers=headers, files=files)
    res.raise_for_status()
    data = res.json()
    mid = data.get("id")
    if not mid:
        raise RuntimeError(f"media upload missing id: {str(data)[:200]}")
    return str(mid)


async def deliver_po_whatsapp(
    db: AsyncSession,
    *,
    business_id: uuid.UUID,
    po_id: uuid.UUID,
    actor_id: uuid.UUID | None = None,
    force: bool = False,
) -> WhatsAppDeliveryLog:
    """Generate PO PDF and send via WhatsApp Cloud API when credentials exist."""
    settings = get_settings()
    if not getattr(settings, "enable_whatsapp_po_delivery", True):
        row = WhatsAppDeliveryLog(
            business_id=business_id,
            po_id=po_id,
            staff_id=actor_id,
            status="pending_manual",
            error_message="WhatsApp PO delivery disabled",
            attempt_count=0,
        )
        db.add(row)
        await db.commit()
        await db.refresh(row)
        return row

    if not force:
        prior = await _existing_success(db, business_id, po_id)
        if prior is not None:
            return prior

    api_key = await resolve_key(
        db, business_id, "whatsapp_api_key", settings.dialog360_api_key
    )
    recipient = await resolve_key(db, business_id, "whatsapp_staff_number", None)
    phone_id = await resolve_key(
        db,
        business_id,
        "whatsapp_phone_number_id",
        (settings.whatsapp_phone_number_id or settings.dialog360_phone_number_id),
    )

    row = WhatsAppDeliveryLog(
        business_id=business_id,
        po_id=po_id,
        staff_id=actor_id,
        recipient_number=(recipient or "")[:32] or None,
        status="pending_manual",
        attempt_count=0,
    )
    db.add(row)
    await db.flush()

    if not (recipient or "").strip():
        row.status = "pending_manual"
        row.error_message = "No WhatsApp staff number configured"
        await db.commit()
        await db.refresh(row)
        return row

    if not (api_key or "").strip() or not (phone_id or "").strip():
        row.status = "pending_manual"
        row.error_message = "WhatsApp API key or phone_number_id missing"
        await db.commit()
        await db.refresh(row)
        return row

    tp = (
        await db.execute(
            select(TradePurchase)
            .where(
                TradePurchase.id == po_id,
                TradePurchase.business_id == business_id,
            )
            .options(selectinload(TradePurchase.supplier_row))
        )
    ).scalar_one_or_none()
    if tp is None:
        row.status = "failed"
        row.error_message = "Purchase not found"
        await db.commit()
        await db.refresh(row)
        return row

    biz = await db.get(Business, business_id)
    label = (
        (biz.branding_title or "").strip()
        if biz is not None and getattr(biz, "branding_title", None)
        else ""
    ) or ((biz.name or "").strip() if biz is not None else "") or "NEW HARISREE AGENCY"

    lines = list(
        (
            await db.execute(
                select(TradePurchaseLine).where(
                    TradePurchaseLine.trade_purchase_id == po_id
                )
            )
        )
        .scalars()
        .all()
    )
    try:
        pdf_bytes = build_purchase_order_pdf(
            business_label=label,
            purchase=tp,
            lines=lines,
        )
    except Exception as e:  # noqa: BLE001
        row.status = "failed"
        row.error_message = f"PDF generation failed: {e}"[:500]
        await db.commit()
        await db.refresh(row)
        return row

    if not pdf_bytes:
        row.status = "failed"
        row.error_message = "Empty PO PDF"
        await db.commit()
        await db.refresh(row)
        return row

    human = getattr(tp, "human_id", None) or str(po_id)
    filename = f"PO_{human}.pdf".replace("/", "-")
    msg_url = f"https://graph.facebook.com/v19.0/{phone_id}/messages"
    auth = {"Authorization": f"Bearer {api_key}"}

    last_err = None
    for attempt in range(1, 4):
        row.attempt_count = attempt
        row.last_attempted_at = _utcnow()
        try:
            async with httpx.AsyncClient(timeout=60.0) as client:
                media_id = await _upload_pdf_media(
                    client,
                    phone_id=phone_id.strip(),
                    api_key=api_key.strip(),
                    pdf_bytes=pdf_bytes,
                    filename=filename,
                )
                payload = {
                    "messaging_product": "whatsapp",
                    "to": recipient.strip().lstrip("+"),
                    "type": "document",
                    "document": {
                        "id": media_id,
                        "filename": filename,
                        "caption": f"Purchase order {human} approved.",
                    },
                }
                res = await client.post(
                    msg_url,
                    headers={**auth, "Content-Type": "application/json"},
                    json=payload,
                )
            if res.status_code < 300:
                row.status = "sent"
                row.error_message = None
                await db.commit()
                await db.refresh(row)
                return row
            last_err = f"HTTP {res.status_code}: {res.text[:200]}"
        except Exception as e:  # noqa: BLE001
            last_err = str(e)[:300]
            logger.warning("whatsapp send attempt %s failed: %s", attempt, e)

    row.status = "pending_manual"
    row.error_message = last_err
    await db.commit()
    await db.refresh(row)
    return row


async def list_deliveries(
    db: AsyncSession, business_id: uuid.UUID, *, limit: int = 50
) -> list[WhatsAppDeliveryLog]:
    return list(
        (
            await db.execute(
                select(WhatsAppDeliveryLog)
                .where(WhatsAppDeliveryLog.business_id == business_id)
                .order_by(WhatsAppDeliveryLog.created_at.desc())
                .limit(limit)
            )
        )
        .scalars()
        .all()
    )
