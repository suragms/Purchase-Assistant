import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';
import 'package:harisree_warehouse/shared/widgets/ledger_history_list_empty.dart';

void main() {
  testWidgets('ledger history empty without search', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LedgerHistoryListEmpty(searchActive: false),
        ),
      ),
    );

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No purchase lines yet'), findsOneWidget);
    expect(find.text('Clear search'), findsNothing);
  });

  testWidgets('ledger history search miss offers Clear search', (tester) async {
    var cleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LedgerHistoryListEmpty(
            searchActive: true,
            onClearSearch: () => cleared = true,
          ),
        ),
      ),
    );

    expect(find.text('No matching lines'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);

    await tester.tap(find.text('Clear search'));
    await tester.pump();
    expect(cleared, isTrue);
  });
}
