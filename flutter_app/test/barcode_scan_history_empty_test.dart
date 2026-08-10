import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/auth/session_notifier.dart';
import 'package:harisree_warehouse/core/models/session.dart';
import 'package:harisree_warehouse/core/providers/staff_home_providers.dart';
import 'package:harisree_warehouse/core/providers/stock_audit_providers.dart';
import 'package:harisree_warehouse/features/barcode/presentation/barcode_scan_history_page.dart';
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
  testWidgets('empty scan history shows HexaEmptyState + Scan barcode',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const BarcodeScanHistoryPage(),
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
          sessionProvider.overrideWith(() => _FakeSessionNotifier()),
          staffRecentScansProvider.overrideWith((ref) async => const []),
          stockAuditKpisProvider.overrideWith((ref) async => const {}),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No recent scans yet'), findsOneWidget);
    expect(find.text('Scan barcode'), findsOneWidget);

    await tester.tap(find.text('Scan barcode'));
    await tester.pumpAndSettle();
    expect(find.text('scan-page'), findsOneWidget);
  });
}
