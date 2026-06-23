import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../core/constants/model_constants.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/logger.dart';
import '../models/gesture_prediction.dart';
import '../models/model_info.dart';
import '../models/sign_language.dart';

/// Service for TFLite model loading and gesture inference.
///
/// Manages the lifecycle of TFLite models and performs real-time
/// gesture classification from normalized hand landmark features.
/// Supports dynamic model swapping for language switching.
class TfliteService {
  Interpreter? _interpreter;
  Map<int, String>? _labelMap;
  SignLanguageConfig? _config;
  SignLanguage? _currentLanguage;
  int _modelFileSize = 0;

  /// Whether a model is currently loaded and ready for inference.
  bool get isModelLoaded => _interpreter != null && _labelMap != null;

  /// The currently loaded sign language.
  SignLanguage? get currentLanguage => _currentLanguage;

  /// Loads a TFLite model for the specified sign language.
  ///
  /// This loads three files from the assets:
  /// - model.tflite: The TFLite classifier model
  /// - labels.json: Maps output indices to gesture labels
  /// - config.json: Model metadata and configuration
  ///
  /// Throws [ModelLoadException] if any file is missing or corrupt.
  Future<void> loadModel(SignLanguage language) async {
    try {
      AppLogger.info('Loading model for ${language.displayName}...');

      // Dispose previous model if loaded
      _interpreter?.close();
      _interpreter = null;

      // Load TFLite model from assets
      _interpreter = await Interpreter.fromAsset(
        language.modelPath,
        options: InterpreterOptions()..threads = 2,
      );

      // Load label mapping
      final labelsJson = await rootBundle.loadString(language.labelsPath);
      final labelsData = json.decode(labelsJson) as Map<String, dynamic>;
      _labelMap = labelsData.map(
        (key, value) => MapEntry(int.parse(key), value as String),
      );

      // Load config
      final configJson = await rootBundle.loadString(language.configPath);
      final configData = json.decode(configJson) as Map<String, dynamic>;
      _config = SignLanguageConfig.fromJson(configData);

      // Get model file size
      final modelData = await rootBundle.load(language.modelPath);
      _modelFileSize = modelData.lengthInBytes;

      _currentLanguage = language;

      AppLogger.info(
        'Model loaded: ${_config!.modelName} v${_config!.version} '
        '(${_labelMap!.length} classes, ${_modelFileSize ~/ 1024}KB)',
      );
    } catch (e) {
      _interpreter?.close();
      _interpreter = null;
      _labelMap = null;
      _config = null;

      throw ModelLoadException(
        'Failed to load model for ${language.displayName}',
        modelPath: language.modelPath,
        originalError: e,
      );
    }
  }

  /// Runs gesture classification on normalized landmark features.
  ///
  /// [features] must be a Float32List of 63 values (21 landmarks × 3 coords).
  /// Returns a [GesturePrediction] with the top prediction and confidence.
  GesturePrediction? classify(Float32List features) {
    if (!isModelLoaded) {
      AppLogger.warning('Attempted inference without loaded model');
      return null;
    }

    if (features.length != ModelConstants.inputFeatureSize) {
      AppLogger.error(
        'Invalid input size: ${features.length} '
        '(expected ${ModelConstants.inputFeatureSize})',
      );
      return null;
    }

    try {
      // Prepare input tensor: [1, 63]
      final input = [features];

      // Prepare output tensor: [1, numClasses]
      final numClasses = _labelMap!.length;
      final output = List.generate(
        1,
        (_) => List.filled(numClasses, 0.0),
      );

      // Run inference
      _interpreter!.run(input, output);

      // Find the class with maximum probability
      final probabilities = output[0];
      int maxIndex = 0;
      double maxProb = probabilities[0];

      final allProbs = <String, double>{};

      for (int i = 0; i < probabilities.length; i++) {
        final label = _labelMap![i] ?? 'Unknown';
        allProbs[label] = probabilities[i];

        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      final predictedLabel = _labelMap![maxIndex] ?? 'Unknown';

      return GesturePrediction(
        label: predictedLabel,
        confidence: maxProb,
        timestamp: DateTime.now(),
        allProbabilities: allProbs,
      );
    } catch (e) {
      AppLogger.error('Inference failed', e);
      return null;
    }
  }

  /// Gets metadata about the currently loaded model.
  ModelInfo getModelInfo() {
    if (!isModelLoaded || _config == null || _currentLanguage == null) {
      return ModelInfo.unknown();
    }

    return ModelInfo(
      modelName: _config!.modelName,
      version: _config!.version,
      numClasses: _config!.numClasses,
      inputSize: _config!.inputSize,
      outputClasses: _labelMap!.values.toList(),
      tfliteVersion: 'LiteRT 1.4.0',
      fileSizeBytes: _modelFileSize,
      languageCode: _currentLanguage!.code,
    );
  }

  /// Disposes the TFLite interpreter and frees resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labelMap = null;
    _config = null;
    _currentLanguage = null;
    AppLogger.info('TFLite service disposed');
  }
}
