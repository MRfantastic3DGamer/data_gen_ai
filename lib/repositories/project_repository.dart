import 'dart:convert';

import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/serialization_data.dart';
import 'package:data_gen_ai/models/unity_envelope.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/json_converter.dart';

class ProjectRepository {
  ProjectRepository({
    required FileService fileService,
    required JsonConverterService jsonConverter,
  }) : _fileService = fileService,
       _jsonConverter = jsonConverter;

  final FileService _fileService;
  final JsonConverterService _jsonConverter;

  Future<List<String>> listJsonPaths() async {
    final files = await _fileService.listJsonFiles();
    return files.map((f) => f.path).toList()..sort();
  }

  Future<GameDataFileEntry> loadEntry(String path) async {
    final envelope = await loadEnvelope(path);
    final payload = _jsonConverter.extractPayload(envelope);
    final typeInfo = SOTypeRegistry.fromClassIdentifier(
      envelope.editorClassIdentifier,
    ) ?? SOTypeRegistry.fromPath(path);
    return GameDataFileEntry(
      path: path,
      fileName: path.split('/').last,
      typeInfo: typeInfo,
      envelope: envelope,
      payload: payload,
    );
  }

  Future<List<GameDataFileEntry>> loadAllEntries() async {
    final paths = await listJsonPaths();
    final entries = <GameDataFileEntry>[];
    for (final path in paths) {
      try {
        entries.add(await loadEntry(path));
      } catch (_) {
        // Skip corrupt files during bulk load.
      }
    }
    return entries;
  }

  Future<UnityEnvelope> loadEnvelope(String path) async {
    final content = await _fileService.readFile(path);
    return _jsonConverter.parseEnvelope(content);
  }

  Future<Map<String, dynamic>> loadPayload(String path) async {
    final envelope = await loadEnvelope(path);
    return _jsonConverter.extractPayload(envelope);
  }

  Future<void> saveEnvelope(String path, UnityEnvelope envelope) async {
    await _fileService.writeFile(path, _jsonConverter.encodeEnvelope(envelope));
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
    final merged = _jsonConverter.mergePayload(
      original: baseEnvelope,
      payload: payload,
    );
    if (name != null && name.isNotEmpty) {
      await saveEnvelope(
        path,
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
      await saveEnvelope(path, merged);
    }
  }

  Future<void> saveRawJson(String path, Map<String, dynamic> json) async {
    await _fileService.writeFile(
      path,
      const JsonEncoder.withIndent('  ').convert(json),
    );
  }

  SOTypeInfo? typeInfoForName(String typeName) {
    for (final info in SOTypeRegistry.all) {
      if (info.key == typeName) return info;
    }
    return null;
  }

  /// Creates a brand-new JSON file wrapped in a Unity envelope.
  /// Returns the absolute file path that was written.
  Future<String> createNewFile({
    SOTypeInfo? typeInfo,
    String? typeName,
    required String objectName,
    required Map<String, dynamic> payload,
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
    final root = await _fileService.getRawRootDirectory();
    final dir = resolved.subfolder.isEmpty
        ? root.path
        : '${root.path}/${resolved.subfolder}';
    final path = '$dir/$objectName.json';

    final envelope = UnityEnvelope(
      name: objectName,
      editorClassIdentifier: resolved.classIdentifier,
      serializationData: resolved.key == 'BeliefSO'
          ? null
          : const SerializationData(),
      payload: payload,
    );

    await saveEnvelope(path, envelope);
    return path;
  }

  Future<int> commitAll(List<GameDataFileEntry> dirtyEntries) async {
    var count = 0;
    for (final entry in dirtyEntries.where((e) => e.isDirty)) {
      await saveEntry(entry);
      count++;
    }
    return count;
  }
}
