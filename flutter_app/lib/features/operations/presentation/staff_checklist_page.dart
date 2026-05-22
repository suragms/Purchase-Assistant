import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/providers/operations_providers.dart';
import '../../../core/providers/warehouse_alerts_provider.dart';
import '../../../core/widgets/friendly_load_error.dart';

class StaffChecklistPage extends ConsumerStatefulWidget {
  const StaffChecklistPage({super.key});

  @override
  ConsumerState<StaffChecklistPage> createState() => _StaffChecklistPageState();
}

class _StaffChecklistPageState extends ConsumerState<StaffChecklistPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(checklistTodayProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily checklist'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Morning'),
            Tab(text: 'Midday'),
            Tab(text: 'Evening'),
          ],
        ),
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => FriendlyLoadError(
          onRetry: () => ref.invalidate(checklistTodayProvider),
        ),
        data: (m) {
          final tasks = [
            for (final t in (m['tasks'] as List? ?? []))
              if (t is Map) Map<String, dynamic>.from(t),
          ];
          final pct = (m['completion_pct'] as num?)?.toDouble() ?? 0;
          return Column(
            children: [
              LinearProgressIndicator(
                value: (pct / 100).clamp(0.0, 1.0),
                color: const Color(0xFF3B6D11),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('${pct.toStringAsFixed(0)}% complete today'),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _slotList(context, ref, tasks, 'morning'),
                    _slotList(context, ref, tasks, 'midday'),
                    _slotList(context, ref, tasks, 'evening'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _slotList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> tasks,
    String slot,
  ) {
    final slotTasks = tasks.where((t) => t['slot'] == slot).toList();
    if (slotTasks.isEmpty) {
      return const Center(child: Text('No tasks for this shift'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: slotTasks.length,
      itemBuilder: (ctx, i) {
        final t = slotTasks[i];
        return CheckboxListTile(
          value: t['completed'] == true,
          onChanged: (v) async {
            if (v != true) return;
            final session = ref.read(sessionProvider);
            if (session == null) return;
            await ref.read(hexaApiProvider).completeChecklistTask(
                  businessId: session.primaryBusiness.id,
                  slot: slot,
                  taskKey: t['task_key']?.toString() ?? '',
                );
            ref.invalidate(checklistTodayProvider);
            ref.invalidate(warehouseAlertsProvider);
          },
          title: Text(t['label']?.toString() ?? ''),
        );
      },
    );
  }
}
