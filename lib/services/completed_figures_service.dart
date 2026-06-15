import 'package:shared_preferences/shared_preferences.dart';

class CompletedFiguresService {
  static const _prefsKey = 'completed_figure_keys';

  Set<String> _completedKeys = {};
  bool _isLoaded = false;

  Set<String> get completedKeys => Set.unmodifiable(_completedKeys);

  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _completedKeys = (prefs.getStringList(_prefsKey) ?? []).toSet();
    _isLoaded = true;
  }

  bool isCompleted(String folderKey) => _completedKeys.contains(folderKey);

  Future<void> markCompleted(String folderKey) async {
    if (_completedKeys.contains(folderKey)) {
      return;
    }

    _completedKeys.add(folderKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _completedKeys.toList()..sort(),
    );
  }

  Future<void> reset() async {
    _completedKeys = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
