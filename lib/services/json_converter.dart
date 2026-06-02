import 'dart:convert';

import 'package:data_gen_ai/models/serialization_data.dart';
import 'package:data_gen_ai/models/unity_envelope.dart';

class JsonConverterService {
  UnityEnvelope parseEnvelope(String rawJson) {
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    return UnityEnvelope.fromJson(decoded);
  }

  String encodeEnvelope(UnityEnvelope envelope) {
    return const JsonEncoder.withIndent('  ').convert(envelope.toJson());
  }

  Map<String, dynamic> extractPayload(UnityEnvelope envelope) {
    final payload = Map<String, dynamic>.from(envelope.payload);
    payload.remove('m_ObjectHideFlags');
    payload.remove('m_CorrespondingSourceObject');
    payload.remove('m_PrefabInstance');
    payload.remove('m_PrefabAsset');
    payload.remove('m_GameObject');
    payload.remove('m_Enabled');
    payload.remove('m_EditorHideFlags');
    payload.remove('m_Script');
    payload.remove('m_Name');
    payload.remove('m_EditorClassIdentifier');
    return payload;
  }

  UnityEnvelope mergePayload({
    required UnityEnvelope original,
    required Map<String, dynamic> payload,
    SerializationData? serializationData,
  }) {
    final next = Map<String, dynamic>.from(original.payload);
    next.addAll(payload);
    return UnityEnvelope(
      name: original.name,
      editorClassIdentifier: original.editorClassIdentifier,
      enabled: original.enabled,
      editorHideFlags: original.editorHideFlags,
      serializationData: serializationData ?? original.serializationData,
      payload: next,
    );
  }
}
