import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/home_breakdown_tab_providers.dart';
import '../../../../core/providers/home_owner_dashboard_providers.dart';
import '../../../../shared/widgets/operational_ui.dart';

/// Category + supplier pills from period snapshot (Wrap layout).
class HomeCategoryPills extends ConsumerWidget {
  const HomeCategoryPills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(homeOwnerPeriodDashboardProvider);
    final shellAsync = ref.watch(homeShellReportsProvider);

    final categories = data.categories
        .where((c) => c.categoryName.trim().isNotEmpty)
        .take(6)
        .map((c) => c.categoryName.trim())
        .toList();

    final suppliers = shellAsync.valueOrNull?.suppliers ?? [];
    final supplierLabels = <String>[];
    for (final s in suppliers.take(6)) {
      final name = s['name']?.toString() ?? s['supplier_name']?.toString();
      if (name != null && name.trim().isNotEmpty) {
        supplierLabels.add(name.trim());
      }
    }

    if (categories.isEmpty && supplierLabels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (categories.isNotEmpty)
          OperationalPillWrap(
            labels: ['All', ...categories],
            selected: 'All',
            padding: EdgeInsets.zero,
            onSelected: (label) {
              if (label == 'All') {
                context.push('/home/breakdown-more?tab=category');
              } else {
                context.push('/home/breakdown-more?tab=category');
              }
            },
          ),
        if (supplierLabels.isNotEmpty) ...[
          const SizedBox(height: 8),
          OperationalPillWrap(
            labels: supplierLabels,
            padding: EdgeInsets.zero,
            onSelected: (_) {
              context.push('/home/breakdown-more?tab=supplier');
            },
          ),
        ],
      ],
    );
  }
}
