import 'package:data_gen_ai/models/serialization_data.dart';

class UnityEnvelope {
  const UnityEnvelope({
    this.name = '',
    this.editorClassIdentifier = '',
    this.enabled = 1,
    this.editorHideFlags = 0,
    this.serializationData,
    this.payload = const <String, dynamic>{},
  });

  final String name;
  final String editorClassIdentifier;
  final int enabled;
  final int editorHideFlags;
  final SerializationData? serializationData;
  final Map<String, dynamic> payload;

  factory UnityEnvelope.fromJson(Map<String, dynamic> json) {
    final mono =
        (json['MonoBehaviour'] as Map<String, dynamic>? ?? <String, dynamic>{});
    return UnityEnvelope(
      name: (mono['m_Name'] ?? '') as String,
      editorClassIdentifier: (mono['m_EditorClassIdentifier'] ?? '') as String,
      enabled: (mono['m_Enabled'] ?? 1) as int,
      editorHideFlags: (mono['m_EditorHideFlags'] ?? 0) as int,
      serializationData: mono.containsKey('serializationData')
          ? SerializationData.fromJson(
              mono['serializationData'] as Map<String, dynamic>?,
            )
          : null,
      payload: Map<String, dynamic>.from(mono),
    );
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>.from(payload);
    data['m_Name'] = name;
    data['m_EditorClassIdentifier'] = editorClassIdentifier;
    data['m_Enabled'] = enabled;
    data['m_EditorHideFlags'] = editorHideFlags;
    if (serializationData != null) {
      data['serializationData'] = serializationData!.toJson();
    }
    return <String, dynamic>{'MonoBehaviour': data};
  }
}
