import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/gesture_prediction.dart';
import '../themes/color_schemes.dart';
import '../themes/text_styles.dart';
import 'confidence_indicator.dart';

/// Displays the current gesture prediction with label, confidence, and animation.
///
/// Features:
/// - Large animated gesture label
/// - Confidence bar with color coding
/// - Smooth fade/slide transitions between predictions
class PredictionCard extends StatelessWidget {
  final GesturePrediction prediction;

  const PredictionCard({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.largePadding,
        vertical: AppConstants.defaultPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.glassBackground(
          isDark ? Brightness.dark : Brightness.light,
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: AppColors.glassBorder(
            isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gesture label (large)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detected Gesture',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  prediction.label,
                  style: AppTextStyles.predictionLabel.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Confidence indicator
          ConfidenceIndicator(confidence: prediction.confidence),
        ],
      ),
    );
  }
}
