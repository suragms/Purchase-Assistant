import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_error_messages.dart';
import '../../../core/auth/session_notifier.dart';
import '../../../core/theme/hexa_colors.dart';
import '../../../core/errors/load_state_error.dart';
import '../../../core/utils/snack.dart';
import '../../../core/widgets/friendly_load_error.dart';

/// Staff / owner view of assignment tasks (Wave 5).
class StaffTasksPage extends ConsumerStatefulWidget {
  const StaffTasksPage({super.key});

  @override
  ConsumerState<StaffTasksPage> createState() => _StaffTasksPageState();
}

class _StaffTasksPageState extends ConsumerState<StaffTasksPage> {
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final bid = ref.read(sessionProvider)?.primaryBusiness.id;
    if (bid == null || bid.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'No business selected';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ref.read(hexaApiProvider).listStaffTasks(businessId: bid);
      if (!mounted) return;
      setState(() {
        _items = (data['items'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = loadStateErrorSubtitle(e);
      });
    }
  }

  Future<void> _accept(String taskId) async {
    final bid = ref.read(sessionProvider)?.primaryBusiness.id;
    if (bid == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(hexaApiProvider).acceptStaffTask(
            businessId: bid,
            taskId: taskId,
          );
      if (mounted) showTopSnack(context, 'Task accepted');
      await _load();
    } on DioException catch (e) {
      if (mounted) showTopSnack(context, friendlyApiError(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _complete(String taskId, {bool rejected = false}) async {
    final bid = ref.read(sessionProvider)?.primaryBusiness.id;
    if (bid == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(hexaApiProvider).completeStaffTask(
            businessId: bid,
            taskId: taskId,
            rejected: rejected,
          );
      if (mounted) {
        showTopSnack(context, rejected ? 'Task rejected' : 'Task completed');
      }
      await _load();
    } on DioException catch (e) {
      if (mounted) showTopSnack(context, friendlyApiError(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createTask() async {
    final session = ref.read(sessionProvider);
    final bid = session?.primaryBusiness.id;
    if (bid == null || session == null) return;
    final role = session.primaryBusiness.role.toLowerCase();
    if (role != 'owner' && role != 'admin' && !session.isSuperAdmin) {
      showTopSnack(context, 'Only owners or admins can create tasks', isError: true);
      return;
    }

    final users = await ref.read(hexaApiProvider).listBusinessUsers(businessId: bid);
    if (!mounted) return;
    final staffIdCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'general');
    final refCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Staff'),
                items: [
                  for (final u in users)
                    DropdownMenuItem(
                      value: '${u['id']}',
                      child: Text(
                        '${u['full_name'] ?? u['email'] ?? u['id']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) staffIdCtrl.text = v;
                },
              ),
              TextField(
                controller: typeCtrl,
                decoration: const InputDecoration(labelText: 'Task type'),
              ),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(labelText: 'Reference (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (staffIdCtrl.text.isEmpty) {
      showTopSnack(context, 'Select a staff member', isError: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(hexaApiProvider).createStaffTask(
            businessId: bid,
            staffId: staffIdCtrl.text,
            taskType: typeCtrl.text.trim().isEmpty ? 'general' : typeCtrl.text.trim(),
            referenceId: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
          );
      if (mounted) showTopSnack(context, 'Task assigned');
      await _load();
    } on DioException catch (e) {
      if (mounted) showTopSnack(context, friendlyApiError(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final isOwner = session != null &&
        (session.isSuperAdmin ||
            session.primaryBusiness.role.toLowerCase() == 'owner' ||
            session.primaryBusiness.role.toLowerCase() == 'admin');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff tasks'),
        actions: [
          if (isOwner)
            IconButton(
              tooltip: 'Assign task',
              onPressed: _busy || _loading ? null : _createTask,
              icon: const Icon(Icons.add_task),
            ),
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const LinearProgressIndicator(minHeight: 2)
          : _error != null
              ? FriendlyLoadError(message: _error!, onRetry: _load)
              : _items.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks assigned.',
                        style: TextStyle(color: HexaColors.neutral),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final t = _items[i];
                        if (t is! Map) return const SizedBox.shrink();
                        final id = '${t['id'] ?? ''}';
                        final status = '${t['status'] ?? ''}';
                        final staffId = '${t['staff_id'] ?? ''}';
                        final open =
                            status == 'assigned' || status == 'accepted';
                        return ListTile(
                          title: Text(
                            '${t['task_type'] ?? 'task'} · $status',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'staff $staffId'
                            '${t['reference_id'] != null ? ' · ref ${t['reference_id']}' : ''}',
                          ),
                          trailing: open && !_busy
                              ? Wrap(
                                  spacing: 4,
                                  children: [
                                    if (status == 'assigned')
                                      TextButton(
                                        onPressed: () => _accept(id),
                                        child: const Text('Accept'),
                                      ),
                                    TextButton(
                                      onPressed: () => _complete(id),
                                      child: const Text('Done'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          _complete(id, rejected: true),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    ),
    );
  }
}
