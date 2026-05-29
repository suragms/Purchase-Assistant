import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/hexa_operational_tokens.dart';
import '../../../../core/design_system/hexa_responsive.dart';
import '../../../../core/providers/stock_providers.dart';

/// Compact horizontal status filters: All, Low, Out, Missing Code, Missing Barcode.
class StockStatusChipRow extends ConsumerWidget {
  const StockStatusChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(stockStatusCountsProvider);
    final q = ref.watch(stockListQueryProvider);
    final op = ref.watch(stockOperationalFiltersProvider);

    return countsAsync.when(
      loading: () => const SizedBox(height: 36),
      error: (_, __) => const SizedBox.shrink(),
      data: (counts) {
        void applyStatus(String status) {
          ref.read(stockListQueryProvider.notifier).state = q.copyWith(
            status: status,
            page: 1,
          );
          ref.read(stockOperationalFiltersProvider.notifier).state =
              const StockOperationalFilters();
          ref.invalidate(stockListProvider);
        }

        void applyMissingCode() {
          ref.read(stockListQueryProvider.notifier).state =
              q.copyWith(status: 'all', page: 1);
          ref.read(stockOperationalFiltersProvider.notifier).state = op
              .copyWith(missingItemCodeOnly: true, clearMissingItemCode: false);
          ref.invalidate(stockListProvider);
        }

        void applyMissingBarcode() {
          ref.read(stockListQueryProvider.notifier).state =
              q.copyWith(status: 'all', page: 1);
          ref.read(stockOperationalFiltersProvider.notifier).state =
              op.copyWith(missingBarcodeOnly: true);
          ref.invalidate(stockListProvider);
        }

        final chips = <({String label, bool selected, VoidCallback onTap})>[
          (
            label: 'All',
            selected: q.status == 'all' &&
                !op.missingBarcodeOnly &&
                !op.missingItemCodeOnly,
            onTap: () => applyStatus('all'),
          ),
          (
            label: 'Low',
            selected: q.status == 'low',
            onTap: () => applyStatus('low'),
          ),
          (
            label: 'Out',
            selected: q.status == 'out',
            onTap: () => applyStatus('out'),
          ),
          (
            label: 'Missing Code',
            selected: op.missingItemCodeOnly,
            onTap: applyMissingCode,
          ),
          (
            label: 'Missing Barcode',
            selected: op.missingBarcodeOnly,
            onTap: applyMissingBarcode,
          ),
        ];

        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: HexaResponsive.pageGutter(context, operational: true),
            ),
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (ctx, i) {
              final c = chips[i];
              final countKey = switch (i) {
                0 => 'all',
                1 => 'low',
                2 => 'out',
                3 => 'missing_code',
                4 => 'missing_barcode',
                _ => 'all',
              };
              final n = counts[countKey] ?? 0;
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: HexaOp.touchTargetMin,
                ),
                child: FilterChip(
                  label: Text('${c.label} ($n)'),
                  selected: c.selected,
                  onSelected: (_) => c.onTap(),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
