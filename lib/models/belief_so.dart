import 'package:data_gen_ai/models/unity_reference.dart';

class BeliefSOModel {
  const BeliefSOModel({
    this.queryViewAsset = const UnityReference(guid: '', fileId: 0),
    this.field = 0,
    this.condition = 0,
    this.isVectorValue = false,
    this.isRangeValue = false,
    this.intValue = 0,
    this.boolValue = false,
    this.floatValue = 0,
    this.vectorValue = const <String, dynamic>{'x': 0, 'y': 0, 'z': 0},
    this.rangeValue = const <String, dynamic>{'x': 0, 'y': 0},
    this.useHysteresis = false,
    this.hysteresisDelta = 0,
  });

  final UnityReference queryViewAsset;
  final int field;
  final int condition;
  final bool isVectorValue;
  final bool isRangeValue;
  final int intValue;
  final bool boolValue;
  final double floatValue;
  final Map<String, dynamic> vectorValue;
  final Map<String, dynamic> rangeValue;
  final bool useHysteresis;
  final double hysteresisDelta;

  factory BeliefSOModel.fromJson(Map<String, dynamic> json) => BeliefSOModel(
    queryViewAsset: UnityReference.fromJson(
      json['queryViewAsset'] as Map<String, dynamic>?,
    ),
    field: (json['field'] ?? 0) as int,
    condition: (json['condition'] ?? 0) as int,
    isVectorValue: (json['isVectorValue'] ?? false) as bool,
    isRangeValue: (json['isRangeValue'] ?? false) as bool,
    intValue: (json['intValue'] ?? 0) as int,
    boolValue: (json['boolValue'] ?? false) as bool,
    floatValue: (json['floatValue'] ?? 0).toDouble(),
    vectorValue: Map<String, dynamic>.from(
      json['vectorValue'] as Map? ?? <String, dynamic>{'x': 0, 'y': 0, 'z': 0},
    ),
    rangeValue: Map<String, dynamic>.from(
      json['rangeValue'] as Map? ?? <String, dynamic>{'x': 0, 'y': 0},
    ),
    useHysteresis: (json['useHysteresis'] ?? false) as bool,
    hysteresisDelta: (json['hysteresisDelta'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'queryViewAsset': queryViewAsset.toJson(),
    'field': field,
    'condition': condition,
    'isVectorValue': isVectorValue,
    'isRangeValue': isRangeValue,
    'intValue': intValue,
    'boolValue': boolValue,
    'floatValue': floatValue,
    'vectorValue': vectorValue,
    'rangeValue': rangeValue,
    'useHysteresis': useHysteresis,
    'hysteresisDelta': hysteresisDelta,
  };
}
