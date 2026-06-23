import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/logger.dart';
import '../models/gesture_prediction.dart';
import '../models/hand_landmark.dart';
import '../services/camera_service.dart';
import '../services/gesture_recognition_service.dart';
import '../services/hand_landmark_service.dart';
import '../services/sentence_builder_service.dart';
import '../services/temporal_smoothing_service.dart';
import 'language_provider.dart';
import 'settings_provider.dart';

/// State for the recognition pipeline.
class RecognitionState {
  final bool isRunning;
  final bool isCameraReady;
  final GesturePrediction? currentPrediction;
  final HandLandmarks? currentLandmarks;
  final String composedText;
  final double fps;
  final double inferenceMs;
  final String? errorMessage;

  const RecognitionState({
    this.isRunning = false,
    this.isCameraReady = false,
    this.currentPrediction,
    this.currentLandmarks,
    this.composedText = '',
    this.fps = 0.0,
    this.inferenceMs = 0.0,
    this.errorMessage,
  });

  RecognitionState copyWith({
    bool? isRunning,
    bool? isCameraReady,
    GesturePrediction? currentPrediction,
    HandLandmarks? currentLandmarks,
    String? composedText,
    double? fps,
    double? inferenceMs,
    String? errorMessage,
  }) {
    return RecognitionState(
      isRunning: isRunning ?? this.isRunning,
      isCameraReady: isCameraReady ?? this.isCameraReady,
      currentPrediction: currentPrediction ?? this.currentPrediction,
      currentLandmarks: currentLandmarks,
      composedText: composedText ?? this.composedText,
      fps: fps ?? this.fps,
      inferenceMs: inferenceMs ?? this.inferenceMs,
      errorMessage: errorMessage,
    );
  }
}

/// Provider for the camera service.
final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the hand landmark service.
final handLandmarkServiceProvider = Provider<HandLandmarkService>((ref) {
  final service = HandLandmarkService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the temporal smoothing service.
final smoothingServiceProvider = Provider<TemporalSmoothingService>((ref) {
  final settings = ref.watch(settingsProvider);
  return TemporalSmoothingService(
    confidenceThreshold: settings.confidenceThreshold,
  );
});

/// Provider for the sentence builder service.
final sentenceBuilderProvider = Provider<SentenceBuilderService>((ref) {
  return SentenceBuilderService();
});

/// Provider for the gesture recognition service.
final gestureRecognitionServiceProvider =
    Provider<GestureRecognitionService>((ref) {
  final cameraService = ref.watch(cameraServiceProvider);
  final landmarkService = ref.watch(handLandmarkServiceProvider);
  final tfliteService = ref.watch(tfliteServiceProvider);
  final smoothingService = ref.watch(smoothingServiceProvider);

  final service = GestureRecognitionService(
    cameraService: cameraService,
    landmarkService: landmarkService,
    tfliteService: tfliteService,
    smoothingService: smoothingService,
  );

  ref.onDispose(() => service.dispose());
  return service;
});

/// Main recognition state provider.
final recognitionProvider =
    StateNotifierProvider<RecognitionNotifier, RecognitionState>((ref) {
  return RecognitionNotifier(ref);
});

/// Manages the recognition pipeline state.
class RecognitionNotifier extends StateNotifier<RecognitionState> {
  final Ref _ref;
  StreamSubscription<GesturePrediction>? _predictionSub;
  StreamSubscription<HandLandmarks?>? _landmarkSub;
  Timer? _fpsTimer;

  RecognitionNotifier(this._ref) : super(const RecognitionState());

  /// Initializes the camera and model.
  Future<void> initialize() async {
    try {
      final cameraService = _ref.read(cameraServiceProvider);
      final settings = _ref.read(settingsProvider);

      await cameraService.initialize(resolution: settings.cameraResolution);

      final landmarkService = _ref.read(handLandmarkServiceProvider);
      await landmarkService.initialize();

      // Load the initial model
      final languageNotifier = _ref.read(languageProvider.notifier);
      await languageNotifier.loadCurrentModel();

      state = state.copyWith(isCameraReady: true);
      AppLogger.info('Recognition initialized');
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to initialize: ${e.toString()}',
      );
      AppLogger.error('Recognition initialization failed', e);
    }
  }

  /// Starts the recognition pipeline.
  Future<void> startRecognition() async {
    if (state.isRunning) return;

    try {
      final service = _ref.read(gestureRecognitionServiceProvider);
      final sentenceBuilder = _ref.read(sentenceBuilderProvider);

      // Listen to predictions
      _predictionSub = service.predictions.listen((prediction) {
        state = state.copyWith(currentPrediction: prediction);

        // Process into text
        if (prediction.isNotEmpty) {
          final text = sentenceBuilder.processPrediction(prediction);
          if (text != null) {
            state = state.copyWith(composedText: text);
          }
        }
      });

      // Listen to landmarks
      _landmarkSub = service.landmarks.listen((landmarks) {
        state = state.copyWith(currentLandmarks: landmarks);
      });

      // Start FPS update timer
      _fpsTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted) {
          state = state.copyWith(
            fps: service.currentFps,
            inferenceMs: service.lastInferenceMs,
          );
        }
      });

      await service.start();
      state = state.copyWith(isRunning: true, errorMessage: null);
      AppLogger.info('Recognition started');
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to start recognition: ${e.toString()}',
      );
      AppLogger.error('Recognition start failed', e);
    }
  }

  /// Stops the recognition pipeline.
  Future<void> stopRecognition() async {
    if (!state.isRunning) return;

    _predictionSub?.cancel();
    _landmarkSub?.cancel();
    _fpsTimer?.cancel();

    final service = _ref.read(gestureRecognitionServiceProvider);
    await service.stop();

    state = state.copyWith(
      isRunning: false,
      currentPrediction: null,
      currentLandmarks: null,
      fps: 0.0,
      inferenceMs: 0.0,
    );

    AppLogger.info('Recognition stopped');
  }

  /// Toggles recognition on/off.
  Future<void> toggleRecognition() async {
    if (state.isRunning) {
      await stopRecognition();
    } else {
      await startRecognition();
    }
  }

  /// Clears the composed text.
  void clearText() {
    final sentenceBuilder = _ref.read(sentenceBuilderProvider);
    sentenceBuilder.clear();
    state = state.copyWith(composedText: '');
  }

  /// Updates composed text from manual editing.
  void updateText(String text) {
    final sentenceBuilder = _ref.read(sentenceBuilderProvider);
    sentenceBuilder.setText(text);
    state = state.copyWith(composedText: text);
  }

  /// Gets the current text for copy/share.
  String get currentText => state.composedText;

  @override
  void dispose() {
    _predictionSub?.cancel();
    _landmarkSub?.cancel();
    _fpsTimer?.cancel();
    super.dispose();
  }
}
