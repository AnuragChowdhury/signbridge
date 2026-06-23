import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recognition_history.dart';
import '../repositories/history_repository.dart';

/// Provider for the history repository.
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

/// Provider for the recognition history list.
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<RecognitionHistory>>((ref) {
  return HistoryNotifier(ref);
});

/// Manages recognition history state.
class HistoryNotifier extends StateNotifier<List<RecognitionHistory>> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super([]) {
    loadHistory();
  }

  /// Loads all history entries from storage.
  void loadHistory() {
    final repo = _ref.read(historyRepositoryProvider);
    state = repo.getAll();
  }

  /// Saves a new entry and refreshes the list.
  Future<void> saveEntry({
    required String text,
    required String languageCode,
    required String languageName,
  }) async {
    final repo = _ref.read(historyRepositoryProvider);
    await repo.saveFromText(
      text: text,
      languageCode: languageCode,
      languageName: languageName,
    );
    loadHistory();
  }

  /// Deletes a specific entry.
  Future<void> deleteEntry(int key) async {
    final repo = _ref.read(historyRepositoryProvider);
    await repo.delete(key);
    loadHistory();
  }

  /// Clears all history.
  Future<void> clearAll() async {
    final repo = _ref.read(historyRepositoryProvider);
    await repo.clearAll();
    state = [];
  }
}
