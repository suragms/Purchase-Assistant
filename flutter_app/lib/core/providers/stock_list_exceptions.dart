/// Thrown when stock list must not return an empty success payload (auth gate / no session).
class StockListFetchBlockedException implements Exception {
  const StockListFetchBlockedException([this.reason]);

  final String? reason;

  @override
  String toString() => 'StockListFetchBlockedException(${reason ?? 'blocked'})';
}

bool isStockListAuthFailure(Object? error) {
  if (error is StockListFetchBlockedException) return true;
  return false;
}
