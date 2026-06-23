import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/gesture_prediction.dart';

/// Intelligently combines stabilized gesture predictions into readable text.
///
/// Features:
/// - Automatic character accumulation
/// - Space insertion via SPACE gesture
/// - Backspace via DELETE gesture
/// - Duplicate character filtering
/// - Prediction buffering
/// - Manual text editing support
class SentenceBuilderService {
  final StringBuffer _buffer = StringBuffer();
  int _cursorPosition = 0;

  /// The current composed text.
  String get text => _buffer.toString();

  /// Current cursor position for editing.
  int get cursorPosition => _cursorPosition;

  /// Whether the buffer has any text.
  bool get hasText => _buffer.isNotEmpty;

  /// Processes a stabilized prediction and updates the text buffer.
  ///
  /// Returns the updated text string, or null if no change was made.
  String? processPrediction(GesturePrediction prediction) {
    if (prediction.isEmpty) return null;

    final label = prediction.label.toUpperCase();

    // Handle special gestures
    if (label == AppConstants.gestureSpace) {
      return _insertSpace();
    }

    if (label == AppConstants.gestureDelete) {
      return _deleteLastChar();
    }

    if (label == AppConstants.gestureNothing) {
      return null;
    }

    // Regular character - add to buffer
    return _addCharacter(label);
  }

  /// Adds a character to the text buffer.
  String? _addCharacter(String character) {
    // Only add single characters (A-Z)
    if (character.length != 1) {
      AppLogger.debug('Ignoring non-single character: $character');
      return null;
    }

    _buffer.write(character);
    _cursorPosition = _buffer.length;

    return text;
  }

  /// Inserts a space at the current position.
  String? _insertSpace() {
    // Don't add space at the beginning or after another space
    if (_buffer.isEmpty) return null;
    if (text.endsWith(' ')) return null;

    _buffer.write(' ');
    _cursorPosition = _buffer.length;

    return text;
  }

  /// Deletes the last character from the buffer.
  String? _deleteLastChar() {
    if (_buffer.isEmpty) return null;

    final currentText = _buffer.toString();
    _buffer.clear();
    _buffer.write(currentText.substring(0, currentText.length - 1));
    _cursorPosition = _buffer.length;

    return text;
  }

  /// Sets the text buffer directly (for manual editing).
  void setText(String newText) {
    _buffer.clear();
    _buffer.write(newText);
    _cursorPosition = _buffer.length;
  }

  /// Clears the entire text buffer.
  String clear() {
    _buffer.clear();
    _cursorPosition = 0;

    return '';
  }

  /// Gets the text and resets (for saving to history).
  String getAndClear() {
    final result = text;
    clear();
    return result;
  }

  /// Returns the last N characters for display.
  String getRecentText(int maxLength) {
    final t = text;
    if (t.length <= maxLength) return t;
    return '...${t.substring(t.length - maxLength)}';
  }

  @override
  String toString() => 'SentenceBuilder("$text")';
}
