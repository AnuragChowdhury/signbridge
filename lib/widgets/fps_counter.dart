import 'package:flutter/material.dart';

import '../themes/text_styles.dart';

/// FPS counter badge displayed on the camera preview.
class FpsCounter extends StatelessWidget {
  final double fps;

  const FpsCounter({
    super.key,
    required this.fps,
  });

  @override
  Widget build(BuildContext context) {
    // Color based on FPS level
    Color fpsColor;
    if (fps >= 25) {
      fpsColor = const Color(0xFF10B981); // Green
    } else if (fps >= 15) {
      fpsColor = const Color(0xFFF59E0B); // Amber
    } else {
      fpsColor = const Color(0xFFEF4444); // Red
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fpsColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: fpsColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '${fps.toStringAsFixed(0)} FPS',
        style: AppTextStyles.fpsCounter.copyWith(
          color: fpsColor,
        ),
      ),
    );
  }
}
