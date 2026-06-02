/// Shared Realtime Database layout for Unity editor and Flutter app.
class FirebaseGameDataConstants {
  const FirebaseGameDataConstants._();

  static const String databaseUrl =
      'https://game-dev-data-sync-default-rtdb.asia-southeast1.firebasedatabase.app';

  /// Root for all GameData JSON payloads (mirrors `Assets/GameData/RAW/`).
  static const String filesRoot = 'gameData/v1/files';

  /// Child key holding the full JSON file body (Unity envelope string).
  static const String contentField = 'content';

  /// Unix ms when the entry was last written.
  static const String updatedAtField = 'updatedAt';
}
