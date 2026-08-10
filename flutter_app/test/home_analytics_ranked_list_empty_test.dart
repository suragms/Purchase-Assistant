import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/home_breakdown_tab_providers.dart';
import 'package:harisree_warehouse/core/providers/home_dashboard_provider.dart';
import 'package:harisree_warehouse/features/home/presentation/widgets/home_analytics_ranked_list.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('ranked list empty uses HexaEmptyState with hint', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeAnalyticsRankedList(
            slices: const [],
            tab: HomeBreakdownTab.items,
            dash: HomeDashboardData.empty,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.byType(HomeAnalyticsRankedListEmpty), findsOneWidget);
    expect(find.text('No item movement in this view'), findsOneWidget);
  });
}
