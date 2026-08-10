import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App-bar entry for Settings + Help (UX-019 discoverability).
class AppSettingsAction extends StatelessWidget {
  const AppSettingsAction({super.key});

  static const settingsValue = 'settings';
  static const helpValue = 'help';

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Settings & help',
      icon: const Icon(Icons.settings_outlined),
      onSelected: (value) {
        switch (value) {
          case helpValue:
            context.push('/settings/help');
          case settingsValue:
            context.go('/settings');
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: settingsValue,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
          ),
        ),
        PopupMenuItem(
          value: helpValue,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.help_outline_rounded),
            title: Text('Help & guide'),
          ),
        ),
      ],
    );
  }
}
