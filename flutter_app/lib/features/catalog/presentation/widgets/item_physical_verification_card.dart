import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_error_messages.dart';
import '../../../../core/auth/dashboard_role.dart';
import '../../../../core/auth/session_notifier.dart';
import '../../../../core/design_system/hexa_operational_tokens.dart';
import '../../../../core/json_coerce.dart';
import '../../../../core/providers/stock_providers.dart';
import '../../../../core/theme/hexa_colors.dart';

class ItemPhysicalVerificationCard extends ConsumerWidget {
  const ItemPhysicalVerificationCard({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(stockItemDetailProvider(itemId)).valueOrNull ?? const <String, dynamic>{};
    final audit = ref.watch(stockItemAuditProvider(itemId)).valueOrNull ?? const <Map<String, dynamic>>[];
    final session = ref.watch(sessionProvider);
    final canVerify = session != null && sessionHasOwnerDashboard(session);

    final countedAtRaw = stock['physical_stock_counted_at']?.toString();
    final countedAt =
        countedAtRaw != null ? DateTime.tryParse(countedAtRaw)?.toLocal() : null;
    final countedBy = stock['physical_stock_counted_by']?.toString();
    final phys = coerceToDouble(stock['physical_stock_qty']);
    final sys = coerceToDouble(stock['current_stock']);
    final diff = (stock['physical_stock_difference_qty'] as num?)?.toDouble() ?? (phys - sys);
    final unit = (stock['stock_unit'] ?? stock['unit'] ?? '').toString().toUpperCase();

    if (countedAt == null && phys == 0 && diff.abs() < 0.001 && audit.isEmpty) {
      return const SizedBox.shrink();
    }

    final df = DateFormat('dd MMM yyyy • h:mm a');
    final showVerify = canVerify && countedAt != null && diff.abs() > 0.001;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(HexaOp.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Physical stock verification', style: HexaOp.cardTitle(context)),
                ),
                if (showVerify)
                  FilledButton(
                    onPressed: () => _verify(context, ref, phys),
                    child: const Text('Verify'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _kv('Last counted', countedAt != null ? df.format(countedAt) : '—'),
            _kv('Counted by', (countedBy != null && countedBy.trim().isNotEmpty) ? countedBy.trim() : '—'),
            _kv('Physical', '${_fmt(phys)} ${unit.isEmpty ? '' : unit}'.trim()),
            _kv('System', '${_fmt(sys)} ${unit.isEmpty ? '' : unit}'.trim()),
            _kv(
              'Difference',
              '${diff > 0 ? '+' : ''}${_fmt(diff)} ${unit.isEmpty ? '' : unit}'.trim(),
              valueColor: diff.abs() > 0.001 ? const Color(0xFFA32D2D) : const Color(0xFF2E7D32),
            ),
            if (audit.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Recent adjustments', style: HexaOp.caption(context).copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              for (final a in audit.take(3)) ...[
                _auditRow(a),
                const SizedBox(height: 6),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
            ),
          ),
          Text(
            v,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: valueColor ?? HexaColors.textBody),
          ),
        ],
      ),
    );
  }

  Widget _auditRow(Map<String, dynamic> a) {
    final atRaw = a['updated_at']?.toString();
    final at = atRaw != null ? DateTime.tryParse(atRaw)?.toLocal() : null;
    final df = DateFormat('dd MMM • h:mm a');
    final who = a['updated_by_name']?.toString();
    final t = a['adjustment_type']?.toString() ?? 'adjustment';
    final oldQ = _fmt(coerceToDouble(a['old_qty']));
    final newQ = _fmt(coerceToDouble(a['new_qty']));
    return Row(
      children: [
        Expanded(
          child: Text(
            [
              t.toUpperCase(),
              if (who != null && who.trim().isNotEmpty) who.trim(),
              if (at != null) df.format(at),
            ].join(' • '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '$oldQ → $newQ',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Future<void> _verify(BuildContext context, WidgetRef ref, double countedQty) async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    try {
      await ref.read(hexaApiProvider).verifyStockCount(
            businessId: session.primaryBusiness.id,
            itemId: itemId,
            countedQty: countedQty,
            reason: 'Physical count',
          );
      ref.invalidate(stockItemDetailProvider(itemId));
      ref.invalidate(stockItemActivityProvider(itemId));
      ref.invalidate(stockItemAuditProvider(itemId));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Physical count verified')),
      );
    } on DioException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiError(e))),
      );
    }
  }
}

String _fmt(double n) {
  if (!n.isFinite) return '—';
  if (n.abs() < 0.001) return '0';
  final s = n.toStringAsFixed(n.abs() < 1 ? 2 : 0);
  return s.replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'(\.\d*[1-9])0+$'), r'$1');
}

