/// Application-wide constants for SignBridge.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SignBridge';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'AI-powered real-time multilingual sign language keyboard';

  // Recognition defaults
  static const double defaultConfidenceThreshold = 0.7;
  static const int defaultSlidingWindowSize = 5;
  static const int defaultPredictionCooldownMs = 500;
  static const int defaultFrameSkip = 2;

  // Camera
  static const int defaultCameraFps = 30;

  // Temporal smoothing
  static const double smoothingFactor = 0.3;
  static const int maxPredictionBufferSize = 10;
  static const int duplicateSuppressionMs = 1000;

  // UI
  static const double cardBorderRadius = 16.0;
  static const double smallBorderRadius = 12.0;
  static const double chipBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Storage keys
  static const String settingsBoxName = 'settings';
  static const String historyBoxName = 'history';
  static const String selectedLanguageKey = 'selected_language';
  static const String confidenceThresholdKey = 'confidence_threshold';
  static const String showLandmarksKey = 'show_landmarks';
  static const String showFpsKey = 'show_fps';
  static const String themeModeKey = 'theme_mode';
  static const String cameraResolutionKey = 'camera_resolution';

  // Special gesture labels
  static const String gestureSpace = 'SPACE';
  static const String gestureDelete = 'DELETE';
  static const String gestureNothing = 'NOTHING';
}
