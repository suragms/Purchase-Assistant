import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/purchase_damage_reports_provider.dart';

class PurchaseDetailDamageSection extends ConsumerStatefulWidget {
  const PurchaseDetailDamageSection({
    super.key,
    required this.purchaseId,
    this.canReport = false,
    this.onReport,
  });

  final String purchaseId;
  final bool canReport;
  final VoidCallback? onReport;

  @override
  ConsumerState<PurchaseDetailDamageSection> createState() =>
      _PurchaseDetailDamageSectionState();
}

class _PurchaseDetailDamageSectionState
    extends ConsumerState<PurchaseDetailDamageSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final reportsAsync =
        ref.watch(purchaseDamageReportsProvider(widget.purchaseId));
    final count = reportsAsync.valueOrNull?.length ?? 0;

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        title: Text(
          'Damage / returns${count > 0 ? ' ($count)' : ''}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        children: [
          if (widget.canReport && widget.onReport != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: widget.onReport,
                  icon: const Icon(Icons.report_outlined, size: 18),
                  label: const Text('Report damage'),
                ),
              ),
            ),
          ],
          reportsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Could not load damage reports'),
            ),
            data: (rows) {
              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'No damage or short-delivery reports for this purchase.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                );
              }
              return Column(
                children: [
                  for (final r in rows) _DamageReportRow(report: r),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DamageReportRow extends StatelessWidget {
  const _DamageReportRow({required this.report});

  final Map<String, dynamic> report;

  static String _typeLabel(String t) {
    switch (t) {
      case 'short':
        return 'Short';
      case 'missing':
        return 'Missing';
      case 'returned':
        return 'Returned';
      default:
        return 'Damaged';
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = report['damage_type']?.toString() ?? 'damaged';
    final item = report['item_name']?.toString() ?? 'Item';
    final qty = report['qty_damaged'];
    final by = report['reported_by']?.toString();
    DateTime? at;
    try {
      at = DateTime.parse(report['created_at']?.toString() ?? '');
    } catch (_) {}

    return ListTile(
      dense: true,
      leading: Chip(
        label: Text(
          _typeLabel(type),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      ),
      title: Text(item, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        [
          if (qty != null) 'Qty $qty',
          if (by != null && by.isNotEmpty) 'By $by',
          if (at != null) DateFormat('d MMM, h:mm a').format(at.toLocal()),
        ].join(' · '),
      ),
    );
  }
}
