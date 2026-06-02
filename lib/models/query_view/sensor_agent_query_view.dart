import 'package:data_gen_ai/models/query_view/base_query_view.dart';

class SensorAgentQueryViewModel extends BaseQueryViewModel {
  const SensorAgentQueryViewModel({
    this.factionMask = 0,
    this.agentFaction = 0,
    this.includeFriends = true,
    this.includeNeutrals = true,
    this.includeEnemies = true,
    this.inLineOfSight = false,
    this.mode = 0,
    this.perceivedPowerAggregation = 0,
    this.interactionType = 0,
    this.notificationFilter = 0,
  }) : super(
         classIdentifier:
             'Assembly-CSharp::AI.DataModels.QueryViews.SensorAgentQueryViewSO',
       );

  final int factionMask;
  final int agentFaction;
  final bool includeFriends;
  final bool includeNeutrals;
  final bool includeEnemies;
  final bool inLineOfSight;
  final int mode;
  final int perceivedPowerAggregation;
  final int interactionType;
  final int notificationFilter;

  factory SensorAgentQueryViewModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('agentFaction') ||
        json.containsKey('includeFriends')) {
      return SensorAgentQueryViewModel(
        factionMask: (json['factionMask'] ?? 0) as int,
        agentFaction: (json['agentFaction'] ?? 0) as int,
        includeFriends: json['includeFriends'] != false,
        includeNeutrals: json['includeNeutrals'] != false,
        includeEnemies: json['includeEnemies'] != false,
        inLineOfSight: json['inLineOfSight'] == true,
        mode: (json['mode'] ?? 0) as int,
        perceivedPowerAggregation:
            (json['perceivedPowerAggregation'] ?? 0) as int,
        interactionType: (json['interactionType'] ?? 0) as int,
        notificationFilter: (json['notificationFilter'] ?? 0) as int,
      );
    }
    var mode = 0;
    if (json['averagesOfAll'] == true) mode = 1;
    if (json['queryInteractionSlot'] == true) mode = 2;
    return SensorAgentQueryViewModel(
      factionMask: (json['factionMask'] ?? 0) as int,
      agentFaction: (json['agentType'] ?? 0) as int,
      inLineOfSight: json['inLineOfSight'] == true,
      mode: mode,
      interactionType: (json['interactionType'] ?? 0) as int,
      notificationFilter: (json['interactionState'] ?? 0) as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'factionMask': factionMask,
    'agentFaction': agentFaction,
    'includeFriends': includeFriends,
    'includeNeutrals': includeNeutrals,
    'includeEnemies': includeEnemies,
    'inLineOfSight': inLineOfSight,
    'mode': mode,
    'perceivedPowerAggregation': perceivedPowerAggregation,
    'interactionType': interactionType,
    'notificationFilter': notificationFilter,
  };

  SensorAgentQueryViewModel copyWith({
    int? factionMask,
    int? agentFaction,
    bool? includeFriends,
    bool? includeNeutrals,
    bool? includeEnemies,
    bool? inLineOfSight,
    int? mode,
    int? perceivedPowerAggregation,
    int? interactionType,
    int? notificationFilter,
  }) {
    return SensorAgentQueryViewModel(
      factionMask: factionMask ?? this.factionMask,
      agentFaction: agentFaction ?? this.agentFaction,
      includeFriends: includeFriends ?? this.includeFriends,
      includeNeutrals: includeNeutrals ?? this.includeNeutrals,
      includeEnemies: includeEnemies ?? this.includeEnemies,
      inLineOfSight: inLineOfSight ?? this.inLineOfSight,
      mode: mode ?? this.mode,
      perceivedPowerAggregation:
          perceivedPowerAggregation ?? this.perceivedPowerAggregation,
      interactionType: interactionType ?? this.interactionType,
      notificationFilter: notificationFilter ?? this.notificationFilter,
    );
  }
}
