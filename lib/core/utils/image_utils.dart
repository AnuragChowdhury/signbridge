import 'dart:typed_data';
import 'package:camera/camera.dart';
import '../../core/constants/model_constants.dart';

/// Utility functions for image processing and landmark manipulation.
class ImageUtils {
  ImageUtils._();

  /// Normalizes 21 hand landmarks to be translation and scale invariant.
  ///
  /// Process:
  /// 1. Centers landmarks relative to the wrist (landmark 0)
  /// 2. Scales so the maximum distance from wrist is 1.0
  /// 3. Flattens to a 1D array of 63 floats [x0, y0, z0, x1, y1, z1, ...]
  static Float32List normalizeLandmarks(List<List<double>> landmarks) {
    if (landmarks.length != ModelConstants.landmarkCount) {
      throw ArgumentError(
        'Expected ${ModelConstants.landmarkCount} landmarks, got ${landmarks.length}',
      );
    }

    // Extract wrist position (landmark 0) as reference point
    final wristX = landmarks[0][0];
    final wristY = landmarks[0][1];
    final wristZ = landmarks[0][2];

    // Center relative to wrist
    final centered = landmarks.map((lm) {
      return [lm[0] - wristX, lm[1] - wristY, lm[2] - wristZ];
    }).toList();

    // Find max distance from wrist for scale normalization
    double maxDist = 0.0;
    for (final lm in centered) {
      final dist = _euclideanDistance(lm);
      if (dist > maxDist) maxDist = dist;
    }

    // Avoid division by zero
    if (maxDist < 1e-6) maxDist = 1.0;

    // Normalize and flatten to 1D array
    final result = Float32List(ModelConstants.inputFeatureSize);
    for (int i = 0; i < centered.length; i++) {
      result[i * 3] = centered[i][0] / maxDist;
      result[i * 3 + 1] = centered[i][1] / maxDist;
      result[i * 3 + 2] = centered[i][2] / maxDist;
    }

    return result;
  }

  /// Calculates the Euclidean distance of a 3D point from origin.
  static double _euclideanDistance(List<double> point) {
    return (point[0] * point[0] + point[1] * point[1] + point[2] * point[2]);
  }

  /// Converts a CameraImage in YUV420 format to RGB bytes.
  ///
  /// This is used when manual image processing is needed.
  /// For MediaPipe integration, the hand_landmarker plugin handles
  /// format conversion internally.
  static Uint8List? yuv420ToRgb(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

      final Uint8List rgbBytes = Uint8List(width * height * 3);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex =
              uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
          final int index = y * width + x;

          final yVal = image.planes[0].bytes[index];
          final uVal = image.planes[1].bytes[uvIndex];
          final vVal = image.planes[2].bytes[uvIndex];

          // YUV to RGB conversion
          final int r = (yVal + 1.370705 * (vVal - 128)).round();
          final int g =
              (yVal - 0.337633 * (uVal - 128) - 0.698001 * (vVal - 128))
                  .round();
          final int b = (yVal + 1.732446 * (uVal - 128)).round();

          rgbBytes[index * 3] = r.clamp(0, 255);
          rgbBytes[index * 3 + 1] = g.clamp(0, 255);
          rgbBytes[index * 3 + 2] = b.clamp(0, 255);
        }
      }

      return rgbBytes;
    } catch (e) {
      return null;
    }
  }
}
