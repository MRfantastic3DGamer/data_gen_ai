import 'package:data_gen_ai/core/game_data_path.dart';

abstract final class GameDataKeyBuilder {
  /// Builds a logical key such as `beliefs/my_belief.json`.
  static String build({
    required String folderPath,
    required String fileName,
  }) {
    var folder = folderPath.replaceAll('\\', '/').trim();
    if (folder.startsWith('/')) folder = folder.substring(1);
    if (folder.endsWith('/')) folder = folder.substring(0, folder.length - 1);

    var name = fileName.trim();
    if (!name.toLowerCase().endsWith('.json')) {
      name = '$name.json';
    }

    final key = folder.isEmpty ? name : '$folder/$name';
    return GameDataPath.normalizeKey(key);
  }

  static String folderFromKey(String key) {
    final normalized = GameDataPath.normalizeKey(key);
    final slash = normalized.lastIndexOf('/');
    if (slash < 0) return '';
    return normalized.substring(0, slash);
  }

  static String baseNameFromKey(String key) {
    final file = GameDataPath.fileNameFromKey(key);
    return file.endsWith('.json')
        ? file.substring(0, file.length - 5)
        : file;
  }
}
