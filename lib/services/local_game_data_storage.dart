import 'package:data_gen_ai/core/game_data_path.dart';
import 'package:data_gen_ai/core/platform_support.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/game_data_storage.dart';

class LocalGameDataStorage implements GameDataStorage {
  LocalGameDataStorage(this._fileService);

  final FileService _fileService;

  @override
  Future<String> displayLocation() => _fileService.rawRootPathLabel();

  @override
  Future<List<String>> listJsonKeys() async {
    if (!supportsLocalRawFileIo) return <String>[];
    final root = await _fileService.getRawRootDirectory();
    final files = await _fileService.listJsonFiles();
    return files
        .map((f) => GameDataPath.keyFromAbsolutePath(f.path, root.path))
        .toList()
      ..sort();
  }

  @override
  Future<String> readContent(String key) async {
    if (!supportsLocalRawFileIo) {
      throw UnsupportedError(FileService.webDataLocationLabel);
    }
    final root = await _fileService.getRawRootDirectory();
    final path = GameDataPath.absolutePathFromKey(key, root.path);
    return _fileService.readFile(path);
  }

  @override
  Future<void> writeContent(String key, String content) async {
    if (!supportsLocalRawFileIo) {
      throw UnsupportedError(FileService.webDataLocationLabel);
    }
    final root = await _fileService.getRawRootDirectory();
    final path = GameDataPath.absolutePathFromKey(key, root.path);
    await _fileService.writeFile(path, content);
  }

  @override
  Future<void> deleteContent(String key) async {
    if (!supportsLocalRawFileIo) {
      throw UnsupportedError(FileService.webDataLocationLabel);
    }
    final root = await _fileService.getRawRootDirectory();
    final path = GameDataPath.absolutePathFromKey(key, root.path);
    await _fileService.deleteFile(path);
  }

  Future<void> clearAllLocalFiles() => _fileService.clearRawRootDirectory();
}
