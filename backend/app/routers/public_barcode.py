"""Public barcode lookup (no auth) — for camera apps and external scanners."""

from fastapi import APIRouter
from starlette.responses import JSONResponse

from app.routers.public_items import _load_public_item, _safe_item_payload

router = APIRouter(prefix="/public/barcode", tags=["public-barcode"])


@router.get("/{barcode}.json")
async def public_barcode_json(barcode: str) -> JSONResponse:
    item, category_name, delivered, phys_qty, phys_at, supplier = await _load_public_item(
        barcode
    )
    payload = _safe_item_payload(
        item,
        category_name,
        delivered_qty=delivered,
        physical_qty=phys_qty,
        physical_counted_at=phys_at,
        supplier_name=supplier,
    )
    return JSONResponse(
        payload,
        headers={"Cache-Control": "public, max-age=60"},
    )
