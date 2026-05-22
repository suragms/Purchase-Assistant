import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/operations_providers.dart';
import '../../../core/widgets/friendly_load_error.dart';

/// Stock movement reports (no financials): dead / fast / slow stock.
class OperationalReportsSection extends ConsumerWidget {
  const OperationalReportsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(operationalReportsProvider);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => FriendlyLoadError(
            onRetry: () => ref.invalidate(operationalReportsProvider),
          ),
          data: (m) {
            final dead = (m['dead_stock'] as List?)?.length ?? 0;
            final fast = (m['fast_moving'] as List?)?.length ?? 0;
            final slow = (m['slow_moving'] as List?)?.length ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stock operations',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(context, 'Dead stock', dead, const Color(0xFFA32D2D), '/stock/dead'),
                    _chip(context, 'Fast moving', fast, const Color(0xFF3B6D11), '/stock/fast-moving'),
                    _chip(context, 'Slow moving', slow, const Color(0xFFBA7517), '/stock/slow-moving'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, int count, Color color, String route) {
    return ActionChip(
      label: Text('$label ($count)'),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      onPressed: count > 0 ? () => context.push(route) : null,
    );
  }
}
