enum InteractionType {
  none(0),
  eating(1),
  switchType(2),
  sleeping(3);

  const InteractionType(this.value);
  final int value;
}
