import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/app_controller.dart';
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
        final people = state.people.where((person) {
          final needle = query.toLowerCase();
          return needle.isEmpty ||
              person.displayName.toLowerCase().contains(needle) ||
              person.id.toLowerCase().contains(needle);
        }).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(
                  'People',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: canEnroll ? widget.onAddPerson : null,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PeopleSummary(count: state.people.length),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search people',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => query = value.trim()),
            ),
            const SizedBox(height: 12),
            if (!canEnroll)
              const StatusBanner(
                label: 'Read-only for this role.',
                tone: BannerTone.warning,
              ),
            const SizedBox(height: 8),
            for (final person in people)
              _PersonTile(
                person: person,
                onOpen: () => _openPerson(context, person),
              ),
            if (people.isEmpty)
              const StatusBanner(
                label: 'No people loaded.',
                tone: BannerTone.info,
              ),
          ],
        );
      },
    );
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffe5e7eb)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _MetricBadge(label: 'Users', value: '$count'),
          const SizedBox(width: 12),
          const _MetricBadge(label: 'Mode', value: 'Manager'),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xfff8fafc),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xff64748b),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person, required this.onOpen});

  final PersonSummary person;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xffe0f2fe),
          foregroundColor: const Color(0xff0369a1),
          child: Text(
            person.displayName.isEmpty
                ? '?'
                : person.displayName[0].toUpperCase(),
          ),
        ),
        title: Text(
          person.displayName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(person.id),
        onTap: onOpen,
        trailing: IconButton(
          tooltip: 'Open',
          onPressed: onOpen,
          icon: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
