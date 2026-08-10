import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/staff_home_providers.dart';
import 'package:harisree_warehouse/features/staff/presentation/widgets/staff_home_dashboard_widgets.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('shift snapshot empty shows HexaEmptyState + Scan barcode',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: SingleChildScrollView(
              child: StaffHomeShiftSnapshotStrip(),
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
          staffTodayActivityProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
          staffTodayStockWorkProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
          staffTodaySummaryProvider.overrideWithValue(
            const StaffTodayActivitySummary(),
          ),
          staffPendingDeliveryCountProvider.overrideWithValue(0),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No activity today'), findsOneWidget);
    expect(find.text('Tap Stock or Scan to log work'), findsNothing);
    expect(find.text('Scan barcode'), findsOneWidget);

    await tester.tap(find.text('Scan barcode'));
    await tester.pumpAndSettle();
    expect(find.text('scan-page'), findsOneWidget);
  });
}
