import 'package:flutter/material.dart';

import 'manager_ui.dart';

class ManagerShellDestination {
  const ManagerShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const managerShellDestinations = [
  ManagerShellDestination(
    label: 'Dashboard',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view,
  ),
  ManagerShellDestination(
    label: 'People',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
  ),
  ManagerShellDestination(
    label: 'Enroll',
    icon: Icons.person_add_alt_1_outlined,
    selectedIcon: Icons.badge,
  ),
  ManagerShellDestination(
    label: 'Verify',
    icon: Icons.camera_alt_outlined,
    selectedIcon: Icons.photo_camera,
  ),
  ManagerShellDestination(
    label: 'Events',
    icon: Icons.history,
    selectedIcon: Icons.receipt_long,
  ),
  ManagerShellDestination(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

class ManagerSidebar extends StatelessWidget {
  const ManagerSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      margin: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      decoration: BoxDecoration(
        color: managerSidebar,
        border: Border.all(color: managerBorder),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        indicatorColor: managerBlue.withValues(alpha: 0.12),
        selectedIconTheme: const IconThemeData(color: managerBlue),
        unselectedIconTheme: const IconThemeData(color: managerMutedText),
        selectedLabelTextStyle: const TextStyle(
          color: managerBlue,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: managerMutedText,
          fontWeight: FontWeight.w700,
        ),
        labelType: NavigationRailLabelType.all,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        leading: const Padding(
          padding: EdgeInsets.only(top: 14, bottom: 18),
          child: ManagerIconTile(
            icon: Icons.admin_panel_settings,
            color: managerBlue,
          ),
        ),
        destinations: [
          for (final destination in managerShellDestinations)
            NavigationRailDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: Text(destination.label),
            ),
        ],
      ),
    );
  }
}

class ManagerBottomNavigation extends StatelessWidget {
  const ManagerBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: managerSurface,
        border: Border.all(color: managerBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (var index = 0; index < managerShellDestinations.length; index++)
            Expanded(
              child: _BottomNavButton(
                destination: managerShellDestinations[index],
                selected: selectedIndex == index,
                onTap: () => onDestinationSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final ManagerShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? managerBlue : managerMutedText;
    return Tooltip(
      message: destination.label,
      child: Semantics(
        label: destination.label,
        button: true,
        selected: selected,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? managerBlue.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                selected ? destination.selectedIcon : destination.icon,
                color: color,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
