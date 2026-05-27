import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/hexa_operational_tokens.dart';
import '../../../../core/providers/home_dashboard_provider.dart';
import '../../../../core/providers/home_owner_dashboard_providers.dart';
import '../../../../core/providers/stock_providers.dart';
import '../../../../core/providers/stock_audit_providers.dart';
import '../../../../core/providers/warehouse_alerts_provider.dart';
import '../../domain/warehouse_health.dart';
import 'home_formatters.dart';

/// Warehouse health summary with GOOD / WARNING / CRITICAL badge.
class HomeWarehouseHealthCard extends ConsumerWidget {
  const HomeWarehouseHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = ref.watch(homeInventorySummaryProvider);
    final alerts = ref.watch(stockAlertCountsProvider);
    final warehouse = ref.watch(warehouseAlertsProvider);
    final dash = ref.watch(homeDashboardDataProvider).snapshot.data;
    final status = ref.watch(stockStatusCountsProvider);
    final auditKpis = ref.watch(stockAuditKpisProvider);

    final invData = inv.valueOrNull ?? HomeInventorySummary.empty;
    final alertData = alerts.valueOrNull;
    final wh = warehouse.valueOrNull;
    final statusMap = status.valueOrNull ?? const {};
    final pendingApproval = auditKpis.valueOrNull?['pending_approval_count'];
    final pendingN = pendingApproval is num ? pendingApproval.toInt() : 0;

    final low = alertData?.low ?? 0;
    final critical = alertData?.critical ?? 0;
    final mismatch = wh?.pendingVerifications ?? 0;
    final negative = dash.negativeStockCount > 0
        ? dash.negativeStockCount
        : (statusMap['negative'] as num?)?.toInt() ?? 0;
    final pendingDel = dash.pendingDeliveryCount;

    final level = computeWarehouseHealth(
      WarehouseHealthInput(
        criticalStock: critical,
        lowStock: low,
        mismatchCount: mismatch,
        negativeStock: negative,
        pendingDeliveries: pendingDel,
        pendingApprovals: pendingN,
      ),
    );

    final badgeColor = switch (level) {
      WarehouseHealthLevel.good => const Color(0xFF2E7D32),
      WarehouseHealthLevel.warning => const Color(0xFFB45309),
      WarehouseHealthLevel.critical => const Color(0xFFA32D2D),
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.go('/stock'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(HexaOp.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Warehouse health', style: HexaOp.cardTitle(context)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: badgeColor, width: 1.5),
                    ),
                    child: Text(
                      warehouseHealthLabel(level),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _stat('Stock value', homeInr(invData.totalValueInr)),
                  _stat('Items', '${invData.itemCount}'),
                  _stat('Bills', '${dash.purchaseCount}'),
                ],
              ),
              if (negative > 0 || mismatch > 0 || low + critical > 0) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (low + critical > 0)
                      _pill('Low/critical: ${low + critical}'),
                    if (mismatch > 0) _pill('Mismatch: $mismatch'),
                    if (negative > 0) _pill('Negative: $negative'),
                    if (pendingDel > 0) _pill('Pending delivery: $pendingDel'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _pill(String t) => Chip(
        label: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
}
