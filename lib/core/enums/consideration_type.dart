enum ConsiderationType {
  linear(0),
  square(1),
  inverse(2),
  step(3),
  sigmoid(4),
  logit(5),
  exponential(6),
  normal(7),
  sine(8),
  bounce(9);

  const ConsiderationType(this.value);
  final int value;
}
