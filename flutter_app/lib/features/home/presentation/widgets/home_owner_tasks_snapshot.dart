import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/operations_providers.dart';

/// Top incomplete owner checklist items.
class HomeOwnerTasksSnapshot extends ConsumerWidget {
  const HomeOwnerTasksSnapshot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(checklistTodayProvider).valueOrNull ?? const <String, dynamic>{};
    final tasks = [
      for (final e in (data['tasks'] as List? ?? const []))
        if (e is Map) Map<String, dynamic>.from(e),
    ];
    final open = tasks.where((t) => t['completed'] != true).take(3).toList();
    if (open.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'My tasks',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/operations/owner-tasks'),
              child: const Text('View all'),
            ),
          ],
        ),
        ...open.map(
          (t) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.radio_button_unchecked, size: 20),
            title: Text(t['label']?.toString() ?? 'Task'),
          ),
        ),
      ],
    );
  }
}
