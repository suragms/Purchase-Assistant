import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/auth/session_notifier.dart';
import 'package:harisree_warehouse/core/models/session.dart';
import 'package:harisree_warehouse/features/catalog/presentation/widgets/item_quick_actions_bar.dart';

class _FakeOwnerSession extends SessionNotifier {
  @override
  Session? build() => const Session(
        accessToken: 't',
        refreshToken: 'r',
        businesses: [
          BusinessBrief(id: 'biz-1', name: 'Test', role: 'owner'),
        ],
      );
}

void main() {
  testWidgets('item quick actions use Wrap not horizontal ListView',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWith(() => _FakeOwnerSession()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ItemQuickActionsBar(
              itemId: 'item-1',
              itemName: 'Test item',
              itemCode: 'T1',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Physical count'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );
  });
}
