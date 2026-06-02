import 'package:data_gen_ai/models/query_view/base_query_view.dart';

class SensorItemQueryViewModel extends BaseQueryViewModel {
  const SensorItemQueryViewModel({
    this.itemTypeId = 0,
    this.inLineOfSight = false,
    this.averagesOfAll = false,
    this.queryInteractionSlot = false,
    this.interactionType = 0,
    this.interactionState = 0,
  }) : super(
         classIdentifier:
             'Assembly-CSharp::AI.DataModels.QueryViews.SensorItemQueryViewSO',
       );

  final int itemTypeId;
  final bool inLineOfSight;
  final bool averagesOfAll;
  final bool queryInteractionSlot;
  final int interactionType;
  final int interactionState;

  factory SensorItemQueryViewModel.fromJson(Map<String, dynamic> json) {
    return SensorItemQueryViewModel(
      itemTypeId: (json['itemTypeId'] ?? 0) as int,
      inLineOfSight: (json['inLineOfSight'] ?? false) as bool,
      averagesOfAll: (json['averagesOfAll'] ?? false) as bool,
      queryInteractionSlot: (json['queryInteractionSlot'] ?? false) as bool,
      interactionType: (json['interactionType'] ?? 0) as int,
      interactionState: (json['interactionState'] ?? 0) as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'itemTypeId': itemTypeId,
    'inLineOfSight': inLineOfSight,
    'averagesOfAll': averagesOfAll,
    'queryInteractionSlot': queryInteractionSlot,
    'interactionType': interactionType,
    'interactionState': interactionState,
  };
}
