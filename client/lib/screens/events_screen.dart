import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/app_controller.dart';
import '../widgets/status_banner.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  RecognitionDecision? filter;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final events = widget.controller.value.events
            .where((event) => filter == null || event.decision == filter)
            .toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text('Events', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                DropdownButton<RecognitionDecision?>(
                  value: filter,
                  hint: const Text('Decision'),
                  onChanged: (value) => setState(() => filter = value),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(
                      value: RecognitionDecision.allow,
                      child: Text('Allow'),
                    ),
                    DropdownMenuItem(
                      value: RecognitionDecision.deny,
                      child: Text('Deny'),
                    ),
                    DropdownMenuItem(
                      value: RecognitionDecision.noFace,
                      child: Text('No face'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final event in events)
              Card(
                child: ListTile(
                  leading: Icon(_iconFor(event.decision)),
                  title: Text(event.id),
                  subtitle: Text('${event.createdAt.toLocal()}'),
                  trailing: Text(_labelFor(event.decision)),
                ),
              ),
            if (events.isEmpty)
              const StatusBanner(
                label: 'No events match the current filter.',
                tone: BannerTone.info,
              ),
          ],
        );
      },
    );
  }
}

IconData _iconFor(RecognitionDecision decision) {
  return switch (decision) {
    RecognitionDecision.allow => Icons.check_circle,
    RecognitionDecision.deny => Icons.block,
    RecognitionDecision.review => Icons.manage_search,
    RecognitionDecision.noFace => Icons.face_retouching_off,
    RecognitionDecision.multiFace => Icons.groups,
    RecognitionDecision.lowQuality => Icons.blur_on,
    RecognitionDecision.error => Icons.error,
  };
}

String _labelFor(RecognitionDecision decision) => decision.name;
