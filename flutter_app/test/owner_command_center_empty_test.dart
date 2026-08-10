import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/features/settings/presentation/owner_command_center_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('command center empty sections use HexaEmptyState + CTAs',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: OwnerCommandCenterBody(
              data: const {
                'exceptions': <dynamic>[],
                'staff_performance': <dynamic>[],
                'stock': {'low_count': 0, 'out_count': 0},
                'comparison': {'spend_last_7_days': 0},
                'backup': {'last_status': 'ok'},
              },
              waItems: const [],
              onRefreshWa: () {},
              onResendWa: (_) {},
            ),
          ),
        ),
        GoRoute(
          path: '/stock',
          builder: (_, __) => const Scaffold(body: Text('stock-page')),
        ),
        GoRoute(
          path: '/staff/tasks-board',
          builder: (_, __) => const Scaffold(body: Text('tasks-page')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsNWidgets(3));
    expect(find.text('No exceptions right now'), findsOneWidget);
    expect(find.text('No delivery attempts yet'), findsOneWidget);
    expect(find.text('No staff tasks yet'), findsOneWidget);
    expect(find.text('No exceptions right now.'), findsNothing);

    await tester.scrollUntilVisible(find.text('Open stock'), 200);
    await tester.tap(find.text('Open stock'));
    await tester.pumpAndSettle();
    expect(find.text('stock-page'), findsOneWidget);
  });
}
