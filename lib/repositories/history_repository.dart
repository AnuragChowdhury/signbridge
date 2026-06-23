import '../core/utils/logger.dart';
import '../models/recognition_history.dart';
import '../services/storage_service.dart';

/// Repository for managing recognition history entries.
///
/// Provides CRUD operations for history with filtering support.
class HistoryRepository {
  /// Gets all history entries sorted by most recent first.
  List<RecognitionHistory> getAll() {
    return StorageService.getHistory();
  }

  /// Gets history entries filtered by language code.
  List<RecognitionHistory> getByLanguage(String languageCode) {
    return getAll()
        .where((entry) => entry.languageCode == languageCode)
        .toList();
  }

  /// Gets history entries from the last N days.
  List<RecognitionHistory> getRecent({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return getAll()
        .where((entry) => entry.timestamp.isAfter(cutoff))
        .toList();
  }

  /// Saves a new recognition entry.
  Future<void> save(RecognitionHistory entry) async {
    await StorageService.addHistory(entry);
    AppLogger.debug('History saved: "${entry.text}"');
  }

  /// Creates and saves a new entry from text and language info.
  Future<void> saveFromText({
    required String text,
    required String languageCode,
    required String languageName,
  }) async {
    if (text.trim().isEmpty) return;

    final entry = RecognitionHistory.create(
      text: text.trim(),
      languageCode: languageCode,
      languageName: languageName,
    );
    await save(entry);
  }

  /// Deletes a specific history entry.
  Future<void> delete(int key) async {
    await StorageService.deleteHistory(key);
    AppLogger.debug('History entry deleted: $key');
  }

  /// Clears all history entries.
  Future<void> clearAll() async {
    await StorageService.clearHistory();
    AppLogger.info('All history cleared');
  }

  /// Gets the total number of history entries.
  int get count => StorageService.historyCount;
}
