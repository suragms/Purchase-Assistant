import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/staff_home_providers.dart';
import 'package:harisree_warehouse/features/staff/presentation/widgets/staff_home_dashboard_widgets.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('staff recent activity empty shows HexaEmptyState + Scan',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: SingleChildScrollView(
              child: StaffHomeRecentActivitySection(),
            ),
          ),
        ),
        GoRoute(
          path: '/barcode/scan',
          builder: (_, __) => const Scaffold(body: Text('scan-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffRecentActivityProvider.overrideWith(
            (ref) async => const <StaffRecentActivityItem>[],
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No activity yet today'), findsOneWidget);
    expect(
      find.text('No activity yet today — tap Scan above.'),
      findsNothing,
    );
    expect(find.text('Scan barcode'), findsOneWidget);

    await tester.tap(find.text('Scan barcode'));
    await tester.pumpAndSettle();
    expect(find.text('scan-page'), findsOneWidget);
  });
}
