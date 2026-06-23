import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/settings_repository.dart';
import '../services/storage_service.dart';

/// Provider for the theme mode (light/dark/system).
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Manages the application theme mode with persistence.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_loadInitialTheme());

  static ThemeMode _loadInitialTheme() {
    return StorageService.getThemeMode();
  }

  /// Sets the theme mode and persists the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    int index;
    switch (mode) {
      case ThemeMode.light:
        index = 1;
      case ThemeMode.dark:
        index = 2;
      default:
        index = 0;
    }
    await SettingsRepository().setThemeMode(index);
  }

  /// Gets the theme mode index for settings UI.
  int get themeIndex {
    switch (state) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      default:
        return 0;
    }
  }
}
