import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/logger.dart';
import '../models/recognition_history.dart';

/// Service for local data persistence using Hive CE.
///
/// Manages two boxes:
/// - settings: User preferences and configuration
/// - history: Recognition history entries
class StorageService {
  static Box? _settingsBox;
  static Box<RecognitionHistory>? _historyBox;

  /// Whether storage has been initialized.
  static bool get isInitialized =>
      _settingsBox != null && _historyBox != null;

  /// Initializes Hive boxes and registers type adapters.
  ///
  /// Must be called once during app startup before any storage operations.
  static Future<void> initialize() async {
    try {
      // Register type adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(RecognitionHistoryAdapter());
      }

      // Open boxes
      _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
      _historyBox = await Hive.openBox<RecognitionHistory>(
        AppConstants.historyBoxName,
      );

      AppLogger.info('Storage initialized successfully');
    } catch (e) {
      throw StorageException('Failed to initialize storage', originalError: e);
    }
  }

  // ── Settings Operations ──

  /// Gets a setting value by key, returns [defaultValue] if not found.
  static T getSetting<T>(String key, T defaultValue) {
    return _settingsBox?.get(key, defaultValue: defaultValue) ?? defaultValue;
  }

  /// Saves a setting value.
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  /// Gets the selected sign language code.
  static String getSelectedLanguage() {
    return getSetting(AppConstants.selectedLanguageKey, 'asl');
  }

  /// Saves the selected sign language code.
  static Future<void> saveSelectedLanguage(String code) async {
    await saveSetting(AppConstants.selectedLanguageKey, code);
  }

  /// Gets the confidence threshold.
  static double getConfidenceThreshold() {
    return getSetting(
      AppConstants.confidenceThresholdKey,
      AppConstants.defaultConfidenceThreshold,
    );
  }

  /// Saves the confidence threshold.
  static Future<void> saveConfidenceThreshold(double threshold) async {
    await saveSetting(AppConstants.confidenceThresholdKey, threshold);
  }

  /// Gets whether landmark overlay should be shown.
  static bool getShowLandmarks() {
    return getSetting(AppConstants.showLandmarksKey, true);
  }

  /// Gets whether FPS counter should be shown.
  static bool getShowFps() {
    return getSetting(AppConstants.showFpsKey, true);
  }

  /// Gets the theme mode index (0=system, 1=light, 2=dark).
  static int getThemeModeIndex() {
    return getSetting(AppConstants.themeModeKey, 0);
  }

  /// Converts theme mode index to Flutter ThemeMode.
  static ThemeMode getThemeMode() {
    switch (getThemeModeIndex()) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Gets the camera resolution setting.
  static String getCameraResolution() {
    return getSetting(AppConstants.cameraResolutionKey, 'medium');
  }

  // ── History Operations ──

  /// Adds a recognition history entry.
  static Future<void> addHistory(RecognitionHistory entry) async {
    await _historyBox?.add(entry);
    AppLogger.debug('History entry added: "${entry.text}"');
  }

  /// Gets all history entries, sorted by most recent first.
  static List<RecognitionHistory> getHistory() {
    final entries = _historyBox?.values.toList() ?? [];
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Deletes a specific history entry by its Hive key.
  static Future<void> deleteHistory(int key) async {
    await _historyBox?.delete(key);
  }

  /// Clears all history entries.
  static Future<void> clearHistory() async {
    await _historyBox?.clear();
    AppLogger.info('History cleared');
  }

  /// Gets the number of history entries.
  static int get historyCount => _historyBox?.length ?? 0;

  /// Closes all Hive boxes.
  static Future<void> close() async {
    await _settingsBox?.close();
    await _historyBox?.close();
    AppLogger.info('Storage closed');
  }
}
