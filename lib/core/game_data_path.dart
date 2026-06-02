import 'package:path/path.dart' as p;

/// Logical keys for GameData JSON (relative to RAW root), e.g. `beliefs/foo.json`.
class GameDataPath {
  const GameDataPath._();

  static String normalizeKey(String key) {
    return key.replaceAll('\\', '/');
  }

  static String fileNameFromKey(String key) {
    return p.basename(normalizeKey(key));
  }

  /// Converts an on-disk path under [rawRoot] to a logical Firebase/local key.
  static String keyFromAbsolutePath(String absolutePath, String rawRoot) {
    final normalizedAbs = p.normalize(absolutePath);
    final normalizedRoot = p.normalize(rawRoot);
    if (normalizedAbs.startsWith(normalizedRoot)) {
      var relative = normalizedAbs.substring(normalizedRoot.length);
      if (relative.startsWith(p.separator)) {
        relative = relative.substring(1);
      }
      return normalizeKey(relative);
    }
    return normalizeKey(absolutePath);
  }

  /// Absolute filesystem path for a logical key under [rawRoot].
  static String absolutePathFromKey(String key, String rawRoot) {
    final segments = normalizeKey(key).split('/');
    return p.joinAll(<String>[rawRoot, ...segments]);
  }

  /// RTDB path segments under [FirebaseGameDataConstants.filesRoot].
  /// `beliefs/foo.json` → `beliefs/foo` (file name without extension as leaf folder).
  static List<String> rtdbSegmentsFromKey(String key) {
    final normalized = normalizeKey(key);
    final dir = p.dirname(normalized);
    final base = p.basenameWithoutExtension(normalized);
    if (dir == '.' || dir.isEmpty) {
      return <String>[base];
    }
    return <String>[...dir.split('/'), base];
  }
}
