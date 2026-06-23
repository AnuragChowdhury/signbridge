import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/logger.dart';
import '../models/sign_language.dart';
import '../services/storage_service.dart';
import '../services/tflite_service.dart';

/// Provider for the TFLite service instance.
final tfliteServiceProvider = Provider<TfliteService>((ref) {
  final service = TfliteService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the currently selected sign language.
final languageProvider =
    StateNotifierProvider<LanguageNotifier, SignLanguage>((ref) {
  return LanguageNotifier(ref);
});

/// Manages the current sign language selection and model loading.
class LanguageNotifier extends StateNotifier<SignLanguage> {
  final Ref _ref;

  LanguageNotifier(this._ref) : super(_loadInitialLanguage());

  static SignLanguage _loadInitialLanguage() {
    final code = StorageService.getSelectedLanguage();
    return SignLanguage.fromCode(code);
  }

  /// Switches to a new sign language.
  ///
  /// This loads the corresponding TFLite model and persists the selection.
  Future<void> switchLanguage(SignLanguage language) async {
    if (language == state) return;

    try {
      final tfliteService = _ref.read(tfliteServiceProvider);
      await tfliteService.loadModel(language);
      await StorageService.saveSelectedLanguage(language.code);
      state = language;
      AppLogger.info('Language switched to ${language.displayName}');
    } catch (e) {
      AppLogger.error('Failed to switch language', e);
      rethrow;
    }
  }

  /// Loads the model for the current language (initial load).
  Future<void> loadCurrentModel() async {
    try {
      final tfliteService = _ref.read(tfliteServiceProvider);
      await tfliteService.loadModel(state);
      AppLogger.info('Model loaded for ${state.displayName}');
    } catch (e) {
      AppLogger.error('Failed to load initial model', e);
    }
  }
}
