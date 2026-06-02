enum ItemCategory {
  consumable(1 << 0),
  weapon(1 << 1),
  shield(1 << 2);

  const ItemCategory(this.value);
  final int value;
}
