import 'dart:async';

import 'package:camera/camera.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/image_utils.dart';
import '../core/utils/logger.dart';
import '../models/gesture_prediction.dart';
import '../models/hand_landmark.dart';
import '../models/sign_language.dart';
import 'camera_service.dart';
import 'hand_landmark_service.dart';
import 'temporal_smoothing_service.dart';
import 'tflite_service.dart';

/// Orchestrates the complete gesture recognition pipeline.
///
/// Pipeline flow:
/// Camera Frame → Hand Landmarks → Feature Normalization →
/// TFLite Inference → Temporal Smoothing → Prediction Output
///
/// Emits a stream of stabilized [GesturePrediction] results.
class GestureRecognitionService {
  final CameraService _cameraService;
  final HandLandmarkService _landmarkService;
  final TfliteService _tfliteService;
  final TemporalSmoothingService _smoothingService;

  // Stream controller for prediction output
  final StreamController<GesturePrediction> _predictionController =
      StreamController<GesturePrediction>.broadcast();

  // Stream controller for landmark output (for overlay rendering)
  final StreamController<HandLandmarks?> _landmarkController =
      StreamController<HandLandmarks?>.broadcast();

  // Performance tracking
  DateTime? _lastFrameTime;
  double _currentFps = 0.0;
  double _lastInferenceMs = 0.0;
  bool _isRunning = false;
  int _processedFrames = 0;

  GestureRecognitionService({
    required CameraService cameraService,
    required HandLandmarkService landmarkService,
    required TfliteService tfliteService,
    required TemporalSmoothingService smoothingService,
  })  : _cameraService = cameraService,
        _landmarkService = landmarkService,
        _tfliteService = tfliteService,
        _smoothingService = smoothingService;

  /// Stream of stabilized gesture predictions.
  Stream<GesturePrediction> get predictions => _predictionController.stream;

  /// Stream of detected hand landmarks (for overlay rendering).
  Stream<HandLandmarks?> get landmarks => _landmarkController.stream;

  /// Current frames per second.
  double get currentFps => _currentFps;

  /// Last inference time in milliseconds.
  double get lastInferenceMs => _lastInferenceMs;

  /// Whether recognition is currently active.
  bool get isRunning => _isRunning;

  /// Total processed frames since last start.
  int get processedFrames => _processedFrames;

  /// Starts the recognition pipeline.
  ///
  /// Begins streaming camera frames, detecting landmarks,
  /// and running gesture classification.
  Future<void> start() async {
    if (_isRunning) {
      AppLogger.warning('Recognition already running');
      return;
    }

    if (!_tfliteService.isModelLoaded) {
      AppLogger.error('Cannot start recognition: no model loaded');
      return;
    }

    _isRunning = true;
    _processedFrames = 0;
    _smoothingService.reset();

    await _cameraService.startFrameStream(
      onFrame: _processFrame,
      frameSkip: AppConstants.defaultFrameSkip,
    );

    AppLogger.info('Gesture recognition started');
  }

  /// Stops the recognition pipeline.
  Future<void> stop() async {
    if (!_isRunning) return;

    _isRunning = false;
    await _cameraService.stopFrameStream();
    _landmarkController.add(null);

    AppLogger.info(
      'Gesture recognition stopped. Processed $processedFrames frames.',
    );
  }

  /// Processes a single camera frame through the full pipeline.
  void _processFrame(CameraImage image) async {
    if (!_isRunning) return;

    final frameStart = DateTime.now();

    // Update FPS counter
    if (_lastFrameTime != null) {
      final elapsed = frameStart.difference(_lastFrameTime!).inMicroseconds;
      if (elapsed > 0) {
        _currentFps = 1000000.0 / elapsed;
      }
    }
    _lastFrameTime = frameStart;

    try {
      // Step 1: Detect hand landmarks
      final landmarks = await _landmarkService.detectLandmarks(image);
      _landmarkController.add(landmarks);

      if (landmarks == null || !landmarks.isValid) {
        // No hand detected - emit empty prediction
        _predictionController.add(GesturePrediction.empty());
        return;
      }

      // Step 2: Normalize landmarks to feature vector
      final features = ImageUtils.normalizeLandmarks(
        landmarks.toCoordinatesList(),
      );

      // Step 3: Run TFLite inference
      final inferenceStart = DateTime.now();
      final rawPrediction = _tfliteService.classify(features);
      _lastInferenceMs =
          DateTime.now().difference(inferenceStart).inMicroseconds / 1000.0;

      if (rawPrediction == null) {
        _predictionController.add(GesturePrediction.empty());
        return;
      }

      // Step 4: Apply temporal smoothing
      final smoothed = _smoothingService.addPrediction(rawPrediction);

      if (smoothed != null) {
        _predictionController.add(smoothed);
      }

      _processedFrames++;
    } catch (e) {
      AppLogger.debug('Frame processing error: $e');
    }
  }

  /// Switches the sign language model.
  ///
  /// Stops recognition, loads the new model, and optionally restarts.
  Future<void> switchLanguage(
    SignLanguage language, {
    bool autoRestart = true,
  }) async {
    final wasRunning = _isRunning;
    if (wasRunning) await stop();

    await _tfliteService.loadModel(language);
    _smoothingService.reset();

    if (wasRunning && autoRestart) await start();

    AppLogger.info('Switched to ${language.displayName}');
  }

  /// Disposes all resources.
  Future<void> dispose() async {
    await stop();
    await _predictionController.close();
    await _landmarkController.close();
    await _landmarkService.dispose();
    _tfliteService.dispose();
    AppLogger.info('Gesture recognition service disposed');
  }
}
