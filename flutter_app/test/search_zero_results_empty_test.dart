import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/auth/session_notifier.dart';
import 'package:harisree_warehouse/core/models/session.dart';
import 'package:harisree_warehouse/core/providers/prefs_provider.dart';
import 'package:harisree_warehouse/features/search/presentation/search_page.dart';
import 'package:harisree_warehouse/features/shell/shell_branch_provider.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSessionNotifier extends SessionNotifier {
  @override
  Session? build() => const Session(
        accessToken: 't',
        refreshToken: 'r',
        businesses: [
          BusinessBrief(id: 'biz-1', name: 'Test', role: 'owner'),
        ],
      );
}

Map<String, dynamic> _emptySearchPayload() => {
      'catalog_items': <dynamic>[],
      'suppliers': <dynamic>[],
      'brokers': <dynamic>[],
      'catalog_subcategories': <dynamic>[],
      'recent_purchases': <dynamic>[],
    };

void main() {
  testWidgets('zero search results show HexaEmptyState + Low stock',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SearchPage(embeddedInShell: true),
        ),
        GoRoute(
          path: '/stock',
          builder: (_, __) => const Scaffold(body: Text('stock-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionProvider.overrideWith(() => _FakeSessionNotifier()),
          shellCurrentBranchProvider.overrideWith((ref) => ShellBranch.search),
          unifiedSearchProvider.overrideWith((ref, q) async => _emptySearchPayload()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzznomatch');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No matching results'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('No matching catalog items.'), findsNothing);

    await tester.tap(find.text('Low stock'));
    await tester.pumpAndSettle();
    expect(find.text('stock-page'), findsOneWidget);
  });
}
