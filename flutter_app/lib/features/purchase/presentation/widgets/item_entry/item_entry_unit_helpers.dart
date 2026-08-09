/// Pure catalog/unit helpers for purchase item entry (no widget state).
library;

String stripKgSuffixForCatalogDisplay(String name) => name
    .replaceAll(RegExp(r'\s*\d+(\.\d+)?\s*KG\s*$', caseSensitive: false), '')
    .trim();

/// Bag-family units that participate in per-kg × kg/bag pricing.
bool isBagFamilyWeightUnit(String? u) {
  final x = (u ?? '').trim().toLowerCase();
  // Back-compat: treat legacy `sack` as canonical `bag`.
  return x == 'bag' || x == 'sack';
}

/// Picks line unit: when the item has a bag weight but purchase unit is
/// `kg` in the catalog, prefer the physical [default_unit] (bag) so
/// per-kg × kg/bag math applies.
String lineUnitForCatalogRow(
  Map<String, dynamic> row, {
  required double? kpbD,
}) {
  final dpu = row['default_purchase_unit']?.toString().trim();
  final du = row['default_unit']?.toString().trim();
  if (kpbD != null && kpbD > 0) {
    if (du != null &&
        isBagFamilyWeightUnit(du) &&
        (dpu == null || dpu.toLowerCase() == 'kg')) {
      return du;
    }
  }
  String? pick() {
    if (dpu != null && dpu.isNotEmpty) return dpu;
    if (du != null && du.isNotEmpty) return du;
    return null;
  }

  final chosen = pick() ?? 'kg';
  final low = chosen.toLowerCase();
  // DB/catalog often store consumer packs as `piece`; wholesale UI uses tin/box/kg.
  if (low == 'piece' || low == 'pcs' || low == 'pieces') {
    final nm = (row['name']?.toString() ?? '').toUpperCase();
    if (nm.contains('TIN') || nm.contains('CAN') || nm.contains('JAR')) {
      return 'tin';
    }
    if (RegExp(r'\d+\s*(GM|GRAMS?|ML|LTR|LITERS?)\b', caseSensitive: false)
        .hasMatch(nm)) {
      return 'tin';
    }
    if (nm.contains('BOX') || nm.contains('CTN') || nm.contains('CARTON')) {
      return 'box';
    }
  }
  return chosen;
}

double? catalogKgPerBagFromRow(Map<String, dynamic>? row) {
  if (row == null) return null;
  for (final key in <String>[
    'default_kg_per_bag',
    'kg_per_bag',
    'kg_per_unit',
  ]) {
    final v = row[key];
    if (v is num && v > 0) return v.toDouble();
  }
  return null;
}
