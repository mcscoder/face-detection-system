import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/app_controller.dart';

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
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _MetricTile(
                  label: 'People',
                  value: '${state.people.length}',
                  icon: Icons.people_outline,
                ),
                const SizedBox(width: 12),
                _MetricTile(
                  label: 'Events',
                  value: '${state.events.length}',
                  icon: Icons.history,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricTile(
                  label: 'Threshold',
                  value: (state.config?.threshold ?? 0).toStringAsFixed(2),
                  icon: Icons.tune,
                ),
                const SizedBox(width: 12),
                _MetricTile(
                  label: 'Server',
                  value: state.serverInfo?.status ?? 'ready',
                  icon: Icons.dns_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _Panel(
              title: 'Quick Actions',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionButton(
                    icon: Icons.people_outline,
                    label: 'People',
                    onTap: onOpenPeople,
                  ),
                  _ActionButton(
                    icon: Icons.person_add_alt,
                    label: 'Enroll',
                    onTap: onOpenEnroll,
                  ),
                  _ActionButton(
                    icon: Icons.center_focus_strong,
                    label: 'Verify',
                    onTap: onOpenVerify,
                  ),
                  _ActionButton(
                    icon: Icons.receipt_long,
                    label: 'Events',
                    onTap: onOpenEvents,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Panel(
              title: 'People Directory',
              actionLabel: 'Open',
              onAction: onOpenPeople,
              child: Column(
                children: [
                  for (final person in state.people.take(3))
                    _PersonPreview(person: person),
                  if (state.people.isEmpty)
                    const _EmptyLine(text: 'No people loaded.'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Panel(
              title: 'Recent Activity',
              actionLabel: 'View',
              onAction: onOpenEvents,
              child: latestEvent == null
                  ? const _EmptyLine(text: 'No recent events.')
                  : _EventPreview(event: latestEvent),
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: _panelDecoration,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xff0f766e)),
              const SizedBox(height: 14),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: Color(0xff64748b))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _panelDecoration,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                if (actionLabel != null)
                  TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
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
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      side: const BorderSide(color: Color(0xffcbd5e1)),
    );
  }
}

class _PersonPreview extends StatelessWidget {
  const _PersonPreview({required this.person});

  final PersonSummary person;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person_outline),
      title: Text(person.displayName),
      subtitle: Text(person.accessStatus),
    );
  }
}

class _EventPreview extends StatelessWidget {
  const _EventPreview({required this.event});

  final RecognitionEvent event;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.receipt_long),
      title: Text(event.decision.name),
      subtitle: Text(event.id),
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
      child: Text(text, style: const TextStyle(color: Color(0xff64748b))),
    );
  }
}

final _panelDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xffe2e8f0)),
  borderRadius: BorderRadius.circular(8),
);
