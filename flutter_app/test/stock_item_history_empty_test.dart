import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/stock_detail_providers.dart';
import 'package:harisree_warehouse/features/stock/presentation/widgets/stock_item_history_panel.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('stock item history empty shows HexaEmptyState', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockItemAuditProvider('item-1').overrideWith((ref) async => const []),
          stockItemPhysicalCountsProvider('item-1')
              .overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: StockItemHistoryPanel(itemId: 'item-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No stock changes recorded'), findsOneWidget);
    expect(
      find.text('Physical remaining and system updates will appear here'),
      findsOneWidget,
    );
  });
}
