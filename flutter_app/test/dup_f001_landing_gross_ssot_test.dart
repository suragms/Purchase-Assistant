import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/calc_engine.dart';
import 'package:harisree_warehouse/core/models/trade_purchase_models.dart';
import 'package:harisree_warehouse/features/purchase/domain/purchase_draft.dart';

void main() {
  group('DUP-F-001 landing gross SSOT', () {
    test('ledgerLineLandingGross weight path matches draft landingApprox', () {
      const draft = PurchaseLineDraft(
        itemName: 'RAVA',
        qty: 10,
        unit: 'bag',
        landingCost: 1500,
        kgPerUnit: 30,
        landingCostPerKg: 50,
      );
      expect(draft.landingApprox, 10 * 30 * 50);
      expect(
        ledgerLineLandingGross(
          qty: draft.qty,
          landingCost: draft.landingCost,
          kgPerUnit: draft.kgPerUnit,
          landingCostPerKg: draft.landingCostPerKg,
        ),
        draft.landingApprox,
      );
    });

    test('ledgerLineLandingGross unit path when no kg fields', () {
      expect(
        ledgerLineLandingGross(qty: 5, landingCost: 100),
        500,
      );
    });

    test('TradePurchaseLine.landingGross prefers API line_landing_gross', () {
      const ln = TradePurchaseLine(
        id: 't1',
        itemName: 'X',
        qty: 2,
        unit: 'kg',
        landingCost: 10,
        lineLandingGross: 99,
      );
      expect(ln.landingGross, 99);
    });
  });
}
