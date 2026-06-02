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
            Text(
              'Events',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DecisionChip(
                  label: 'All',
                  selected: filter == null,
                  onSelected: () => setState(() => filter = null),
                ),
                _DecisionChip(
                  label: 'Allow',
                  selected: filter == RecognitionDecision.allow,
                  onSelected: () {
                    setState(() => filter = RecognitionDecision.allow);
                  },
                ),
                _DecisionChip(
                  label: 'Deny',
                  selected: filter == RecognitionDecision.deny,
                  onSelected: () {
                    setState(() => filter = RecognitionDecision.deny);
                  },
                ),
                _DecisionChip(
                  label: 'No face',
                  selected: filter == RecognitionDecision.noFace,
                  onSelected: () {
                    setState(() => filter = RecognitionDecision.noFace);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final event in events) _EventTile(event: event),
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

class _DecisionChip extends StatelessWidget {
  const _DecisionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      side: BorderSide(
        color: selected ? const Color(0xff0a84ff) : const Color(0xffd1d5db),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final RecognitionEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xfff1f5f9),
          foregroundColor: const Color(0xff0f172a),
          child: Icon(_iconFor(event.decision), size: 20),
        ),
        title: Text(
          event.id,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${event.createdAt.toLocal()}'),
        trailing: Text(
          _labelFor(event.decision),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
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
