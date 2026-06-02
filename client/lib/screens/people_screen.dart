import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/app_controller.dart';
import '../widgets/manager_ui.dart';
import '../widgets/status_banner.dart';
import 'person_detail_screen.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key, required this.controller, this.onAddPerson});

  final AppController controller;
  final VoidCallback? onAddPerson;

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;
        final canEnroll = state.session?.canEnroll ?? false;
        final people = state.people.where(_matchesQuery).toList();
        return ManagerPage(
          title: 'People',
          subtitle: 'Search and manage enrolled identities',
          trailing: FilledButton.icon(
            onPressed: canEnroll ? widget.onAddPerson : null,
            icon: const Icon(Icons.person_add),
            label: const Text('Add'),
          ),
          children: [
            _PeopleSummary(count: state.people.length),
            const SizedBox(height: 14),
            ManagerCard(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search people',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => query = value.trim()),
              ),
            ),
            const SizedBox(height: 14),
            if (!canEnroll) ...[
              const StatusBanner(
                label: 'Read-only for this role.',
                tone: BannerTone.warning,
              ),
              const SizedBox(height: 12),
            ],
            ManagerCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (final person in people)
                    ManagerListRow(
                      icon: Icons.person_outline,
                      title: person.displayName,
                      subtitle: person.id,
                      color: _statusColor(person.accessStatus),
                      onTap: () => _openPerson(context, person),
                      trailing: IconButton(
                        tooltip: 'Open',
                        onPressed: () => _openPerson(context, person),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ),
                  if (people.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: StatusBanner(
                        label: 'No people loaded.',
                        tone: BannerTone.info,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool _matchesQuery(PersonSummary person) {
    final needle = query.toLowerCase();
    return needle.isEmpty ||
        person.displayName.toLowerCase().contains(needle) ||
        person.id.toLowerCase().contains(needle);
  }

  void _openPerson(BuildContext context, PersonSummary person) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonDetailScreen(
          controller: widget.controller,
          initialPerson: person,
        ),
      ),
    );
  }
}

class _PeopleSummary extends StatelessWidget {
  const _PeopleSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ManagerCard(
      child: Row(
        children: [
          Expanded(
            child: _SummaryCell(
              label: 'Users',
              value: '$count',
              icon: Icons.people_outline,
              color: managerBlue,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: _SummaryCell(
              label: 'Mode',
              value: 'Manager',
              icon: Icons.admin_panel_settings_outlined,
              color: managerGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 180;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: managerSurfaceMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManagerIconTile(icon: icon, color: color),
                      const SizedBox(height: 10),
                      _SummaryText(label: label, value: value),
                    ],
                  )
                : Row(
                    children: [
                      ManagerIconTile(icon: icon, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryText(label: label, value: value),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _SummaryText extends StatelessWidget {
  const _SummaryText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

Color _statusColor(String status) {
  final value = status.toLowerCase();
  if (value.contains('active') || value.contains('allow')) return managerGreen;
  if (value.contains('deny') || value.contains('blocked')) return managerRed;
  return managerBlue;
}
