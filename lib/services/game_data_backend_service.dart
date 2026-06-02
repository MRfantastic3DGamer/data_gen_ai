import 'package:data_gen_ai/core/enums/game_data_backend.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/firebase_game_data_storage.dart';
import 'package:data_gen_ai/services/game_data_storage.dart';
import 'package:data_gen_ai/services/local_game_data_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameDataBackendService {
  GameDataBackendService({
    FileService? fileService,
    FirebaseGameDataStorage? firebaseStorage,
  }) : _fileService = fileService ?? FileService(),
       _firebaseStorage = firebaseStorage ?? FirebaseGameDataStorage();

  static const _prefKey = 'game_data_backend';

  final FileService _fileService;
  final FirebaseGameDataStorage _firebaseStorage;

  GameDataBackend _backend = GameDataBackend.firebase;

  GameDataBackend get backend => _backend;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _backend = GameDataBackend.fromStorageKey(prefs.getString(_prefKey));
  }

  Future<void> setBackend(GameDataBackend backend) async {
    _backend = backend;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, backend.storageKey);
  }

  GameDataStorage storageFor(GameDataBackend? override) {
    final resolved = override ?? _backend;
    switch (resolved) {
      case GameDataBackend.localFiles:
        return LocalGameDataStorage(_fileService);
      case GameDataBackend.firebase:
        return _firebaseStorage;
    }
  }

  GameDataStorage get activeStorage => storageFor(null);
}
