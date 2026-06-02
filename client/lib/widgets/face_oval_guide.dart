import 'dart:math' as math;

import 'package:flutter/material.dart';

class FaceOvalGuide extends StatelessWidget {
  const FaceOvalGuide({
    super.key,
    this.color = Colors.white,
    this.accentColor = const Color(0xff0a84ff),
    this.progress = 0,
    this.showScan = false,
  });

  final Color color;
  final Color accentColor;
  final double progress;
  final bool showScan;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _FaceOvalGuidePainter(
          color: color,
          accentColor: accentColor,
          progress: progress.clamp(0, 1),
          showScan: showScan,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _FaceOvalGuidePainter extends CustomPainter {
  const _FaceOvalGuidePainter({
    required this.color,
    required this.accentColor,
    required this.progress,
    required this.showScan,
  });

  final Color color;
  final Color accentColor;
  final double progress;
  final bool showScan;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final width = math.min(size.width * 0.72, 310.0);
    final height = math.min(size.height * 0.54, 410.0);
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.22);
    final cutout = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(rect.inflate(12));
    canvas.drawPath(cutout, dim);

    final guide = Paint()
      ..color = color.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(rect, guide);

    final corner = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const sweep = math.pi / 5;
    canvas.drawArc(rect, math.pi * 1.18, sweep, false, corner);
    canvas.drawArc(rect, math.pi * 1.62, sweep, false, corner);
    canvas.drawArc(rect, math.pi * 0.18, sweep, false, corner);
    canvas.drawArc(rect, math.pi * 0.62, sweep, false, corner);

    if (!showScan) return;
    final y = rect.top + (rect.height * progress);
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accentColor.withValues(alpha: 0),
          accentColor.withValues(alpha: 0.9),
          accentColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(rect.left, y - 20, rect.width, 40));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left + 18, y - 2, rect.width - 36, 4),
        const Radius.circular(8),
      ),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(_FaceOvalGuidePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.progress != progress ||
        oldDelegate.showScan != showScan;
  }
}
