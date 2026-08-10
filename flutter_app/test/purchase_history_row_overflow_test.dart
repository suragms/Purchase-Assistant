import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/models/trade_purchase_models.dart';
import 'package:harisree_warehouse/features/purchase/presentation/purchase_home_page.dart';

void main() {
  testWidgets('purchase history meta line ellipsizes on narrow width',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(320, 640)),
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              child: PurchaseHistoryRowMetaLine(
                pack: '12 BAG · 4 TIN · EXTRA PACK DETAIL',
                humanId: 'PUR-2026-VERY-LONG-HUMAN-ID-99999',
                broker: 'Very Long Broker Name Trading Co',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(PurchaseHistoryRowMetaLine), findsOneWidget);
  });

  testWidgets('purchase history status line wraps quick actions', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(320, 640)),
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              child: PurchaseHistoryRowStatusLine(
                daysChip: null,
                statusLabel: PurchaseStatus.confirmed,
                deliveryStatus: DeliveryStatus.pending,
                selectMode: false,
                showCommitStock: true,
                showPay: true,
                onMarkDelivered: () {},
                onMarkPaid: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('COMMIT STOCK'), findsOneWidget);
    expect(find.text('PAY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
