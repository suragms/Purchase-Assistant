import html

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select
from starlette.responses import HTMLResponse

from app.database import async_session_factory
from app.models import CatalogItem, ItemCategory
from app.services.stock_inventory import stock_status

router = APIRouter(prefix="/public/items", tags=["public-items"])


def _safe_item_payload(item: CatalogItem, category_name: str | None) -> dict:
    current = item.current_stock or 0
    reorder = item.reorder_level or 0
    unit = item.stock_unit or item.default_unit or item.selling_unit or "unit"
    return {
        "name": item.name,
        "category": category_name,
        "item_code": item.item_code,
        "barcode": item.barcode,
        "current_stock": float(current),
        "stock_unit": unit,
        "status": stock_status(current, reorder),
        "rack_location": item.rack_location,
        "last_stock_updated_at": item.last_stock_updated_at.isoformat()
        if item.last_stock_updated_at
        else None,
    }


async def _load_public_item(token: str) -> tuple[CatalogItem, str | None]:
    clean = token.strip()
    if not clean or len(clean) > 64:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Item not found")
    async with async_session_factory() as db:
        res = await db.execute(
            select(CatalogItem, ItemCategory.name)
            .join(ItemCategory, ItemCategory.id == CatalogItem.category_id)
            .where(
                CatalogItem.public_token == clean,
                CatalogItem.deleted_at.is_(None),
            )
        )
        row = res.first()
        if row is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Item not found")
        return row[0], row[1]


@router.get("/{token}.json")
async def public_item_json(token: str) -> dict:
    item, category_name = await _load_public_item(token)
    return _safe_item_payload(item, category_name)


@router.get("/{token}", response_class=HTMLResponse)
async def public_item_page(token: str) -> HTMLResponse:
    item, category_name = await _load_public_item(token)
    payload = _safe_item_payload(item, category_name)
    status_label = str(payload["status"]).replace("_", " ").title()
    body = f"""
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{html.escape(payload["name"])}</title>
  <style>
    body {{ font-family: system-ui, -apple-system, Segoe UI, sans-serif; margin: 0; background: #f7f9f6; color: #0f172a; }}
    .card {{ margin: 24px auto; max-width: 420px; background: white; border-radius: 20px; padding: 24px; box-shadow: 0 12px 40px rgba(15, 23, 42, .10); }}
    .brand {{ color: #0e4f46; font-weight: 800; letter-spacing: .02em; }}
    h1 {{ margin: 12px 0 4px; font-size: 26px; }}
    .muted {{ color: #64748b; }}
    .stock {{ margin-top: 18px; padding: 16px; border-radius: 16px; background: #e8f5f2; }}
    .qty {{ font-size: 34px; font-weight: 900; color: #0e4f46; }}
    .status {{ display: inline-block; margin-top: 10px; padding: 6px 10px; border-radius: 999px; background: #fff7ed; color: #c2410c; font-weight: 800; }}
  </style>
</head>
<body>
  <main class="card">
    <div class="brand">Harisree Warehouse</div>
    <h1>{html.escape(payload["name"])}</h1>
    <div class="muted">{html.escape(payload.get("category") or "Catalog item")}</div>
    <div class="stock">
      <div class="muted">Current stock</div>
      <div class="qty">{payload["current_stock"]:g} {html.escape(str(payload["stock_unit"]).upper())}</div>
      <div class="status">{html.escape(status_label)}</div>
    </div>
    <p class="muted">Item code: {html.escape(payload.get("item_code") or "-")}</p>
    <p class="muted">Rack: {html.escape(payload.get("rack_location") or "-")}</p>
  </main>
</body>
</html>
"""
    return HTMLResponse(body)

