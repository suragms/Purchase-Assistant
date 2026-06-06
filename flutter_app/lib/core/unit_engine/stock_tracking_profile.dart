// Client mirror of backend stock-tracking modes (packaging type SSOT).

class StockTrackingMode {
  StockTrackingMode._();

  static const wholesaleBag = 'wholesale_bag';
  static const retailPacket = 'retail_packet';
  static const looseKg = 'loose_kg';
  static const box = 'box';
  static const tin = 'tin';
  static const piece = 'piece';

  /// Suggest mode from item name — 5KG/10KG → retail packet, 50KG bulk → bag.
  static String? suggestFromName(String rawName, {String? categoryName}) {
    final upper = rawName.toUpperCase().trim();
    final cat = (categoryName ?? '').toUpperCase();
    if (upper.contains('LOOSE')) return looseKg;
    if (RegExp(r'\b(BAG|SACK)\b').hasMatch(upper)) return wholesaleBag;
    if (upper.contains('TIN') || RegExp(r'\d+\s*LTR').hasMatch(upper)) {
      return tin;
    }
    if (upper.contains('BOX') || upper.contains('CTN')) return box;
    final kgM = RegExp(r'(\d+(?:\.\d+)?)\s*KG\b', caseSensitive: false)
        .firstMatch(upper);
    if (kgM != null) {
      final kg = double.tryParse(kgM.group(1) ?? '');
      if (kg != null) {
        if ({25, 30, 40, 45, 50, 55}.contains(kg.round())) {
          return wholesaleBag;
        }
        if (kg <= 10) return retailPacket;
      }
    }
    if (RegExp(r'\d+\s*GM\b').hasMatch(upper)) return retailPacket;
    if (cat.contains('OIL')) return tin;
    return null;
  }

  /// Map packaging picker choice → catalog `default_unit`.
  static String catalogUnitForMode(String mode) {
    switch (mode) {
      case wholesaleBag:
        return 'bag';
      case retailPacket:
      case piece:
        return 'piece';
      case looseKg:
        return 'kg';
      case box:
        return 'box';
      case tin:
        return 'tin';
      default:
        return 'piece';
    }
  }

  static String labelForMode(String mode) {
    switch (mode) {
      case wholesaleBag:
        return 'Wholesale bag';
      case retailPacket:
        return 'Retail packet';
      case looseKg:
        return 'Loose KG';
      case box:
        return 'Box / carton';
      case tin:
        return 'Tin';
      default:
        return 'Piece';
    }
  }

  /// Short chip label for create/edit unit picker (kg, bag, pc, …).
  static String shortLabelForMode(String mode) {
    switch (mode) {
      case wholesaleBag:
        return 'bag';
      case retailPacket:
        return 'pkt';
      case looseKg:
        return 'kg';
      case box:
        return 'box';
      case tin:
        return 'tin';
      default:
        return 'pc';
    }
  }

  static bool isPieceLikeMode(String? mode) =>
      mode == piece || mode == retailPacket;
}
