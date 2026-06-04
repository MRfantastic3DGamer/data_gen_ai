import 'dart:convert';

import 'package:data_gen_ai/core/enums/game_data_backend.dart';
import 'package:data_gen_ai/core/platform_support.dart';
import 'package:data_gen_ai/core/game_data_path.dart';
import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/serialization_data.dart';
import 'package:data_gen_ai/models/unity_envelope.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/game_data_backend_service.dart';
import 'package:data_gen_ai/services/game_data_storage.dart';
import 'package:data_gen_ai/services/json_converter.dart';

class ProjectRepository {
  ProjectRepository({
    required GameDataBackendService backendService,
    required JsonConverterService jsonConverter,
    FileService? fileService,
  }) : _backendService = backendService,
       _jsonConverter = jsonConverter,
       _fileService = fileService ?? FileService();

  final GameDataBackendService _backendService;
  final JsonConverterService _jsonConverter;
  final FileService _fileService;

  GameDataStorage get _storage => _backendService.activeStorage;

  Future<String> dataLocationLabel() => _storage.displayLocation();

  Future<List<String>> listJsonKeys() => _storage.listJsonKeys();

  /// Backward-compatible alias used by blocs.
  Future<List<String>> listJsonPaths() => listJsonKeys();

  Future<GameDataFileEntry> loadEntry(String key) async {
    final envelope = await loadEnvelope(key);
    final payload = _jsonConverter.extractPayload(envelope);
    final typeInfo = SOTypeRegistry.fromClassIdentifier(
      envelope.editorClassIdentifier,
    ) ?? SOTypeRegistry.fromPath(key);
    return GameDataFileEntry(
      path: GameDataPath.normalizeKey(key),
      fileName: GameDataPath.fileNameFromKey(key),
      typeInfo: typeInfo,
      envelope: envelope,
      payload: payload,
    );
  }

  Future<List<GameDataFileEntry>> loadAllEntries() async {
    final keys = await listJsonKeys();
    final entries = <GameDataFileEntry>[];
    for (final key in keys) {
      try {
        entries.add(await loadEntry(key));
      } catch (_) {
        // Skip corrupt files during bulk load.
      }
    }
    return entries;
  }

  Future<UnityEnvelope> loadEnvelope(String key) async {
    final content = await _storage.readContent(key);
    return _jsonConverter.parseEnvelope(content);
  }

  Future<Map<String, dynamic>> loadPayload(String key) async {
    final envelope = await loadEnvelope(key);
    return _jsonConverter.extractPayload(envelope);
  }

  Future<void> saveEnvelope(String key, UnityEnvelope envelope) async {
    await _storage.writeContent(key, _jsonConverter.encodeEnvelope(envelope));
  }

  Future<void> saveEntry(GameDataFileEntry entry) async {
    await savePayload(
      path: entry.path,
      baseEnvelope: entry.envelope,
      payload: entry.payload,
      name: entry.envelope.name,
    );
  }

  Future<void> savePayload({
    required String path,
    required UnityEnvelope baseEnvelope,
    required Map<String, dynamic> payload,
    String? name,
  }) async {
    final key = GameDataPath.normalizeKey(path);
    final merged = _jsonConverter.mergePayload(
      original: baseEnvelope,
      payload: payload,
    );
    if (name != null && name.isNotEmpty) {
      await saveEnvelope(
        key,
        UnityEnvelope(
          name: name,
          editorClassIdentifier: merged.editorClassIdentifier,
          enabled: merged.enabled,
          editorHideFlags: merged.editorHideFlags,
          serializationData: merged.serializationData,
          payload: merged.payload,
        ),
      );
    } else {
      await saveEnvelope(key, merged);
    }
  }

  Future<void> saveRawJson(String key, Map<String, dynamic> json) async {
    await _storage.writeContent(
      GameDataPath.normalizeKey(key),
      const JsonEncoder.withIndent('  ').convert(json),
    );
  }

  SOTypeInfo? typeInfoForName(String typeName) {
    for (final info in SOTypeRegistry.all) {
      if (info.key == typeName) return info;
    }
    return null;
  }

  /// Creates a new JSON entry. Returns the logical key (e.g. `beliefs/foo.json`).
  Future<String> createNewFile({
    SOTypeInfo? typeInfo,
    String? typeName,
    required String objectName,
    required Map<String, dynamic> payload,
    String? folderPath,
    String? classIdentifierOverride,
  }) async {
    final resolved = typeInfo ??
        typeInfoForName(typeName ?? '') ??
        SOTypeInfo(
          key: typeName ?? 'Unknown',
          displayName: typeName ?? 'Unknown',
          classIdentifier: 'Assembly-CSharp::${typeName ?? 'Unknown'}',
          subfolder: '',
          category: 'Other',
        );

    final key = folderPath != null && folderPath.isNotEmpty
        ? _keyFromFolderAndName(folderPath, objectName)
        : _keyFromTypeDefaults(resolved, objectName);

    final assetName = objectName.endsWith('.json')
        ? objectName.substring(0, objectName.length - 5)
        : objectName;

    final envelope = UnityEnvelope(
      name: assetName,
      editorClassIdentifier:
          classIdentifierOverride ?? resolved.classIdentifier,
      serializationData: _needsSerializationData(resolved.key)
          ? const SerializationData()
          : null,
      payload: payload,
    );

    await saveEnvelope(key, envelope);
    return GameDataPath.normalizeKey(key);
  }

  static String _keyFromFolderAndName(String folderPath, String objectName) {
    var folder = folderPath.replaceAll('\\', '/').trim();
    if (folder.endsWith('/')) folder = folder.substring(0, folder.length - 1);
    final fileName = objectName.endsWith('.json') ? objectName : '$objectName.json';
    final key = folder.isEmpty ? fileName : '$folder/$fileName';
    return GameDataPath.normalizeKey(key);
  }

  static String _keyFromTypeDefaults(SOTypeInfo resolved, String objectName) {
    final fileName = objectName.endsWith('.json')
        ? objectName
        : '$objectName.json';
    return resolved.subfolder.isEmpty
        ? fileName
        : '${resolved.subfolder}/$fileName';
  }

  static bool _needsSerializationData(String typeKey) {
    return typeKey != 'BeliefSO';
  }

  Future<int> commitAll(
    List<GameDataFileEntry> dirtyEntries, {
    Iterable<String> deletedKeys = const <String>[],
  }) async {
    var count = 0;
    for (final key in deletedKeys) {
      await deleteEntry(key);
      count++;
    }
    for (final entry in dirtyEntries.where((e) => e.isDirty)) {
      await saveEntry(entry);
      count++;
    }
    return count;
  }

  Future<void> deleteEntry(String key) async {
    await _storage.deleteContent(GameDataPath.normalizeKey(key));
  }

  /// For local backend: absolute RAW root (meta file indexing).
  Future<String?> localRawRootPath() async {
    if (!supportsLocalRawFileIo ||
        _backendService.backend != GameDataBackend.localFiles) {
      return null;
    }
    final root = await _fileService.getRawRootDirectory();
    return root.path;
  }
}
