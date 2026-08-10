import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/reporting/trade_report_aggregate.dart';
import 'package:harisree_warehouse/features/reports/tabs/reports_purchases_tab.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty purchases tab shows HexaEmptyState + Change period',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var changed = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ReportsPurchasesTab(
              agg: buildTradeReportAgg(const []),
              purchases: const [],
              merged: const [],
              onLoadMore: null,
              hasMore: false,
              onChangePeriod: () => changed = true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No purchases in this period'), findsOneWidget);
    expect(find.text('Change period'), findsOneWidget);
    expect(find.text('No purchases in this period.'), findsNothing);

    await tester.tap(find.text('Change period'));
    await tester.pump();
    expect(changed, isTrue);
  });
}
