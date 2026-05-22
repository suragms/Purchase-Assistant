import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/warehouse_alerts_provider.dart';

/// All operational alerts visible at once (owner home).
class HomeMultiAlertStrip extends ConsumerWidget {
  const HomeMultiAlertStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(warehouseAlertsProvider).valueOrNull;
    if (a == null || !a.hasAny) return const SizedBox.shrink();

    final chips = <Widget>[];
    final lowTotal = a.lowStock + a.criticalStock;
    if (lowTotal > 0) {
      chips.add(_chip(
        context,
        '$lowTotal low stock',
        const Color(0xFFBA7517),
        () => context.go('/stock'),
      ));
    }
    if (a.missingUsageLogs > 0) {
      chips.add(_chip(
        context,
        '${a.missingUsageLogs} usage logs missing',
        const Color(0xFFBA7517),
        () => context.push('/operations/usage'),
      ));
    }
    if (a.missingBarcode > 0) {
      chips.add(_chip(
        context,
        '${a.missingBarcode} missing barcode',
        const Color(0xFFA32D2D),
        () => context.push('/stock/missing-barcodes'),
      ));
    }
    if (a.evictionCount > 0) {
      chips.add(_chip(
        context,
        '${a.evictionCount} need eviction',
        const Color(0xFFA32D2D),
        () => context.go('/stock'),
      ));
    }
    if (a.pendingDeliveries > 0) {
      chips.add(_chip(
        context,
        '${a.pendingDeliveries} awaiting delivery',
        const Color(0xFF3B6D11),
        () => context.go('/purchase'),
      ));
    }
    if (a.incompleteChecklist) {
      chips.add(_chip(
        context,
        'Checklist incomplete',
        const Color(0xFFBA7517),
        () => context.push('/operations/checklist'),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ActionChip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.45)),
      onPressed: onTap,
    );
  }
}
