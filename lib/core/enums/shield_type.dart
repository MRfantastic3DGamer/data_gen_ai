enum ShieldType {
  none(0),
  light(1),
  medium(2),
  heavy(4);

  const ShieldType(this.value);
  final int value;
}
