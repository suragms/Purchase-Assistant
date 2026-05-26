# AGENT PROMPT 07 — OPENING STOCK SETUP + PHYSICAL STOCK ENTRY FLOW
**Priority:** HIGH — required before going live so staff can set initial stock levels.

---

## BUSINESS RULES (memorize these)

1. **Opening stock** = the quantity of each item in the warehouse on the day the app goes live. Set ONCE per item, never automatically updated.
2. Only **owner** can set or override opening stock. Staff can enter it the first time if the owner delegates, but owner must confirm.
3. Once set, opening stock is **locked** — only owner can override.
4. Opening stock appears in the **ledger** as the starting row: `Opening Stock: 500 bags on [date]`.
5. **Physical stock** = what staff physically counts any day. Separate from opening stock.
6. Difference shown in stock list = `physical_stock_qty − period_purchased_qty`.
7. When staff scans a barcode AND the item has no opening stock set → prompt to enter opening stock first.

---

## BACKEND: Opening Stock

### Migration (add to existing catalog_items table)

**File:** `backend/alembic/versions/035_opening_stock_fields.py`
```python
from alembic import op
import sqlalchemy as sa

revision = "035"
down_revision = "034"

def upgrade():
    op.add_column("catalog_items", sa.Column("opening_stock", sa.Numeric(14, 3), nullable=True))
    op.add_column("catalog_items", sa.Column("opening_stock_date", sa.DateTime(timezone=True), nullable=True))
    op.add_column("catalog_items", sa.Column("opening_stock_set_by", sa.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=True))
    op.add_column("catalog_items", sa.Column("opening_stock_locked", sa.Boolean, server_default="false", nullable=False))

def downgrade():
    op.drop_column("catalog_items", "opening_stock_locked")
    op.drop_column("catalog_items", "opening_stock_set_by")
    op.drop_column("catalog_items", "opening_stock_date")
    op.drop_column("catalog_items", "opening_stock")
```

### API endpoint: Set opening stock

**File:** `backend/app/routers/stock.py` (add new endpoint)

```python
class OpeningStockIn(BaseModel):
    opening_stock: Decimal = Field(ge=0)
    opening_stock_date: date | None = None
    force_override: bool = False  # Owner can override locked opening stock


@router.post("/{item_id}/opening-stock", status_code=201)
async def set_opening_stock(
    business_id: uuid.UUID,
    item_id: uuid.UUID,
    body: OpeningStockIn,
    user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    _m: Annotated[Membership, Depends(require_membership)],
):
    """Set opening stock for an item. Owner can set/override; staff can only set if not yet locked."""
    is_owner = _m.role in ("owner", "super_admin", "manager")
    
    r = await db.execute(
        select(CatalogItem).where(
            CatalogItem.id == item_id,
            CatalogItem.business_id == business_id,
        )
    )
    item = r.scalar_one_or_none()
    if not item:
        raise HTTPException(404, "Item not found")
    
    # Staff cannot override a locked opening stock
    if item.opening_stock_locked and not is_owner:
        raise HTTPException(403, "Opening stock is locked. Only owner can override.")
    
    # Staff cannot force_override
    if body.force_override and not is_owner:
        raise HTTPException(403, "Only owner can force override opening stock.")
    
    # If already set and not force_override, reject
    if item.opening_stock is not None and not body.force_override:
        raise HTTPException(409, "Opening stock already set. Use force_override=true (owner only).")
    
    from datetime import datetime, timezone
    set_date = (
        datetime.combine(body.opening_stock_date, datetime.min.time(), tzinfo=timezone.utc)
        if body.opening_stock_date
        else datetime.now(timezone.utc)
    )
    
    old_qty = item.current_stock or Decimal("0")
    item.opening_stock = body.opening_stock
    item.opening_stock_date = set_date
    item.opening_stock_set_by = user.id
    item.opening_stock_locked = True  # Lock after first set
    
    # Also update current_stock to opening_stock if current_stock is 0 (new item)
    if item.current_stock is None or item.current_stock == Decimal("0"):
        item.current_stock = body.opening_stock
        # Log as opening_stock adjustment
        adj = StockAdjustment(
            business_id=business_id,
            catalog_item_id=item_id,
            old_qty=old_qty,
            new_qty=body.opening_stock,
            adjustment_type="opening_stock",
            reason="Opening stock setup",
            updated_by=user.id,
        )
        db.add(adj)
    
    await db.commit()
    return {"opening_stock": float(item.opening_stock), "locked": item.opening_stock_locked}
```

### API endpoint: List items missing opening stock

```python
@router.get("/missing-opening-stock")
async def items_missing_opening_stock(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    _m: Annotated[Membership, Depends(require_membership)],
    limit: int = Query(100, ge=1, le=500),
):
    """Returns items that have no opening_stock set yet."""
    r = await db.execute(
        select(CatalogItem)
        .where(
            CatalogItem.business_id == business_id,
            CatalogItem.opening_stock.is_(None),
            CatalogItem.archived.is_(False),
        )
        .order_by(CatalogItem.name)
        .limit(limit)
    )
    items = r.scalars().all()
    return [
        {"id": str(i.id), "name": i.name, "item_code": i.item_code, "unit": i.default_unit}
        for i in items
    ]
```

### Update `StockListItemOut` to include opening stock fields

```python
class StockListItemOut(BaseModel):
    # ... existing fields ...
    opening_stock: Decimal | None = None
    opening_stock_date: datetime | None = None
    opening_stock_locked: bool = False
```

---

## FLUTTER: Opening Stock Setup Flow

### App startup banner

**File:** `flutter_app/lib/features/shell/shell_screen.dart` OR `home_page.dart`

Add a banner at the top of the home page if items are missing opening stock:

```dart
class _OpeningStockBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missingCount = ref.watch(missingOpeningStockCountProvider).valueOrNull ?? 0;
    if (missingCount == 0) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$missingCount item(s) need opening stock. Set now →',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/stock/opening-stock-setup'),
            child: const Text('Set Now'),
          ),
        ],
      ),
    );
  }
}
```

### Provider

```dart
// In core/providers/stock_providers.dart
final missingOpeningStockCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return 0;
  final result = await ref.read(hexaApiProvider).listMissingOpeningStock(
    businessId: session.primaryBusiness.id,
  );
  return (result as List).length;
});
```

### Opening Stock Setup Page

**File:** `flutter_app/lib/features/stock/presentation/opening_stock_setup_page.dart`

```dart
class OpeningStockSetupPage extends ConsumerStatefulWidget {
  const OpeningStockSetupPage({super.key});

  @override
  ConsumerState<OpeningStockSetupPage> createState() => _OpeningStockSetupPageState();
}

class _OpeningStockSetupPageState extends ConsumerState<OpeningStockSetupPage> {
  List<Map<String, dynamic>> _items = [];
  final Map<String, TextEditingController> _ctrls = {};
  bool _loading = true;
  bool _saving = false;
  DateTime _openingDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    try {
      final result = await ref.read(hexaApiProvider).listMissingOpeningStock(
        businessId: session.primaryBusiness.id,
      );
      final items = List<Map<String, dynamic>>.from(result as List);
      setState(() {
        _items = items;
        for (final item in items) {
          _ctrls[item['id']] = TextEditingController();
        }
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveAll() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    
    final toSave = <String, double>{};
    for (final item in _items) {
      final id = item['id']?.toString() ?? '';
      final text = _ctrls[id]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      final qty = double.tryParse(text);
      if (qty == null || qty < 0) continue;
      toSave[id] = qty;
    }
    
    if (toSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one opening stock quantity')),
      );
      return;
    }
    
    setState(() => _saving = true);
    int saved = 0;
    int failed = 0;
    
    for (final entry in toSave.entries) {
      try {
        await ref.read(hexaApiProvider).setOpeningStock(
          businessId: session.primaryBusiness.id,
          itemId: entry.key,
          qty: entry.value,
          date: _openingDate,
        );
        saved++;
      } catch (_) {
        failed++;
      }
    }
    
    setState(() => _saving = false);
    ref.invalidate(missingOpeningStockCountProvider);
    ref.invalidate(stockListProvider);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$saved item(s) saved.' +
            (failed > 0 ? ' $failed failed.' : ''),
          ),
          backgroundColor: failed == 0 ? Colors.green : Colors.orange,
        ),
      );
      if (failed == 0) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Opening Stock'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _saveAll,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save All'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('All items have opening stock set ✓'))
              : Column(
                  children: [
                    // Date selector
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('Opening Date: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextButton(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _openingDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (d != null) setState(() => _openingDate = d);
                            },
                            child: Text(
                              '${_openingDate.day}/${_openingDate.month}/${_openingDate.year}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Item list
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          final id = item['id']?.toString() ?? '';
                          final name = item['name']?.toString() ?? '—';
                          final unit = item['unit']?.toString() ?? '';
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    if (item['item_code'] != null)
                                      Text('#${item['item_code']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: _ctrls[id],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.end,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    suffixText: unit,
                                    isDense: true,
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Bottom save button
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveAll,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _saving
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Save Opening Stock', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
```

### Router addition

In `app_router.dart`:
```dart
GoRoute(
  path: '/stock/opening-stock-setup',
  builder: (_, __) => const OpeningStockSetupPage(),
),
GoRoute(
  path: '/stock/opening-stock/:itemId',
  builder: (_, state) => OpeningStockSinglePage(itemId: state.pathParameters['itemId']!),
),
```

---

## FLUTTER: Physical Stock Entry (quick sheet from stock page)

This is covered in Prompt 06 (stock page columns). However, also ensure:

1. From **barcode scan result sheet**, after showing the item, add a "Update Physical Count" button.
2. From **staff home page**, add a quick action card: "Enter Physical Count".

---

## LEDGER DISPLAY (item detail page)

**File:** `flutter_app/lib/features/stock/presentation/stock_item_intelligence_page.dart`

In the item detail / intelligence page, add an "Opening Stock" row at the top of the timeline:

```dart
if (item['opening_stock'] != null) ...[
  _TimelineRow(
    icon: Icons.play_circle_outline,
    iconColor: Colors.indigo,
    title: 'Opening Stock',
    subtitle: '${_fmtQty(item['opening_stock'])} ${item['unit'] ?? ''} · ${_fmtDate(item['opening_stock_date'])}',
    trailing: item['opening_stock_locked'] == true
        ? const Icon(Icons.lock_outline, size: 14, color: Colors.grey)
        : null,
  ),
  const Divider(indent: 48),
],
```

---

## VERIFICATION CHECKLIST

- [ ] Owner sees banner if any item has no opening stock
- [ ] Banner links to opening stock setup page
- [ ] Setup page lists all items without opening stock
- [ ] Staff can enter qty for each item in a list (batch input)
- [ ] "Save All" saves all entered qtys in one go
- [ ] After save, banner disappears
- [ ] Opening stock appears in item detail as first timeline entry
- [ ] Opening stock is locked after first set
- [ ] Owner can override opening stock (with confirmation dialog)
- [ ] Staff cannot override locked opening stock
- [ ] Physical count entry is available from stock list row tap
- [ ] Physical count saves to `physical_stock_entries` table
- [ ] Stock page diff column updates after physical count
