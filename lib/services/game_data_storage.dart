/// Abstraction for reading/writing GameData JSON (local files or Firebase).
abstract class GameDataStorage {
  Future<List<String>> listJsonKeys();

  Future<String> readContent(String key);

  Future<void> writeContent(String key, String content);

  Future<void> deleteContent(String key);

  /// Human-readable location for UI (folder path or Firebase label).
  Future<String> displayLocation();
}
