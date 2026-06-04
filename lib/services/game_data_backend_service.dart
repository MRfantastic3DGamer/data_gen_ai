import 'package:data_gen_ai/core/enums/game_data_backend.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/firebase_game_data_storage.dart';
import 'package:data_gen_ai/services/game_data_storage.dart';
import 'package:data_gen_ai/services/local_game_data_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Editing always uses the local RAW folder. Firebase is only used via [GameDataSyncService].
class GameDataBackendService {
  GameDataBackendService({
    FileService? fileService,
    FirebaseGameDataStorage? firebaseStorage,
  }) : _firebaseStorage = firebaseStorage ?? FirebaseGameDataStorage(),
       _localStorage = LocalGameDataStorage(fileService ?? FileService());

  static const _prefKey = 'game_data_backend';

  final FirebaseGameDataStorage _firebaseStorage;
  final LocalGameDataStorage _localStorage;

  /// Always local — all design work reads/writes the on-device RAW folder.
  GameDataBackend get backend => GameDataBackend.localFiles;

  FirebaseGameDataStorage get firebaseStorage => _firebaseStorage;

  LocalGameDataStorage get localStorage => _localStorage;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, GameDataBackend.localFiles.storageKey);
  }

  /// Kept for compatibility; editing storage is always local.
  Future<void> setBackend(GameDataBackend backend) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, GameDataBackend.localFiles.storageKey);
  }

  GameDataStorage storageFor(GameDataBackend? override) {
    return _localStorage;
  }

  GameDataStorage get activeStorage => _localStorage;
}
