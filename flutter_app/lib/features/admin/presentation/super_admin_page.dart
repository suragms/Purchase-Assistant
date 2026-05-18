import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/router/navigation_ext.dart';

final _superAdminHealthProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(hexaApiProvider).superAdminHealth();
});

final _superAdminBizProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(hexaApiProvider).superAdminBusinessesOverview(limit: 80);
});

/// JWT super-admin tools (stubs wired to `/v1/admin/health` + businesses overview).
class SuperAdminPage extends ConsumerWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final health = ref.watch(_superAdminHealthProvider);
    final biz = ref.watch(_superAdminBizProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Super admin',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.popOrGo('/settings'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('System health', style: tt.titleMedium),
          const SizedBox(height: 8),
          health.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (e, _) => Text('Error: $e'),
            data: (m) => Text(m.toString(), style: tt.bodySmall),
          ),
          const SizedBox(height: 24),
          Text('Businesses (overview)', style: tt.titleMedium),
          const SizedBox(height: 8),
          biz.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (e, _) => Text('Error: $e'),
            data: (m) {
              final items = m['items'];
              if (items is! List || items.isEmpty) {
                return const Text('No businesses returned.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final raw in items.take(20))
                    if (raw is Map)
                      ListTile(
                        dense: true,
                        title: Text(raw['name']?.toString() ?? '—'),
                        subtitle: Text(raw['id']?.toString() ?? ''),
                      ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          FilledButton.tonal(
            onPressed: () {
              ref.invalidate(_superAdminHealthProvider);
              ref.invalidate(_superAdminBizProvider);
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
