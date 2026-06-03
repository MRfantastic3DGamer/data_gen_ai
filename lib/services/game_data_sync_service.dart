import 'package:data_gen_ai/services/firebase_game_data_storage.dart';
import 'package:data_gen_ai/services/local_game_data_storage.dart';

class GameDataSyncResult {
  const GameDataSyncResult({required this.fileCount});

  final int fileCount;
}

/// Pulls remote Firebase game data into the local RAW folder, or pushes local edits up.
class GameDataSyncService {
  GameDataSyncService({
    required FirebaseGameDataStorage firebaseStorage,
    required LocalGameDataStorage localStorage,
  }) : _firebase = firebaseStorage,
       _local = localStorage;

  final FirebaseGameDataStorage _firebase;
  final LocalGameDataStorage _local;

  Future<GameDataSyncResult> pullFromFirebase({
    void Function(int current, int total, String key)? onProgress,
  }) async {
    final keys = await _firebase.listJsonKeys();
    final total = keys.length;
    var index = 0;
    for (final key in keys) {
      index++;
      onProgress?.call(index, total, key);
      final content = await _firebase.readContent(key);
      await _local.writeContent(key, content);
    }
    return GameDataSyncResult(fileCount: total);
  }

  Future<GameDataSyncResult> pushToFirebase({
    void Function(int current, int total, String key)? onProgress,
  }) async {
    final keys = await _local.listJsonKeys();
    final total = keys.length;
    var index = 0;
    for (final key in keys) {
      index++;
      onProgress?.call(index, total, key);
      final content = await _local.readContent(key);
      await _firebase.writeContent(key, content);
    }
    return GameDataSyncResult(fileCount: total);
  }
}
