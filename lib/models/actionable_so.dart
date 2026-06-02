import 'package:data_gen_ai/models/unity_reference.dart';

class ActionableSOModel {
  const ActionableSOModel({
    this.providedBeliefAssets = const <UnityReference>[],
    this.actionDataAsset = const UnityReference(guid: '', fileId: 0),
    this.requiredBeliefAssets = const <UnityReference>[],
    this.constCost = 0,
    this.costQuery = const UnityReference(guid: '', fileId: 0),
    this.costField = 0,
    this.costFieldMultiplier = 0,
    this.constTime = 0,
    this.timeQuery = const UnityReference(guid: '', fileId: 0),
    this.timeField = 0,
    this.timeFieldMultiplier = 0,
  });

  final List<UnityReference> providedBeliefAssets;
  final UnityReference actionDataAsset;
  final List<UnityReference> requiredBeliefAssets;
  final double constCost;
  final UnityReference costQuery;
  final int costField;
  final double costFieldMultiplier;
  final double constTime;
  final UnityReference timeQuery;
  final int timeField;
  final double timeFieldMultiplier;

  factory ActionableSOModel.fromJson(
    Map<String, dynamic> json,
  ) => ActionableSOModel(
    providedBeliefAssets:
        (json['providedBeliefAssets'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (dynamic e) =>
                  UnityReference.fromJson(e as Map<String, dynamic>?),
            )
            .toList(),
    actionDataAsset: UnityReference.fromJson(
      json['actionDataAsset'] as Map<String, dynamic>?,
    ),
    requiredBeliefAssets:
        (json['requiredBeliefAssets'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (dynamic e) =>
                  UnityReference.fromJson(e as Map<String, dynamic>?),
            )
            .toList(),
    constCost: (json['ConstCost'] ?? 0).toDouble(),
    costQuery: UnityReference.fromJson(
      json['CostQuery'] as Map<String, dynamic>?,
    ),
    costField: (json['CostField'] ?? 0) as int,
    costFieldMultiplier: (json['CostFieldMultiplier'] ?? 0).toDouble(),
    constTime: (json['ConstTime'] ?? 0).toDouble(),
    timeQuery: UnityReference.fromJson(
      json['TimeQuery'] as Map<String, dynamic>?,
    ),
    timeField: (json['TimeField'] ?? 0) as int,
    timeFieldMultiplier: (json['TimeFieldMultiplier'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'providedBeliefAssets': providedBeliefAssets
        .map((e) => e.toJson())
        .toList(),
    'actionDataAsset': actionDataAsset.toJson(),
    'requiredBeliefAssets': requiredBeliefAssets
        .map((e) => e.toJson())
        .toList(),
    'ConstCost': constCost,
    'CostQuery': costQuery.toJson(),
    'CostField': costField,
    'CostFieldMultiplier': costFieldMultiplier,
    'ConstTime': constTime,
    'TimeQuery': timeQuery.toJson(),
    'TimeField': timeField,
    'TimeFieldMultiplier': timeFieldMultiplier,
  };
}
