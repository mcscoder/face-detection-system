import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../widgets/manager_ui.dart';
import 'manager_dashboard_metrics.dart';
import 'manager_dashboard_panels.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({
    super.key,
    required this.controller,
    required this.onOpenPeople,
    required this.onOpenEnroll,
    required this.onOpenVerify,
    required this.onOpenEvents,
  });

  final AppController controller;
  final VoidCallback onOpenPeople;
  final VoidCallback onOpenEnroll;
  final VoidCallback onOpenVerify;
  final VoidCallback onOpenEvents;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.value;
        final latestEvent = state.events.isEmpty ? null : state.events.first;
        return ManagerPage(
          title: 'Dashboard',
          subtitle: 'Face access overview',
          children: [
            DashboardMetricGrid(state: state),
            const SizedBox(height: 16),
            DashboardQuickActions(
              onOpenPeople: onOpenPeople,
              onOpenEnroll: onOpenEnroll,
              onOpenVerify: onOpenVerify,
              onOpenEvents: onOpenEvents,
            ),
            const SizedBox(height: 16),
            DashboardPeoplePreview(
              people: state.people,
              onOpenPeople: onOpenPeople,
            ),
            const SizedBox(height: 16),
            DashboardRecentActivity(
              event: latestEvent,
              onOpenEvents: onOpenEvents,
            ),
          ],
        );
      },
    );
  }
}
