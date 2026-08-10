import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/reporting/trade_report_aggregate.dart';
import 'package:harisree_warehouse/features/reports/tabs/reports_overview_tab.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('desktop overview aside empty shows HexaEmptyState + Change period',
      (tester) async {
    // ≥1024 and <1366 so master + Period insights pane both show.
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var periodPicked = false;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: ReportsOverviewTab(
              agg: buildTradeReportAgg(const []),
              merged: const [],
              showSkeleton: false,
              hasFetchError: false,
              showEmpty: true,
              purchasesError: null,
              onRetry: () {},
              onMatchHome: () {},
              onPickRange: () => periodPicked = true,
            ),
          ),
        ),
        GoRoute(
          path: '/reports',
          builder: (_, __) => const Scaffold(body: Text('reports')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Period insights'), findsOneWidget);
    expect(find.byType(HexaEmptyState), findsWidgets);
    expect(find.text('No purchases in this period'), findsWidgets);
    expect(find.text('No purchases in this period.'), findsNothing);
    expect(find.text('Change period'), findsWidgets);

    await tester.tap(find.text('Change period').last);
    await tester.pump();
    expect(periodPicked, isTrue);
  });
}
