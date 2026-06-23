/// Metadata about the currently loaded TFLite model.
///
/// Displayed on the Model Info screen.
class ModelInfo {
  final String modelName;
  final String version;
  final int numClasses;
  final int inputSize;
  final List<String> outputClasses;
  final String tfliteVersion;
  final int fileSizeBytes;
  final String languageCode;

  const ModelInfo({
    required this.modelName,
    required this.version,
    required this.numClasses,
    required this.inputSize,
    required this.outputClasses,
    required this.tfliteVersion,
    required this.fileSizeBytes,
    required this.languageCode,
  });

  /// Human-readable file size string.
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Creates a default/unknown model info.
  factory ModelInfo.unknown() {
    return const ModelInfo(
      modelName: 'Unknown',
      version: '0.0.0',
      numClasses: 0,
      inputSize: 0,
      outputClasses: [],
      tfliteVersion: 'N/A',
      fileSizeBytes: 0,
      languageCode: '',
    );
  }

  @override
  String toString() => 'ModelInfo($modelName v$version, $numClasses classes)';
}
