/// Metadata for Unity ScriptableObject types exported as JSON envelopes.
class SOTypeInfo {
  const SOTypeInfo({
    required this.key,
    required this.displayName,
    required this.classIdentifier,
    required this.subfolder,
    required this.category,
    this.iconName = 'description',
  });

  final String key;
  final String displayName;
  final String classIdentifier;
  final String subfolder;
  final String category;
  final String iconName;
}

class SOTypeRegistry {
  const SOTypeRegistry._();

  static const List<SOTypeInfo> all = <SOTypeInfo>[
    SOTypeInfo(
      key: 'ActionableSO',
      displayName: 'Actionable',
      classIdentifier: 'Assembly-CSharp::AI.DataModels.ActionableSO',
      subfolder: 'actionable',
      category: 'Actions',
      iconName: 'play_circle_outline',
    ),
    SOTypeInfo(
      key: 'BeliefSO',
      displayName: 'Belief',
      classIdentifier: 'Assembly-CSharp::AI.DataModels.BeliefSO',
      subfolder: 'beliefs',
      category: 'Actions',
      iconName: 'psychology_outlined',
    ),
    SOTypeInfo(
      key: 'BeliefSelectionSO',
      displayName: 'Belief Selection',
      classIdentifier: 'Assembly-CSharp::AI.Utility.BeliefSelectionSO',
      subfolder: 'belief selection',
      category: 'Actions',
      iconName: 'hub_outlined',
    ),
    SOTypeInfo(
      key: 'ConsiderableSO',
      displayName: 'Considerable',
      classIdentifier: 'Assembly-CSharp::AI.Utility.ConsiderableSO',
      subfolder: 'considerables',
      category: 'Utility AI',
      iconName: 'tune',
    ),
    SOTypeInfo(
      key: 'ConsiderationFunctionSO',
      displayName: 'Consideration Function',
      classIdentifier: 'Assembly-CSharp::AI.Utility.ConsiderationFunctionSO',
      subfolder: 'consideration functions',
      category: 'Utility AI',
      iconName: 'functions',
    ),
    SOTypeInfo(
      key: 'BaseQueryViewSO',
      displayName: 'Query View',
      classIdentifier: 'Assembly-CSharp::AI.DataModels.QueryViews',
      subfolder: 'queries',
      category: 'Queries',
      iconName: 'search',
    ),
    SOTypeInfo(
      key: 'CharacterData',
      displayName: 'Character',
      classIdentifier: 'Assembly-CSharp::Character.CharacterData',
      subfolder: 'Characters',
      category: 'Characters',
      iconName: 'person_outline',
    ),
    SOTypeInfo(
      key: 'ItemData',
      displayName: 'Item',
      classIdentifier: 'Assembly-CSharp::Item.ItemData',
      subfolder: 'Items',
      category: 'Items',
      iconName: 'inventory_2_outlined',
    ),
    SOTypeInfo(
      key: 'ActionCatalogEntrySO',
      displayName: 'Catalog Entry',
      classIdentifier: 'Assembly-CSharp::AI.DataModels.ActionCatalogEntrySO',
      subfolder: 'actionable',
      category: 'Catalog',
      iconName: 'list_alt',
    ),
    SOTypeInfo(
      key: 'FactionsConfig',
      displayName: 'Factions Config',
      classIdentifier: 'Assembly-CSharp::GameData.Characters.FactionsConfig',
      subfolder: 'Characters/Resources',
      category: 'Registries',
      iconName: 'groups',
    ),
    SOTypeInfo(
      key: 'AnimationTypesConfig',
      displayName: 'Animation Types',
      classIdentifier: 'Assembly-CSharp::GameData.Animation.AnimationTypesConfig',
      subfolder: 'Animations',
      category: 'Registries',
      iconName: 'animation',
    ),
    SOTypeInfo(
      key: 'ArmatureTypesConfig',
      displayName: 'Armature Types',
      classIdentifier: 'Assembly-CSharp::GameData.Animation.ArmatureTypesConfig',
      subfolder: 'Animations',
      category: 'Registries',
      iconName: 'accessibility_new',
    ),
    SOTypeInfo(
      key: 'CharacterAnimationDatabase',
      displayName: 'Animation Database',
      classIdentifier: 'Assembly-CSharp::CharacterAnimationDatabase',
      subfolder: 'Animations',
      category: 'Registries',
      iconName: 'video_library',
    ),
    SOTypeInfo(
      key: 'ActionCatalogRegistry',
      displayName: 'Catalog Registry',
      classIdentifier: 'Assembly-CSharp::AI.DataModels.ActionCatalogRegistry',
      subfolder: 'actionable',
      category: 'Catalog',
      iconName: 'storage',
    ),
    SOTypeInfo(
      key: 'CharacterStatsSO',
      displayName: 'Character Stats',
      classIdentifier: 'Assembly-CSharp::AI.DataModels.CharacterStatsSO',
      subfolder: 'Characters',
      category: 'Characters',
      iconName: 'monitor_heart',
    ),
    SOTypeInfo(
      key: 'ComboDataSO',
      displayName: 'Combo Data',
      classIdentifier: 'Assembly-CSharp::CommandSystem.ComboDataSO',
      subfolder: 'combos',
      category: 'Combat',
      iconName: 'sports_martial_arts',
    ),
    SOTypeInfo(
      key: 'MoveLibrarySO',
      displayName: 'Move Library',
      classIdentifier: 'Assembly-CSharp::Moves.Core.MoveLibrarySO',
      subfolder: 'Moves',
      category: 'Combat',
      iconName: 'sports_kabaddi',
    ),
    SOTypeInfo(
      key: 'AnimationRegistry',
      displayName: 'Animation Registry',
      classIdentifier: 'Assembly-CSharp::AnimationRegistry',
      subfolder: 'Animation',
      category: 'Registries',
      iconName: 'video_settings',
    ),
    SOTypeInfo(
      key: 'WorkTypesConfig',
      displayName: 'Work Types',
      classIdentifier: 'Assembly-CSharp::GameData.Workpost.WorkTypesConfig',
      subfolder: 'Workpost',
      category: 'Registries',
      iconName: 'work',
    ),
  ];

  static SOTypeInfo? fromClassIdentifier(String? identifier) {
    if (identifier == null || identifier.isEmpty) return null;
    for (final info in all) {
      if (identifier == info.classIdentifier) return info;
      if (identifier.contains(info.key)) return info;
    }
    if (identifier.contains('QueryViews.')) {
      return all.firstWhere((e) => e.key == 'BaseQueryViewSO');
    }
    return null;
  }

  static SOTypeInfo? fromPath(String path) {
    final lower = path.replaceAll('\\', '/').toLowerCase();
    final baseName = lower.split('/').last;
    if (baseName.contains('action_catalog_registry')) {
      return _byKey('ActionCatalogRegistry');
    }
    if (lower.contains('/actionable/') || lower.startsWith('actionable/')) {
      return _byKey('ActionCatalogEntrySO');
    }
    for (final info in all) {
      if (info.subfolder.isNotEmpty &&
          lower.contains('/${info.subfolder.toLowerCase()}/')) {
        return info;
      }
    }
    if (lower.contains('/characters/')) {
      return all.firstWhere((e) => e.key == 'CharacterData');
    }
    return null;
  }

  static List<String> get categories {
    return all.map((e) => e.category).toSet().toList()..sort();
  }

  static SOTypeInfo? _byKey(String key) {
    for (final info in all) {
      if (info.key == key) return info;
    }
    return null;
  }
}
