enum UtilityAIResultField {
  none(0),
  survivalSatiety(1),
  survivalHydration(2),
  survivalEnergy(3),
  survivalVitality(4),
  inventoryCount(16),
  closestItemDistance(20),
  closestItemPosition(22),
  interactionSlotDistance(29),
  interactionSlotPosition(30),
  interactionState(34),
  hidingPosition(35);

  const UtilityAIResultField(this.value);
  final int value;
}
