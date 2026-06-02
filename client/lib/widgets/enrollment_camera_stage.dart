import 'package:flutter/material.dart';

import '../models/guided_enrollment.dart';
import '../services/enrollment_camera_session.dart';
import 'face_oval_guide.dart';

class EnrollmentCameraStage extends StatelessWidget {
  const EnrollmentCameraStage({
    super.key,
    required this.cameraSession,
    required this.prompt,
    required this.countdownSeconds,
    required this.isStarting,
    required this.isActive,
  });

  final EnrollmentCameraSession cameraSession;
  final EnrollmentPrompt prompt;
  final int countdownSeconds;
  final bool isStarting;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: cameraSession.previewAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.black),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (cameraSession.isReady)
                cameraSession.buildPreview()
              else
                const Icon(
                  Icons.camera_front_outlined,
                  color: Colors.white54,
                  size: 72,
                ),
              _FaceGuideOverlay(
                prompt: prompt,
                countdownSeconds: countdownSeconds,
                isStarting: isStarting,
                isActive: isActive,
                isReady: cameraSession.isReady,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaceGuideOverlay extends StatelessWidget {
  const _FaceGuideOverlay({
    required this.prompt,
    required this.countdownSeconds,
    required this.isStarting,
    required this.isActive,
    required this.isReady,
  });

  final EnrollmentPrompt prompt;
  final int countdownSeconds;
  final bool isStarting;
  final bool isActive;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final label = isStarting
        ? 'Starting camera'
        : countdownSeconds > 0
            ? '$countdownSeconds'
            : prompt.title;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(color: Colors.black.withValues(alpha: 0.08)),
        FaceOvalGuide(
          color: Colors.white.withValues(
            alpha: isReady || isActive ? 0.9 : 0.5,
          ),
          showScan: countdownSeconds == 0 && isActive,
          progress: 0.48,
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 16,
          child: _OverlayLabel(text: label, large: countdownSeconds > 0),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _OverlayLabel(
            text: isReady || isActive
                ? prompt.instruction
                : 'Create a person to start camera setup.',
          ),
        ),
      ],
    );
  }
}

class _OverlayLabel extends StatelessWidget {
  const _OverlayLabel({required this.text, this.large = false});

  final String text;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: large ? 28 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
