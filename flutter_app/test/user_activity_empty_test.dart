import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/settings/users/user_activity_tab.dart';
import 'package:harisree_warehouse/features/settings/users/user_profile_providers.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('feed empty shows HexaEmptyState + Refresh', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userActivityFeedProvider('u1').overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: UserActivityTab(userId: 'u1')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No activity in the last 30 days'), findsOneWidget);
    expect(find.text('No activity in the last 30 days.'), findsNothing);
    expect(find.text('Refresh'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pump();
  });

  testWidgets('stock section empty shows HexaEmptyState', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userActivityFeedProvider('u1').overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
          userStockHistoryProvider('u1').overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              home: Scaffold(body: UserActivityTab(userId: 'u1')),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    container.read(userActivitySectionProvider.notifier).state =
        UserActivitySection.stock;
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No stock activity yet'), findsOneWidget);
    expect(find.text('No stock activity yet.'), findsNothing);
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets('section chips use Wrap not horizontal scroll', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userActivityFeedProvider('u1').overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: UserActivityTab(userId: 'u1')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All activity'), findsOneWidget);
    expect(find.text('Ledger'), findsOneWidget);
    expect(find.byType(Wrap), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(UserActivityTab),
        matching: find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
      ),
      findsNothing,
    );
  });
}
