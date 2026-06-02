import 'dart:async';

import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../services/enrollment_camera_session.dart';
import '../state/app_controller.dart';
import '../widgets/capture_camera_stage.dart';
import '../widgets/face_oval_guide.dart';
import '../widgets/manager_ui.dart';
import '../widgets/status_banner.dart';
import 'result_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({
    super.key,
    required this.controller,
    this.cameraSession,
    this.publicMode = false,
  });

  final AppController controller;
  final EnrollmentCameraSession? cameraSession;
  final bool publicMode;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

enum _CaptureRunState { startingCamera, idle, capturing }

class _CaptureScreenState extends State<CaptureScreen> {
  late final EnrollmentCameraSession _cameraSession =
      widget.cameraSession ?? LiveEnrollmentCameraSession();
  _CaptureRunState runState = _CaptureRunState.startingCamera;
  late bool _hideInitialPublicResult;
  String? statusText;

  @override
  void initState() {
    super.initState();
    _hideInitialPublicResult =
        widget.publicMode && widget.controller.value.lastResult != null;
    if (_hideInitialPublicResult) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.controller.clearLastResult();
        setState(() => _hideInitialPublicResult = false);
      });
    }
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
      if (widget.publicMode) {
        await widget.controller.identifyUserImage(
          fileName: capture.fileName,
          bytes: capture.bytes,
        );
      } else {
        await widget.controller.identifyImage(
          fileName: capture.fileName,
          bytes: capture.bytes,
        );
      }
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
    if (widget.publicMode) {
      return AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final state = widget.controller.value;
          final isActive = state.isBusy ||
              runState == _CaptureRunState.startingCamera ||
              runState == _CaptureRunState.capturing;
          final result = _hideInitialPublicResult ? null : state.lastResult;
          if (result != null) {
            return _PublicVerifyResult(
              result: result,
              onDone: () => Navigator.of(context).maybePop(),
              onRetry: () {
                widget.controller.clearLastResult();
                setState(() => statusText = 'Position your face.');
              },
            );
          }
          return _PublicVerifyCamera(
            cameraSession: _cameraSession,
            statusText: _publicStatusText(state.message),
            isStarting: runState == _CaptureRunState.startingCamera,
            isScanning: runState == _CaptureRunState.capturing,
            canScan: !isActive && _cameraSession.isReady,
            onScan: _identifyFromCamera,
          );
        },
      );
    }
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;
        final result = state.lastResult;
        final isActive = state.isBusy ||
            runState == _CaptureRunState.startingCamera ||
            runState == _CaptureRunState.capturing;
        return ManagerPage(
          title: 'Face Check',
          subtitle: 'Capture a live probe and review the decision',
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
              icon: const Icon(Icons.center_focus_strong),
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

  String _publicStatusText(String? message) {
    if (message != null) return message;
    if (runState == _CaptureRunState.startingCamera) return 'Starting camera';
    if (runState == _CaptureRunState.capturing) return 'Scanning';
    if (!_cameraSession.isReady) return statusText ?? 'Camera unavailable';
    return 'Position your face';
  }
}

class _PublicVerifyCamera extends StatelessWidget {
  const _PublicVerifyCamera({
    required this.cameraSession,
    required this.statusText,
    required this.isStarting,
    required this.isScanning,
    required this.canScan,
    required this.onScan,
  });

  final EnrollmentCameraSession cameraSession;
  final String statusText;
  final bool isStarting;
  final bool isScanning;
  final bool canScan;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _PublicCameraSurface(
                cameraSession: cameraSession,
                isScanning: isScanning,
              ),
            ),
            Positioned(
              left: 12,
              top: 8,
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                color: Colors.white,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: canScan ? onScan : null,
                    icon: Icon(
                      isStarting
                          ? Icons.hourglass_top
                          : Icons.center_focus_strong,
                    ),
                    label: Text(isScanning ? 'Scanning' : 'Scan Face'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicCameraSurface extends StatelessWidget {
  const _PublicCameraSurface({
    required this.cameraSession,
    required this.isScanning,
  });

  final EnrollmentCameraSession cameraSession;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: cameraSession.previewAspectRatio,
              child: cameraSession.isReady
                  ? cameraSession.buildPreview()
                  : const ColoredBox(color: Colors.black),
            ),
          ),
        ),
        FaceOvalGuide(showScan: isScanning, progress: isScanning ? 0.55 : 0),
      ],
    );
  }
}

class _PublicVerifyResult extends StatelessWidget {
  const _PublicVerifyResult({
    required this.result,
    required this.onDone,
    required this.onRetry,
  });

  final RecognitionResult result;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final view = _resultView(result.decision);
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: view.color, width: 6),
                ),
                child: Icon(view.icon, color: view.color, size: 72),
              ),
              const SizedBox(height: 28),
              Text(
                view.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                view.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: result.decision == RecognitionDecision.allow
                    ? onDone
                    : onRetry,
                child: Text(
                  result.decision == RecognitionDecision.allow
                      ? 'Done'
                      : 'Try Again',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

({String title, String message, Color color, IconData icon}) _resultView(
  RecognitionDecision decision,
) {
  return switch (decision) {
    RecognitionDecision.allow => (
        title: 'Verified',
        message: 'Identity accepted.',
        color: const Color(0xff34c759),
        icon: Icons.check,
      ),
    RecognitionDecision.noFace => (
        title: 'No face found',
        message: 'Center your face in the guide.',
        color: const Color(0xffffcc00),
        icon: Icons.face_retouching_off,
      ),
    RecognitionDecision.multiFace => (
        title: 'Multiple faces',
        message: 'Only one face can be scanned.',
        color: const Color(0xffffcc00),
        icon: Icons.groups,
      ),
    RecognitionDecision.lowQuality => (
        title: 'Image too blurry',
        message: 'Hold steady and try again.',
        color: const Color(0xffffcc00),
        icon: Icons.blur_on,
      ),
    RecognitionDecision.review || RecognitionDecision.error => (
        title: 'Try again',
        message: 'The scan could not be completed.',
        color: const Color(0xffffcc00),
        icon: Icons.refresh,
      ),
    RecognitionDecision.deny => (
        title: 'Not verified',
        message: 'Face did not match an enrolled user.',
        color: const Color(0xffff3b30),
        icon: Icons.close,
      ),
  };
}
