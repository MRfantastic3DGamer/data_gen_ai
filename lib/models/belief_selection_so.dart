import 'package:data_gen_ai/models/unity_reference.dart';

class ConsiderationItemModel {
  const ConsiderationItemModel({
    this.considerableSource = 0,
    this.considerableAsset = const UnityReference(guid: '', fileId: 0),
    this.considerableInline = const <String, dynamic>{},
    this.functionSource = 0,
    this.functionAsset = const UnityReference(guid: '', fileId: 0),
    this.functionInline = const <String, dynamic>{},
  });

  final int considerableSource;
  final UnityReference considerableAsset;
  final Map<String, dynamic> considerableInline;
  final int functionSource;
  final UnityReference functionAsset;
  final Map<String, dynamic> functionInline;

  factory ConsiderationItemModel.fromJson(Map<String, dynamic> json) =>
      ConsiderationItemModel(
        considerableSource: (json['ConsiderableSource'] ?? 0) as int,
        considerableAsset: UnityReference.fromJson(
          json['ConsiderableAsset'] as Map<String, dynamic>?,
        ),
        considerableInline: Map<String, dynamic>.from(
          json['ConsiderableInline'] as Map? ?? <String, dynamic>{},
        ),
        functionSource: (json['FunctionSource'] ?? 0) as int,
        functionAsset: UnityReference.fromJson(
          json['FunctionAsset'] as Map<String, dynamic>?,
        ),
        functionInline: Map<String, dynamic>.from(
          json['FunctionInline'] as Map? ?? <String, dynamic>{},
        ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'ConsiderableSource': considerableSource,
    'ConsiderableAsset': considerableAsset.toJson(),
    'ConsiderableInline': considerableInline,
    'FunctionSource': functionSource,
    'FunctionAsset': functionAsset.toJson(),
    'FunctionInline': functionInline,
  };
}

class BeliefSelectionSOModel {
  const BeliefSelectionSOModel({
    this.belief = const UnityReference(guid: '', fileId: 0),
    this.considerables = const <ConsiderationItemModel>[],
  });

  final UnityReference belief;
  final List<ConsiderationItemModel> considerables;

  factory BeliefSelectionSOModel.fromJson(Map<String, dynamic> json) =>
      BeliefSelectionSOModel(
        belief: UnityReference.fromJson(
          json['belief'] as Map<String, dynamic>?,
        ),
        considerables:
            (json['considerables'] as List<dynamic>? ?? const <dynamic>[])
                .map(
                  (dynamic e) => ConsiderationItemModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'belief': belief.toJson(),
    'considerables': considerables.map((e) => e.toJson()).toList(),
  };
}
