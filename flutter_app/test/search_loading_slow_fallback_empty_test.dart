import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/search/presentation/search_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('search slow fallback uses HexaEmptyState + recent chips',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? applied;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchLoadingSlowFallback(
            recents: const ['Sugar', 'Rice'],
            onApplyQuery: (q) => applied = q,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Search is taking longer than expected'), findsOneWidget);
    expect(find.text('Sugar'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);

    await tester.tap(find.text('Sugar'));
    await tester.pumpAndSettle();
    expect(applied, 'Sugar');
  });
}
