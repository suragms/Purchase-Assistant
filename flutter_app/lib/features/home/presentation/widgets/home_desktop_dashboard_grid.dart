import 'package:flutter/material.dart';

import '../../../../core/design_system/hexa_desktop_layout.dart';
import '../../../../core/design_system/hexa_responsive.dart';
import 'home_low_stock_section.dart';
import 'home_opening_stock_card.dart';
import 'home_out_of_stock_section.dart';
import 'home_owner_tasks_snapshot.dart';
import 'home_purchase_control_center.dart';
import 'home_warehouse_snapshot_card.dart';

/// Owner home dashboard cards in a 2-column grid at ≥ [kDesktopMin].
class HomeDesktopDashboardGrid extends StatelessWidget {
  const HomeDesktopDashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktopLayout) {
      return const _MobileDashboardColumn();
    }
    return DesktopTwoColumnGrid(
      spacing: HexaResponsive.sectionGap(context),
      runSpacing: HexaResponsive.sectionGap(context),
      children: const [
        HomeWarehouseSnapshotCard(),
        HomeOpeningStockCard(),
        HomeLowStockSection(),
        HomePurchaseControlCenter(),
        HomeOutOfStockSection(),
        HomeOwnerTasksSnapshot(),
      ],
    );
  }
}

class _MobileDashboardColumn extends StatelessWidget {
  const _MobileDashboardColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HomeWarehouseSnapshotCard(),
        SizedBox(height: HexaResponsive.sectionGap(context)),
        const HomeOpeningStockCard(),
        SizedBox(height: HexaResponsive.sectionGap(context)),
        const HomeLowStockSection(),
        SizedBox(height: HexaResponsive.sectionGap(context)),
        const HomeOutOfStockSection(),
        SizedBox(height: HexaResponsive.sectionGap(context)),
        const HomePurchaseControlCenter(),
        SizedBox(height: HexaResponsive.sectionGap(context)),
        const HomeOwnerTasksSnapshot(),
      ],
    );
  }
}
