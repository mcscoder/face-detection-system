import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../widgets/status_banner.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  int acceptedSamples = 0;
  String personId = '';

  @override
  Widget build(BuildContext context) {
    final remaining = (3 - acceptedSamples).clamp(0, 3);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Enrollment', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(labelText: 'Person ID'),
          onChanged: (value) => setState(() => personId = value.trim()),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: acceptedSamples / 5),
        const SizedBox(height: 8),
        Text('$acceptedSamples accepted samples. $remaining more required.'),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: acceptedSamples >= 5
              ? null
              : () => setState(() => acceptedSamples++),
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Add Sample'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: acceptedSamples >= 3 && personId.isNotEmpty ? () {} : null,
          icon: const Icon(Icons.cloud_upload),
          label: const Text('Submit Enrollment'),
        ),
        const SizedBox(height: 16),
        const StatusBanner(
          label:
              'Samples should be clear, single-face images. Server performs quality checks.',
          tone: BannerTone.info,
        ),
      ],
    );
  }
}
