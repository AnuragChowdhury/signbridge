import 'package:flutter/material.dart';

import '../themes/color_schemes.dart';
import '../themes/text_styles.dart';

/// Circular confidence gauge with percentage display.
///
/// Color-coded:
/// - Green: >= 80%
/// - Amber: >= 50%
/// - Red: < 50%
class ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final double size;

  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.confidenceColor(confidence);
    final percentage = (confidence * 100).toStringAsFixed(0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                color.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Foreground progress
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: confidence),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: Colors.transparent,
                );
              },
            ),
          ),
          // Percentage text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: AppTextStyles.confidenceValue.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
