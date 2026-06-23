/// Represents a single hand landmark with 3D coordinates.
///
/// MediaPipe hand detection produces 21 landmarks per hand.
/// Each landmark has normalized (x, y, z) coordinates where:
/// - x, y are normalized to [0.0, 1.0] by image dimensions
/// - z represents depth relative to the wrist
class HandLandmark {
  final double x;
  final double y;
  final double z;

  const HandLandmark({
    required this.x,
    required this.y,
    required this.z,
  });

  /// Creates a landmark from a list of coordinates [x, y, z].
  factory HandLandmark.fromList(List<double> coords) {
    assert(coords.length == 3, 'Landmark requires exactly 3 coordinates');
    return HandLandmark(x: coords[0], y: coords[1], z: coords[2]);
  }

  /// Converts to a list [x, y, z].
  List<double> toList() => [x, y, z];

  @override
  String toString() => 'HandLandmark($x, $y, $z)';
}

/// Represents a complete set of 21 hand landmarks detected in a frame.
///
/// The landmark indices follow MediaPipe's convention:
/// 0: WRIST
/// 1-4: THUMB (CMC, MCP, IP, TIP)
/// 5-8: INDEX FINGER (MCP, PIP, DIP, TIP)
/// 9-12: MIDDLE FINGER (MCP, PIP, DIP, TIP)
/// 13-16: RING FINGER (MCP, PIP, DIP, TIP)
/// 17-20: PINKY (MCP, PIP, DIP, TIP)
class HandLandmarks {
  final List<HandLandmark> landmarks;
  final double handedness; // 0.0 = left, 1.0 = right
  final double detectionConfidence;

  const HandLandmarks({
    required this.landmarks,
    this.handedness = 0.5,
    this.detectionConfidence = 0.0,
  });

  /// Number of landmarks (should always be 21).
  int get count => landmarks.length;

  /// Whether this represents a valid hand detection.
  bool get isValid => landmarks.length == 21;

  /// Gets the wrist landmark (index 0).
  HandLandmark get wrist => landmarks[0];

  /// Converts all landmarks to a flat list of coordinates.
  /// Returns [[x0, y0, z0], [x1, y1, z1], ...].
  List<List<double>> toCoordinatesList() {
    return landmarks.map((lm) => lm.toList()).toList();
  }

  /// Creates landmarks from a flat list of coordinate triples.
  factory HandLandmarks.fromCoordinatesList(
    List<List<double>> coords, {
    double handedness = 0.5,
    double detectionConfidence = 0.0,
  }) {
    return HandLandmarks(
      landmarks: coords.map((c) => HandLandmark.fromList(c)).toList(),
      handedness: handedness,
      detectionConfidence: detectionConfidence,
    );
  }

  /// Landmark connection pairs for drawing skeleton overlay.
  /// Each pair represents indices of connected landmarks.
  static const List<List<int>> connections = [
    [0, 1], [1, 2], [2, 3], [3, 4], // Thumb
    [0, 5], [5, 6], [6, 7], [7, 8], // Index
    [0, 9], [9, 10], [10, 11], [11, 12], // Middle
    [0, 13], [13, 14], [14, 15], [15, 16], // Ring
    [0, 17], [17, 18], [18, 19], [19, 20], // Pinky
    [5, 9], [9, 13], [13, 17], // Palm
  ];
}
