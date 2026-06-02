enum ActionType {
  none(0),
  moveTowards(1 << 0),
  lookTowards(1 << 1),
  moveAwayFrom(1 << 2),
  hideFrom(1 << 3),
  interact(1 << 4),
  attackMelee(1 << 10),
  attackRanged(1 << 11),
  pickup(1 << 14),
  quickly(1 << 20),
  forward(1 << 21),
  backword(1 << 22),
  lHanded(1 << 23),
  rHanded(1 << 24);

  const ActionType(this.value);
  final int value;
}
