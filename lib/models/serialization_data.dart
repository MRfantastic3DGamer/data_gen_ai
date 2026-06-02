class SerializationData {
  const SerializationData({
    this.serializedFormat = 2,
    this.serializedBytes = '',
    this.referencedUnityObjects = const <dynamic>[],
    this.serializedBytesString = '',
    this.prefab = const <String, dynamic>{'fileID': 0},
    this.prefabModificationsReferencedUnityObjects = const <dynamic>[],
    this.prefabModifications = const <dynamic>[],
    this.serializationNodes = const <dynamic>[],
  });

  final int serializedFormat;
  final String serializedBytes;
  final List<dynamic> referencedUnityObjects;
  final String serializedBytesString;
  final Map<String, dynamic> prefab;
  final List<dynamic> prefabModificationsReferencedUnityObjects;
  final List<dynamic> prefabModifications;
  final List<dynamic> serializationNodes;

  factory SerializationData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SerializationData();
    return SerializationData(
      serializedFormat: (json['SerializedFormat'] ?? 2) as int,
      serializedBytes: (json['SerializedBytes'] ?? '') as String,
      referencedUnityObjects:
          (json['ReferencedUnityObjects'] as List<dynamic>? ??
          const <dynamic>[]),
      serializedBytesString: (json['SerializedBytesString'] ?? '') as String,
      prefab:
          (json['Prefab'] as Map<String, dynamic>? ??
          const <String, dynamic>{'fileID': 0}),
      prefabModificationsReferencedUnityObjects:
          (json['PrefabModificationsReferencedUnityObjects']
              as List<dynamic>? ??
          const <dynamic>[]),
      prefabModifications:
          (json['PrefabModifications'] as List<dynamic>? ?? const <dynamic>[]),
      serializationNodes:
          (json['SerializationNodes'] as List<dynamic>? ?? const <dynamic>[]),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'SerializedFormat': serializedFormat,
    'SerializedBytes': serializedBytes,
    'ReferencedUnityObjects': referencedUnityObjects,
    'SerializedBytesString': serializedBytesString,
    'Prefab': prefab,
    'PrefabModificationsReferencedUnityObjects':
        prefabModificationsReferencedUnityObjects,
    'PrefabModifications': prefabModifications,
    'SerializationNodes': serializationNodes,
  };
}
