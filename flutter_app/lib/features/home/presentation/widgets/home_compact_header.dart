import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/session_notifier.dart';
import '../../../../core/design_system/hexa_ds_tokens.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../../core/theme/hexa_colors.dart';

/// Compact operational header: business avatar, date, notifications, settings.
class HomeCompactHeader extends ConsumerWidget {
  const HomeCompactHeader({
    super.key,
    required this.offline,
    this.onSettingsLongPress,
  });

  final bool offline;
  final VoidCallback? onSettingsLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final bellCount = ref.watch(notificationsUnreadCountProvider);
    final title = session?.primaryBusiness.effectiveDisplayTitle ?? 'Home';
    final code = _warehouseCode(session?.primaryBusiness.id);
    final initial = title.trim().isNotEmpty ? title.trim()[0].toUpperCase() : 'H';

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          GestureDetector(
            onLongPress: onSettingsLongPress,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: HexaColors.brandPrimary.withValues(alpha: 0.12),
              child: Text(
                initial,
                style: HexaDsType.heading(16, color: HexaColors.brandPrimary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HexaDsType.heading(15, color: HexaDsColors.textPrimary),
                ),
                Text(
                  code,
                  style: HexaDsType.labelCaps(context).copyWith(
                    fontSize: 10,
                    color: HexaDsColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('EEE, d MMM').format(DateTime.now()),
                style: HexaDsType.bodySm(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: HexaDsColors.textPrimary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: offline
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    offline ? 'Offline' : 'Synced',
                    style: HexaDsType.labelCaps(context).copyWith(
                      fontSize: 10,
                      color: offline
                          ? HexaDsColors.textMuted
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: bellCount > 0,
              label: Text(
                bellCount > 99 ? '99+' : '$bellCount',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
              ),
              child: const Icon(Icons.notifications_outlined, size: 22),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined, size: 22),
          ),
        ],
      ),
    );
  }

  static String _warehouseCode(String? businessId) {
    if (businessId == null || businessId.isEmpty) return 'WH';
    final clean = businessId.replaceAll('-', '');
    if (clean.length >= 4) return 'WH-${clean.substring(0, 4).toUpperCase()}';
    return 'WH-${clean.toUpperCase()}';
  }
}
