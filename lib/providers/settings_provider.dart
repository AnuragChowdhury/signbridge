import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../repositories/settings_repository.dart';
import '../services/camera_service.dart';

/// Application settings state.
class AppSettings {
  final double confidenceThreshold;
  final bool showLandmarks;
  final bool showFps;
  final CameraResolution cameraResolution;

  const AppSettings({
    this.confidenceThreshold = AppConstants.defaultConfidenceThreshold,
    this.showLandmarks = true,
    this.showFps = true,
    this.cameraResolution = CameraResolution.medium,
  });

  AppSettings copyWith({
    double? confidenceThreshold,
    bool? showLandmarks,
    bool? showFps,
    CameraResolution? cameraResolution,
  }) {
    return AppSettings(
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      showLandmarks: showLandmarks ?? this.showLandmarks,
      showFps: showFps ?? this.showFps,
      cameraResolution: cameraResolution ?? this.cameraResolution,
    );
  }
}

/// Provider for application settings.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

/// Manages application settings with persistence.
class SettingsNotifier extends StateNotifier<AppSettings> {
  final _repo = SettingsRepository();

  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = AppSettings(
      confidenceThreshold: _repo.getConfidenceThreshold(),
      showLandmarks: _repo.getShowLandmarks(),
      showFps: _repo.getShowFps(),
      cameraResolution: _repo.getCameraResolution(),
    );
  }

  /// Updates the confidence threshold.
  Future<void> setConfidenceThreshold(double value) async {
    state = state.copyWith(confidenceThreshold: value);
    await _repo.setConfidenceThreshold(value);
  }

  /// Toggles the landmark overlay visibility.
  Future<void> setShowLandmarks(bool show) async {
    state = state.copyWith(showLandmarks: show);
    await _repo.setShowLandmarks(show);
  }

  /// Toggles the FPS counter visibility.
  Future<void> setShowFps(bool show) async {
    state = state.copyWith(showFps: show);
    await _repo.setShowFps(show);
  }

  /// Changes the camera resolution.
  Future<void> setCameraResolution(CameraResolution resolution) async {
    state = state.copyWith(cameraResolution: resolution);
    await _repo.setCameraResolution(resolution);
  }
}
