import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/operations_providers.dart';
import 'package:harisree_warehouse/features/operations/presentation/owner_tasks_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('Check today empty shows HexaEmptyState + Arrange list',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checklistTemplatesProvider.overrideWith((ref) async => const []),
          checklistTodayProvider.overrideWith(
            (ref) async => const {'tasks': <dynamic>[]},
          ),
          ownerChecklistSummaryProvider.overrideWith(
            (ref) async => const {
              'completion_pct': 0,
              'tasks_completed': 0,
              'tasks_total': 0,
            },
          ),
        ],
        child: const MaterialApp(home: OwnerTasksPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Check today'));
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No tasks for today'), findsOneWidget);
    expect(find.text('Edit task list'), findsOneWidget);
    expect(
      find.text('No tasks — save a list in Arrange tab'),
      findsNothing,
    );

    await tester.tap(find.text('Edit task list'));
    await tester.pumpAndSettle();

    expect(find.text('Save task list for all staff'), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
  });
}
