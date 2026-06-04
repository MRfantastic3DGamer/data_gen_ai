import 'package:data_gen_ai/core/game_data_path.dart';

/// Paths for Action Catalog entry JSON under `actionable/`.
abstract final class ActionCatalogPaths {
  static const String _prefix = 'actionable/';

  /// Tree path relative to the actionable folder (e.g. `general/combat/attack`).
  static String treePathFromKey(String jsonKey) {
    var path = GameDataPath.normalizeKey(jsonKey);
    if (path.startsWith(_prefix)) {
      path = path.substring(_prefix.length);
    }
    if (path.endsWith('.json')) {
      path = path.substring(0, path.length - 5);
    }
    return path;
  }
}
