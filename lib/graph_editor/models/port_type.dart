/// Port types aligned with Unity Character Design Graph blackboard types.
enum PortType {
  graphQueryRef,
  belief,
  beliefSelection,
  actionable,
  graphActuatorRef,
  characterProfileGraphData,
  string,
  intType,
  floatType,
  boolType,
  utilityAIResultField,
  beliefCondition,
  utilityAIValue,
  considerable,
  considerationFunctionData,
  characterFactionTag,
  beastVariableStat,
  beastStatModifyMode,
  avatarMask,
  interactionType,
}

extension PortTypeX on PortType {
  String get label => switch (this) {
    PortType.graphQueryRef => 'GraphQueryRef',
    PortType.belief => 'Belief',
    PortType.beliefSelection => 'BeliefSelection',
    PortType.actionable => 'Actionable',
    PortType.graphActuatorRef => 'GraphActuatorRef',
    PortType.characterProfileGraphData => 'CharacterProfileGraphData',
    PortType.string => 'string',
    PortType.intType => 'int',
    PortType.floatType => 'float',
    PortType.boolType => 'bool',
    PortType.utilityAIResultField => 'UtilityAIResultField',
    PortType.beliefCondition => 'BeliefCondition',
    PortType.utilityAIValue => 'UtilityAIValue',
    PortType.considerable => 'Considerable',
    PortType.considerationFunctionData => 'ConsiderationFunctionData',
    PortType.characterFactionTag => 'CharacterFactionTag',
    PortType.beastVariableStat => 'BeastVariableStat',
    PortType.beastStatModifyMode => 'BeastStatModifyMode',
    PortType.avatarMask => 'AvatarMask',
    PortType.interactionType => 'InteractionType',
  };

  bool isCompatibleWith(PortType other) => this == other;
}
