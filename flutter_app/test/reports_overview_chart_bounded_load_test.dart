import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/reports/presentation/reports_overview_chart_section.dart';

void main() {
  testWidgets('UX-193 chart bounded load shows retry after timeout',
      (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportsOverviewChartBoundedLoad(
            height: 120,
            timeout: const Duration(milliseconds: 50),
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('Chart is taking too long.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(retries, 1);
  });
}
