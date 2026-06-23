import 'package:camera/camera.dart';

import '../core/errors/exceptions.dart';
import '../core/utils/logger.dart';

/// Camera resolution presets available to the user.
enum CameraResolution {
  low(ResolutionPreset.low, 'Low (240p)'),
  medium(ResolutionPreset.medium, 'Medium (480p)'),
  high(ResolutionPreset.high, 'High (720p)');

  final ResolutionPreset preset;
  final String displayName;

  const CameraResolution(this.preset, this.displayName);

  static CameraResolution fromString(String value) {
    return CameraResolution.values.firstWhere(
      (r) => r.name == value,
      orElse: () => CameraResolution.medium,
    );
  }
}

/// Manages the device camera lifecycle and frame streaming.
///
/// Provides the front camera preview and streams camera frames
/// for real-time hand landmark detection.
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isStreaming = false;

  /// The current camera controller (null if not initialized).
  CameraController? get controller => _controller;

  /// Whether the camera is currently initialized and ready.
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// Whether frame streaming is active.
  bool get isStreaming => _isStreaming;

  /// Initializes the front-facing camera.
  ///
  /// Throws [CameraServiceException] if no front camera is found
  /// or initialization fails.
  Future<void> initialize({
    CameraResolution resolution = CameraResolution.medium,
  }) async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw const CameraServiceException('No cameras available on device');
      }

      // Find the front camera
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        resolution.preset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      AppLogger.info(
        'Camera initialized: ${frontCamera.name} at ${resolution.displayName}',
      );
    } catch (e) {
      if (e is CameraServiceException) rethrow;
      throw CameraServiceException(
        'Failed to initialize camera',
        originalError: e,
      );
    }
  }

  /// Starts streaming camera frames.
  ///
  /// [onFrame] is called for each captured frame.
  /// Uses frame skipping to control processing load.
  Future<void> startFrameStream({
    required void Function(CameraImage image) onFrame,
    int frameSkip = 2,
  }) async {
    if (!isInitialized) {
      throw const CameraServiceException(
        'Camera not initialized. Call initialize() first.',
      );
    }

    if (_isStreaming) {
      AppLogger.warning('Frame stream already active');
      return;
    }

    int frameCount = 0;

    await _controller!.startImageStream((CameraImage image) {
      frameCount++;
      // Skip frames to reduce processing load
      if (frameCount % (frameSkip + 1) != 0) return;
      onFrame(image);
    });

    _isStreaming = true;
    AppLogger.info('Camera frame stream started (skip: $frameSkip)');
  }

  /// Stops the camera frame stream.
  Future<void> stopFrameStream() async {
    if (!_isStreaming) return;

    try {
      await _controller?.stopImageStream();
      _isStreaming = false;
      AppLogger.info('Camera frame stream stopped');
    } catch (e) {
      AppLogger.warning('Error stopping frame stream', e);
      _isStreaming = false;
    }
  }

  /// Changes camera resolution.
  ///
  /// This requires reinitializing the camera controller.
  Future<void> changeResolution(CameraResolution resolution) async {
    final wasStreaming = _isStreaming;
    if (wasStreaming) await stopFrameStream();
    await dispose();
    await initialize(resolution: resolution);
    AppLogger.info('Camera resolution changed to ${resolution.displayName}');
  }

  /// Disposes the camera controller and releases resources.
  Future<void> dispose() async {
    if (_isStreaming) await stopFrameStream();
    await _controller?.dispose();
    _controller = null;
    AppLogger.info('Camera disposed');
  }
}
