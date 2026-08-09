"""Media endpoints: OCR/plain-text preview only; no auto-save."""

import uuid
from typing import Annotated

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings, get_settings
from app.database import get_db
from app.deps import require_membership
from app.models import Membership
from app.services.bill_line_extract import extract_purchase_lines_from_text
from app.services.ocr_parser import extract_item_rows_via_ai

router = APIRouter(prefix="/v1/businesses/{business_id}/media", tags=["media"])


class OcrRequest(BaseModel):
    image_base64: str = Field(default="", description="Base64 image data (optional when paste_text set)")
    paste_text: str | None = Field(
        default=None,
        max_length=20000,
        description="Optional pasted invoice lines for local extraction when OCR is unavailable",
    )
    use_ai: bool = Field(
        default=False,
        description="When true and AI enabled, run tiered LLM JSON extract on pasted text",
    )


class OcrLineOut(BaseModel):
    item_name: str
    qty: float
    unit: str
    landing_cost: float


class OcrResponse(BaseModel):
    text: str = ""
    confidence: float = 0.0
    items: list[OcrLineOut] = Field(default_factory=list)
    missing_fields: list[str] = Field(default_factory=list)
    requires_user_confirmation: bool = True
    auto_save_allowed: bool = False
    note: str = "OCR provider not configured. Set OCR_API_KEY and ENABLE_OCR."
    ai_meta: dict | None = None


@router.post("/ocr", response_model=OcrResponse)
async def ocr_image(
    business_id: uuid.UUID,
    _m: Annotated[Membership, Depends(require_membership)],
    db: Annotated[AsyncSession, Depends(get_db)],
    settings: Annotated[Settings, Depends(get_settings)],
    body: OcrRequest,
):
    del _m
    paste = (body.paste_text or "").strip()
    raw_text = paste
    if not raw_text and body.image_base64:
        try:
            import base64

            raw = base64.b64decode(body.image_base64, validate=False)
            raw_text = raw.decode("utf-8", errors="ignore").strip()[:20000]
        except Exception:  # noqa: BLE001
            raw_text = ""

    ai_meta = None
    items: list[OcrLineOut] = []
    missing: list[str] = []

    if body.use_ai and raw_text and settings.enable_ai and settings.enable_ai_extraction:
        rows, missing, ai_meta = await extract_item_rows_via_ai(
            raw_text, db=db, business_id=business_id
        )
        items = [
            OcrLineOut(
                item_name=str(r.get("item_name") or r.get("name") or ""),
                qty=float(r.get("qty") or 0),
                unit=str(r.get("unit") or "kg"),
                landing_cost=float(
                    r.get("landing_cost") or r.get("rate") or 0
                ),
            )
            for r in rows
        ]
    else:
        extracted = extract_purchase_lines_from_text(raw_text)
        items = [
            OcrLineOut(
                item_name=e["item_name"],
                qty=float(e["qty"]),
                unit=str(e["unit"]),
                landing_cost=float(e["landing_cost"]),
            )
            for e in extracted
        ]

    ocr_on = settings.enable_ocr
    note = "Confirm lines before save. AI never finalizes purchases."
    if body.use_ai and ai_meta:
        note = (
            f"AI extract via {ai_meta.get('provider_used') or 'failover'} — "
            "confirm lines before save."
        )
    elif not ocr_on:
        note = "Cloud OCR off — parsed pasted/plain text only. Confirm lines before save."

    return OcrResponse(
        text=raw_text[:5000],
        confidence=0.55 if items and body.use_ai else (0.35 if items else 0.0),
        items=items,
        missing_fields=missing if missing else ([] if items else ["item_name", "qty", "unit", "rate"]),
        requires_user_confirmation=True,
        auto_save_allowed=False,
        note=note,
        ai_meta=ai_meta,
    )
