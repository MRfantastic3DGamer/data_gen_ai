/// Unity query view SO types (suffix of [classIdentifier]).
class QueryViewTypeInfo {
  const QueryViewTypeInfo({
    required this.key,
    required this.displayName,
  });

  final String key;
  final String displayName;

  String get classIdentifier =>
      'Assembly-CSharp::AI.DataModels.QueryViews.$key';
}

abstract final class QueryViewTypes {
  static const List<QueryViewTypeInfo> all = <QueryViewTypeInfo>[
    QueryViewTypeInfo(key: 'SensorItemQueryViewSO', displayName: 'Sensor item'),
    QueryViewTypeInfo(key: 'SensorAgentQueryViewSO', displayName: 'Sensor agent'),
    QueryViewTypeInfo(
      key: 'ThreatAdvertisementQueryViewSO',
      displayName: 'Threat advertisement',
    ),
    QueryViewTypeInfo(key: 'InventoryQueryViewSO', displayName: 'Inventory'),
    QueryViewTypeInfo(key: 'EquipmentQueryViewSO', displayName: 'Equipment'),
    QueryViewTypeInfo(key: 'SelfStatsQueryViewSO', displayName: 'Self stats'),
    QueryViewTypeInfo(key: 'WorkpostQueryViewSO', displayName: 'Workpost'),
    QueryViewTypeInfo(key: 'NotificationQueryViewSO', displayName: 'Notification'),
    QueryViewTypeInfo(key: 'PositioningQueryViewSO', displayName: 'Positioning'),
    QueryViewTypeInfo(
      key: 'ReservedSlotQueryViewSO',
      displayName: 'Reserved slot',
    ),
    QueryViewTypeInfo(key: 'ScheduleQueryViewSO', displayName: 'Schedule'),
  ];

  static QueryViewTypeInfo? byKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final t in all) {
      if (t.key == key) return t;
    }
    return null;
  }

  static QueryViewTypeInfo? fromClassIdentifier(String? identifier) {
    if (identifier == null) return null;
    for (final t in all) {
      if (identifier.contains(t.key)) return t;
    }
    return null;
  }
}
