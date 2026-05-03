import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/app_controller.dart';
import '../widgets/status_banner.dart';
import 'person_detail_screen.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key, required this.controller, this.onAddPerson});

  final AppController controller;
  final VoidCallback? onAddPerson;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.value;
        final canEnroll = state.session?.canEnroll ?? false;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text('People', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                FilledButton.icon(
                  onPressed: canEnroll ? onAddPerson : null,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!canEnroll)
              const StatusBanner(
                label: 'Read-only for this role.',
                tone: BannerTone.warning,
              ),
            const SizedBox(height: 8),
            for (final person in state.people)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(person.displayName),
                  subtitle: Text(person.id),
                  onTap: () => _openPerson(context, person),
                  trailing: IconButton(
                    tooltip: 'Open',
                    onPressed: () => _openPerson(context, person),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ),
              ),
            if (state.people.isEmpty)
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
          controller: controller,
          initialPerson: person,
        ),
      ),
    );
  }
}
