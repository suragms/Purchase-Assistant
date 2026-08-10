import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/home_dashboard_provider.dart';
import 'package:harisree_warehouse/features/home/presentation/widgets/home_period_filter_row.dart';
import 'package:harisree_warehouse/shared/widgets/operational_ui.dart';

void main() {
  testWidgets('home period filters use Wrap on phone width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: HomePeriodFilterRow()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(OperationalPillWrap), findsOneWidget);
    expect(find.byType(OperationalPillRow), findsNothing);
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(HomePeriod.values.length, greaterThanOrEqualTo(5));
  });
}
