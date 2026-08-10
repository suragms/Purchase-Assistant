import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/home_dashboard_provider.dart';
import 'package:harisree_warehouse/core/providers/home_owner_dashboard_providers.dart';
import 'package:harisree_warehouse/features/home/presentation/widgets/home_warehouse_activity_feed.dart';

void main() {
  testWidgets(
    'API-DUP-H-004 HomeWarehouseActivityFeed enables activity fetch gate',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeRecentActivityFeedProvider.overrideWith((ref) async => const []),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return const MaterialApp(
                home: Scaffold(
                  body: HomeWarehouseActivityFeed(maxRows: 3),
                ),
              );
            },
          ),
        ),
      );

      // Post-frame callback flips the gate (same frame settle as Home paint).
      await tester.pump();
      expect(container.read(homeActivityFeedFetchEnabledProvider), isTrue);
    },
  );
}
