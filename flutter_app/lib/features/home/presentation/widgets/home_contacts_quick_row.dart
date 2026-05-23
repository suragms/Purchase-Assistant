import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fast links to suppliers, brokers, and catalog items.
class HomeContactsQuickRow extends StatelessWidget {
  const HomeContactsQuickRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickTile(
            icon: Icons.local_shipping_outlined,
            label: 'Suppliers',
            onTap: () => context.push('/contacts?tab=suppliers'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickTile(
            icon: Icons.handshake_outlined,
            label: 'Brokers',
            onTap: () => context.push('/contacts?tab=brokers'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickTile(
            icon: Icons.inventory_2_outlined,
            label: 'Items',
            onTap: () => context.push('/search'),
          ),
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0DDD8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: const Color(0xFF1A6B8A)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
