import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../services/camera_service.dart';
import '../services/storage_service.dart';

/// Repository for managing user settings with persistence.
///
/// Provides a type-safe API over the raw Hive storage
/// for reading and writing user preferences.
class SettingsRepository {
  /// Gets the currently selected sign language code.
  String getSelectedLanguage() {
    return StorageService.getSelectedLanguage();
  }

  /// Saves the selected sign language.
  Future<void> setSelectedLanguage(String code) async {
    await StorageService.saveSelectedLanguage(code);
    AppLogger.debug('Selected language saved: $code');
  }

  /// Gets the recognition confidence threshold.
  double getConfidenceThreshold() {
    return StorageService.getConfidenceThreshold();
  }

  /// Saves the confidence threshold.
  Future<void> setConfidenceThreshold(double threshold) async {
    await StorageService.saveConfidenceThreshold(threshold);
    AppLogger.debug('Confidence threshold saved: $threshold');
  }

  /// Gets whether the landmark overlay is enabled.
  bool getShowLandmarks() {
    return StorageService.getShowLandmarks();
  }

  /// Saves the landmark overlay preference.
  Future<void> setShowLandmarks(bool show) async {
    await StorageService.saveSetting(AppConstants.showLandmarksKey, show);
  }

  /// Gets whether the FPS counter is visible.
  bool getShowFps() {
    return StorageService.getShowFps();
  }

  /// Saves the FPS counter preference.
  Future<void> setShowFps(bool show) async {
    await StorageService.saveSetting(AppConstants.showFpsKey, show);
  }

  /// Gets the current theme mode.
  ThemeMode getThemeMode() {
    return StorageService.getThemeMode();
  }

  /// Gets the raw theme mode index (0=system, 1=light, 2=dark).
  int getThemeModeIndex() {
    return StorageService.getThemeModeIndex();
  }

  /// Saves the theme mode preference.
  Future<void> setThemeMode(int index) async {
    await StorageService.saveSetting(AppConstants.themeModeKey, index);
    AppLogger.debug('Theme mode saved: $index');
  }

  /// Gets the camera resolution setting.
  CameraResolution getCameraResolution() {
    final value = StorageService.getCameraResolution();
    return CameraResolution.fromString(value);
  }

  /// Saves the camera resolution preference.
  Future<void> setCameraResolution(CameraResolution resolution) async {
    await StorageService.saveSetting(
      AppConstants.cameraResolutionKey,
      resolution.name,
    );
  }
}
