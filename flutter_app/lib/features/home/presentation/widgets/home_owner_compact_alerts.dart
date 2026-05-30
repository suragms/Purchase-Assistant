import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/hexa_operational_tokens.dart';
import '../../../../core/json_coerce.dart';
import '../../../../core/providers/delivery_pipeline_provider.dart';
import '../../../../core/providers/home_dashboard_provider.dart';
import '../../../../core/providers/stock_providers.dart'
    show openingStockMissingProvider, stockStatusCountsProvider;
import '../../../../core/theme/hexa_colors.dart';

/// Owner home: four compact tappable chips (low · opening · out · pending delivery).
class HomeOwnerCompactAlerts extends ConsumerWidget {
  const HomeOwnerCompactAlerts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(stockStatusCountsProvider).valueOrNull ?? const {};
    final low = coerceToInt(status['low']) + coerceToInt(status['critical']);
    final out = coerceToInt(status['out']);
    final openingN =
        coerceToInt(ref.watch(openingStockMissingProvider).valueOrNull?['missing_count']);
    final pipeline = ref.watch(deliveryPipelineProvider).valueOrNull;
    var pending = deliveryPipelinePendingCount(pipeline);
    if (pending == 0) {
      pending = ref.watch(homeDashboardDataProvider).snapshot.data.pendingDeliveryCount;
    }

    final chips = <_ChipSpec>[
      _ChipSpec(
        label: 'Low stock',
        count: low,
        accent: HexaColors.warning,
        urgent: low > 0,
        onTap: () => context.push('/stock/low-stock'),
      ),
      _ChipSpec(
        label: 'Opening',
        count: openingN,
        accent: const Color(0xFFCA8A04),
        urgent: openingN > 0,
        onTap: () => context.push('/stock/opening-setup'),
      ),
      _ChipSpec(
        label: 'Out',
        count: out,
        accent: const Color(0xFFC62828),
        urgent: out > 0,
        onTap: () => context.go('/stock?status=out'),
      ),
      _ChipSpec(
        label: 'Pending delivery',
        count: pending,
        accent: const Color(0xFFB91C1C),
        urgent: pending > 0,
        filled: pending > 0,
        onTap: () => context.go('/purchase'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Needs attention', style: HexaOp.cardTitle(context)),
        const SizedBox(height: 6),
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _CompactChip(spec: chips[i]),
          ),
        ),
      ],
    );
  }
}

class _ChipSpec {
  const _ChipSpec({
    required this.label,
    required this.count,
    required this.accent,
    required this.onTap,
    this.urgent = false,
    this.filled = false,
  });

  final String label;
  final int count;
  final Color accent;
  final VoidCallback onTap;
  final bool urgent;
  final bool filled;
}

class _CompactChip extends StatelessWidget {
  const _CompactChip({required this.spec});

  final _ChipSpec spec;

  @override
  Widget build(BuildContext context) {
    final bg = spec.filled
        ? spec.accent.withValues(alpha: 0.12)
        : Colors.white;
    final border = spec.urgent
        ? spec.accent.withValues(alpha: 0.65)
        : Colors.grey.shade300;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: spec.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 108,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: spec.filled ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: spec.filled ? spec.accent : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                spec.count > 0 ? '${spec.count}' : '—',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: spec.urgent ? spec.accent : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
