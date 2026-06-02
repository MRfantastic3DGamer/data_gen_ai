import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user-selected JSON root folder path (from manual transfer / file picker).
class DataFolderService {
  static const String _prefKey = 'game_data_json_root';

  Future<String?> getCustomRootPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  Future<void> setCustomRootPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, path);
    }
  }
}
