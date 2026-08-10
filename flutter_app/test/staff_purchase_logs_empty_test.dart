import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/auth/session_notifier.dart';
import 'package:harisree_warehouse/core/models/session.dart';
import 'package:harisree_warehouse/features/stock/presentation/staff_purchase_logs_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

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

void main() {
  testWidgets('empty staff cash purchases shows HexaEmptyState + stock CTA',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const StaffPurchaseLogsPage(),
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
          sessionProvider.overrideWith(() => _FakeSessionNotifier()),
          staffPurchaseLogsProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No staff cash purchases yet'), findsOneWidget);
    expect(find.text('Go to stock'), findsOneWidget);

    await tester.tap(find.text('Go to stock'));
    await tester.pumpAndSettle();
    expect(find.text('stock-page'), findsOneWidget);
  });
}
