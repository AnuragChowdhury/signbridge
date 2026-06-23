/// Constants related to TFLite model configuration.
class ModelConstants {
  ModelConstants._();

  // Model asset paths (relative to assets/)
  static const String modelsBasePath = 'assets/models';
  static const String modelFileName = 'model.tflite';
  static const String labelsFileName = 'labels.json';
  static const String configFileName = 'config.json';

  // Input/Output shapes
  static const int landmarkCount = 21;
  static const int coordinatesPerLandmark = 3; // x, y, z
  static const int inputFeatureSize = landmarkCount * coordinatesPerLandmark; // 63

  // Default model config values
  static const String defaultModelVersion = '1.0.0';
  static const int defaultNumClasses = 29; // A-Z + SPACE + DELETE + NOTHING

  // Model loading timeouts
  static const int modelLoadTimeoutMs = 5000;
  static const int inferenceTimeoutMs = 100;
}
