import 'package:flutter/material.dart';

import 'manager_ui.dart';

class ManagerCommandBar extends StatelessWidget {
  const ManagerCommandBar({
    super.key,
    required this.status,
    required this.onRefresh,
    required this.onLogout,
  });

  final String status;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        return Container(
          height: 72,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: managerSurface,
            border: Border.all(color: managerBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Manager Console',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: ManagerPill(
                    label: status,
                    color: managerGreen,
                    icon: Icons.circle,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Logout',
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        );
      },
    );
  }
}
