import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/reporting/trade_report_aggregate.dart';
import 'package:harisree_warehouse/features/reports/presentation/reports_overview_chart_section.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('overview chart empty shows HexaEmptyState + period CTAs',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var retried = false;
    var periodPicked = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ReportsOverviewChartSection(
              agg: buildTradeReportAgg(const []),
              viewportHeight: 800,
              isLoadingInitial: false,
              isEmpty: true,
              canRetry: true,
              onRetry: () => retried = true,
              onMatchHome: () {},
              onPickRange: () => periodPicked = true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No purchases in selected range'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Change period'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(retried, isTrue);

    await tester.tap(find.text('Change period'));
    await tester.pump();
    expect(periodPicked, isTrue);
  });

  testWidgets('overview chart load failed shows HexaEmptyState + Match Home',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var matched = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ReportsOverviewChartSection(
              agg: buildTradeReportAgg(const []),
              viewportHeight: 800,
              isLoadingInitial: false,
              loadFailed: true,
              loadError: Exception('network'),
              isEmpty: false,
              canRetry: true,
              onRetry: () {},
              onMatchHome: () => matched = true,
              onPickRange: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Could not load report data'), findsOneWidget);
    expect(find.text('Match Home period'), findsOneWidget);

    await tester.tap(find.text('Match Home period'));
    await tester.pump();
    expect(matched, isTrue);
  });
}
