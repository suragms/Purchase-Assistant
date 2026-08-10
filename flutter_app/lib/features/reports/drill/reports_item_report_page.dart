import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_error_messages.dart';
import '../../../core/providers/reports_item_bundle_provider.dart';
import '../../../core/theme/hexa_colors.dart';
import '../../../shared/widgets/hexa_empty_state.dart';
import 'reports_breadcrumb_bar.dart';
import '../presentation/reports_item_detail_page.dart';
import 'widgets/reports_item_report_body.dart';

/// Reports drill-down: item properties + period purchases (backend SSOT).
class ReportsItemReportPage extends ConsumerStatefulWidget {
  const ReportsItemReportPage({
    super.key,
    required this.catalogItemId,
    this.itemName,
  });

  final String catalogItemId;
  final String? itemName;

  @override
  ConsumerState<ReportsItemReportPage> createState() =>
      _ReportsItemReportPageState();
}

class _ReportsItemReportPageState extends ConsumerState<ReportsItemReportPage> {
  bool _autoRetried = false;
  bool _manualRetry = false;

  void _retryBundle() {
    setState(() => _manualRetry = true);
    ref.invalidate(reportsItemBundleProvider(widget.catalogItemId));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      reportsItemBundleProvider(widget.catalogItemId),
      (prev, next) {
        if (next.hasError &&
            !_autoRetried &&
            !_manualRetry &&
            mounted) {
          setState(() => _autoRetried = true);
          ref.invalidate(reportsItemBundleProvider(widget.catalogItemId));
        }
      },
    );

    final bundleAsync =
        ref.watch(reportsItemBundleProvider(widget.catalogItemId));

    return Scaffold(
      backgroundColor: HexaColors.brandBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/reports?tab=items');
            }
          },
        ),
        title: bundleAsync.maybeWhen(
          data: (b) {
            final rawName = b['item_name'];
            final nameStr = rawName?.toString().trim();
            return Text(
              (nameStr != null && nameStr.isNotEmpty)
                  ? nameStr
                  : (widget.itemName ?? 'Item'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
          orElse: () => Text(
            widget.itemName ?? 'Item',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        backgroundColor: HexaColors.brandBackground,
        foregroundColor: HexaColors.brandPrimary,
      ),
      body: bundleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ReportsItemReportLoadError(
          subtitle: friendlyApiError(e),
          onRetry: _retryBundle,
        ),
        data: (bundle) {
          final rawName = bundle['item_name'];
          final nameStr = rawName?.toString().trim();
          final displayName =
              (nameStr != null && nameStr.isNotEmpty)
                  ? nameStr
                  : (widget.itemName ?? 'Item');
          final item = Map<String, dynamic>.from(
            bundle['item'] as Map? ?? const {},
          );
          final summary = Map<String, dynamic>.from(
            bundle['summary'] as Map? ?? const {},
          );
          final lines = (bundle['lines'] as List?)
                  ?.whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList() ??
              const <Map<String, dynamic>>[];

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              ReportsBreadcrumbBar(
                segments: [
                  ('Reports', '/reports?tab=items'),
                  (displayName, null),
                ],
              ),
              ReportsItemSnapshotCard(item: item),
              ReportsItemPeriodStrip(summary: summary, item: item),
              ReportsItemActionBar(catalogItemId: widget.catalogItemId),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Text(
                  'Purchase history (${lines.length})',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
              if (lines.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: HexaEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No purchases in this period',
                    subtitle:
                        'Change the date range on Reports, or pick another item.',
                    primaryActionLabel: 'Back to Reports',
                    onPrimaryAction: () => context.go('/reports?tab=items'),
                  ),
                )
              else
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < lines.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: HexaColors.brandPrimary.withValues(alpha: 0.06),
                          ),
                        ReportsItemPurchaseLineTile(line: lines[i]),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Reports item drill-down bundle load failure (UX-150).
@visibleForTesting
class ReportsItemReportLoadError extends StatelessWidget {
  const ReportsItemReportLoadError({
    super.key,
    required this.onRetry,
    this.subtitle,
  });

  final VoidCallback onRetry;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.assessment_outlined,
      title: 'Could not load item report',
      subtitle: subtitle ?? 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}

/// Fallback when catalog id unknown — delegates to legacy detail page.
class ReportsItemReportFallbackPage extends ConsumerWidget {
  const ReportsItemReportFallbackPage({
    super.key,
    required this.itemKey,
    required this.itemName,
  });

  final String itemKey;
  final String itemName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReportsItemDetailPage(itemKey: itemKey, itemName: itemName);
  }
}
