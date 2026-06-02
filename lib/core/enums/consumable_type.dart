enum ConsumableType {
  none(0),
  bush(1),
  drink(2),
  medicine(4);

  const ConsumableType(this.value);
  final int value;
}
