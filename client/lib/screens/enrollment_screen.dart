import 'dart:async';

import 'package:flutter/material.dart';

import '../models/guided_enrollment.dart';
import '../services/enrollment_camera_session.dart';
import '../state/app_controller.dart';
import '../widgets/enrollment_action_panel.dart';
import '../widgets/enrollment_camera_stage.dart';
import '../widgets/enrollment_person_form.dart';
import '../widgets/status_banner.dart';

enum _EnrollmentRunState {
  idle,
  startingCamera,
  waiting,
  capturing,
  uploading,
  retrying,
  complete,
}

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({
    super.key,
    required this.controller,
    this.cameraSession,
  });

  final AppController controller;
  final EnrollmentCameraSession? cameraSession;

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final TextEditingController _personIdController = TextEditingController();
  late final EnrollmentCameraSession _cameraSession =
      widget.cameraSession ?? LiveEnrollmentCameraSession();

  GuidedEnrollmentProgress progress = const GuidedEnrollmentProgress();
  String displayName = '';
  String personId = '';
  String? statusText;
  int countdownSeconds = 0;
  _EnrollmentRunState runState = _EnrollmentRunState.idle;
  Timer? _timer;

  bool get _isActive =>
      runState == _EnrollmentRunState.startingCamera ||
      runState == _EnrollmentRunState.waiting ||
      runState == _EnrollmentRunState.capturing ||
      runState == _EnrollmentRunState.uploading ||
      runState == _EnrollmentRunState.retrying;

  @override
  void dispose() {
    _timer?.cancel();
    _personIdController.dispose();
    unawaited(_cameraSession.dispose());
    super.dispose();
  }

  Future<void> _createPerson() async {
    final person = await widget.controller.createPerson(
      displayName: displayName,
    );
    if (!mounted || person == null) return;
    setState(() {
      personId = person.id;
      _personIdController.text = person.id;
      progress = progress.reset();
      statusText = 'Person created. Starting camera.';
    });
    await _startCamera();
  }

  Future<void> _startCamera() async {
    if (_cameraSession.isReady) return;
    setState(() => runState = _EnrollmentRunState.startingCamera);
    try {
      await _cameraSession.initialize();
      if (!mounted) return;
      setState(() {
        runState = _EnrollmentRunState.idle;
        statusText = 'Camera ready.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        runState = _EnrollmentRunState.idle;
        statusText = 'Camera unavailable.';
      });
    }
  }

  Future<void> _beginGuidedCapture() async {
    if (personId.isEmpty || progress.isComplete) return;
    if (!_cameraSession.isReady) await _startCamera();
    if (!mounted || !_cameraSession.isReady) return;
    _scheduleCapture();
  }

  void _scheduleCapture() {
    _timer?.cancel();
    setState(() {
      countdownSeconds = 3;
      runState = _EnrollmentRunState.waiting;
      statusText = 'Hold still for ${progress.currentPrompt.title}.';
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (countdownSeconds > 1) {
        setState(() => countdownSeconds--);
        return;
      }
      timer.cancel();
      unawaited(_captureCurrentPrompt());
    });
  }

  Future<void> _captureCurrentPrompt() async {
    setState(() {
      countdownSeconds = 0;
      runState = _EnrollmentRunState.capturing;
      statusText = 'Capturing ${progress.currentPrompt.title}.';
    });
    try {
      final capture = await _cameraSession.capture();
      if (!mounted) return;
      setState(() {
        runState = _EnrollmentRunState.uploading;
        statusText = 'Checking sample.';
      });
      final template = await widget.controller.uploadEnrollmentSample(
        personId: personId,
        fileName: capture.fileName,
        bytes: capture.bytes,
        expectedPose: progress.currentPrompt.poseCode,
      );
      if (!mounted) return;
      if (template == null) {
        _retryCurrentPrompt(widget.controller.value.message);
        return;
      }
      final nextProgress = progress.acceptSample();
      final quality = template.qualityScore?.toStringAsFixed(2) ?? 'accepted';
      setState(() {
        progress = nextProgress;
        runState = nextProgress.isComplete
            ? _EnrollmentRunState.complete
            : _EnrollmentRunState.waiting;
        statusText = 'Sample accepted. Quality: $quality.';
      });
      if (nextProgress.isComplete) {
        await _cameraSession.dispose();
        if (!mounted) return;
        setState(() => statusText = 'Enrollment ready for identify.');
      } else {
        _scheduleCapture();
      }
    } catch (_) {
      if (!mounted) return;
      widget.controller.showMessage('Could not capture camera sample.');
      setState(() => runState = _EnrollmentRunState.idle);
    }
  }

  void _retryCurrentPrompt(String? message) {
    setState(() {
      runState = _EnrollmentRunState.retrying;
      statusText =
          '${message ?? 'Sample rejected.'} Retrying ${progress.currentPrompt.title}.';
    });
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) _scheduleCapture();
    });
  }

  void _cancelEnrollment() {
    _timer?.cancel();
    setState(() {
      countdownSeconds = 0;
      runState = _EnrollmentRunState.idle;
      statusText = 'Enrollment canceled.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;
        final canEnroll = state.session?.canEnroll ?? false;
        final canCreate =
            canEnroll && !state.isBusy && !_isActive && displayName.isNotEmpty;
        final canStart = canEnroll &&
            !state.isBusy &&
            !_isActive &&
            personId.isNotEmpty &&
            !progress.isComplete;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Enrollment', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            EnrollmentPersonForm(
              isActive: _isActive,
              isBusy: state.isBusy,
              canCreate: canCreate,
              personIdController: _personIdController,
              onDisplayNameChanged: (value) {
                setState(() => displayName = value.trim());
              },
              onPersonIdChanged: (value) {
                setState(() {
                  personId = value.trim();
                  progress = progress.reset();
                  statusText = null;
                });
              },
              onCreatePerson: _createPerson,
            ),
            const SizedBox(height: 16),
            EnrollmentCameraStage(
              cameraSession: _cameraSession,
              prompt: progress.currentPrompt,
              countdownSeconds: countdownSeconds,
              isStarting: runState == _EnrollmentRunState.startingCamera,
              isActive: _isActive,
            ),
            const SizedBox(height: 16),
            EnrollmentActionPanel(
              progress: progress,
              canStart: canStart,
              isActive: _isActive,
              onStart: _beginGuidedCapture,
              onCancel: _cancelEnrollment,
            ),
            const SizedBox(height: 16),
            if (state.message != null) ...[
              StatusBanner(label: state.message!, tone: BannerTone.error),
              const SizedBox(height: 12),
            ],
            if (!canEnroll) ...[
              const StatusBanner(
                label: 'Enrollment role required.',
                tone: BannerTone.warning,
              ),
              const SizedBox(height: 12),
            ],
            if (statusText != null)
              StatusBanner(label: statusText!, tone: BannerTone.info),
          ],
        );
      },
    );
  }
}
