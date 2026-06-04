import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/game_data_tree_node.dart';

/// Builds folder trees from logical GameData JSON keys.
abstract final class GameDataTreeBuilder {
  static List<GameDataTreeNode> fromEntries(List<GameDataFileEntry> entries) {
    return fromPaths(
      entries
          .map(
            (e) => _PathEntry(
              path: e.path,
              label: e.displayName,
              entry: e,
            ),
          )
          .toList(),
    );
  }

  static List<GameDataTreeNode> fromAssetOptions(List<AssetPickerOption> options) {
    final pathEntries = <_PathEntry>[];
    for (final option in options) {
      if (option.label == '(None)' && option.path == null) continue;
      final path = option.path ?? option.subtitle;
      if (path.isEmpty) {
        pathEntries.add(
          _PathEntry(
            path: option.guid.isEmpty ? option.label : option.guid,
            label: option.label,
            option: option,
          ),
        );
        continue;
      }
      pathEntries.add(
        _PathEntry(path: path, label: option.label, option: option),
      );
    }
    return fromPaths(pathEntries);
  }

  static List<GameDataTreeNode> fromPaths(List<String> paths) {
    return fromPathEntries(
      paths.map((path) => _PathEntry(path: path, label: _fileLabel(path))).toList(),
    );
  }

  static List<GameDataTreeNode> fromPathEntries(List<_PathEntry> items) {
    final root = <String, _MutableNode>{};

    for (final item in items) {
      final segments = item.path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) continue;

      var level = root;
      for (var i = 0; i < segments.length; i++) {
        final segment = segments[i];
        final isLeaf = i == segments.length - 1;
        level.putIfAbsent(segment, _MutableNode.new);
        final node = level[segment]!;

        if (isLeaf) {
          node.leaf = item;
        } else {
          level = node.children;
        }
      }
    }

    return _toNodes(root);
  }

  static List<GameDataTreeNode> _toNodes(Map<String, _MutableNode> map) {
    final keys = map.keys.toList()..sort(_compareSegment);
    return keys.map((key) {
      final node = map[key]!;
      if (node.leaf != null && node.children.isEmpty) {
        final leaf = node.leaf!;
        return GameDataTreeNode.file(
          name: leaf.label,
          path: leaf.path,
          entry: leaf.entry,
          option: leaf.option,
        );
      }

      final childNodes = _toNodes(node.children);
      if (node.leaf != null) {
        final leaf = node.leaf!;
        childNodes.add(
          GameDataTreeNode.file(
            name: leaf.label,
            path: leaf.path,
            entry: leaf.entry,
            option: leaf.option,
          ),
        );
        childNodes.sort(_compareNode);
      }

      return GameDataTreeNode.folder(name: key, children: childNodes);
    }).toList();
  }

  static int _compareSegment(String a, String b) {
    final aIsFile = a.endsWith('.json');
    final bIsFile = b.endsWith('.json');
    if (aIsFile != bIsFile) return aIsFile ? 1 : -1;
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  static int _compareNode(GameDataTreeNode a, GameDataTreeNode b) {
    if (a.isFolder != b.isFolder) return a.isFolder ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  static String _fileLabel(String path) {
    final name = path.split('/').last;
    return name.endsWith('.json')
        ? name.substring(0, name.length - 5)
        : name;
  }
}

class _PathEntry {
  const _PathEntry({
    required this.path,
    required this.label,
    this.entry,
    this.option,
  });

  final String path;
  final String label;
  final GameDataFileEntry? entry;
  final AssetPickerOption? option;
}

class _MutableNode {
  Map<String, _MutableNode> children = <String, _MutableNode>{};
  _PathEntry? leaf;
}
