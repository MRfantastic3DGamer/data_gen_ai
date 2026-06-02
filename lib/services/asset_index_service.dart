import 'dart:io';

import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:path/path.dart' as p;

/// Maps Unity GUIDs and GameData JSON paths to human-readable picker labels.
class AssetIndexService {
  AssetIndexService(this._fileService);

  final FileService _fileService;

  final Map<String, AssetPickerOption> _byGuid = <String, AssetPickerOption>{};
  final Map<String, String> _guidByPath = <String, String>{};
  final Map<String, List<AssetPickerOption>> _optionsByTypeKey =
      <String, List<AssetPickerOption>>{};
  List<AssetPickerOption> _allOptions = <AssetPickerOption>[];

  static final RegExp _metaGuidPattern = RegExp(
    r'^guid:\s*([a-f0-9]{32})\s*$',
    multiLine: true,
    caseSensitive: false,
  );

  bool get isBuilt => _allOptions.isNotEmpty;

  Future<void> rebuild(List<GameDataFileEntry> entries) async {
    _byGuid.clear();
    _guidByPath.clear();
    _optionsByTypeKey.clear();
    _allOptions = <AssetPickerOption>[];

    final pathToEntry = <String, GameDataFileEntry>{
      for (final e in entries) e.path: e,
    };
    final stemToPaths = <String, List<String>>{};
    for (final entry in entries) {
      final stem = _stem(entry.fileName);
      stemToPaths.putIfAbsent(stem, () => <String>[]).add(entry.path);
    }

    await _ingestMetaFiles(stemToPaths, pathToEntry);

    for (final entry in entries) {
      final guid = _guidByPath[entry.path] ?? '';
      _registerEntry(entry, guid: guid);
    }

    _sortOptions();
  }

  Future<void> _ingestMetaFiles(
    Map<String, List<String>> stemToPaths,
    Map<String, GameDataFileEntry> pathToEntry,
  ) async {
    List<File> metaFiles;
    try {
      metaFiles = await _fileService.listMetaFiles();
    } catch (_) {
      return;
    }

    for (final meta in metaFiles) {
      final guid = await _readMetaGuid(meta);
      if (guid == null || guid.isEmpty) continue;

      final stems = _stemsForMetaPath(meta.path);
      for (final stem in stems) {
        final paths = stemToPaths[stem];
        if (paths == null) continue;
        for (final path in paths) {
          if (pathToEntry.containsKey(path)) {
            _guidByPath[path] = guid;
          }
        }
      }
    }
  }

  Future<String?> _readMetaGuid(File metaFile) async {
    try {
      final text = await metaFile.readAsString();
      final match = _metaGuidPattern.firstMatch(text);
      return match?.group(1)?.toLowerCase();
    } catch (_) {
      return null;
    }
  }

  Set<String> _stemsForMetaPath(String metaPath) {
    final base = p.basename(metaPath);
    final stems = <String>{};
    if (base.endsWith('.asset.meta')) {
      stems.add(_stem(base.replaceAll('.asset.meta', '')));
    } else if (base.endsWith('.json.meta')) {
      stems.add(_stem(base.replaceAll('.json.meta', '')));
    } else if (base.endsWith('.meta')) {
      stems.add(_stem(base.replaceAll('.meta', '')));
    }
    return stems;
  }

  void _registerEntry(GameDataFileEntry entry, {required String guid}) {
    final typeKey = entry.typeInfo?.key ?? _typeKeyFromClassId(
      entry.envelope.editorClassIdentifier,
    );
    final label = entry.displayName;
    final subtitle = '${entry.typeLabel} · ${_shortPath(entry.path)}';

    final option = AssetPickerOption(
      guid: guid,
      fileId: guid.isEmpty ? 0 : 11400000,
      label: label,
      subtitle: subtitle,
      typeKey: typeKey,
      path: entry.path,
      entry: entry,
    );

    _allOptions.add(option);
    if (guid.isNotEmpty) {
      _byGuid[guid] = option;
    }
    _optionsByTypeKey.putIfAbsent(typeKey, () => <AssetPickerOption>[]).add(
      option,
    );
  }

  void _sortOptions() {
    int compare(AssetPickerOption a, AssetPickerOption b) =>
        a.label.toLowerCase().compareTo(b.label.toLowerCase());
    _allOptions.sort(compare);
    for (final list in _optionsByTypeKey.values) {
      list.sort(compare);
    }
  }

  List<AssetPickerOption> optionsFor({
    List<String>? typeKeys,
    bool includeQueryViews = false,
    bool allowNone = true,
  }) {
    Iterable<AssetPickerOption> source = _allOptions;
    if (typeKeys != null && typeKeys.isNotEmpty) {
      final allowed = typeKeys.toSet();
      source = _allOptions.where((o) {
        if (allowed.contains(o.typeKey)) return true;
        if (includeQueryViews &&
            _isQueryViewClass(o.entry?.envelope.editorClassIdentifier)) {
          return true;
        }
        return false;
      });
    } else if (!includeQueryViews) {
      source = _allOptions;
    }

    final list = source.toList();
    if (!allowNone) return list;
    return <AssetPickerOption>[AssetPickerOption.empty, ...list];
  }

  AssetPickerOption? optionForReference(UnityReference ref) {
    if (ref.guid.isNotEmpty) {
      return _byGuid[ref.guid.toLowerCase()];
    }
    return null;
  }

  AssetPickerOption? optionForPath(String path) {
    final guid = _guidByPath[path];
    if (guid != null && guid.isNotEmpty) {
      return _byGuid[guid];
    }
    for (final o in _allOptions) {
      if (o.path == path) return o;
    }
    return null;
  }

  UnityReference resolveReference(UnityReference current, AssetPickerOption picked) {
    if (picked.guid.isEmpty) {
      return UnityReference.empty();
    }
    return picked.toReference();
  }

  String _stem(String fileName) =>
      p.basenameWithoutExtension(fileName).toLowerCase();

  String _shortPath(String path) {
    final parts = path.split('/');
    if (parts.length <= 2) return parts.last;
    return '${parts[parts.length - 2]}/${parts.last}';
  }

  String _typeKeyFromClassId(String classId) {
    final info = SOTypeRegistry.fromClassIdentifier(classId);
    if (info != null) return info.key;
    if (classId.contains('QueryViews.')) return 'BaseQueryViewSO';
    return 'Unknown';
  }

  bool _isQueryViewClass(String? classId) =>
      classId != null && classId.contains('QueryViews.');
}
