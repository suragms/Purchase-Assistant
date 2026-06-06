import 'package:shared_preferences/shared_preferences.dart';

/// Remembers last supplier/broker on catalog item create (per business).
class CatalogCreatePrefs {
  static String _supplierKey(String businessId) =>
      'catalog_create_supplier_$businessId';
  static String _brokerKey(String businessId) => 'catalog_create_broker_$businessId';

  static Future<({String? supplierId, String? brokerId})> load(
    String businessId,
  ) async {
    final sp = await SharedPreferences.getInstance();
    return (
      supplierId: sp.getString(_supplierKey(businessId)),
      brokerId: sp.getString(_brokerKey(businessId)),
    );
  }

  static Future<void> save({
    required String businessId,
    String? supplierId,
    String? brokerId,
  }) async {
    final sp = await SharedPreferences.getInstance();
    final sup = supplierId?.trim();
    final bro = brokerId?.trim();
    if (sup == null || sup.isEmpty) {
      await sp.remove(_supplierKey(businessId));
    } else {
      await sp.setString(_supplierKey(businessId), sup);
    }
    if (bro == null || bro.isEmpty) {
      await sp.remove(_brokerKey(businessId));
    } else {
      await sp.setString(_brokerKey(businessId), bro);
    }
  }
}
