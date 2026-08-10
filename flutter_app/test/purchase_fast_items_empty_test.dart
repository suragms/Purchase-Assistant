import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/purchase/presentation/wizard/purchase_fast_items_step.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty items shows HexaEmptyState + Add item', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var added = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PurchaseFastItemsEmpty(
            blocked: false,
            onAddItem: () => added = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No items yet'), findsOneWidget);
    expect(find.text('No items yet. Tap + Add Item below.'), findsNothing);
    expect(find.text('Add item'), findsOneWidget);

    await tester.tap(find.text('Add item'));
    await tester.pump();
    expect(added, isTrue);
  });

  testWidgets('blocked empty shows supplier required without Add item',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PurchaseFastItemsEmpty(
            blocked: true,
            onAddItem: _noop,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Supplier required'), findsOneWidget);
    expect(find.text('Supplier required for catalog links.'), findsNothing);
    expect(find.text('Add item'), findsNothing);
  });
}

void _noop() {}
