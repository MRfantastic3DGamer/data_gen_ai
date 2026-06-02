enum ConsiderationMode {
  scalar(0),
  vectorMagnitude(1),
  boolean(2),
  vectorDistance(3);

  const ConsiderationMode(this.value);
  final int value;
}
