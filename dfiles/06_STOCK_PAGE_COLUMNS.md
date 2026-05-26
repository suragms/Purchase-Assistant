# AGENT PROMPT 06 — STOCK PAGE: PHYSICAL / PURCHASED QTY / DIFFERENCE COLUMNS
**Priority:** HIGH — core warehouse tracking feature.

---

## WHAT THE CLIENT WANTS

Each row in the stock list must show:
- **Physical Stock** = what staff counted physically in the warehouse (entered via "Update Physical Count")
- **Purchased Qty** = total qty purchased in the current period (already in `period_purchased_qty` from API)
- **Difference** = Physical Stock − Purchased Qty (negative = shortage, positive = surplus)

Below each row (on mobile) in **red text**, show:
```
Purchased this period: 100 bags | Diff: -10 bags
```

On desktop/tablet, show as separate columns:
```
| Item | Physical Stock | Purchased Qty | Diff |
```

---

## BACKEND CHANGES

### Add `physical_stock` to `StockListItemOut` schema

**File:** `backend/app/schemas/stock.py`

Add these fields to `StockListItemOut`:
```python
class StockListItemOut(BaseModel):
    # ... existing fields ...
    physical_stock: Decimal | None = None           # ← ADD: last physical count entered by staff
    physical_stock_entered_at: datetime | None = None   # ← ADD: when it was entered
    physical_stock_entered_by: str | None = None    # ← ADD: who entered it
    physical_vs_purchased_diff: Decimal | None = None   # ← ADD: physical - purchased
```

### Add `physical_stock_entries` table (migration 034)

**File:** `backend/alembic/versions/034_physical_stock_entries.py`
```python
from alembic import op
import sqlalchemy as sa

revision = "034"
down_revision = "033"

def upgrade():
    op.create_table(
        "physical_stock_entries",
        sa.Column("id", sa.UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("business_id", sa.UUID(as_uuid=True), sa.ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False),
        sa.Column("catalog_item_id", sa.UUID(as_uuid=True), sa.ForeignKey("catalog_items.id", ondelete="CASCADE"), nullable=False),
        sa.Column("physical_qty", sa.Numeric(14, 3), nullable=False),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("entered_by", sa.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("entered_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
    )
    op.create_index("idx_pse_biz_item", "physical_stock_entries", ["business_id", "catalog_item_id"])
    op.create_index("idx_pse_entered_at", "physical_stock_entries", ["entered_at"])

def downgrade():
    op.drop_table("physical_stock_entries")
```

### Add SQLAlchemy model

**File:** `backend/app/models/physical_stock_entry.py`
```python
from __future__ import annotations
import uuid
from datetime import datetime
from sqlalchemy import DateTime, ForeignKey, Numeric, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import Base

class PhysicalStockEntry(Base):
    __tablename__ = "physical_stock_entries"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    business_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("businesses.id", ondelete="CASCADE"), nullable=False)
    catalog_item_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("catalog_items.id", ondelete="CASCADE"), nullable=False)
    physical_qty: Mapped[float] = mapped_column(Numeric(14, 3), nullable=False)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    entered_by: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), nullable=False)
    entered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
```

### Add to `backend/app/models/__init__.py`:
```python
from .physical_stock_entry import PhysicalStockEntry
```

### Add physical count endpoints in `stock.py`

```python
# POST: staff enters physical count
@router.post("/{item_id}/physical-count", status_code=201)
async def add_physical_count(
    business_id: uuid.UUID,
    item_id: uuid.UUID,
    body: PhysicalCountIn,
    user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    _m: Annotated[Membership, Depends(require_membership)],
):
    entry = PhysicalStockEntry(
        business_id=business_id,
        catalog_item_id=item_id,
        physical_qty=body.physical_qty,
        notes=body.notes,
        entered_by=user.id,
    )
    db.add(entry)
    await db.commit()
    return {"id": str(entry.id), "physical_qty": float(entry.physical_qty)}


# GET: latest physical count for an item
@router.get("/{item_id}/physical-count/latest")
async def latest_physical_count(
    business_id: uuid.UUID,
    item_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    _m: Annotated[Membership, Depends(require_membership)],
):
    r = await db.execute(
        select(PhysicalStockEntry)
        .where(
            PhysicalStockEntry.business_id == business_id,
            PhysicalStockEntry.catalog_item_id == item_id,
        )
        .order_by(PhysicalStockEntry.entered_at.desc())
        .limit(1)
    )
    entry = r.scalar_one_or_none()
    if not entry:
        return {"physical_qty": None, "entered_at": None, "entered_by": None}
    return {
        "physical_qty": float(entry.physical_qty),
        "entered_at": entry.entered_at.isoformat(),
    }
```

Pydantic schemas to add in `stock.py` or `schemas/stock.py`:
```python
class PhysicalCountIn(BaseModel):
    physical_qty: Decimal = Field(ge=0)
    notes: str | None = None
```

### Enrich `list_stock` to include physical count

In `backend/app/routers/stock.py`, in the `list_stock` function, after building the stock list rows:

```python
# After existing period_map logic, add physical stock map:
async def _latest_physical_map(
    db: AsyncSession,
    business_id: uuid.UUID,
    item_ids: list[uuid.UUID],
) -> dict[uuid.UUID, dict]:
    """Returns {item_id: {physical_qty, entered_at}} for items with physical counts."""
    if not item_ids:
        return {}
    # Subquery: latest entry per item
    subq = (
        select(
            PhysicalStockEntry.catalog_item_id,
            func.max(PhysicalStockEntry.entered_at).label("max_at"),
        )
        .where(
            PhysicalStockEntry.business_id == business_id,
            PhysicalStockEntry.catalog_item_id.in_(item_ids),
        )
        .group_by(PhysicalStockEntry.catalog_item_id)
        .subquery()
    )
    r = await db.execute(
        select(PhysicalStockEntry)
        .join(subq, (PhysicalStockEntry.catalog_item_id == subq.c.catalog_item_id) &
                    (PhysicalStockEntry.entered_at == subq.c.max_at))
    )
    result = {}
    for entry in r.scalars().all():
        result[entry.catalog_item_id] = {
            "physical_qty": float(entry.physical_qty),
            "entered_at": entry.entered_at.isoformat(),
        }
    return result
```

Then in `_item_to_list_row()`, add:
```python
def _item_to_list_row(item, ..., physical_data: dict | None = None, ...):
    physical_qty = None
    physical_diff = None
    if physical_data:
        pq = physical_data.get("physical_qty")
        if pq is not None:
            physical_qty = Decimal(str(pq))
            if period_purchased_qty is not None:
                physical_diff = physical_qty - period_purchased_qty
    return StockListItemOut(
        ...
        physical_stock=physical_qty,
        physical_vs_purchased_diff=physical_diff,
        ...
    )
```

---

## FLUTTER CHANGES

### Mobile layout: sub-row under each item

**File:** `flutter_app/lib/features/stock/presentation/widgets/stock_table_row.dart`

Replace or extend the existing row widget to add a sub-row on mobile:

```dart
class StockTableRow extends StatelessWidget {
  const StockTableRow({super.key, required this.item, this.onTap});
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentStock = _asDecimal(item['current_stock']);
    final purchasedQty = _asDecimal(item['period_purchased_qty']);
    final physicalStock = _asDecimal(item['physical_stock']);
    final diff = _asDecimal(item['physical_vs_purchased_diff']);
    final unit = item['unit']?.toString() ?? '';
    final name = item['name']?.toString() ?? '—';
    final code = item['item_code']?.toString();
    final hasDiff = diff != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (code != null)
                          Text(
                            '#$code',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_fmt(physicalStock ?? currentStock)} $unit',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        physicalStock != null ? 'physical' : 'on record',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
              // Sub-row: purchased qty + difference
              if (purchasedQty != null && purchasedQty > Decimal.zero) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Purchased: ${_fmt(purchasedQty)} $unit',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (hasDiff) ...[
                      const Text('  |  ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        'Diff: ${diff! >= Decimal.zero ? '+' : ''}${_fmt(diff)} $unit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: diff < Decimal.zero
                              ? Colors.red.shade700
                              : diff > Decimal.zero
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(Decimal? v) {
    if (v == null) return '0';
    return v == v.truncate() ? v.truncate().toString() : v.toStringAsFixed(1);
  }

  Decimal? _asDecimal(dynamic v) {
    if (v == null) return null;
    try { return Decimal.parse(v.toString()); } catch (_) { return null; }
  }
}
```

### Desktop/Tablet layout: 4-column table

**File:** `flutter_app/lib/features/stock/presentation/stock_page.dart`

Use `LayoutBuilder` to switch between mobile card layout and desktop table:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 768) {
      return _DesktopStockTable(items: items);
    }
    return _MobileStockList(items: items);
  },
)
```

Desktop table header:
```dart
class _StockTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Expanded(flex: 5, child: Text('Item', style: _hdr)),
          const SizedBox(width: 110, child: Text('Physical', style: _hdr, textAlign: TextAlign.end)),
          const SizedBox(width: 110, child: Text('Purchased Qty', style: _hdr, textAlign: TextAlign.end)),
          const SizedBox(width: 90, child: Text('Diff', style: _hdr, textAlign: TextAlign.end)),
          const SizedBox(width: 60),  // actions column
        ],
      ),
    );
  }
  static const _hdr = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey);
}
```

Desktop table row:
```dart
class _DesktopStockRow extends StatelessWidget {
  const _DesktopStockRow({required this.item, this.onTap, this.onPhysicalCount});
  final Map<String, dynamic> item;
  final VoidCallback? onTap;
  final VoidCallback? onPhysicalCount;

  @override
  Widget build(BuildContext context) {
    final currentStock = double.tryParse(item['current_stock']?.toString() ?? '') ?? 0;
    final physicalQty = double.tryParse(item['physical_stock']?.toString() ?? '');
    final purchasedQty = double.tryParse(item['period_purchased_qty']?.toString() ?? '');
    final diff = double.tryParse(item['physical_vs_purchased_diff']?.toString() ?? '');
    final unit = item['unit']?.toString() ?? '';

    Color diffColor = Colors.grey;
    if (diff != null) {
      diffColor = diff < 0 ? Colors.red.shade700 : diff > 0 ? Colors.orange : Colors.green;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']?.toString() ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  if (item['item_code'] != null)
                    Text(
                      '#${item['item_code']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              child: Text(
                physicalQty != null ? '${_fmt(physicalQty)} $unit' : '${_fmt(currentStock)} $unit',
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 110,
              child: Text(
                purchasedQty != null ? '${_fmt(purchasedQty)} $unit' : '—',
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 90,
              child: Text(
                diff != null ? '${diff >= 0 ? '+' : ''}${_fmt(diff)} $unit' : '—',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: diffColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 60,
              child: IconButton(
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                tooltip: 'Enter physical count',
                onPressed: onPhysicalCount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}
```

---

## BOTTOM SHEET: Update Physical Count

When staff taps a row or the edit icon, show a bottom sheet:

```dart
Future<void> showPhysicalCountSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Map<String, dynamic> item,
}) async {
  final nameCtrl = item['name']?.toString() ?? 'Item';
  final qtyCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final unit = item['unit']?.toString() ?? 'units';
  final currentPhysical = item['physical_stock'];
  if (currentPhysical != null) {
    qtyCtrl.text = currentPhysical.toString();
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Physical Count: $nameCtrl', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Enter how many $unit are physically in warehouse', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: qtyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Physical qty ($unit)',
              border: const OutlineInputBorder(),
              suffixText: unit,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesCtrl,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final qty = double.tryParse(qtyCtrl.text.trim());
                if (qty == null || qty < 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Enter a valid quantity')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                await _submitPhysicalCount(
                  ref: ref,
                  itemId: item['id']?.toString() ?? '',
                  qty: qty,
                  notes: notesCtrl.text.trim(),
                );
              },
              child: const Text('Save Physical Count'),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _submitPhysicalCount({
  required WidgetRef ref,
  required String itemId,
  required double qty,
  required String notes,
}) async {
  final session = ref.read(sessionProvider);
  if (session == null) return;
  try {
    await ref.read(hexaApiProvider).addPhysicalCount(
      businessId: session.primaryBusiness.id,
      itemId: itemId,
      qty: qty,
      notes: notes.isEmpty ? null : notes,
    );
    ref.invalidate(stockListProvider);
  } catch (e) {
    // Show error snackbar
  }
}
```

---

## VERIFICATION CHECKLIST

- [ ] Stock list API returns `physical_stock`, `physical_vs_purchased_diff` fields
- [ ] Mobile stock row shows sub-row with purchased qty + diff in red
- [ ] Negative diff shows in red, zero in green, positive in orange
- [ ] Desktop view shows 4-column table (Item | Physical | Purchased | Diff)
- [ ] Tapping row or edit icon opens physical count bottom sheet
- [ ] Physical count saves to `physical_stock_entries` table
- [ ] Physical count shows in stock list after refresh
- [ ] All text has `overflow: TextOverflow.ellipsis` — no overflow errors
- [ ] Table columns are min-width constrained — no layout overflow on any screen size
