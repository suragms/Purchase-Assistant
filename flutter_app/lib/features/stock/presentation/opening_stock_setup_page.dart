import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/errors/user_facing_errors.dart';
import '../../../core/json_coerce.dart';
import '../../../core/providers/business_aggregates_invalidation.dart';
import '../../../core/providers/stock_providers.dart';
import '../../../core/utils/unit_utils.dart';

final openingStockMissingProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) {
    return {'items': <Map<String, dynamic>>[], 'missing_count': 0};
  }
  return ref
      .read(hexaApiProvider)
      .getMissingOpeningStock(businessId: session.primaryBusiness.id);
});

class OpeningStockSetupPage extends ConsumerWidget {
  const OpeningStockSetupPage({super.key});

  bool _isOwner(session) {
    final role = session?.primaryBusiness.role.toString().toLowerCase() ?? '';
    return role == 'owner' || role == 'admin' || session?.isSuperAdmin == true;
  }

  Future<void> _setOpening(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
  ) async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    if (!_isOwner(session)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only owners can set opening stock.')),
      );
      return;
    }
    final id = item['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final unit =
        (item['stock_unit'] ?? item['unit'] ?? '').toString().toUpperCase();
    final current = coerceToDouble(item['current_stock']);
    final locked = item['opening_stock_locked'] == true;
    final qtyCtrl = TextEditingController(text: formatStockQtyNumber(current));
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locked ? 'Override opening stock?' : 'Set opening stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item['name']?.toString() ?? 'Item',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Opening stock',
                suffixText: unit,
                border: const OutlineInputBorder(),
              ),
            ),
            if (locked) ...[
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Override reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final qty = double.tryParse(qtyCtrl.text.trim().replaceAll(',', ''));
    if (qty == null || !qty.isFinite || qty < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid opening stock.')),
      );
      return;
    }
    try {
      await ref.read(hexaApiProvider).setOpeningStock(
            businessId: session.primaryBusiness.id,
            itemId: id,
            qty: qty,
            override: locked,
            reason: reasonCtrl.text,
          );
      invalidateWarehouseSurfaces(ref);
      ref.invalidate(openingStockMissingProvider);
      ref.invalidate(stockListProvider);
      ref.invalidate(stockStatusCountsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening stock saved.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final isOwner = _isOwner(session);
    final async = ref.watch(openingStockMissingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Opening stock setup')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(userFacingError(e))),
        data: (data) {
          final rows = [
            for (final e in (data['items'] as List? ?? []))
              if (e is Map) Map<String, dynamic>.from(e),
          ];
          final missing = coerceToInt(data['missing_count']);
          if (rows.isEmpty) {
            return const Center(child: Text('Opening stock is complete.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemBuilder: (ctx, i) {
              if (i == 0) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      '$missing items still need opening stock. '
                      'This sets the initial system stock and locks the value.',
                    ),
                  ),
                );
              }
              final item = rows[i - 1];
              final unit =
                  (item['stock_unit'] ?? item['unit'] ?? '').toString();
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: Text(item['name']?.toString() ?? 'Item'),
                subtitle: Text(
                  'Current ${formatStockQtyNumber(coerceToDouble(item['current_stock']))} ${unit.toUpperCase()}',
                ),
                trailing: FilledButton(
                  onPressed:
                      isOwner ? () => _setOpening(context, ref, item) : null,
                  child: const Text('Set'),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: rows.length + 1,
          );
        },
      ),
    );
  }
}
