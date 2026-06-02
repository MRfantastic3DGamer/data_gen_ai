enum SensorQueryMode {
  closest(0),
  average(1),
  interactionSlot(2),
  notification(3);

  const SensorQueryMode(this.value);
  final int value;
}

enum FactionRelationshipType {
  friend(0),
  neutral(1),
  enemy(2);

  const FactionRelationshipType(this.value);
  final int value;
}

enum NotificationType {
  none(0),
  threat(1),
  social(2);

  const NotificationType(this.value);
  final int value;
}
