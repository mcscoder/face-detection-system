import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/app_controller.dart';
import '../widgets/manager_ui.dart';
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
        return ManagerPage(
          title: 'Events',
          subtitle: 'Recognition decisions and audit activity',
          children: [
            ManagerCard(
              child: Wrap(
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
            ),
            const SizedBox(height: 14),
            ManagerCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (final event in events) _EventTile(event: event),
                  if (events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: StatusBanner(
                        label: 'No events match the current filter.',
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
      selectedColor: managerBlue.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: selected ? managerBlue : managerText,
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(
        color: selected ? managerBlue : managerBorder,
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final RecognitionEvent event;

  @override
  Widget build(BuildContext context) {
    final color = _decisionColor(event.decision);
    return ManagerListRow(
      icon: _iconFor(event.decision),
      title: event.id,
      subtitle: '${event.createdAt.toLocal()}',
      color: color,
      trailing: ManagerPill(label: _labelFor(event.decision), color: color),
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

String _labelFor(RecognitionDecision decision) => decision.name;
