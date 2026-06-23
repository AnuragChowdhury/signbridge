import 'package:hive_ce/hive.dart';

part 'recognition_history.g.dart';

/// A single recognition history entry persisted via Hive.
@HiveType(typeId: 0)
class RecognitionHistory extends HiveObject {
  /// The recognized text from the session.
  @HiveField(0)
  final String text;

  /// Timestamp when the recognition occurred.
  @HiveField(1)
  final DateTime timestamp;

  /// The sign language code that was active during recognition.
  @HiveField(2)
  final String languageCode;

  /// Optional: the display name of the language.
  @HiveField(3)
  final String languageName;

  RecognitionHistory({
    required this.text,
    required this.timestamp,
    required this.languageCode,
    required this.languageName,
  });

  /// Creates a new history entry for the current time.
  factory RecognitionHistory.create({
    required String text,
    required String languageCode,
    required String languageName,
  }) {
    return RecognitionHistory(
      text: text,
      timestamp: DateTime.now(),
      languageCode: languageCode,
      languageName: languageName,
    );
  }

  /// Formatted timestamp string for display.
  String get formattedTimestamp {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  String toString() =>
      'RecognitionHistory("$text", $languageCode, $formattedTimestamp)';
}
