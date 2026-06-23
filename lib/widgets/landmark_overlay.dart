import 'package:flutter/material.dart';

import '../models/hand_landmark.dart';
import '../themes/color_schemes.dart';

/// Custom painter overlay for rendering hand landmarks on the camera preview.
///
/// Draws 21 landmark points and connection lines following
/// MediaPipe's hand skeleton topology.
class LandmarkOverlay extends StatelessWidget {
  final HandLandmarks landmarks;
  final Size imageSize;

  const LandmarkOverlay({
    super.key,
    required this.landmarks,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LandmarkPainter(
        landmarks: landmarks,
        imageSize: imageSize,
        brightness: Theme.of(context).brightness,
      ),
      size: Size.infinite,
    );
  }
}

class _LandmarkPainter extends CustomPainter {
  final HandLandmarks landmarks;
  final Size imageSize;
  final Brightness brightness;

  _LandmarkPainter({
    required this.landmarks,
    required this.imageSize,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!landmarks.isValid) return;

    // Scale factors to map normalized landmark coords to canvas
    final scaleX = size.width;
    final scaleY = size.height;

    // Connection line paint
    final linePaint = Paint()
      ..color = brightness == Brightness.dark
          ? AppColors.darkScheme.primary.withValues(alpha: 0.7)
          : AppColors.lightScheme.primary.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Landmark point paint
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Point border paint
    final borderPaint = Paint()
      ..color = brightness == Brightness.dark
          ? AppColors.darkScheme.primary
          : AppColors.lightScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Special points (fingertips) paint
    final tipPaint = Paint()
      ..color = brightness == Brightness.dark
          ? AppColors.darkScheme.secondary
          : AppColors.lightScheme.secondary
      ..style = PaintingStyle.fill;

    // Fingertip indices
    const fingerTips = {4, 8, 12, 16, 20};

    // Draw connections
    for (final connection in HandLandmarks.connections) {
      final start = landmarks.landmarks[connection[0]];
      final end = landmarks.landmarks[connection[1]];

      // Mirror X for front camera display
      final startPoint = Offset(
        (1 - start.x) * scaleX,
        start.y * scaleY,
      );
      final endPoint = Offset(
        (1 - end.x) * scaleX,
        end.y * scaleY,
      );

      canvas.drawLine(startPoint, endPoint, linePaint);
    }

    // Draw landmark points
    for (int i = 0; i < landmarks.landmarks.length; i++) {
      final lm = landmarks.landmarks[i];
      final point = Offset(
        (1 - lm.x) * scaleX,
        lm.y * scaleY,
      );

      final isTip = fingerTips.contains(i);
      final radius = isTip ? 6.0 : 4.0;

      // Draw point
      canvas.drawCircle(point, radius, isTip ? tipPaint : pointPaint);
      canvas.drawCircle(point, radius, borderPaint);
    }

    // Draw wrist indicator
    final wrist = landmarks.wrist;
    final wristPoint = Offset(
      (1 - wrist.x) * scaleX,
      wrist.y * scaleY,
    );
    canvas.drawCircle(wristPoint, 8.0, pointPaint);
    canvas.drawCircle(wristPoint, 8.0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _LandmarkPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
}
