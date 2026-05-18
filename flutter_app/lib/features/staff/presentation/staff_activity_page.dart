import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/router/navigation_ext.dart';
import '../../../core/widgets/friendly_load_error.dart';
import '../../../core/widgets/list_skeleton.dart';

final _staffActivityPeriodProvider = StateProvider<String>((_) => 'today');

final staffActivityLogProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final session = ref.watch(sessionProvider);
  final period = ref.watch(_staffActivityPeriodProvider);
  if (session == null) return [];
  return ref.read(hexaApiProvider).listActivityLog(
        businessId: session.primaryBusiness.id,
        period: period,
      );
});

/// Staff: recent actions (scans, stock updates, etc.) from `/activity-log`.
class StaffActivityPage extends ConsumerWidget {
  const StaffActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final period = ref.watch(_staffActivityPeriodProvider);
    final async = ref.watch(staffActivityLogProvider);
    final onSurf = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text('My activity',
            style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800, color: onSurf)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.popOrGo('/staff/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HexaDsLayout.pageGutter,
          vertical: HexaDsLayout.sectionGap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'today', label: Text('Today')),
                ButtonSegment(value: 'week', label: Text('Week')),
                ButtonSegment(value: 'month', label: Text('Month')),
              ],
              selected: {period},
              onSelectionChanged: (s) {
                ref.read(_staffActivityPeriodProvider.notifier).state =
                    s.first;
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: async.when(
                loading: () => const ListSkeleton(rowCount: 10),
                error: (e, _) => FriendlyLoadError(
                  message: 'Could not load activity.\n$e',
                  onRetry: () => ref.invalidate(staffActivityLogProvider),
                ),
                data: (rows) {
                  if (rows.isEmpty) {
                    return Center(
                      child: Text(
                        'No activity in this period.',
                        style: tt.bodyLarge?.copyWith(color: onSurf),
                      ),
                    );
                  }
                  final fmt = DateFormat.MMMd().add_Hm();
                  return ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final r = rows[i];
                      final action = r['action_type']?.toString() ?? '—';
                      final item = r['item_name']?.toString();
                      final who = r['user_name']?.toString();
                      DateTime when;
                      try {
                        when = DateTime.parse(
                            r['created_at']?.toString() ?? '');
                      } catch (_) {
                        when = DateTime.now();
                      }
                      return ListTile(
                        title: Text(action.replaceAll('_', ' ')),
                        subtitle: Text(
                          [
                            if (item != null && item.isNotEmpty) item,
                            if (who != null && who.isNotEmpty) who,
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          fmt.format(when.toLocal()),
                          style: tt.labelSmall,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
