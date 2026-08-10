import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/stock_list_providers.dart';

void main() {
  test('API-DUP-K-003 status chip alone does not need scoped totals', () {
    expect(
      stockNeedsScopedStatusTotals(
        const StockListQuery(status: 'shortage'),
        const StockOperationalFilters(),
      ),
      isFalse,
    );
    expect(
      stockNeedsScopedStatusTotals(
        const StockListQuery(status: 'out'),
        const StockOperationalFilters(),
      ),
      isFalse,
    );
  });

  test('API-DUP-K-003 search/category/ops still need scoped totals', () {
    expect(
      stockNeedsScopedStatusTotals(
        const StockListQuery(status: 'all', q: 'rice'),
        const StockOperationalFilters(),
      ),
      isTrue,
    );
    expect(
      stockNeedsScopedStatusTotals(
        const StockListQuery(status: 'shortage', category: 'Oil'),
        const StockOperationalFilters(),
      ),
      isTrue,
    );
    expect(
      stockNeedsScopedStatusTotals(
        const StockListQuery(status: 'all'),
        const StockOperationalFilters(missingBarcodeOnly: true),
      ),
      isTrue,
    );
  });

  test(
    'API-DUP-K-003 filtered provider uses unscoped counts when only status set',
    () async {
      final container = ProviderContainer(
        overrides: [
          stockListQueryProvider.overrideWith(
            (ref) => const StockListQuery(status: 'shortage'),
          ),
          stockStatusCountsProvider.overrideWith(
            (ref) async => const {
              'all': 40,
              'low': 5,
              'critical': 2,
              'out': 1,
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      final counts =
          await container.read(stockFilteredStatusCountsProvider.future);
      expect(counts['low'], 5);
      expect(counts['critical'], 2);
      expect(counts['out'], 1);
    },
  );
}
