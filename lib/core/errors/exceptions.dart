// Core exceptions for the SignBridge application.

// Thrown when a TFLite model fails to load.
class ModelLoadException implements Exception {
  final String message;
  final String? modelPath;
  final dynamic originalError;

  const ModelLoadException(
    this.message, {
    this.modelPath,
    this.originalError,
  });

  @override
  String toString() =>
      'ModelLoadException: $message${modelPath != null ? ' (path: $modelPath)' : ''}';
}

/// Thrown when camera initialization or access fails.
class CameraServiceException implements Exception {
  final String message;
  final dynamic originalError;

  const CameraServiceException(this.message, {this.originalError});

  @override
  String toString() => 'CameraServiceException: $message';
}

/// Thrown when hand landmark detection fails.
class LandmarkDetectionException implements Exception {
  final String message;
  final dynamic originalError;

  const LandmarkDetectionException(this.message, {this.originalError});

  @override
  String toString() => 'LandmarkDetectionException: $message';
}

/// Thrown when gesture recognition inference fails.
class InferenceException implements Exception {
  final String message;
  final dynamic originalError;

  const InferenceException(this.message, {this.originalError});

  @override
  String toString() => 'InferenceException: $message';
}

/// Thrown when required assets are missing.
class AssetNotFoundException implements Exception {
  final String assetPath;
  final String message;

  const AssetNotFoundException(this.assetPath, {this.message = ''});

  @override
  String toString() =>
      'AssetNotFoundException: Asset not found at "$assetPath"${message.isNotEmpty ? ' - $message' : ''}';
}

/// Thrown when storage operations fail.
class StorageException implements Exception {
  final String message;
  final dynamic originalError;

  const StorageException(this.message, {this.originalError});

  @override
  String toString() => 'StorageException: $message';
}
