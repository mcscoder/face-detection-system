import 'package:flutter/material.dart';

import '../models/guided_enrollment.dart';
import 'manager_ui.dart';

class EnrollmentActionPanel extends StatelessWidget {
  const EnrollmentActionPanel({
    super.key,
    required this.progress,
    required this.canStart,
    required this.isActive,
    required this.onStart,
    required this.onCancel,
    this.startLabel = 'Start Face Setup',
  });

  final GuidedEnrollmentProgress progress;
  final bool canStart;
  final bool isActive;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  final String startLabel;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return ManagerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    value: progress.value,
                    color: managerBlue,
                    backgroundColor: managerBlue.withValues(alpha: 0.12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress.value * 100).round()}%',
                style: textStyle?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${progress.acceptedSamples} accepted samples. '
            '${progress.remainingRequired} more required.',
            style: textStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: canStart ? onStart : null,
                  icon: const Icon(Icons.face),
                  label: Text(startLabel),
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
      ),
    );
  }
}
