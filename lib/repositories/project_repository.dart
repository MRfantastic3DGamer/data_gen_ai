import 'dart:convert';

import 'package:data_gen_ai/models/serialization_data.dart';
import 'package:data_gen_ai/models/unity_envelope.dart';
import 'package:data_gen_ai/services/file_service.dart';
import 'package:data_gen_ai/services/json_converter.dart';

class _TypeMeta {
  const _TypeMeta(this.classIdentifier, this.subfolder);
  final String classIdentifier;
  final String subfolder;
}

class ProjectRepository {
  ProjectRepository({
    required FileService fileService,
    required JsonConverterService jsonConverter,
  }) : _fileService = fileService,
       _jsonConverter = jsonConverter;

  final FileService _fileService;
  final JsonConverterService _jsonConverter;

  static const Map<String, _TypeMeta> _typeMeta = <String, _TypeMeta>{
    'CharacterData': _TypeMeta(
      'Assembly-CSharp::Character.CharacterData',
      '',
    ),
    'ItemData': _TypeMeta('Assembly-CSharp::Item.ItemData', 'Items'),
    'ActionableSO': _TypeMeta(
      'Assembly-CSharp::AI.DataModels.ActionableSO',
      'actionable',
    ),
    'BeliefSO': _TypeMeta(
      'Assembly-CSharp::AI.Utility.BeliefSelectionSO',
      'belief selection',
    ),
  };

  Future<List<String>> listJsonPaths() async {
    final files = await _fileService.listJsonFiles();
    return files.map((f) => f.path).toList()..sort();
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

  Future<void> savePayload({
    required String path,
    required UnityEnvelope baseEnvelope,
    required Map<String, dynamic> payload,
  }) async {
    final merged = _jsonConverter.mergePayload(
      original: baseEnvelope,
      payload: payload,
    );
    await saveEnvelope(path, merged);
  }

  Future<void> saveRawJson(String path, Map<String, dynamic> json) async {
    await _fileService.writeFile(
      path,
      const JsonEncoder.withIndent('  ').convert(json),
    );
  }

  /// Creates a brand-new JSON file wrapped in a Unity envelope.
  /// Returns the absolute file path that was written.
  Future<String> createNewFile({
    required String typeName,
    required String objectName,
    required Map<String, dynamic> payload,
  }) async {
    final meta = _typeMeta[typeName];
    final classId = meta?.classIdentifier ?? 'Assembly-CSharp::$typeName';
    final subfolder = meta?.subfolder ?? '';

    final root = await _fileService.getRawRootDirectory();
    final dir = subfolder.isEmpty ? root.path : '${root.path}/$subfolder';
    final path = '$dir/$objectName.json';

    final envelope = UnityEnvelope(
      name: objectName,
      editorClassIdentifier: classId,
      serializationData: const SerializationData(),
      payload: payload,
    );

    await saveEnvelope(path, envelope);
    return path;
  }
}
