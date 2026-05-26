# AGENT PROMPT 04 — FIX BARCODE SCAN SPEED + PUBLIC QR CODE ENDPOINT
**Priority:** HIGH — scan takes 3–5 seconds, should be < 1 second.

---

## PART A: FIX IN-APP BARCODE SCAN SPEED

### Root Causes (all confirmed in code)

**File:** `flutter_app/lib/features/barcode/presentation/barcode_scan_page.dart`

| Cause | Line/location | Fix |
|-------|--------------|-----|
| Wrong detection speed | `_initCamera()` → `DetectionSpeed.normal` | Change to `DetectionSpeed.noDuplicates` |
| Camera stops before API call | `_lookupAndNavigate()` → `await _camera?.stop()` before network | Keep camera running until navigate |
| Debounce too high | `const _kDebounceMs = 1500` | Change to `800` |
| No loading indicator during API call | Missing | Show overlay spinner instead of stopping camera |
| All BarcodeFormats searched | Not filtered | Limit to Code128 + QR only |

---

### Fix 1: Change detection speed and debounce

Find the two places where `MobileScannerController` is created:

```dart
// BOTH occurrences (one for web, one for native):
_camera = MobileScannerController(
  detectionSpeed: DetectionSpeed.normal,     // ← CHANGE TO:
  // detectionSpeed: DetectionSpeed.noDuplicates,
  facing: CameraFacing.back,
  formats: const [BarcodeFormat.code128, BarcodeFormat.qrCode],
);
```

Change both to:
```dart
_camera = MobileScannerController(
  detectionSpeed: DetectionSpeed.noDuplicates,  // ← FIXED
  facing: CameraFacing.back,
  formats: const [BarcodeFormat.code128, BarcodeFormat.qrCode],
);
```

Change debounce:
```dart
// Line 1:
const _kDebounceMs = 1500;  // ← CHANGE TO:
const _kDebounceMs = 800;
```

---

### Fix 2: Don't stop camera during API lookup — show overlay instead

Replace the `_lookupAndNavigate` function with this corrected version:

```dart
Future<void> _lookupAndNavigate(String raw) async {
  final code = raw.trim();
  if (code.isEmpty) return;
  final session = ref.read(sessionProvider);
  if (session == null) return;
  if (_busy) return;
  
  // ← REMOVED: await _camera?.stop();  // Don't stop camera during lookup!
  setState(() => _busy = true);  // Shows loading overlay on camera preview instead
  
  try {
    final row = await ref
        .read(hexaApiProvider)
        .barcodeStockLookup(
          businessId: session.primaryBusiness.id,
          code: code,
        )
        .timeout(const Duration(seconds: 8));  // Reduced from 10 to 8

    final id = row['id']?.toString();
    final name = row['name']?.toString() ?? code;
    if (id == null || id.isEmpty) {
      // Stop camera only when showing sheet
      if (!kIsWeb) {
        try { await _camera?.stop(); } catch (_) {}
      }
      await _showNotFoundSheet(code);
      return;
    }
    
    // Stop camera only on confirmed navigate
    if (!kIsWeb) {
      try { await _camera?.stop(); } catch (_) {}
    }
    
    await _pushRecent(BarcodeRecentScan(id: id, name: name, code: code));
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    
    final returnTo = GoRouterState.of(context).uri.queryParameters['return'];
    if (returnTo == 'stock') {
      final saved = await showQuickStockPatchSheet(
        context: context,
        ref: ref,
        item: Map<String, dynamic>.from(row),
      );
      if (saved && mounted) {
        ref.invalidate(stockListProvider);
        ref.invalidate(stockAuditPeriodProvider);
        if (id.isNotEmpty) {
          ref.invalidate(catalogItemDetailProvider(id));
        }
        await _loadRecent();
        showStockUndoSnackBar(context: context, ref: ref, itemId: id, itemName: name);
      }
      if (mounted) context.pop();
      return;
    }
    await _showFoundActions(row, id, name);
    
  } on TimeoutException {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Network timeout — check connection and try again'),
        duration: Duration(seconds: 3),
      ),
    );
    await _resumeScan();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(barcodeMessageForUser(e, ctx: BarcodeOperationContext.scanner)),
        duration: const Duration(seconds: 3),
      ),
    );
    await _resumeScan();
  } finally {
    if (mounted) setState(() => _busy = false);
  }
}
```

---

### Fix 3: Loading overlay on camera (not camera stop)

In the `build` method, where the camera preview is shown, add a loading overlay that appears when `_busy = true` but does NOT stop the camera:

Find the MobileScanner widget in the build tree and wrap it:
```dart
// Find the Stack that contains MobileScanner and add this overlay:
if (_busy)
  Container(
    color: Colors.black.withOpacity(0.5),
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 12),
          Text(
            'Looking up...',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    ),
  ),
```

---

### Fix 4: Backend barcode lookup — add caching

**File:** `backend/app/routers/stock.py`
**Function:** `barcode_lookup()` (around line 819)

Add response caching with a short TTL:
```python
from fastapi_cache.decorator import cache  # if using fastapi-cache
# OR use the existing read_cache_generation system

@router.get("/barcode/{code}", response_model=BarcodeLookupOut)
async def barcode_lookup(
    business_id: uuid.UUID,
    code: str,
    ...
):
    # Add index hint: ensure there's an index on catalog_items.barcode
    # This query must use the barcode index, not a full scan
    ...
```

**Database:** Verify the index on `catalog_items.barcode` column:
```sql
-- Check:
SELECT indexname, indexdef FROM pg_indexes 
WHERE tablename = 'catalog_items' AND indexdef LIKE '%barcode%';

-- If missing, add:
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_catalog_items_barcode 
ON catalog_items(barcode) WHERE barcode IS NOT NULL;
```

---

## PART B: PUBLIC QR CODE ENDPOINT (no-auth scan)

### Overview
QR codes printed on shelves must work with any phone camera (iPhone camera, Google Lens) WITHOUT the app. 
The QR code URL: `https://yourapp.com/item/{public_token}`
Public token: a 32-char hex string stored in `catalog_items.public_token` column.

---

### Backend: New migration for public_token

**File:** `backend/alembic/versions/033_catalog_public_token.py` (adjust revision number)
```python
from alembic import op
import sqlalchemy as sa

revision = "033"
down_revision = "032"  # adjust to actual last migration

def upgrade():
    op.add_column(
        "catalog_items",
        sa.Column("public_token", sa.String(32), nullable=True, unique=True),
    )
    op.create_index(
        "idx_catalog_items_public_token",
        "catalog_items",
        ["public_token"],
        unique=True,
    )
    # Backfill all existing items
    op.execute("""
        UPDATE catalog_items 
        SET public_token = encode(gen_random_bytes(16), 'hex')
        WHERE public_token IS NULL
    """)

def downgrade():
    op.drop_index("idx_catalog_items_public_token")
    op.drop_column("catalog_items", "public_token")
```

---

### Backend: New router `public_items.py`

**File:** `backend/app/routers/public_items.py`

```python
"""Public item lookup — no authentication required."""
from __future__ import annotations
from fastapi import APIRouter, HTTPException, status
from fastapi.responses import HTMLResponse, JSONResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends
from app.database import get_db
from app.models.catalog import CatalogItem
from pydantic import BaseModel
from typing import Annotated

router = APIRouter(prefix="/public", tags=["public"])


class PublicItemOut(BaseModel):
    name: str
    item_code: str | None
    current_stock: float
    unit: str | None
    stock_status: str
    last_updated: str | None


@router.get("/item/{public_token}", response_class=HTMLResponse)
async def public_item_page(
    public_token: str,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Returns a branded HTML page — works with any QR scanner without the app."""
    item = await _get_item_by_token(db, public_token)
    if not item:
        return HTMLResponse(content=_not_found_html(), status_code=404)
    return HTMLResponse(content=_item_html(item))


@router.get("/item/{public_token}/json", response_model=PublicItemOut)
async def public_item_json(
    public_token: str,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """Returns JSON for app-based QR scan with full detail for logged-in users."""
    item = await _get_item_by_token(db, public_token)
    if not item:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Item not found")
    return PublicItemOut(
        name=item.name,
        item_code=item.item_code,
        current_stock=float(item.current_stock or 0),
        unit=item.default_unit,
        stock_status=_stock_status(item),
        last_updated=item.last_stock_updated_at.isoformat() if item.last_stock_updated_at else None,
    )


async def _get_item_by_token(db: AsyncSession, token: str) -> CatalogItem | None:
    r = await db.execute(
        select(CatalogItem).where(CatalogItem.public_token == token)
    )
    return r.scalar_one_or_none()


def _stock_status(item: CatalogItem) -> str:
    stock = float(item.current_stock or 0)
    reorder = float(item.reorder_level or 0)
    if stock <= 0:
        return "out_of_stock"
    if stock <= reorder * 0.5:
        return "critical"
    if stock <= reorder:
        return "low"
    return "ok"


def _item_html(item: CatalogItem) -> str:
    stock = float(item.current_stock or 0)
    status = _stock_status(item)
    status_color = {
        "out_of_stock": "#dc2626",
        "critical": "#ea580c",
        "low": "#d97706",
        "ok": "#16a34a",
    }.get(status, "#6b7280")
    status_label = {
        "out_of_stock": "OUT OF STOCK",
        "critical": "CRITICALLY LOW",
        "low": "LOW STOCK",
        "ok": "IN STOCK",
    }.get(status, "UNKNOWN")
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{item.name} — Harisree Warehouse</title>
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
           margin: 0; background: #f8fafc; min-height: 100vh;
           display: flex; align-items: center; justify-content: center; }}
    .card {{ background: white; border-radius: 16px; padding: 32px;
             max-width: 380px; width: 90%; box-shadow: 0 4px 24px rgba(0,0,0,.08); }}
    .brand {{ font-size: 13px; color: #64748b; margin-bottom: 20px; font-weight: 500; }}
    .name {{ font-size: 22px; font-weight: 700; color: #0f172a; margin-bottom: 4px; }}
    .code {{ font-size: 13px; color: #64748b; margin-bottom: 24px; }}
    .stock-row {{ display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }}
    .stock-val {{ font-size: 40px; font-weight: 800; color: #0f172a; }}
    .stock-unit {{ font-size: 16px; color: #64748b; font-weight: 500; }}
    .badge {{ display: inline-block; padding: 4px 10px; border-radius: 99px;
              font-size: 12px; font-weight: 700; color: white;
              background: {status_color}; }}
    .divider {{ height: 1px; background: #e2e8f0; margin: 20px 0; }}
    .login-btn {{ display: block; text-align: center; background: #14532d;
                  color: white; padding: 12px; border-radius: 10px;
                  text-decoration: none; font-weight: 600; font-size: 15px; }}
    .footer {{ margin-top: 20px; font-size: 11px; color: #94a3b8; text-align: center; }}
  </style>
</head>
<body>
  <div class="card">
    <div class="brand">🏭 Harisree Warehouse</div>
    <div class="name">{item.name}</div>
    <div class="code">#{item.item_code or '—'}</div>
    <div class="stock-row">
      <div class="stock-val">{int(stock) if stock == int(stock) else stock}</div>
      <div class="stock-unit">{item.default_unit or 'units'}</div>
    </div>
    <span class="badge">{status_label}</span>
    <div class="divider"></div>
    <a href="/login?redirect=item/{item.public_token}" class="login-btn">
      Log in to update stock →
    </a>
    <div class="footer">Scan this QR to check stock anytime.</div>
  </div>
</body>
</html>"""


def _not_found_html() -> str:
    return """<!DOCTYPE html><html><body style="font-family:sans-serif;text-align:center;padding:40px">
<h2>Item not found</h2><p>This QR code is not linked to any item.</p></body></html>"""
```

### Register in `main.py`:
```python
from app.routers import public_items
app.include_router(public_items.router)
```

---

### Backend: Generate public tokens for all existing items

Add a management endpoint (owner only) or run via Alembic migration:
```python
# In stock.py or a new admin endpoint:
@router.post("/generate-public-tokens", status_code=204)
async def generate_missing_public_tokens(
    business_id: uuid.UUID,
    db: ...,
    _m: require_role("owner"),
):
    """One-time: generates public_token for any item missing one."""
    await db.execute(text("""
        UPDATE catalog_items 
        SET public_token = encode(gen_random_bytes(16), 'hex')
        WHERE business_id = :bid AND public_token IS NULL
    """), {"bid": str(business_id)})
    await db.commit()
```

---

### Flutter: Show public QR code in item detail / barcode label

**File:** `flutter_app/lib/features/barcode/presentation/` (barcode label widgets)

When generating the barcode label PDF, also include a QR code that points to the public URL:

```dart
// In the label generation code:
final publicToken = item['public_token']?.toString();
if (publicToken != null && publicToken.isNotEmpty) {
  final publicUrl = 'https://yourapp.com/item/$publicToken';
  // Render QR code using qr_flutter package:
  // pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: publicUrl)
}
```

In `BarcodeLabelOut` schema (backend), add:
```python
public_token: str | None = None
```

And populate it in `_barcode_label()` in `stock.py`.

---

## VERIFICATION CHECKLIST

- [ ] Scan response time < 1 second on WiFi (measure with DevTools network tab)
- [ ] Camera stays alive during barcode lookup (no black screen flash)
- [ ] Loading overlay shows during API call
- [ ] Debounce fires at 800 ms, not 1500 ms
- [ ] `DetectionSpeed.noDuplicates` set in both web and native camera init
- [ ] `GET /public/item/{token}` returns HTML page without auth
- [ ] HTML page shows item name, current stock, status badge
- [ ] Unknown token returns 404 HTML page (not JSON 404)
- [ ] `GET /public/item/{token}/json` returns JSON without auth
- [ ] Index on `catalog_items.barcode` exists in production DB
- [ ] Index on `catalog_items.public_token` exists in production DB
