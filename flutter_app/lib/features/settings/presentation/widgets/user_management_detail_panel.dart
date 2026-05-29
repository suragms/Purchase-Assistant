import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/hexa_ds_tokens.dart';
import '../../../../core/theme/theme_context_ext.dart';

/// Inline user detail for desktop user management (≥1024px).
class UserManagementDetailPanel extends StatelessWidget {
  const UserManagementDetailPanel({
    super.key,
    required this.user,
    required this.canAdmin,
    required this.onPatch,
    required this.onResetPassword,
    required this.onDelete,
    required this.onBlock,
  });

  final Map<String, dynamic>? user;
  final bool canAdmin;
  final Future<void> Function(Map<String, dynamic> data) onPatch;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const ColoredBox(
        color: Color(0xFFFAFAF8),
        child: Center(
          child: Text(
            'Select a user',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
      );
    }
    final name = user!['name']?.toString() ?? '—';
    final email = user!['email']?.toString() ?? '';
    final phone = user!['phone']?.toString() ?? '';
    final role = user!['role']?.toString() ?? '';
    final active = user!['is_active'] == true && user!['is_blocked'] != true;
    final blocked = user!['is_blocked'] == true;
    final isOwner = role == 'owner';

    return ColoredBox(
      color: context.adaptiveScaffold,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(email, style: HexaDsType.body(13)),
          ],
          const SizedBox(height: 16),
          _infoRow('Role', role.toUpperCase()),
          _infoRow('Phone', phone.isEmpty ? '—' : phone),
          _infoRow(
            'Status',
            blocked ? 'Blocked' : (active ? 'Active' : 'Inactive'),
          ),
          const SizedBox(height: 20),
          if (canAdmin && !isOwner) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!active && !blocked)
                  FilledButton.tonal(
                    onPressed: () => onPatch({'is_active': true}),
                    child: const Text('Activate'),
                  ),
                if (active)
                  OutlinedButton(
                    onPressed: () => onPatch({'is_active': false}),
                    child: const Text('Deactivate'),
                  ),
                if (!blocked)
                  OutlinedButton(
                    onPressed: onBlock,
                    child: const Text('Block'),
                  ),
                OutlinedButton(
                  onPressed: onResetPassword,
                  child: const Text('Reset password'),
                ),
                OutlinedButton(
                  onPressed: onDelete,
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              final id = user!['id']?.toString() ?? '';
              if (id.isNotEmpty) context.push('/settings/users/$id');
            },
            child: const Text('Open full profile'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: HexaDsType.label(12)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
