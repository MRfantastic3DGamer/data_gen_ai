import 'package:data_gen_ai/core/game_data_path.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/game_data_storage.dart';

class LocalGameDataStorage implements GameDataStorage {
  LocalGameDataStorage(this._fileService);

  final FileService _fileService;

  @override
  Future<String> displayLocation() async {
    final root = await _fileService.getRawRootDirectory();
    return root.path;
  }

  @override
  Future<List<String>> listJsonKeys() async {
    final root = await _fileService.getRawRootDirectory();
    final files = await _fileService.listJsonFiles();
    return files
        .map((f) => GameDataPath.keyFromAbsolutePath(f.path, root.path))
        .toList()
      ..sort();
  }

  @override
  Future<String> readContent(String key) async {
    final root = await _fileService.getRawRootDirectory();
    final path = GameDataPath.absolutePathFromKey(key, root.path);
    return _fileService.readFile(path);
  }

  @override
  Future<void> writeContent(String key, String content) async {
    final root = await _fileService.getRawRootDirectory();
    final path = GameDataPath.absolutePathFromKey(key, root.path);
    await _fileService.writeFile(path, content);
  }

  Future<void> clearAllLocalFiles() => _fileService.clearRawRootDirectory();
}
