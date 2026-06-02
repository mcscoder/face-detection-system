import 'dart:async';

import 'package:flutter/material.dart';

import '../models/guided_enrollment.dart';
import '../services/enrollment_camera_session.dart';
import '../state/app_controller.dart';
import '../widgets/face_oval_guide.dart';

enum _UserEnrollmentRunState {
  idle,
  startingCamera,
  waiting,
  capturing,
  uploading,
  retrying,
  complete,
}

class UserEnrollmentScreen extends StatefulWidget {
  const UserEnrollmentScreen({
    super.key,
    required this.controller,
    this.cameraSession,
  });

  final AppController controller;
  final EnrollmentCameraSession? cameraSession;

  @override
  State<UserEnrollmentScreen> createState() => _UserEnrollmentScreenState();
}

class _UserEnrollmentScreenState extends State<UserEnrollmentScreen> {
  late final EnrollmentCameraSession _cameraSession =
      widget.cameraSession ?? LiveEnrollmentCameraSession();
  final TextEditingController _nameController = TextEditingController();

  GuidedEnrollmentProgress progress = const GuidedEnrollmentProgress();
  String personId = '';
  String enrollmentKey = '';
  String? statusText;
  int countdownSeconds = 0;
  int _runToken = 0;
  _UserEnrollmentRunState runState = _UserEnrollmentRunState.idle;
  Timer? _timer;

  bool get _isActive =>
      runState == _UserEnrollmentRunState.startingCamera ||
      runState == _UserEnrollmentRunState.waiting ||
      runState == _UserEnrollmentRunState.capturing ||
      runState == _UserEnrollmentRunState.uploading ||
      runState == _UserEnrollmentRunState.retrying;

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    unawaited(_cameraSession.dispose());
    super.dispose();
  }

  Future<void> _startEnrollment() async {
    final displayName = _nameController.text.trim();
    if (displayName.isEmpty || _isActive) return;
    if (!_cameraSession.isReady) await _startCamera();
    if (!mounted || !_cameraSession.isReady) return;
    final person = await widget.controller.createUserPerson(
      displayName: displayName,
    );
    if (!mounted || person == null) return;
    setState(() {
      personId = person.id;
      enrollmentKey = person.enrollmentKey ?? '';
      progress = progress.reset();
      statusText = 'Starting enrollment.';
    });
    if (enrollmentKey.isEmpty) {
      widget.controller.showMessage('Enrollment could not start.');
      setState(() => runState = _UserEnrollmentRunState.idle);
      return;
    }
    _runToken++;
    _scheduleCapture();
  }

  Future<void> _startCamera() async {
    setState(() => runState = _UserEnrollmentRunState.startingCamera);
    try {
      await _cameraSession.initialize();
      if (!mounted) return;
      setState(() {
        runState = _UserEnrollmentRunState.idle;
        statusText = 'Camera ready.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        runState = _UserEnrollmentRunState.idle;
        statusText = 'Camera unavailable.';
      });
    }
  }

  void _scheduleCapture() {
    _timer?.cancel();
    setState(() {
      countdownSeconds = 3;
      runState = _UserEnrollmentRunState.waiting;
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
    final runToken = _runToken;
    setState(() {
      countdownSeconds = 0;
      runState = _UserEnrollmentRunState.capturing;
      statusText = 'Capturing ${progress.currentPrompt.title}.';
    });
    try {
      final capture = await _cameraSession.capture();
      if (runToken != _runToken) return;
      if (!mounted) return;
      setState(() {
        runState = _UserEnrollmentRunState.uploading;
        statusText = 'Checking sample.';
      });
      final template = await widget.controller.uploadUserEnrollmentSample(
        personId: personId,
        enrollmentKey: enrollmentKey,
        fileName: capture.fileName,
        bytes: capture.bytes,
        expectedPose: progress.currentPrompt.poseCode,
      );
      if (runToken != _runToken) return;
      if (!mounted) return;
      if (template == null) {
        _retryCurrentPrompt(widget.controller.value.message);
        return;
      }
      final nextProgress = progress.acceptSample();
      setState(() {
        progress = nextProgress;
        runState = nextProgress.isComplete
            ? _UserEnrollmentRunState.complete
            : _UserEnrollmentRunState.waiting;
        statusText = nextProgress.isComplete
            ? 'Enrollment complete.'
            : 'Sample accepted.';
      });
      if (nextProgress.isComplete) {
        await _cameraSession.dispose();
      } else {
        _scheduleCapture();
      }
    } catch (_) {
      if (!mounted) return;
      widget.controller.showMessage('Could not capture camera sample.');
      setState(() => runState = _UserEnrollmentRunState.idle);
    }
  }

  void _retryCurrentPrompt(String? message) {
    setState(() {
      runState = _UserEnrollmentRunState.retrying;
      statusText =
          '${message ?? 'Sample rejected.'} Retrying ${progress.currentPrompt.title}.';
    });
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) _scheduleCapture();
    });
  }

  void _cancelEnrollment() {
    _timer?.cancel();
    _runToken++;
    setState(() {
      countdownSeconds = 0;
      runState = _UserEnrollmentRunState.idle;
      personId = '';
      enrollmentKey = '';
      progress = progress.reset();
      statusText = 'Enrollment canceled.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;
        final canStart = !state.isBusy &&
            !_isActive &&
            _nameController.text.trim().isNotEmpty &&
            !progress.isComplete;
        final canRetryCapture = personId.isNotEmpty &&
            !_isActive &&
            !state.isBusy &&
            !progress.isComplete;
        return _PublicEnrollmentTheme(
          child: runState == _UserEnrollmentRunState.complete
              ? _EnrollmentCompleteView(
                  progressLabel: _progressLabel,
                  onDone: () => Navigator.of(context).maybePop(),
                )
              : personId.isEmpty
                  ? _EnrollmentNameStep(
                      controller: _nameController,
                      canStart: canStart,
                      isBusy: state.isBusy || _isActive,
                      statusText: state.message ?? statusText,
                      onChanged: () => setState(() {}),
                      onStart: _startEnrollment,
                    )
                  : _EnrollmentCaptureStep(
                      cameraSession: _cameraSession,
                      progress: progress,
                      countdownSeconds: countdownSeconds,
                      statusText: state.message ?? statusText,
                      isScanning:
                          runState == _UserEnrollmentRunState.capturing ||
                              runState == _UserEnrollmentRunState.uploading,
                      progressLabel: _progressLabel,
                      canRetry: canRetryCapture,
                      onRetry: _scheduleCapture,
                      onCancel: _cancelEnrollment,
                    ),
        );
      },
    );
  }

  String get _progressLabel {
    return '${progress.acceptedSamples} accepted samples. '
        '${progress.remainingRequired} more required.';
  }
}

class _PublicEnrollmentTheme extends StatelessWidget {
  const _PublicEnrollmentTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff000000), Color(0xff101010), Color(0xff000000)],
        ),
      ),
      child: Theme(
        data: ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xff0a84ff),
            surface: Color(0xff151515),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xff0a84ff)),
            ),
          ),
        ),
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
  }
}

class _EnrollmentNameStep extends StatelessWidget {
  const _EnrollmentNameStep({
    required this.controller,
    required this.canStart,
    required this.isBusy,
    required this.statusText,
    required this.onChanged,
    required this.onStart,
  });

  final TextEditingController controller;
  final bool canStart;
  final bool isBusy;
  final String? statusText;
  final VoidCallback onChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _StepLabel(text: 'Step 1 of 2'),
            const SizedBox(height: 8),
            Text(
              'Create your face profile',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter your name before the guided face scan.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: controller,
              enabled: !isBusy,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (_) => onChanged(),
            ),
            if (statusText != null) ...[
              const SizedBox(height: 14),
              Text(
                statusText!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: canStart ? onStart : null,
              child: Text(isBusy ? 'Starting' : 'Start Enrollment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentCaptureStep extends StatelessWidget {
  const _EnrollmentCaptureStep({
    required this.cameraSession,
    required this.progress,
    required this.countdownSeconds,
    required this.statusText,
    required this.isScanning,
    required this.progressLabel,
    required this.canRetry,
    required this.onRetry,
    required this.onCancel,
  });

  final EnrollmentCameraSession cameraSession;
  final GuidedEnrollmentProgress progress;
  final int countdownSeconds;
  final String? statusText;
  final bool isScanning;
  final String progressLabel;
  final bool canRetry;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: cameraSession.previewAspectRatio,
                        child: cameraSession.isReady
                            ? cameraSession.buildPreview()
                            : const ColoredBox(color: Colors.black),
                      ),
                    ),
                    FaceOvalGuide(showScan: isScanning, progress: 0.5),
                    if (countdownSeconds > 0)
                      Center(
                        child: Text(
                          '$countdownSeconds',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                top: 8,
                child: IconButton(
                  tooltip: 'Cancel',
                  onPressed: onCancel,
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: 18,
                child: const Center(child: _StepLabel(text: 'Step 2 of 2')),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight > 96
                        ? constraints.maxHeight - 96
                        : 0,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PromptDots(progress: progress),
                        const SizedBox(height: 14),
                        Text(
                          progress.currentPrompt.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          progress.currentPrompt.instruction,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progressLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (statusText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            statusText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (canRetry) ...[
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: onRetry,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EnrollmentCompleteView extends StatelessWidget {
  const _EnrollmentCompleteView({
    required this.progressLabel,
    required this.onDone,
  });

  final String progressLabel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xff34c759), width: 5),
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xff34c759),
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Enrollment complete.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              progressLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onDone, child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptDots extends StatelessWidget {
  const _PromptDots({required this.progress});

  final GuidedEnrollmentProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < progress.totalSamples; index++)
          Container(
            width: 34,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: index < progress.acceptedSamples
                  ? const Color(0xff34c759)
                  : index == progress.promptIndex
                      ? const Color(0xff0a84ff)
                      : Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      ],
    );
  }
}
