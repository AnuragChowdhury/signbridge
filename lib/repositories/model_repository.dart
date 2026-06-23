import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/errors/exceptions.dart';
import '../core/utils/logger.dart';
import '../models/model_info.dart';
import '../models/sign_language.dart';

/// Repository for managing TFLite model assets.
///
/// Handles loading model files, label mappings, and configurations
/// from the app's asset bundle. Provides model metadata for display.
class ModelRepository {
  /// Cached configurations per language.
  final Map<String, SignLanguageConfig> _configCache = {};

  /// Cached label maps per language.
  final Map<String, Map<int, String>> _labelCache = {};

  /// Loads and returns the label mapping for a sign language.
  ///
  /// The label map is a JSON file mapping class indices to gesture labels:
  /// `{"0": "A", "1": "B", ..., "25": "Z", "26": "SPACE", ...}`
  Future<Map<int, String>> loadLabels(SignLanguage language) async {
    // Check cache first
    if (_labelCache.containsKey(language.code)) {
      return _labelCache[language.code]!;
    }

    try {
      final jsonString = await rootBundle.loadString(language.labelsPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final labels = data.map(
        (key, value) => MapEntry(int.parse(key), value as String),
      );

      _labelCache[language.code] = labels;
      AppLogger.debug('Labels loaded for ${language.shortName}: ${labels.length} classes');
      return labels;
    } catch (e) {
      throw AssetNotFoundException(
        language.labelsPath,
        message: 'Failed to load labels for ${language.displayName}',
      );
    }
  }

  /// Loads and returns the model configuration for a sign language.
  Future<SignLanguageConfig> loadConfig(SignLanguage language) async {
    if (_configCache.containsKey(language.code)) {
      return _configCache[language.code]!;
    }

    try {
      final jsonString = await rootBundle.loadString(language.configPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final config = SignLanguageConfig.fromJson(data);

      _configCache[language.code] = config;
      AppLogger.debug('Config loaded for ${language.shortName}: ${config.modelName}');
      return config;
    } catch (e) {
      throw AssetNotFoundException(
        language.configPath,
        message: 'Failed to load config for ${language.displayName}',
      );
    }
  }

  /// Gets the model file size in bytes.
  Future<int> getModelFileSize(SignLanguage language) async {
    try {
      final data = await rootBundle.load(language.modelPath);
      return data.lengthInBytes;
    } catch (e) {
      AppLogger.warning('Could not determine model file size: $e');
      return 0;
    }
  }

  /// Builds a [ModelInfo] object for a sign language.
  Future<ModelInfo> getModelInfo(SignLanguage language) async {
    try {
      final config = await loadConfig(language);
      final labels = await loadLabels(language);
      final fileSize = await getModelFileSize(language);

      return ModelInfo(
        modelName: config.modelName,
        version: config.version,
        numClasses: config.numClasses,
        inputSize: config.inputSize,
        outputClasses: labels.values.toList(),
        tfliteVersion: 'LiteRT 1.4.0',
        fileSizeBytes: fileSize,
        languageCode: language.code,
      );
    } catch (e) {
      AppLogger.error('Failed to get model info for ${language.shortName}', e);
      return ModelInfo.unknown();
    }
  }

  /// Validates that all required assets exist for a sign language.
  Future<bool> validateAssets(SignLanguage language) async {
    try {
      await rootBundle.load(language.modelPath);
      await rootBundle.loadString(language.labelsPath);
      await rootBundle.loadString(language.configPath);
      return true;
    } catch (e) {
      AppLogger.warning('Asset validation failed for ${language.shortName}: $e');
      return false;
    }
  }

  /// Clears all cached data.
  void clearCache() {
    _configCache.clear();
    _labelCache.clear();
  }
}
