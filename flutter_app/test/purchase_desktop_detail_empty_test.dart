import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/purchase/presentation/widgets/purchase_desktop_detail_pane.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets(
      'PurchaseDesktopDetailPane empty selection uses HexaEmptyState',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PurchaseDesktopDetailPane(purchaseId: null),
          ),
        ),
      ),
    );

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.byType(PurchaseDesktopDetailEmptySelection), findsOneWidget);
    expect(find.text('Select a purchase'), findsOneWidget);
    expect(
      find.text(
        'Choose a row on the left to see bill detail and delivery status.',
      ),
      findsOneWidget,
    );
  });
}
