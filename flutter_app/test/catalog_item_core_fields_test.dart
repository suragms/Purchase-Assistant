import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/catalog/presentation/widgets/catalog_item_core_fields.dart';

void main() {
  testWidgets('DUP-F-003 shared catalog fields use edit-form labels',
      (tester) async {
    final name = TextEditingController();
    final code = TextEditingController();
    final hsn = TextEditingController();
    final kg = TextEditingController();
    final land = TextEditingController();
    final sell = TextEditingController();
    addTearDown(() {
      name.dispose();
      code.dispose();
      hsn.dispose();
      kg.dispose();
      land.dispose();
      sell.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              CatalogItemNameField(controller: name),
              CatalogItemCodeField(controller: code, codeRequired: true),
              CatalogItemHsnField(controller: hsn),
              CatalogItemKgPerBagField(controller: kg),
              CatalogItemDefaultRatesRow(landCtrl: land, sellCtrl: sell),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Item code *'), findsOneWidget);
    expect(find.text('HSN code'), findsOneWidget);
    expect(find.text('Kg per bag *'), findsOneWidget);
    expect(find.textContaining('Default landing'), findsOneWidget);
    expect(find.textContaining('Default selling'), findsOneWidget);
  });
}
