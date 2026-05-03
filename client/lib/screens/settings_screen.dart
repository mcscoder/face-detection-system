import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../widgets/status_banner.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.value;
        final config = state.config;
        final canAdmin = state.session?.canAdmin ?? false;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (!canAdmin)
              const StatusBanner(
                label: 'Settings are admin-only.',
                tone: BannerTone.warning,
              ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: canAdmin,
              initialValue: (config?.threshold ?? 0.5).toStringAsFixed(2),
              decoration: const InputDecoration(
                labelText: 'Recognition threshold',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              enabled: canAdmin,
              initialValue: '${config?.retentionDays ?? 30}',
              decoration: const InputDecoration(
                labelText: 'Probe retention days',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: canAdmin ? () {} : null,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
            const SizedBox(height: 16),
            const StatusBanner(
              label:
                  'Threshold changes affect future recognition decisions only.',
              tone: BannerTone.info,
            ),
          ],
        );
      },
    );
  }
}
