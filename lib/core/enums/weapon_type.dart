enum WeaponType {
  none(0),
  melee(1),
  ranged(2),
  magic(4);

  const WeaponType(this.value);
  final int value;
}
