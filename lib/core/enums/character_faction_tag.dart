enum CharacterFactionTag {
  none(0),
  herbivore(1 << 62),
  carnivore(1 << 63),
  omnivore((1 << 62) | (1 << 63));

  const CharacterFactionTag(this.value);
  final int value;
}
