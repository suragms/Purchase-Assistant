import '../auth/session_notifier.dart';
import '../errors/user_facing_errors.dart';
import '../json_coerce.dart';
import '../../features/stock/stock_list_row_patch.dart'
    show stockListPatchFromPhysicalCount, stockListPatchFromStockDetail;
import 'stock_list_providers.dart';
import 'stock_detail_providers.dart';

/// Realtime single-item refresh: fetch one row and patch list cache (no full list refetch).
///
/// If the item's patch sequence advanced while the fetch was in-flight (meaning
/// another, more recent patch was applied), the server response is skipped to
/// avoid overwriting newer data with stale data.
///
/// Also rejects a GET that **regresses** `physical_stock_qty` / `stock_version`
/// relative to the current overlay (stale list/detail after physical save).
Future<void> patchStockItemInCache(
  dynamic ref, {
  required String itemId,
}) async {
  if (itemId.isEmpty) return;
  final session = ref.read(sessionProvider);
  if (session == null) return;
  final seqBefore = captureItemPatchSeq(itemId);
  try {
    final detail = await ref.read(hexaApiProvider).getStockItem(
          businessId: session.primaryBusiness.id,
          itemId: itemId,
        );
    if (captureItemPatchSeq(itemId) != seqBefore) return;
    final overlays =
        ref.read(stockListRowPatchProvider) as Map<String, Map<String, dynamic>>;
    final overlay = overlays[itemId];
    if (_stockGetRegressesOverlay(detail, overlay)) return;
    final patch = <String, dynamic>{
      ...stockListPatchFromStockDetail(detail),
      ...stockListPatchFromPhysicalCount(detail),
    };
    if (patch.isNotEmpty) {
      applyStockListRowPatch(ref, itemId: itemId, patch: patch);
    }
    clearStockItemDetailPatch(ref, itemId: itemId);
    ref.invalidate(stockItemDetailProvider(itemId));
    ref.invalidate(stockItemIntelligenceProvider(itemId));
    ref.invalidate(stockItemActivityProvider(itemId));
  } catch (e, st) {
    logSilencedApiError(e, st);
    ref.invalidate(stockItemDetailProvider(itemId));
    ref.invalidate(stockItemActivityProvider(itemId));
  }
}

bool _stockGetRegressesOverlay(
  Map<String, dynamic> detail,
  Map<String, dynamic>? overlay,
) {
  if (overlay == null || overlay.isEmpty) return false;
  final overlayVersion = coerceToDoubleNullable(overlay['stock_version']);
  final detailVersion = coerceToDoubleNullable(detail['stock_version']);
  // Authoritative newer server version always wins (lower recount / other session).
  if (overlayVersion != null &&
      detailVersion != null &&
      detailVersion > overlayVersion) {
    return false;
  }
  if (overlayVersion != null &&
      detailVersion != null &&
      detailVersion < overlayVersion) {
    return true;
  }
  final overlayPhys = coerceToDoubleNullable(overlay['physical_stock_qty']);
  if (overlayPhys == null || !overlayPhys.isFinite) return false;
  final detailPhys = coerceToDoubleNullable(detail['physical_stock_qty']);
  // Same/unknown version: overlay counted qty the GET has not caught up to yet.
  if (detailPhys == null || !detailPhys.isFinite) return true;
  if (detailPhys < overlayPhys - 0.001) return true;
  return false;
}
