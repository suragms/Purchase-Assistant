import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/providers/stock_providers.dart';
import '../../../core/widgets/friendly_load_error.dart';
import '../../../core/widgets/list_skeleton.dart';

class StockHistoryPage extends ConsumerWidget {
  const StockHistoryPage({super.key, required this.itemId, this.itemName});

  final String itemId;
  final String? itemName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(stockItemAuditProvider(itemId));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(itemName?.trim().isNotEmpty == true ? itemName! : 'Stock history'),
      ),
      body: auditAsync.when(
        loading: () => const ListSkeleton(rowCount: 8),
        error: (e, _) => FriendlyLoadError(
          message: '$e',
          onRetry: () => ref.invalidate(stockItemAuditProvider(itemId)),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: Text(
                'No stock changes recorded yet.',
                style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = rows[i];
              final oldQ = (r['old_qty'] as num?)?.toDouble() ?? 0;
              final newQ = (r['new_qty'] as num?)?.toDouble() ?? 0;
              final diff = newQ - oldQ;
              final isUp = diff > 0;
              final dotColor = diff > 0
                  ? const Color(0xFF2E7D32)
                  : diff < 0
                      ? cs.error
                      : cs.outline;
              final at = DateTime.tryParse(r['updated_at']?.toString() ?? '');
              final timeLabel = at != null
                  ? DateFormat('d MMM yyyy · HH:mm').format(at.toLocal())
                  : '';
              final reason = r['reason']?.toString() ?? r['adjustment_type']?.toString() ?? '';
              final who = r['updated_by_name']?.toString() ?? '';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${isUp ? '+' : ''}${diff == diff.roundToDouble() ? diff.toInt() : diff.toStringAsFixed(2)} '
                              '(${oldQ.toStringAsFixed(0)} → ${newQ.toStringAsFixed(0)})',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            if (reason.isNotEmpty)
                              Text(
                                reason,
                                style: HexaDsType.body(13),
                              ),
                            if (timeLabel.isNotEmpty || who.isNotEmpty)
                              Text(
                                [timeLabel, if (who.isNotEmpty) who].join(' · '),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
