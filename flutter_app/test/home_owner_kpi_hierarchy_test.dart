import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/home/presentation/widgets/home_owner_dashboard_body.dart';

void main() {
  testWidgets('secondary Home KPI uses quieter chrome than primary',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: HomeOwnerKpiTile(
                    label: 'Purchases',
                    value: '12',
                    subtitle: 'This month',
                    secondary: true,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: HomeOwnerKpiTile(
                    label: 'Pending delivery',
                    value: '3',
                    subtitle: 'Needs action',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    BoxDecoration? primary;
    BoxDecoration? secondary;
    for (final c in tester.widgetList<Container>(find.byType(Container))) {
      final d = c.decoration;
      if (d is! BoxDecoration) continue;
      if (d.color == Colors.white && (d.boxShadow?.isNotEmpty ?? false)) {
        primary = d;
      }
      if (d.color == const Color(0xFFF7F8FA)) {
        secondary = d;
      }
    }

    expect(find.text('Purchases'), findsOneWidget);
    expect(find.text('Pending delivery'), findsOneWidget);
    expect(primary, isNotNull);
    expect(secondary, isNotNull);
    expect(secondary!.boxShadow ?? const <BoxShadow>[], isEmpty);
    expect(tester.takeException(), isNull);
  });
}
