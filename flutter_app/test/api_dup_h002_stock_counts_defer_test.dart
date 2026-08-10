import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/home_dashboard_provider.dart';
import 'package:harisree_warehouse/core/providers/stock_list_providers.dart';
import 'package:harisree_warehouse/core/providers/warehouse_alerts_provider.dart';
import 'package:harisree_warehouse/features/shell/shell_branch_provider.dart';

void main() {
  test(
    'API-DUP-H-002 stockStatusCounts skips alerts while Home overview refreshing',
    () async {
      var alertsCalled = false;
      final container = ProviderContainer(
        overrides: [
          shellCurrentBranchProvider.overrideWith((ref) => ShellBranch.home),
          homeDashboardDataProvider.overrideWith(() => _RefreshingDash()),
          stockAlertsSummaryProvider.overrideWith((ref) async {
            alertsCalled = true;
            return const <String, dynamic>{};
          }),
        ],
      );
      addTearDown(container.dispose);

      final counts = await container.read(stockStatusCountsProvider.future);
      expect(counts, isEmpty);
      expect(alertsCalled, isFalse);
    },
  );

  test(
    'API-DUP-H-002 stockStatusCounts uses Home operational bundle when present',
    () async {
      var alertsCalled = false;
      final container = ProviderContainer(
        overrides: [
          shellCurrentBranchProvider.overrideWith((ref) => ShellBranch.home),
          homeDashboardDataProvider.overrideWith(() => _BundledDash()),
          stockAlertsSummaryProvider.overrideWith((ref) async {
            alertsCalled = true;
            return const <String, dynamic>{};
          }),
        ],
      );
      addTearDown(container.dispose);

      final counts = await container.read(stockStatusCountsProvider.future);
      expect(counts['low'], 3);
      expect(counts['critical'], 1);
      expect(alertsCalled, isFalse);
    },
  );
}

class _RefreshingDash extends HomeDashboardDataNotifier {
  @override
  HomeDashboardDashState build() {
    return const HomeDashboardDashState(
      snapshot: HomeDashboardPayload(data: HomeDashboardData.empty),
      refreshing: true,
    );
  }
}

class _BundledDash extends HomeDashboardDataNotifier {
  @override
  HomeDashboardDashState build() {
    final op = HomeOperationalBundle(
      stockStatusCounts: const {'low': 3, 'critical': 1, 'out': 0, 'all': 10},
      warehouseAlerts: const WarehouseAlerts(),
      deliveryPipeline: const <String, dynamic>{},
      notificationsUnread: 0,
    );
    return HomeDashboardDashState(
      snapshot: HomeDashboardPayload(
        data: HomeDashboardData(
          period: HomePeriod.month,
          totalPurchase: 0,
          totalLanding: 0,
          totalSelling: 0,
          totalProfit: 0,
          totalQtyAllLines: 0,
          totalKg: 0,
          totalBags: 0,
          totalBoxes: 0,
          totalTins: 0,
          purchaseCount: 1,
          categories: const [],
          subcategories: const [],
          itemSlices: const [],
          operational: op,
        ),
      ),
      refreshing: false,
    );
  }
}
