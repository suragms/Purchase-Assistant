import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/hexa_operational_tokens.dart';
import '../../../../core/json_coerce.dart';
import '../../../../core/providers/home_owner_dashboard_providers.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../../core/providers/stock_audit_providers.dart';
import '../../../../core/theme/hexa_colors.dart';

/// Staff corrections and pending stock approvals.
class HomeStaffOperationsPanel extends ConsumerWidget {
  const HomeStaffOperationsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(stockAuditKpisProvider);
    final feed = ref.watch(homeRecentActivityFeedProvider).valueOrNull ?? [];
    final approvalNotifs = ref
        .watch(mergedNotificationFeedProvider)
        .where((n) => !n.isRead && n.serverKind == 'approval_required')
        .length;

    final pending = kpis.valueOrNull?['pending_approval_count'];
    final pendingN = coerceToInt(pending) + approvalNotifs;
    final staffRows = feed
        .where((i) =>
            i.kind == 'stock_quick_purchase' ||
            i.kind == 'stock' ||
            i.kind == 'stock_adjustment')
        .take(3)
        .toList();

    if (pendingN <= 0 && staffRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(HexaOp.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Staff operations', style: HexaOp.cardTitle(context)),
            if (pendingN > 0) ...[
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.fact_check_outlined, color: HexaColors.brandPrimary),
                title: Text(
                  '$pendingN pending approval${pendingN == 1 ? '' : 's'}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                subtitle: const Text('Stock audits need your review'),
                trailing: FilledButton(
                  onPressed: () => context.push('/barcode/scan-history'),
                  child: const Text('Review'),
                ),
              ),
            ],
            for (final row in staffRows) ...[
              const Divider(height: 1),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(row.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  [row.subtitle, row.actor ?? ''].where((s) => s.isNotEmpty).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
