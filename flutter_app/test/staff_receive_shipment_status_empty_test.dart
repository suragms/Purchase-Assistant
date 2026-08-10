import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/staff/presentation/staff_receive_shipment_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('already-committed status uses HexaEmptyState + Back',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var backed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaffReceiveAlreadyCommittedEmpty(
            onBack: () => backed = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Stock already committed'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(backed, isTrue);
  });

  testWidgets('awaiting-owner status uses HexaEmptyState + Back',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var backed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaffReceiveAwaitingOwnerEmpty(
            onBack: () => backed = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Waiting for owner approval'), findsOneWidget);
    expect(
      find.text(
        'You verified this shipment. Owner must commit to stock.',
      ),
      findsOneWidget,
    );
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(backed, isTrue);
  });
}
