import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/errors/user_facing_errors.dart';
import '../../../core/json_coerce.dart';
import '../../../core/providers/business_aggregates_invalidation.dart';
import '../../../core/providers/stock_providers.dart';
import '../../../core/utils/unit_utils.dart';

class StaffQuickPurchasePage extends ConsumerStatefulWidget {
  const StaffQuickPurchasePage({super.key});

  @override
  ConsumerState<StaffQuickPurchasePage> createState() =>
      _StaffQuickPurchasePageState();
}

class _StaffQuickPurchasePageState
    extends ConsumerState<StaffQuickPurchasePage> {
  final _searchCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  Timer? _debounce;
  bool _saving = false;
  Map<String, dynamic>? _selected;
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
    _searchCtrl.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _itemsFuture = _loadItems());
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _qtyCtrl.dispose();
    _amountCtrl.dispose();
    _supplierCtrl.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadItems() async {
    final session = ref.read(sessionProvider);
    if (session == null) return [];
    final data = await ref.read(hexaApiProvider).listStock(
          businessId: session.primaryBusiness.id,
          q: _searchCtrl.text.trim(),
          perPage: 30,
          sort: 'name',
        );
    return [
      for (final e in (data['items'] as List? ?? []))
        if (e is Map) Map<String, dynamic>.from(e),
    ];
  }

  Future<void> _save() async {
    final session = ref.read(sessionProvider);
    final item = _selected;
    if (session == null || item == null || _saving) return;
    final qty = double.tryParse(_qtyCtrl.text.trim().replaceAll(',', ''));
    if (qty == null || !qty.isFinite || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid quantity.')),
      );
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', ''));
    setState(() => _saving = true);
    try {
      await ref.read(hexaApiProvider).createStaffPurchaseLog(
            businessId: session.primaryBusiness.id,
            itemId: item['id'].toString(),
            qty: qty,
            amount: amount,
            supplierName: _supplierCtrl.text,
          );
      invalidateWarehouseSurfaces(ref);
      ref.invalidate(stockListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cash purchase logged and stock added.')),
      );
      setState(() {
        _selected = null;
        _qtyCtrl.clear();
        _amountCtrl.clear();
        _supplierCtrl.clear();
        _itemsFuture = _loadItems();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final unit = (selected?['stock_unit'] ?? selected?['unit'] ?? '')
        .toString()
        .toUpperCase();
    return Scaffold(
      appBar: AppBar(title: const Text('Quick cash purchase')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              labelText: 'Search item',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _itemsFuture,
            builder: (context, snap) {
              final items = snap.data ?? const <Map<String, dynamic>>[];
              if (snap.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }
              return Column(
                children: [
                  for (final item in items.take(8))
                    ListTile(
                      selected:
                          selected?['id']?.toString() == item['id'].toString(),
                      onTap: () => setState(() => _selected = item),
                      leading: Icon(
                        selected?['id']?.toString() == item['id'].toString()
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      title: Text(item['name']?.toString() ?? 'Item'),
                      subtitle: Text(
                        'Stock ${formatStockQtyNumber(coerceToDouble(item['current_stock']))} '
                        '${(item['stock_unit'] ?? item['unit'] ?? '').toString().toUpperCase()}',
                      ),
                    ),
                ],
              );
            },
          ),
          const Divider(height: 28),
          TextField(
            controller: _qtyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Purchased quantity',
              suffixText: unit,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount paid (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _supplierCtrl,
            decoration: const InputDecoration(
              labelText: 'Supplier/shop (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: selected == null || _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Log purchase and add stock'),
          ),
        ],
      ),
    );
  }
}
