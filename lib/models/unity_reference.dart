/// Cross-asset reference using a logical GameData JSON key instead of a Unity GUID.
///
/// Wire format between Flutter and Unity:
/// `{ "assetKey": "beliefs/MyBelief.json", "displayName": "MyBelief" }`
///
/// Legacy Unity YAML refs `{ "fileID", "guid", "type" }` are still accepted on read.
class UnityReference {
  const UnityReference({
    this.assetKey = '',
    this.displayName = '',
    this.guid = '',
    this.fileId = 0,
  });

  final String assetKey;
  final String displayName;
  final String guid;
  final int fileId;

  factory UnityReference.empty() => const UnityReference();

  bool get isNull => assetKey.isEmpty && guid.isEmpty && fileId == 0;

  /// Human-readable label for UI and raw JSON inspection.
  String get label {
    if (displayName.isNotEmpty) return displayName;
    if (assetKey.isNotEmpty) {
      final parts = assetKey.split('/');
      return parts.last.replaceAll('.json', '');
    }
    if (guid.isNotEmpty) return guid;
    return '(None)';
  }

  factory UnityReference.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UnityReference.empty();

    final assetKey = json['assetKey'] as String? ?? '';
    if (json.containsKey('assetKey')) {
      return UnityReference(
        assetKey: assetKey,
        displayName:
            json['displayName'] as String? ?? json['name'] as String? ?? '',
      );
    }

    final fileId = _readInt(json['fileID']);
    final guid = (json['guid'] ?? '') as String;
    if (fileId == 0 && guid.isEmpty) return UnityReference.empty();

    return UnityReference(
      guid: guid,
      fileId: fileId,
    );
  }

  factory UnityReference.fromAssetKey(
    String key, {
    String displayName = '',
  }) =>
      UnityReference(assetKey: key, displayName: displayName);

  Map<String, dynamic> toJson() {
    if (isNull) return <String, dynamic>{'assetKey': ''};

    if (assetKey.isNotEmpty) {
      return <String, dynamic>{
        'assetKey': assetKey,
        if (displayName.isNotEmpty) 'displayName': displayName,
      };
    }

    // Legacy fallback when only a GUID was resolved locally.
    return <String, dynamic>{
      'fileID': fileId == 0 ? 11400000 : fileId,
      'guid': guid,
      'type': 2,
    };
  }

  UnityReference copyWith({
    String? assetKey,
    String? displayName,
    String? guid,
    int? fileId,
  }) =>
      UnityReference(
        assetKey: assetKey ?? this.assetKey,
        displayName: displayName ?? this.displayName,
        guid: guid ?? this.guid,
        fileId: fileId ?? this.fileId,
      );

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
