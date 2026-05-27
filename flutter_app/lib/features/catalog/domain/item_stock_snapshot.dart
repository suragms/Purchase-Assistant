import 'package:flutter/material.dart';

class ItemStockSnapshot {
  const ItemStockSnapshot({
    required this.unitLabel,
    required this.openingQty,
    required this.purchasedQty,
    required this.physicalQty,
    required this.systemQty,
    required this.diffQty,
    required this.reorderLevel,
    required this.hasPendingIncoming,
    required this.pendingIncomingDays,
    required this.lastUpdatedAt,
    required this.lastUpdatedBy,
    required this.needsVerification,
  });

  final String unitLabel;
  final double openingQty;
  final double purchasedQty;
  final double physicalQty;
  final double systemQty;
  final double diffQty;
  final double reorderLevel;
  final bool hasPendingIncoming;
  final int? pendingIncomingDays;
  final DateTime? lastUpdatedAt;
  final String? lastUpdatedBy;
  final bool needsVerification;

  ItemStockStatus get status {
    if (systemQty < -0.0001) return ItemStockStatus.negative;
    if (needsVerification) return ItemStockStatus.pendingVerification;
    if (diffQty.abs() > 0.0001) return ItemStockStatus.mismatch;
    if (systemQty <= 0.0001) return ItemStockStatus.outOfStock;
    if (reorderLevel > 0.0001 && systemQty <= reorderLevel) {
      return ItemStockStatus.lowStock;
    }
    return ItemStockStatus.healthy;
  }

  String diffLabel() {
    final abs = diffQty.abs();
    if (abs <= 0.0001) return 'No difference';
    final n = _fmt(abs);
    if (diffQty < 0) return '$n $unitLabel missing';
    return '$n $unitLabel extra';
  }

  Color statusColor() => switch (status) {
        ItemStockStatus.healthy => const Color(0xFF2E7D32),
        ItemStockStatus.lowStock => const Color(0xFFB45309),
        ItemStockStatus.outOfStock => const Color(0xFFC62828),
        ItemStockStatus.negative => const Color(0xFF7F1D1D),
        ItemStockStatus.mismatch => const Color(0xFFA32D2D),
        ItemStockStatus.pendingVerification => const Color(0xFF1565C0),
      };

  String statusChipLabel() => switch (status) {
        ItemStockStatus.healthy => 'HEALTHY',
        ItemStockStatus.lowStock => 'LOW STOCK',
        ItemStockStatus.outOfStock => 'OUT OF STOCK',
        ItemStockStatus.negative => 'NEGATIVE STOCK',
        ItemStockStatus.mismatch => 'MISMATCH',
        ItemStockStatus.pendingVerification => 'PENDING VERIFICATION',
      };
}

enum ItemStockStatus {
  healthy,
  lowStock,
  outOfStock,
  negative,
  mismatch,
  pendingVerification,
}

String _fmt(double n) {
  final s = n.toStringAsFixed(n.abs() < 1 ? 2 : 0);
  return s.replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'(\.\d*[1-9])0+$'), r'$1');
}

