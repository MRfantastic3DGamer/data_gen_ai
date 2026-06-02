class Vector3Data {
  const Vector3Data({this.x = 0, this.y = 0, this.z = 0});
  final double x;
  final double y;
  final double z;

  factory Vector3Data.fromJson(Map<String, dynamic>? json) => Vector3Data(
    x: (json?['x'] ?? 0).toDouble(),
    y: (json?['y'] ?? 0).toDouble(),
    z: (json?['z'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{'x': x, 'y': y, 'z': z};
}

class QuaternionData {
  const QuaternionData({this.x = 0, this.y = 0, this.z = 0, this.w = 1});
  final double x;
  final double y;
  final double z;
  final double w;

  factory QuaternionData.fromJson(Map<String, dynamic>? json) => QuaternionData(
    x: (json?['x'] ?? 0).toDouble(),
    y: (json?['y'] ?? 0).toDouble(),
    z: (json?['z'] ?? 0).toDouble(),
    w: (json?['w'] ?? 1).toDouble(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'x': x,
    'y': y,
    'z': z,
    'w': w,
  };
}

class ItemInteractionSlotDefinition {
  const ItemInteractionSlotDefinition({
    this.interactionType = 0,
    this.terminationAuthority = 0,
    this.localPosition = const Vector3Data(),
    this.localRotation = const QuaternionData(),
  });

  final int interactionType;
  final int terminationAuthority;
  final Vector3Data localPosition;
  final QuaternionData localRotation;

  factory ItemInteractionSlotDefinition.fromJson(Map<String, dynamic> json) {
    return ItemInteractionSlotDefinition(
      interactionType: (json['InteractionType'] ?? 0) as int,
      terminationAuthority: (json['TerminationAuthority'] ?? 0) as int,
      localPosition: Vector3Data.fromJson(
        json['LocalPosition'] as Map<String, dynamic>?,
      ),
      localRotation: QuaternionData.fromJson(
        json['LocalRotation'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'InteractionType': interactionType,
    'TerminationAuthority': terminationAuthority,
    'LocalPosition': localPosition.toJson(),
    'LocalRotation': localRotation.toJson(),
  };
}
