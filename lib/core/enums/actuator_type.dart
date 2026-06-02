enum ActuatorType {
  none(0),
  navigateToPosition(1),
  playAnimation(14),
  wait(30),
  eat(101),
  reserveSlot(102);

  const ActuatorType(this.value);
  final int value;
}
