enum BeliefCondition {
  greaterOrEqual(0),
  lessOrEqual(1),
  greaterThan(2),
  lessThan(3),
  equal(4),
  notEqual(5),
  inRange(6);

  const BeliefCondition(this.value);
  final int value;
}
