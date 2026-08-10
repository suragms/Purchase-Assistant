import '../../../../core/providers/home_owner_dashboard_providers.dart';
import '../../home_pack_unit_word.dart';
import 'home_formatters.dart';

/// On-hand inventory units line for the owner Home dashboard.
String inventoryUnitsLine(HomeInventorySummary inv) {
  final parts = <String>[];
  if (inv.bags > 0) {
    parts.add(
      '${homeFmtQty(inv.bags)} ${homePackUnitWord('BAG', inv.bags)}',
    );
  }
  if (inv.boxes > 0) {
    parts.add(
      '${homeFmtQty(inv.boxes)} ${homePackUnitWord('BOX', inv.boxes)}',
    );
  }
  if (inv.tins > 0) {
    parts.add(
      '${homeFmtQty(inv.tins)} ${homePackUnitWord('TIN', inv.tins)}',
    );
  }
  if (inv.kg > 0) parts.add('${homeFmtQty(inv.kg)} KG');
  return parts.isEmpty ? 'No stock on hand' : parts.join(' · ');
}
