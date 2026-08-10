import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/session_notifier.dart';
import '../../../../core/design_system/desktop_detail_chrome.dart';
import '../../../../core/models/trade_purchase_models.dart';
import '../../../../core/router/post_auth_route.dart' show sessionCanSeeFinancials;
import '../../../../core/theme/hexa_colors.dart';
import '../../../../core/widgets/list_skeleton.dart';
import '../../../../shared/widgets/hexa_empty_state.dart';
import '../../providers/trade_purchase_detail_provider.dart'
    show
        tradePurchaseDetailProvider,
        tradePurchaseDeliveryOptimisticProvider;
import '../purchase_detail_page.dart';

/// Desktop purchase history right pane — embeds [PurchaseDetailBody].
class PurchaseDesktopDetailPane extends ConsumerWidget {
  const PurchaseDesktopDetailPane({
    super.key,
    required this.purchaseId,
    this.seedPurchase,
  });

  final String? purchaseId;
  final TradePurchase? seedPurchase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (purchaseId == null || purchaseId!.isEmpty) {
      return const ColoredBox(
        color: HexaColors.panelWarm,
        child: PurchaseDesktopDetailEmptySelection(),
      );
    }
    final async = ref.watch(tradePurchaseDetailProvider(purchaseId!));
    final seedOk =
        seedPurchase != null && seedPurchase!.id == purchaseId;
    final session = ref.watch(sessionProvider);
    final hideFinancials =
        session != null && !sessionCanSeeFinancials(session);
    final optim = ref.watch(
      tradePurchaseDeliveryOptimisticProvider(purchaseId!),
    );

    Widget paneFor(TradePurchase p) {
      return DesktopDetailPaneScaffold(
        header: Text(
          p.supplierName?.trim().isNotEmpty == true
              ? p.supplierName!
              : (p.invoiceNumber?.trim().isNotEmpty == true
                  ? p.invoiceNumber!
                  : 'Purchase'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        bodyTitle: 'Bill detail',
        body: PurchaseDetailBody(
          p: p,
          hideFinancials: hideFinancials,
          embedded: true,
        ),
      );
    }

    return ColoredBox(
      color: HexaColors.panelWarm,
      child: async.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        loading: () {
          if (seedOk) {
            final p = optim == null
                ? seedPurchase!
                : seedPurchase!.withDelivered(optim);
            return paneFor(p);
          }
          return const Center(child: ListSkeleton());
        },
        error: (e, _) => PurchaseDesktopDetailLoadError(
          onRetry: () =>
              ref.invalidate(tradePurchaseDetailProvider(purchaseId!)),
        ),
        data: (p) {
          final displayP = optim == null ? p : p.withDelivered(optim);
          return paneFor(displayP);
        },
      ),
    );
  }
}

/// Desktop purchase detail pane load failure.
@visibleForTesting
class PurchaseDesktopDetailLoadError extends StatelessWidget {
  const PurchaseDesktopDetailLoadError({
    super.key,
    required this.onRetry,
    this.title = 'Could not load purchase',
    this.subtitle = 'Check your connection, then retry.',
  });

  final VoidCallback onRetry;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.receipt_long_outlined,
      title: title,
      subtitle: subtitle,
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}

/// Desktop master-detail empty right pane when no purchase row is selected.
@visibleForTesting
class PurchaseDesktopDetailEmptySelection extends StatelessWidget {
  const PurchaseDesktopDetailEmptySelection({super.key});

  @override
  Widget build(BuildContext context) {
    return const HexaEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Select a purchase',
      subtitle:
          'Choose a row on the left to see bill detail and delivery status.',
    );
  }
}
