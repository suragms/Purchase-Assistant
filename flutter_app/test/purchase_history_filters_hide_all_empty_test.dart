import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/purchase/presentation/purchase_home_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('filters hide all shows HexaEmptyState + Clear search & filters',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var cleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PurchaseHistoryFiltersHideAllEmpty(
            loadedCount: 12,
            onClearAll: () => cleared = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Filters hide all purchases'), findsOneWidget);
    expect(find.text('Clear search & filters'), findsOneWidget);
    expect(
      find.textContaining('12 loaded purchases'),
      findsOneWidget,
    );

    await tester.tap(find.text('Clear search & filters'));
    await tester.pump();
    expect(cleared, isTrue);
  });
}
