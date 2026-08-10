import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/json_coerce.dart';
import '../../../core/providers/staff_home_providers.dart';
import '../../../core/providers/stock_audit_providers.dart';
import '../../../core/theme/hexa_colors.dart';
import '../../../shared/widgets/hexa_empty_state.dart';

/// Recent scans + server activity for warehouse accountability.
class BarcodeScanHistoryPage extends ConsumerWidget {
  const BarcodeScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final recentAsync = ref.watch(staffRecentScansProvider);
    final kpis = ref.watch(stockAuditKpisProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan history')),
      body: session == null
          ? const HexaEmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Sign in required',
              subtitle: 'Sign in to see recent barcode scans on this device.',
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                kpis.when(
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (_, __) => BarcodeScanHistoryAuditKpiError(
                    onRetry: () => ref.invalidate(stockAuditKpisProvider),
                  ),
                  data: (k) {
                    final pending = coerceToInt(k['pending_approval_count']);
                    if (pending <= 0) return const SizedBox.shrink();
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.pending_actions,
                          color: HexaColors.brandPrimary,
                        ),
                        title: Text('$pending pending approval(s)'),
                        subtitle: const Text(
                          'Manager or owner must approve large variances',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Recent on device',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                recentAsync.when(
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (_, __) => BarcodeScanHistoryRecentScansError(
                    onRetry: () => ref.invalidate(staffRecentScansProvider),
                  ),
                  data: (recent) {
                    if (recent.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        child: HexaEmptyState(
                          icon: Icons.qr_code_scanner_outlined,
                          title: 'No recent scans yet',
                          subtitle:
                              'Scan a barcode to start the on-device history.',
                          primaryActionLabel: 'Scan barcode',
                          onPrimaryAction: () =>
                              context.push('/barcode/scan'),
                        ),
                      );
                    }
                    return Column(
                      children: recent
                          .map(
                            (r) => ListTile(
                              dense: true,
                              title: Text(
                                r.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(r.code),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                if (r.id.isNotEmpty) {
                                  context.push('/stock/intelligence/${r.id}');
                                }
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

/// Scan history pending-approval KPI load failure (UX-121).
@visibleForTesting
class BarcodeScanHistoryAuditKpiError extends StatelessWidget {
  const BarcodeScanHistoryAuditKpiError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.pending_actions_outlined,
      title: 'Could not load pending approvals',
      subtitle: 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}

/// Scan history on-device recent list load failure (UX-127).
@visibleForTesting
class BarcodeScanHistoryRecentScansError extends StatelessWidget {
  const BarcodeScanHistoryRecentScansError({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.qr_code_scanner_outlined,
      title: 'Could not load recent scans',
      subtitle: 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}
