import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../widgets/manager_ui.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({
    super.key,
    required this.onOpenPeople,
    required this.onOpenEnroll,
    required this.onOpenVerify,
    required this.onOpenEvents,
  });

  final VoidCallback onOpenPeople;
  final VoidCallback onOpenEnroll;
  final VoidCallback onOpenVerify;
  final VoidCallback onOpenEvents;

  @override
  Widget build(BuildContext context) {
    return ManagerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ManagerSectionTitle(title: 'Quick Actions'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionButton(
                icon: Icons.people_outline,
                label: 'People',
                onTap: onOpenPeople,
              ),
              _ActionButton(
                icon: Icons.person_add_alt_1_outlined,
                label: 'Enrollment',
                onTap: onOpenEnroll,
              ),
              _ActionButton(
                icon: Icons.center_focus_strong,
                label: 'Face Check',
                onTap: onOpenVerify,
              ),
              _ActionButton(
                icon: Icons.receipt_long,
                label: 'Events',
                onTap: onOpenEvents,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardPeoplePreview extends StatelessWidget {
  const DashboardPeoplePreview({
    super.key,
    required this.people,
    required this.onOpenPeople,
  });

  final List<PersonSummary> people;
  final VoidCallback onOpenPeople;

  @override
  Widget build(BuildContext context) {
    return ManagerCard(
      child: Column(
        children: [
          ManagerSectionTitle(
            title: 'People Directory',
            actionLabel: 'Open',
            onAction: onOpenPeople,
          ),
          const SizedBox(height: 8),
          if (people.isEmpty)
            const _EmptyLine(text: 'No people loaded.')
          else
            for (final person in people.take(3))
              ManagerListRow(
                icon: Icons.person_outline,
                title: person.displayName,
                subtitle: person.accessStatus,
                color: managerBlue,
              ),
        ],
      ),
    );
  }
}

class DashboardRecentActivity extends StatelessWidget {
  const DashboardRecentActivity({
    super.key,
    required this.event,
    required this.onOpenEvents,
  });

  final RecognitionEvent? event;
  final VoidCallback onOpenEvents;

  @override
  Widget build(BuildContext context) {
    return ManagerCard(
      child: Column(
        children: [
          ManagerSectionTitle(
            title: 'Recent Activity',
            actionLabel: 'View',
            onAction: onOpenEvents,
          ),
          const SizedBox(height: 8),
          if (event == null)
            const _EmptyLine(text: 'No recent events.')
          else
            ManagerListRow(
              icon: Icons.receipt_long,
              title: event!.decision.name,
              subtitle: event!.id,
              color: _decisionColor(event!.decision),
              trailing: const Icon(Icons.chevron_right),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

Color _decisionColor(RecognitionDecision decision) {
  return switch (decision) {
    RecognitionDecision.allow => managerGreen,
    RecognitionDecision.deny || RecognitionDecision.error => managerRed,
    RecognitionDecision.review => managerOrange,
    RecognitionDecision.noFace ||
    RecognitionDecision.multiFace ||
    RecognitionDecision.lowQuality =>
      managerBlue,
  };
}
