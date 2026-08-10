import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/auth/session_notifier.dart';
import 'package:harisree_warehouse/core/models/session.dart';
import 'package:harisree_warehouse/core/providers/home_dashboard_provider.dart';
import 'package:harisree_warehouse/core/providers/staff_home_providers.dart';
import 'package:harisree_warehouse/core/providers/stock_list_providers.dart';
import 'package:harisree_warehouse/core/providers/stock_opening_providers.dart';
import 'package:harisree_warehouse/features/shell/shell_branch_provider.dart';

const _staffSession = Session(
  accessToken: 'test',
  refreshToken: 'test',
  businesses: [
    BusinessBrief(id: 'biz-1', name: 'New Harisree', role: 'staff'),
  ],
);

void main() {
  test('API-DUP-SF-003 staff missing-code count uses alerts summary', () async {
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(() => _FakeStaffSession()),
        stockStatusCountsProvider.overrideWith(
          (ref) async => const {
            'all': 100,
            'low': 2,
            'critical': 1,
            'out': 0,
            'missing_code': 7,
          },
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(stockStatusCountsProvider.future);
    expect(container.read(staffMissingCodeCountProvider), 7);
    expect(container.read(staffLowStockAttentionCountProvider), 3);
  });

  test('API-DUP-SF-004 opening missing defers only on owner Home refreshing',
      () {
    final deferProbe = Provider<bool>(
      (ref) => openingStockMissingShouldDefer(ref),
    );

    final deferring = ProviderContainer(
      overrides: [
        shellCurrentBranchProvider.overrideWith((ref) => ShellBranch.home),
        homeDashboardDataProvider.overrideWith(() => _RefreshingDash()),
      ],
    );
    addTearDown(deferring.dispose);
    expect(deferring.read(deferProbe), isTrue);

    final offHome = ProviderContainer(
      overrides: [
        shellCurrentBranchProvider.overrideWith((ref) => ShellBranch.stock),
        homeDashboardDataProvider.overrideWith(() => _RefreshingDash()),
      ],
    );
    addTearDown(offHome.dispose);
    expect(offHome.read(deferProbe), isFalse);
  });
}

class _FakeStaffSession extends SessionNotifier {
  @override
  Session? build() => _staffSession;
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
