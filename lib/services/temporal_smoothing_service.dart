import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/gesture_prediction.dart';

/// Provides temporal stabilization for gesture predictions.
///
/// Reduces prediction noise using multiple techniques:
/// - Sliding window with majority voting
/// - Confidence threshold filtering
/// - Prediction cooldown timer
/// - Duplicate suppression
/// - Exponential moving average smoothing
class TemporalSmoothingService {
  /// Size of the sliding prediction window.
  final int windowSize;

  /// Minimum confidence to accept a prediction.
  double confidenceThreshold;

  /// Minimum time between accepted predictions (milliseconds).
  final int cooldownMs;

  // Internal state
  final List<GesturePrediction> _window = [];
  DateTime? _lastAcceptedTime;
  String? _lastAcceptedLabel;
  final Map<String, double> _smoothedConfidences = {};

  TemporalSmoothingService({
    this.windowSize = AppConstants.defaultSlidingWindowSize,
    this.confidenceThreshold = AppConstants.defaultConfidenceThreshold,
    this.cooldownMs = AppConstants.defaultPredictionCooldownMs,
  });

  /// Updates the confidence threshold (e.g., from settings).
  void updateThreshold(double newThreshold) {
    confidenceThreshold = newThreshold;
    AppLogger.debug('Confidence threshold updated to $newThreshold');
  }

  /// Adds a raw prediction and returns a stabilized result.
  ///
  /// Returns null if the prediction should be suppressed.
  /// Returns a [GesturePrediction] if a stable prediction is confirmed.
  GesturePrediction? addPrediction(GesturePrediction prediction) {
    // Skip low-confidence predictions
    if (!prediction.isConfident(confidenceThreshold)) {
      return null;
    }

    // Skip "NOTHING" predictions
    if (prediction.label == AppConstants.gestureNothing) {
      return null;
    }

    // Add to sliding window
    _window.add(prediction);
    if (_window.length > windowSize) {
      _window.removeAt(0);
    }

    // Apply exponential moving average on confidence
    _updateSmoothedConfidence(prediction);

    // Check if window is full
    if (_window.length < windowSize) {
      return null;
    }

    // Perform majority voting
    final majorityLabel = _getMajorityVote();
    if (majorityLabel == null) return null;

    // Check cooldown timer
    if (_lastAcceptedTime != null) {
      final elapsed =
          DateTime.now().difference(_lastAcceptedTime!).inMilliseconds;
      if (elapsed < cooldownMs) return null;
    }

    // Duplicate suppression: don't emit same label consecutively
    // unless enough time has passed
    if (majorityLabel == _lastAcceptedLabel) {
      final elapsed = _lastAcceptedTime != null
          ? DateTime.now().difference(_lastAcceptedTime!).inMilliseconds
          : cooldownMs + 1;
      if (elapsed < AppConstants.duplicateSuppressionMs) {
        return null;
      }
    }

    // Accept this prediction
    _lastAcceptedTime = DateTime.now();
    _lastAcceptedLabel = majorityLabel;

    final smoothedConf = _smoothedConfidences[majorityLabel] ?? 0.0;

    return GesturePrediction(
      label: majorityLabel,
      confidence: smoothedConf,
      timestamp: DateTime.now(),
    );
  }

  /// Gets the majority vote from the current window.
  String? _getMajorityVote() {
    if (_window.isEmpty) return null;

    final counts = <String, int>{};
    for (final pred in _window) {
      counts[pred.label] = (counts[pred.label] ?? 0) + 1;
    }

    // Find label with most votes
    String? bestLabel;
    int bestCount = 0;

    counts.forEach((label, count) {
      if (count > bestCount) {
        bestCount = count;
        bestLabel = label;
      }
    });

    // Require majority (more than half the window)
    if (bestCount <= windowSize ~/ 2) return null;

    return bestLabel;
  }

  /// Updates the exponential moving average for a prediction's confidence.
  void _updateSmoothedConfidence(GesturePrediction prediction) {
    final current = _smoothedConfidences[prediction.label] ?? 0.0;
    _smoothedConfidences[prediction.label] =
        AppConstants.smoothingFactor * prediction.confidence +
            (1 - AppConstants.smoothingFactor) * current;
  }

  /// Resets all smoothing state.
  ///
  /// Called when switching languages or clearing the session.
  void reset() {
    _window.clear();
    _lastAcceptedTime = null;
    _lastAcceptedLabel = null;
    _smoothedConfidences.clear();
    AppLogger.debug('Temporal smoothing reset');
  }
}
