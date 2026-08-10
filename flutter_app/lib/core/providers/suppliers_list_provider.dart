import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';
import 'contacts_list_fetch.dart';

/// Kept alive so supplier pickers never cold-load across navigations.
final suppliersListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 3), link.close);
  ref.onDispose(timer.cancel);
  final bid = ref.watch(sessionProvider.select((s) => s?.primaryBusiness.id));
  if (bid == null || bid.isEmpty) return [];
  final api = ref.read(hexaApiProvider);
  return fetchContactsListWithApiGuard(
    ref,
    () => api.listSuppliers(businessId: bid),
  );
});
