import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/contacts/presentation/broker_detail_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('broker detail PUR empty shows HexaEmptyState + New purchase',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrokerDetailPurEmpty(onAddPurchase: () => tapped = true),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No PUR bills in this range'), findsOneWidget);
    expect(find.text('New purchase'), findsOneWidget);
    expect(
      find.text('No PUR bills with this broker in this date range.'),
      findsNothing,
    );
    expect(
      find.text('No broker-linked trade purchases in this range.'),
      findsNothing,
    );

    await tester.tap(find.text('New purchase'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
