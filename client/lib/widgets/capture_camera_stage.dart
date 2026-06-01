import 'package:flutter/material.dart';

import '../services/enrollment_camera_session.dart';

class CaptureCameraStage extends StatelessWidget {
  const CaptureCameraStage({
    super.key,
    required this.cameraSession,
    required this.isStarting,
    required this.isCapturing,
  });

  final EnrollmentCameraSession cameraSession;
  final bool isStarting;
  final bool isCapturing;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: cameraSession.previewAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xff111827)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (cameraSession.isReady)
                cameraSession.buildPreview()
              else
                const Icon(
                  Icons.center_focus_strong,
                  color: Colors.white70,
                  size: 96,
                ),
              _CaptureGuideOverlay(
                isReady: cameraSession.isReady,
                isStarting: isStarting,
                isCapturing: isCapturing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureGuideOverlay extends StatelessWidget {
  const _CaptureGuideOverlay({
    required this.isReady,
    required this.isStarting,
    required this.isCapturing,
  });

  final bool isReady;
  final bool isStarting;
  final bool isCapturing;

  @override
  Widget build(BuildContext context) {
    final label = isStarting
        ? 'Starting camera'
        : isCapturing
            ? 'Checking'
            : isReady
                ? 'Identify'
                : 'Camera unavailable';
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 190,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(95),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 16,
          child: _OverlayLabel(text: label),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _OverlayLabel(
            text: isReady
                ? 'Center your face in the guide.'
                : 'Camera starts when this screen opens.',
          ),
        ),
      ],
    );
  }
}

class _OverlayLabel extends StatelessWidget {
  const _OverlayLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
