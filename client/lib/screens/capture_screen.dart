import 'dart:async';

import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../services/enrollment_camera_session.dart';
import '../state/app_controller.dart';
import '../widgets/capture_camera_stage.dart';
import '../widgets/status_banner.dart';
import 'result_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({
    super.key,
    required this.controller,
    this.cameraSession,
  });

  final AppController controller;
  final EnrollmentCameraSession? cameraSession;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

enum _CaptureRunState { startingCamera, idle, capturing }

class _CaptureScreenState extends State<CaptureScreen> {
  late final EnrollmentCameraSession _cameraSession =
      widget.cameraSession ?? LiveEnrollmentCameraSession();
  _CaptureRunState runState = _CaptureRunState.startingCamera;
  String? statusText;

  @override
  void initState() {
    super.initState();
    unawaited(_startCamera());
  }

  @override
  void dispose() {
    unawaited(_cameraSession.dispose());
    super.dispose();
  }

  Future<void> _startCamera() async {
    if (_cameraSession.isReady) {
      setState(() => runState = _CaptureRunState.idle);
      return;
    }
    setState(() {
      runState = _CaptureRunState.startingCamera;
      statusText = 'Starting camera.';
    });
    try {
      await _cameraSession.initialize();
      if (!mounted) return;
      setState(() {
        runState = _CaptureRunState.idle;
        statusText = 'Camera ready.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        runState = _CaptureRunState.idle;
        statusText = 'Camera unavailable.';
      });
    }
  }

  Future<void> _identifyFromCamera() async {
    if (!_cameraSession.isReady) await _startCamera();
    if (!mounted || !_cameraSession.isReady) return;
    setState(() {
      runState = _CaptureRunState.capturing;
      statusText = 'Checking face.';
    });
    try {
      final capture = await _cameraSession.capture();
      if (!mounted) return;
      await widget.controller.identifyImage(
        fileName: capture.fileName,
        bytes: capture.bytes,
      );
      if (!mounted) return;
      setState(() {
        runState = _CaptureRunState.idle;
        statusText = 'Capture checked.';
      });
    } catch (_) {
      if (mounted) {
        widget.controller.showMessage('Could not capture camera image.');
        setState(() => runState = _CaptureRunState.idle);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;
        final result = state.lastResult;
        final isActive = state.isBusy ||
            runState == _CaptureRunState.startingCamera ||
            runState == _CaptureRunState.capturing;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CaptureCameraStage(
              cameraSession: _cameraSession,
              isStarting: runState == _CaptureRunState.startingCamera,
              isCapturing: runState == _CaptureRunState.capturing,
            ),
            const SizedBox(height: 16),
            if (state.message != null) ...[
              StatusBanner(label: state.message!, tone: BannerTone.error),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: isActive || !_cameraSession.isReady
                  ? null
                  : _identifyFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: Text(isActive ? 'Checking...' : 'Check Face'),
            ),
            const SizedBox(height: 16),
            if (result == null)
              StatusBanner(
                label: statusText ?? 'Camera starts when this screen opens.',
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
