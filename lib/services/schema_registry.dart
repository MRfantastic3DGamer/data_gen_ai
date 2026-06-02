class SchemaRegistry {
  const SchemaRegistry._();

  static final Map<String, String> _schemas = <String, String>{
    'CharacterData': '''
{
  "description": "string",
  "InitialStats": {
    "Satiety": "number",
    "Hydration": "number",
    "Energy": "number",
    "Vitality": "number",
    "Wasts": "number",
    "MaxSatiety": "number"
  },
  "Faction": "int(CharacterFactionTag)",
  "CharacterType": "int(CharacterTypes)",
  "BakeModularStates": "bool",
  "StateDesign": "object",
  "beliefsObjects": [{"guid": "string", "fileID": "int", "type": 2}],
  "actionables": [{"guid": "string", "fileID": "int", "type": 2}],
  "defaultActionSo": {"guid": "string", "fileID": "int", "type": 2},
  "DefaultNavigateConfig": "object",
  "DefaultWaitConfig": "object",
  "DefaultEatConfig": "object",
  "actuatorMappings": [{
    "actionData": {"guid": "string", "fileID": "int", "type": 2},
    "actuatorType": "int(ActuatorType)",
    "navigateConfig": "object",
    "waitConfig": "object",
    "eatingInteractionConfig": "object",
    "reserveSlotConfig": "object",
    "playAnimationConfig": "object",
    "avatarMask": {"guid": "string", "fileID": "int", "type": 2},
    "navigateQueryView": {"guid": "string", "fileID": "int", "type": 2},
    "navigateResultField": "int(UtilityAIResultField)",
    "reserveSlotQueryView": {"guid": "string", "fileID": "int", "type": 2},
    "reserveSlotResultField": "int(UtilityAIResultField)",
    "eatPrimaryQueryView": {"guid": "string", "fileID": "int", "type": 2},
    "eatPrimaryResultField": "int(UtilityAIResultField)"
  }],
  "InteractionSlots": [{
    "InteractionType": "int",
    "TerminationAuthority": "int",
    "LocalPosition": {"x": "number", "y": "number", "z": "number"},
    "LocalRotation": {"x": "number", "y": "number", "z": "number", "w": "number"}
  }]
}
''',
    'ItemData': '''
{
  "ItemId": "string",
  "Description": "string",
  "Category": "int(ItemCategory)",
  "ConsumableTypeValue": "int(ConsumableType)",
  "WeaponTypeValue": "int(WeaponType)",
  "ShieldTypeValue": "int(ShieldType)",
  "InteractionSlots": [{
    "InteractionType": "int(InteractionType)",
    "TerminationAuthority": "int(TerminationAuthority)",
    "LocalPosition": {"x": "number", "y": "number", "z": "number"},
    "LocalRotation": {"x": "number", "y": "number", "z": "number", "w": "number"}
  }]
}
''',
    'BeliefSO': '''
{
  "queryViewAsset": {"guid": "string", "fileID": "int", "type": 2},
  "field": "int(UtilityAIResultField)",
  "condition": "int(BeliefCondition)",
  "isVectorValue": "bool",
  "isRangeValue": "bool",
  "intValue": "int",
  "boolValue": "bool",
  "floatValue": "number",
  "vectorValue": {"x": "number", "y": "number", "z": "number"},
  "rangeValue": {"x": "number", "y": "number"},
  "useHysteresis": "bool",
  "hysteresisDelta": "number"
}
''',
    'ActionableSO': '''
{
  "providedBeliefAssets": [{"guid": "string", "fileID": "int", "type": 2}],
  "actionDataAsset": {"guid": "string", "fileID": "int", "type": 2},
  "requiredBeliefAssets": [{"guid": "string", "fileID": "int", "type": 2}],
  "ConstCost": "number",
  "CostQuery": {"guid": "string", "fileID": "int", "type": 2},
  "CostField": "int(UtilityAIResultField)",
  "CostFieldMultiplier": "number",
  "ConstTime": "number",
  "TimeQuery": {"guid": "string", "fileID": "int", "type": 2},
  "TimeField": "int(UtilityAIResultField)",
  "TimeFieldMultiplier": "number"
}
''',
  };

  static String schemaFor(String typeName) {
    final schema = _schemas[typeName];
    if (schema == null) {
      return '''
{
  "type": "$typeName",
  "payload": "Generate a valid Unity payload object for this ScriptableObject type."
}
''';
    }
    return schema.trim();
  }

  static String modelContextFor(String typeName) {
    switch (typeName) {
      case 'ItemData':
        return '''
Related models and enums:
- ItemCategory: Consumable=1, Weapon=2, Shield=4
- ConsumableType: None=0, Bush=1, Drink=2, Medicine=4
- WeaponType: None=0, Melee=1, Ranged=2, Magic=4
- ShieldType: None=0, Light=1, Medium=2, Heavy=4
- InteractionType: None=0, Eating=1, Switch=2, Sleeping=3
- TerminationAuthority: Interactor=0, Interactable=1
- ItemInteractionSlotDefinition contains LocalPosition{x,y,z} and LocalRotation{x,y,z,w}
''';
      case 'CharacterData':
        return '''
Related models and enums:
- CharacterFactionTag: None=0, Herbivore=1<<62, Carnivore=1<<63
- CharacterTypes: NONE=0, BASE_ANIMATIONS=1, BASE_ANIMATIONS_2=2, MAMET=3, MULET=4, ROOT_MOTION_CHARACTER=5, WORRIOR=6
- ActuatorType: NavigateToPosition=1, PlayAnimation=14, Wait=30, Eat=101, ReserveSlot=102
- UtilityAIResultField and BaseQueryView references must use int enum values + GUID refs
- Interaction slots use ItemInteractionSlotDefinition shape
''';
      default:
        return '''
Follow Unity-style payload conventions:
- Use numeric enum values
- Keep references as {"guid":"...","fileID":123,"type":2}
- Return only payload fields, not MonoBehaviour wrapper
''';
    }
  }
}
