import '../core/constants/model_constants.dart';

/// Supported sign languages in SignBridge.
///
/// Each language has its own TFLite model, label mapping, and configuration.
/// The architecture allows adding new languages by simply adding a new
/// enum value and placing the corresponding assets in the models directory.
enum SignLanguage {
  asl(
    code: 'asl',
    displayName: 'American Sign Language',
    shortName: 'ASL',
    flagEmoji: '🇺🇸',
  ),
  bsl(
    code: 'bsl',
    displayName: 'British Sign Language',
    shortName: 'BSL',
    flagEmoji: '🇬🇧',
  ),
  ipsl(
    code: 'ipsl',
    displayName: 'Indo-Pakistani Sign Language',
    shortName: 'IPSL',
    flagEmoji: '🇮🇳',
  ),
  csl(
    code: 'csl',
    displayName: 'Chinese Sign Language',
    shortName: 'CSL',
    flagEmoji: '🇨🇳',
  );

  final String code;
  final String displayName;
  final String shortName;
  final String flagEmoji;

  const SignLanguage({
    required this.code,
    required this.displayName,
    required this.shortName,
    required this.flagEmoji,
  });

  /// Path to the TFLite model file for this language.
  String get modelPath =>
      '${ModelConstants.modelsBasePath}/$code/${ModelConstants.modelFileName}';

  /// Path to the labels JSON file for this language.
  String get labelsPath =>
      '${ModelConstants.modelsBasePath}/$code/${ModelConstants.labelsFileName}';

  /// Path to the config JSON file for this language.
  String get configPath =>
      '${ModelConstants.modelsBasePath}/$code/${ModelConstants.configFileName}';

  /// Finds a SignLanguage by its code string.
  static SignLanguage fromCode(String code) {
    return SignLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => SignLanguage.asl,
    );
  }
}

/// Configuration loaded from a language's config.json file.
class SignLanguageConfig {
  final String modelName;
  final String version;
  final int numClasses;
  final int inputSize;
  final List<String> gestureLabels;
  final double recommendedThreshold;

  const SignLanguageConfig({
    required this.modelName,
    required this.version,
    required this.numClasses,
    required this.inputSize,
    required this.gestureLabels,
    this.recommendedThreshold = 0.7,
  });

  factory SignLanguageConfig.fromJson(Map<String, dynamic> json) {
    return SignLanguageConfig(
      modelName: json['model_name'] as String? ?? 'Unknown',
      version: json['version'] as String? ?? '1.0.0',
      numClasses: json['num_classes'] as int? ?? 29,
      inputSize: json['input_size'] as int? ?? ModelConstants.inputFeatureSize,
      gestureLabels: (json['gesture_labels'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      recommendedThreshold:
          (json['recommended_threshold'] as num?)?.toDouble() ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_name': modelName,
      'version': version,
      'num_classes': numClasses,
      'input_size': inputSize,
      'gesture_labels': gestureLabels,
      'recommended_threshold': recommendedThreshold,
    };
  }
}
