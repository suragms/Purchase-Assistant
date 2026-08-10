import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/features/staff/presentation/staff_activity_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty staff activity shows HexaEmptyState + Scan barcode',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const StaffActivityPage(),
        ),
        GoRoute(
          path: '/staff/scan',
          builder: (_, __) => const Scaffold(body: Text('scan-page')),
        ),
        GoRoute(
          path: '/staff/home',
          builder: (_, __) => const Scaffold(body: Text('home')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffActivityLogProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No activity in this period'), findsOneWidget);
    expect(find.text('Scan barcode'), findsOneWidget);

    await tester.tap(find.text('Scan barcode'));
    await tester.pumpAndSettle();
    expect(find.text('scan-page'), findsOneWidget);
  });
}
