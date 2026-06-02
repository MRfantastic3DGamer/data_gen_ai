import 'package:data_gen_ai/models/actuator_mapping.dart';
import 'package:data_gen_ai/models/character_state_design.dart';
import 'package:data_gen_ai/models/character_stats.dart';
import 'package:data_gen_ai/models/eat_config.dart';
import 'package:data_gen_ai/models/interaction_slot.dart';
import 'package:data_gen_ai/models/nav_config.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/models/wait_config.dart';

class CharacterDataModel {
  const CharacterDataModel({
    this.description = '',
    this.initialStats = const CharacterStatsModel(),
    this.faction = 0,
    this.characterType = 0,
    this.bakeModularStates = true,
    this.stateDesign = const CharacterStateDesignModel(),
    this.beliefsObjects = const <UnityReference>[],
    this.actionables = const <UnityReference>[],
    this.defaultAction = -1,
    this.defaultNavigateConfig = const NavigateConfigModel(),
    this.defaultWaitConfig = const WaitConfigModel(),
    this.defaultEatConfig = const EatConfigModel(),
    this.actuatorMappings = const <ActuatorMappingModel>[],
    this.interactionSlots = const <ItemInteractionSlotDefinition>[],
  });

  final String description;
  final CharacterStatsModel initialStats;
  final int faction;
  final int characterType;
  final bool bakeModularStates;
  final CharacterStateDesignModel stateDesign;
  final List<UnityReference> beliefsObjects;
  final List<UnityReference> actionables;
  final int defaultAction;
  final NavigateConfigModel defaultNavigateConfig;
  final WaitConfigModel defaultWaitConfig;
  final EatConfigModel defaultEatConfig;
  final List<ActuatorMappingModel> actuatorMappings;
  final List<ItemInteractionSlotDefinition> interactionSlots;

  factory CharacterDataModel.fromJson(Map<String, dynamic> json) {
    return CharacterDataModel(
      description: (json['description'] ?? '') as String,
      initialStats: CharacterStatsModel.fromJson(
        json['InitialStats'] as Map<String, dynamic>?,
      ),
      faction: (json['Faction'] ?? 0) as int,
      characterType: (json['CharacterType'] ?? 0) as int,
      bakeModularStates: (json['BakeModularStates'] ?? true) as bool,
      stateDesign: CharacterStateDesignModel.fromJson(
        json['StateDesign'] as Map<String, dynamic>?,
      ),
      beliefsObjects:
          (json['beliefsObjects'] as List<dynamic>? ?? const <dynamic>[])
              .map(
                (dynamic e) =>
                    UnityReference.fromJson(e as Map<String, dynamic>?),
              )
              .toList(),
      actionables: (json['actionables'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (dynamic e) => UnityReference.fromJson(e as Map<String, dynamic>?),
          )
          .toList(),
      defaultAction: (json['defaultAction'] ?? -1) as int,
      defaultNavigateConfig: NavigateConfigModel.fromJson(
        json['DefaultNavigateConfig'] as Map<String, dynamic>?,
      ),
      defaultWaitConfig: WaitConfigModel.fromJson(
        json['DefaultWaitConfig'] as Map<String, dynamic>?,
      ),
      defaultEatConfig: EatConfigModel.fromJson(
        json['DefaultEatConfig'] as Map<String, dynamic>?,
      ),
      actuatorMappings:
          (json['actuatorMappings'] as List<dynamic>? ?? const <dynamic>[])
              .map(
                (dynamic e) => ActuatorMappingModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
      interactionSlots:
          (json['InteractionSlots'] as List<dynamic>? ?? const <dynamic>[])
              .map(
                (dynamic e) => ItemInteractionSlotDefinition.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'description': description,
    'InitialStats': initialStats.toJson(),
    'Faction': faction,
    'CharacterType': characterType,
    'BakeModularStates': bakeModularStates,
    'StateDesign': stateDesign.toJson(),
    'beliefsObjects': beliefsObjects.map((e) => e.toJson()).toList(),
    'actionables': actionables.map((e) => e.toJson()).toList(),
    'defaultAction': defaultAction,
    'DefaultNavigateConfig': defaultNavigateConfig.toJson(),
    'DefaultWaitConfig': defaultWaitConfig.toJson(),
    'DefaultEatConfig': defaultEatConfig.toJson(),
    'actuatorMappings': actuatorMappings.map((e) => e.toJson()).toList(),
    'InteractionSlots': interactionSlots.map((e) => e.toJson()).toList(),
  };

  CharacterDataModel copyWith({
    String? description,
    CharacterStatsModel? initialStats,
    int? faction,
    int? characterType,
    bool? bakeModularStates,
    CharacterStateDesignModel? stateDesign,
    List<UnityReference>? beliefsObjects,
    List<UnityReference>? actionables,
    int? defaultAction,
    NavigateConfigModel? defaultNavigateConfig,
    WaitConfigModel? defaultWaitConfig,
    EatConfigModel? defaultEatConfig,
    List<ActuatorMappingModel>? actuatorMappings,
    List<ItemInteractionSlotDefinition>? interactionSlots,
  }) {
    return CharacterDataModel(
      description: description ?? this.description,
      initialStats: initialStats ?? this.initialStats,
      faction: faction ?? this.faction,
      characterType: characterType ?? this.characterType,
      bakeModularStates: bakeModularStates ?? this.bakeModularStates,
      stateDesign: stateDesign ?? this.stateDesign,
      beliefsObjects: beliefsObjects ?? this.beliefsObjects,
      actionables: actionables ?? this.actionables,
      defaultAction: defaultAction ?? this.defaultAction,
      defaultNavigateConfig:
          defaultNavigateConfig ?? this.defaultNavigateConfig,
      defaultWaitConfig: defaultWaitConfig ?? this.defaultWaitConfig,
      defaultEatConfig: defaultEatConfig ?? this.defaultEatConfig,
      actuatorMappings: actuatorMappings ?? this.actuatorMappings,
      interactionSlots: interactionSlots ?? this.interactionSlots,
    );
  }
}
