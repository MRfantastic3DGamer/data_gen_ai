class UnityReference {
  const UnityReference({
    required this.guid,
    required this.fileId,
    this.type = 2,
  });

  final String guid;
  final int fileId;
  final int type;

  factory UnityReference.empty() =>
      const UnityReference(guid: '', fileId: 0, type: 2);

  bool get isNull => guid.isEmpty || fileId == 0;

  factory UnityReference.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UnityReference.empty();
    return UnityReference(
      guid: (json['guid'] ?? '') as String,
      fileId: (json['fileID'] ?? 0) as int,
      type: (json['type'] ?? 2) as int,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'guid': guid,
    'fileID': fileId,
    'type': type,
  };
}
