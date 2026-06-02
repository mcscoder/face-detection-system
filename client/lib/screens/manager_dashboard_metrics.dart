import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../widgets/manager_ui.dart';

class DashboardMetricGrid extends StatelessWidget {
  const DashboardMetricGrid({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ManagerMetricCard(
        label: 'People',
        value: '${state.people.length}',
        icon: Icons.people_outline,
        color: managerBlue,
      ),
      ManagerMetricCard(
        label: 'Events',
        value: '${state.events.length}',
        icon: Icons.history,
        color: managerOrange,
      ),
      ManagerMetricCard(
        label: 'Threshold',
        value: (state.config?.threshold ?? 0).toStringAsFixed(2),
        icon: Icons.tune,
        color: managerGreen,
      ),
      ManagerMetricCard(
        label: 'Server',
        value: state.serverInfo?.status ?? 'ready',
        icon: Icons.dns_outlined,
        color: managerBlue,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 420
            ? 1
            : constraints.maxWidth < 760
                ? 2
                : 4;
        final aspectRatio = columns == 1
            ? 2.0
            : columns == 2
                ? 1.45
                : 1.18;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: metrics,
        );
      },
    );
  }
}
