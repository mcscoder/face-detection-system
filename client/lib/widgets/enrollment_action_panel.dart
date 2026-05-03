import 'package:flutter/material.dart';

import '../models/guided_enrollment.dart';

class EnrollmentActionPanel extends StatelessWidget {
  const EnrollmentActionPanel({
    super.key,
    required this.progress,
    required this.canStart,
    required this.isActive,
    required this.onStart,
    required this.onCancel,
  });

  final GuidedEnrollmentProgress progress;
  final bool canStart;
  final bool isActive;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress.value),
        const SizedBox(height: 8),
        Text(
          '${progress.acceptedSamples} accepted samples. '
          '${progress.remainingRequired} more required.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: canStart ? onStart : null,
                icon: const Icon(Icons.face),
                label: const Text('Start Face Setup'),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.outlined(
              tooltip: 'Cancel',
              onPressed: isActive ? onCancel : null,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ],
    );
  }
}
