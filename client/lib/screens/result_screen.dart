import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../widgets/status_banner.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final RecognitionResult result;

  @override
  Widget build(BuildContext context) {
    final status = _statusFor(result.decision);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatusBanner(label: status.label, tone: status.tone, icon: status.icon),
        const SizedBox(height: 12),
        _Metric(label: 'Person', value: result.personId ?? 'Unknown'),
        _Metric(label: 'Score', value: _formatDouble(result.similarityScore)),
        _Metric(label: 'Threshold', value: _formatDouble(result.threshold)),
        _Metric(label: 'Event', value: result.eventId ?? 'Not recorded'),
        if (result.message != null)
          _Metric(label: 'Message', value: result.message!),
      ],
    );
  }
}

({String label, BannerTone tone, IconData icon}) _statusFor(
  RecognitionDecision decision,
) {
  return switch (decision) {
    RecognitionDecision.allow => (
        label: 'Allowed',
        tone: BannerTone.success,
        icon: Icons.check_circle,
      ),
    RecognitionDecision.deny => (
        label: 'Denied',
        tone: BannerTone.warning,
        icon: Icons.block,
      ),
    RecognitionDecision.review => (
        label: 'Needs review',
        tone: BannerTone.warning,
        icon: Icons.manage_search,
      ),
    RecognitionDecision.noFace => (
        label: 'No face detected',
        tone: BannerTone.warning,
        icon: Icons.face_retouching_off,
      ),
    RecognitionDecision.multiFace => (
        label: 'Multiple faces detected',
        tone: BannerTone.warning,
        icon: Icons.groups,
      ),
    RecognitionDecision.lowQuality => (
        label: 'Low image quality',
        tone: BannerTone.warning,
        icon: Icons.blur_on,
      ),
    RecognitionDecision.error => (
        label: 'System error',
        tone: BannerTone.error,
        icon: Icons.error,
      ),
  };
}

String _formatDouble(double? value) {
  return value == null ? 'Not available' : value.toStringAsFixed(2);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
