import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/hexa_ds_tokens.dart';
import '../../../../core/providers/home_owner_dashboard_providers.dart';
import 'home_formatters.dart';

/// Single-row operational status: sync, refresh time, alerts, staff, variances.
class HomeLiveStatusBar extends ConsumerWidget {
  const HomeLiveStatusBar({
    super.key,
    required this.offline,
    required this.lastRefreshedAt,
    this.isOwner = true,
  });

  final bool offline;
  final DateTime? lastRefreshedAt;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOwner) return const SizedBox.shrink();

    final alerts = ref.watch(stockAlertCountsProvider).valueOrNull;
    final low = alerts?.low ?? 0;
    final crit = alerts?.critical ?? 0;
    final staffN = ref.watch(activeSessionsCountProvider).valueOrNull ?? 0;
    final varianceN =
        ref.watch(stockVariancesTodayProvider).valueOrNull?.length ?? 0;
    final ago = homeRefreshAgo(lastRefreshedAt);

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            offline ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
            size: 16,
            color: offline ? const Color(0xFF9E9E9E) : const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              offline
                  ? 'Offline · $ago'
                  : 'Live · $ago · $low low · $crit critical'
                      '${varianceN > 0 ? ' · $varianceN verify' : ''}'
                      '${staffN > 0 ? ' · $staffN staff' : ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HexaDsType.bodySm(context).copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: HexaDsColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
