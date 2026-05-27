import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/notifications_provider.dart';

void main() {
  test('category filter all includes purchase due items', () {
    final n = NotificationItem(
      id: 'pur_due_1',
      type: NotificationType.purchaseDue,
      title: 'Payment due',
      subtitle: 'Remaining 100',
      createdAt: DateTime(2026, 5, 27),
      isRead: false,
      actionRoute: '/purchase/detail/x',
    );
    expect(
      notificationMatchesCategoryFilter(n, NotificationCategoryFilter.all),
      isTrue,
    );
    expect(
      notificationMatchesCategoryFilter(n, NotificationCategoryFilter.purchases),
      isTrue,
    );
    expect(
      notificationMatchesCategoryFilter(n, NotificationCategoryFilter.warehouse),
      isFalse,
    );
  });

  test('stock variance maps to critical filter', () {
    final n = NotificationItem(
      id: 'srv_1',
      type: NotificationType.serverInApp,
      title: 'Mismatch',
      subtitle: 'Sugar',
      createdAt: DateTime(2026, 5, 27),
      serverKind: 'stock_variance',
    );
    expect(
      notificationMatchesCategoryFilter(n, NotificationCategoryFilter.critical),
      isTrue,
    );
  });
}
