import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/home/presentation/widgets/home_warehouse_activity_feed.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('home warehouse activity empty uses HexaEmptyState',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeWarehouseActivityEmpty(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No activity in this period'), findsOneWidget);
    expect(
      find.text('Stock updates and purchases will appear here.'),
      findsOneWidget,
    );
  });
}
