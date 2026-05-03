import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/app_controller.dart';
import '../widgets/status_banner.dart';
import 'result_screen.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.value;
        final result = state.lastResult;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xff111827),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.center_focus_strong,
                      color: Colors.white70,
                      size: 96,
                    ),
                    Container(
                      width: 180,
                      height: 230,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(90),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.message != null) ...[
              StatusBanner(label: state.message!, tone: BannerTone.error),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: state.isBusy ? null : controller.identifyDemoImage,
              icon: const Icon(Icons.camera_alt),
              label: Text(state.isBusy ? 'Checking...' : 'Capture / Upload'),
            ),
            const SizedBox(height: 16),
            if (result == null)
              const StatusBanner(
                label:
                    'Ready for capture. Camera integration will attach here.',
                tone: BannerTone.info,
              )
            else
              ResultScreen(result: result),
            if (result?.decision == RecognitionDecision.error)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Retry or contact admin if this continues.'),
              ),
          ],
        );
      },
    );
  }
}
