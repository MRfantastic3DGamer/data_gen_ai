import 'package:data_gen_ai/models/query_view/base_query_view.dart';

class NotificationQueryViewModel extends BaseQueryViewModel {
  const NotificationQueryViewModel({
    this.factionMask = 0,
    this.agentFaction = 0,
    this.inLineOfSight = false,
    this.notificationFilter = 0,
  }) : super(
         classIdentifier:
             'Assembly-CSharp::AI.DataModels.QueryViews.NotificationQueryViewSO',
       );

  final int factionMask;
  final int agentFaction;
  final bool inLineOfSight;
  final int notificationFilter;

  factory NotificationQueryViewModel.fromJson(Map<String, dynamic> json) =>
      NotificationQueryViewModel(
        factionMask: (json['factionMask'] ?? 0) as int,
        agentFaction: (json['agentFaction'] ?? json['agentType'] ?? 0) as int,
        inLineOfSight: json['inLineOfSight'] == true,
        notificationFilter: (json['notificationFilter'] ?? 0) as int,
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'factionMask': factionMask,
    'agentFaction': agentFaction,
    'inLineOfSight': inLineOfSight,
    'notificationFilter': notificationFilter,
  };

  NotificationQueryViewModel copyWith({
    int? factionMask,
    int? agentFaction,
    bool? inLineOfSight,
    int? notificationFilter,
  }) {
    return NotificationQueryViewModel(
      factionMask: factionMask ?? this.factionMask,
      agentFaction: agentFaction ?? this.agentFaction,
      inLineOfSight: inLineOfSight ?? this.inLineOfSight,
      notificationFilter: notificationFilter ?? this.notificationFilter,
    );
  }
}
