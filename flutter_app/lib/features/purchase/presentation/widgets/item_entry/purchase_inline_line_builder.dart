import '../../../../../core/calc_engine.dart';
import '../../../../../core/pricing/tax_mode.dart';
import '../../../../../core/strict_decimal.dart';
import '../../../../../shared/widgets/inline_search_field.dart';
import 'item_entry_payload.dart';

/// Compact unit choices for inline purchase table (Tally-style).
const List<String> kPurchaseInlineUnitChoices = [
  'kg',
  'bag',
  'box',
  'tin',
  'pcs',
  'litre',
  'quintal',
];

/// Common GST % presets for the inline tax cell.
const List<double> kPurchaseInlineTaxPresets = [0, 5, 12, 18, 28];

double? parseInlineDecimal(String? text) {
  final v = text?.trim() ?? '';
  if (v.isEmpty) return null;
  try {
    return StrictDecimal.parse(v).toDouble();
  } on FormatException {
    return null;
  }
}

/// Field-level validation errors for [buildInlinePurchaseLineMap].
class InlineLineValidation {
  const InlineLineValidation({
    this.item,
    this.qty,
    this.unit,
    this.buy,
    this.sell,
  });

  final String? item;
  final String? qty;
  final String? unit;
  final String? buy;
  final String? sell;

  bool get hasError =>
      item != null ||
      qty != null ||
      unit != null ||
      buy != null ||
      sell != null;
}

/// Result of building an inline purchase line map.
class InlineLineBuildResult {
  const InlineLineBuildResult({
    this.line,
    required this.errors,
  });

  final Map<String, dynamic>? line;
  final InlineLineValidation errors;

  bool get ok => line != null && !errors.hasError;
}

/// Builds a purchase line wire map for the common (non-advanced) entry path.
///
/// Preserves the same field names as [PurchaseItemEntrySheet] / [PurchaseLineDraft].
/// Bag/box advanced inventory (items-per-box, per-kg economics UI) stays in the
/// full sheet — here bag lines store flat per-bag [landing_cost] plus optional
/// [kg_per_unit] snapshot from catalog when available.
InlineLineBuildResult buildInlinePurchaseLineMap({
  required String? catalogItemId,
  required String itemName,
  required String qtyText,
  required String unit,
  required String buyRateText,
  required String sellRateText,
  required TaxMode taxMode,
  required double? taxPercent,
  String? hsnCode,
  String? itemCode,
  double? catalogKgPerBag,
  double? catalogTaxPercent,
}) {
  final name = itemName.trim();
  final u = unit.trim().isEmpty ? 'kg' : unit.trim();
  final uLow = u.toLowerCase();
  final qty = parseInlineDecimal(qtyText) ?? 0;
  final buy = parseInlineDecimal(buyRateText) ?? 0;
  final sellRaw = sellRateText.trim();
  final sell = sellRaw.isEmpty ? null : parseInlineDecimal(sellRaw);

  String? errItem;
  String? errQty;
  String? errUnit;
  String? errBuy;
  String? errSell;

  if (name.isEmpty) {
    errItem = 'Enter an item';
  } else if (catalogItemId == null || catalogItemId.isEmpty) {
    errItem = 'Pick a catalog item';
  }

  final fracPack = (uLow == 'bag' ||
          uLow == 'sack' ||
          uLow == 'box' ||
          uLow == 'tin') &&
      (qty - qty.roundToDouble()).abs() > 1e-6;
  if (qty <= 0) {
    errQty = 'Qty > 0';
  } else if (fracPack) {
    errQty = 'Whole number';
  }

  if (u.isEmpty) {
    errUnit = 'Required';
  }

  if (buy <= 0) {
    errBuy = 'Rate > 0';
  }

  if (sellRaw.isNotEmpty && (sell == null || sell < 0)) {
    errSell = 'Invalid';
  }

  final errors = InlineLineValidation(
    item: errItem,
    qty: errQty,
    unit: errUnit,
    buy: errBuy,
    sell: errSell,
  );
  if (errors.hasError) {
    return InlineLineBuildResult(errors: errors);
  }

  final m = <String, dynamic>{
    'catalog_item_id': catalogItemId,
    'item_name': name,
    'qty': qty,
    'unit': uLow == 'sack' ? 'bag' : u,
    'landing_cost': buy,
    'purchase_rate': buy,
  };

  if (catalogKgPerBag != null &&
      catalogKgPerBag > 0 &&
      (uLow == 'bag' || uLow == 'sack')) {
    m['kg_per_unit'] = catalogKgPerBag;
    m['weight_per_unit'] = catalogKgPerBag;
  }

  if (sell != null && sell > 0) {
    m['selling_cost'] = sell;
    m['selling_rate'] = sell;
  }

  applyTaxPercentToPurchaseLineMap(
    m,
    taxOn: taxMode != TaxMode.none,
    typedTaxPercent: taxMode == TaxMode.none ? null : taxPercent,
    catalogTaxPercent: catalogTaxPercent,
  );
  m['tax_mode'] = taxModeToWire(taxMode);

  final h = hsnCode?.trim() ?? '';
  if (h.isNotEmpty) m['hsn_code'] = h;
  final ic = itemCode?.trim() ?? '';
  if (ic.isNotEmpty) m['item_code'] = ic;

  return InlineLineBuildResult(line: m, errors: errors);
}

/// Live line total for the inline row preview (same engine as the sheet).
double inlineLineTotalPreview({
  required double qty,
  required double landingCost,
  double? kgPerUnit,
  double? landingCostPerKg,
  double? taxPercent,
  TaxMode taxMode = TaxMode.exclusive,
}) {
  final li = TradeCalcLine(
    qty: qty,
    landingCost: landingCost,
    kgPerUnit: kgPerUnit,
    landingCostPerKg: landingCostPerKg,
    taxPercent: taxMode == TaxMode.none ? 0 : taxPercent,
  );
  return lineMoney(li, taxMode: taxMode);
}

/// Builds [InlineSearchItem] list from catalog rows (name / code / HSN).
List<InlineSearchItem> buildPurchaseCatalogSearchItems(
  List<Map<String, dynamic>> catalog, {
  String? preferredSupplierId,
  List<String> priorityCatalogItemIds = const [],
}) {
  final pref = preferredSupplierId?.trim();
  final priority = priorityCatalogItemIds;
  final out = <InlineSearchItem>[];
  for (final row in catalog) {
    var boost = 0;
    final rowId = row['id']?.toString() ?? '';
    if (rowId.isNotEmpty && priority.isNotEmpty) {
      final idx = priority.indexOf(rowId);
      if (idx >= 0) boost += 400 - (idx * 20);
    }
    if (pref != null && pref.isNotEmpty) {
      final ls = row['last_supplier_id']?.toString().trim();
      if (ls == pref) boost += 120;
      final ids = row['default_supplier_ids'];
      if (ids is List) {
        for (final e in ids) {
          if (e != null && e.toString().trim() == pref) {
            boost += 80;
            break;
          }
        }
      }
    }
    final name = row['name']?.toString() ?? '';
    final code = row['item_code']?.toString().trim() ?? '';
    final hsn = (row['hsn_code'] ?? row['hsn'])?.toString().trim() ?? '';
    final blob = [
      name,
      code,
      hsn,
      row['category_name']?.toString().trim() ?? '',
      row['subcategory_name']?.toString().trim() ?? '',
    ].where((s) => s.isNotEmpty).join(' ').toLowerCase();
    final subParts = <String>[
      if (code.isNotEmpty) code,
      if (hsn.isNotEmpty) 'HSN $hsn',
    ];
    out.add(
      InlineSearchItem(
        id: rowId,
        label: name,
        subtitle: subParts.isEmpty ? null : subParts.join(' · '),
        searchText: blob.isEmpty ? null : blob,
        sortBoost: boost,
      ),
    );
  }
  return out;
}

Map<String, dynamic>? catalogRowById(
  List<Map<String, dynamic>> catalog,
  String id,
) {
  for (final row in catalog) {
    if (row['id']?.toString() == id) return row;
  }
  return null;
}

double? catalogNumeric(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return parseInlineDecimal(v.toString());
}
