/// Represents a single gesture prediction from the TFLite model.
class GesturePrediction {
  /// The predicted gesture label (e.g., 'A', 'B', 'SPACE').
  final String label;

  /// Confidence score between 0.0 and 1.0.
  final double confidence;

  /// Timestamp when this prediction was made.
  final DateTime timestamp;

  /// All class probabilities from the model output.
  final Map<String, double>? allProbabilities;

  const GesturePrediction({
    required this.label,
    required this.confidence,
    required this.timestamp,
    this.allProbabilities,
  });

  /// Whether this prediction exceeds the given confidence threshold.
  bool isConfident(double threshold) => confidence >= threshold;

  /// Creates a "no prediction" result.
  factory GesturePrediction.empty() {
    return GesturePrediction(
      label: '',
      confidence: 0.0,
      timestamp: DateTime.now(),
    );
  }

  /// Whether this is an empty/null prediction.
  bool get isEmpty => label.isEmpty;
  bool get isNotEmpty => label.isNotEmpty;

  @override
  String toString() =>
      'GesturePrediction($label, ${(confidence * 100).toStringAsFixed(1)}%)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GesturePrediction &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => label.hashCode;
}
