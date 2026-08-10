import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/home/presentation/widgets/home_recent_changes_section.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('home recent changes empty uses HexaEmptyState + New purchase',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeRecentChangesEmpty(
            onNewPurchase: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No recent warehouse activity'), findsOneWidget);
    expect(find.text('New purchase'), findsOneWidget);

    await tester.tap(find.text('New purchase'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
