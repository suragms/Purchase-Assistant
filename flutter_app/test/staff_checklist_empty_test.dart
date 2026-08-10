import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/operations_providers.dart';
import 'package:harisree_warehouse/features/operations/presentation/staff_checklist_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty staff checklist shows HexaEmptyState + Refresh',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checklistTodayProvider.overrideWith(
            (ref) async => const {'tasks': <dynamic>[]},
          ),
        ],
        child: const MaterialApp(
          home: StaffChecklistPage(embeddedInShell: true),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No tasks configured'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
    expect(
      find.textContaining('ask owner to add tasks in Settings'),
      findsNothing,
    );
  });
}
