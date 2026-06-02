enum UtilityAIQueryType {
  none(0),
  selfStats(1),
  inventory(2),
  equipment(3),
  sensedItem(4),
  sensedAgent(5),
  positioning(6),
  threatAdvertisement(7),
  myReservedSlot(8),
  combatStats(9);

  const UtilityAIQueryType(this.value);
  final int value;
}
