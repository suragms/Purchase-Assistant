import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/stock_detail_providers.dart';
import 'package:harisree_warehouse/features/catalog/presentation/widgets/item_timeline_section.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('timeline empty shows HexaEmptyState + Full timeline',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: SingleChildScrollView(
              child: ItemTimelineSection(itemId: 'item-1'),
            ),
          ),
        ),
        GoRoute(
          path: '/catalog/item/:id/timeline',
          builder: (_, __) => const Scaffold(body: Text('full-timeline')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockItemActivityProvider('item-1').overrideWith(
            (ref) async => <String, dynamic>{
              'activity': <dynamic>[],
            },
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No activity yet'), findsOneWidget);
    expect(find.text('Full timeline'), findsWidgets);

    await tester.tap(find.text('Full timeline').last);
    await tester.pumpAndSettle();
    expect(find.text('full-timeline'), findsOneWidget);
  });

  testWidgets('filtered empty Clear filters restores empty all state',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockItemActivityProvider('item-1').overrideWith(
            (ref) async => <String, dynamic>{
              'activity': <dynamic>[],
            },
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ItemTimelineSection(itemId: 'item-1'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Purchases'));
    await tester.pumpAndSettle();

    expect(find.text('No movements match'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('No activity yet'), findsOneWidget);
    expect(find.text('Full timeline'), findsWidgets);
  });

  testWidgets('kind chips use Wrap not horizontal scroll', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockItemActivityProvider('item-1').overrideWith(
            (ref) async => <String, dynamic>{
              'activity': <dynamic>[],
            },
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ItemTimelineSection(itemId: 'item-1'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Physical'), findsOneWidget);
    expect(find.byType(Wrap), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(ItemTimelineSection),
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
