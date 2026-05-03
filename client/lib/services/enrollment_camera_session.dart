import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class EnrollmentCapture {
  const EnrollmentCapture({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

abstract interface class EnrollmentCameraSession {
  bool get isReady;

  Future<void> initialize();

  Future<EnrollmentCapture> capture();

  Widget buildPreview();

  Future<void> dispose();
}

class LiveEnrollmentCameraSession implements EnrollmentCameraSession {
  CameraController? _controller;

  @override
  bool get isReady => _controller?.value.isInitialized ?? false;

  @override
  Future<void> initialize() async {
    if (isReady) return;
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw StateError('No camera available.');
    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    CameraController? controller;
    try {
      controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {}
      _controller = controller;
    } catch (_) {
      await controller?.dispose();
      rethrow;
    }
  }

  @override
  Future<EnrollmentCapture> capture() async {
    final controller = _controller;
    if (controller == null || !isReady) {
      throw StateError('Camera is not ready.');
    }
    final photo = await controller.takePicture();
    return EnrollmentCapture(
      fileName: _cameraFileName(photo.name),
      bytes: await photo.readAsBytes(),
    );
  }

  @override
  Widget buildPreview() {
    final controller = _controller;
    if (controller == null || !isReady) return const SizedBox.shrink();
    return CameraPreview(controller);
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}

String _cameraFileName(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? 'enrollment.jpg' : trimmed;
}
