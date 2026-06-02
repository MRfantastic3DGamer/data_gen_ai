import 'package:data_gen_ai/models/unity_reference.dart';

class ConsiderableConfigModel {
  const ConsiderableConfigModel({
    this.defaultValue = 0,
    this.minValue = const <String, dynamic>{},
    this.maxValue = const <String, dynamic>{},
    this.queryInput = const UnityReference(guid: '', fileId: 0),
    this.field = 0,
  });

  final double defaultValue;
  final Map<String, dynamic> minValue;
  final Map<String, dynamic> maxValue;
  final UnityReference queryInput;
  final int field;

  factory ConsiderableConfigModel.fromJson(Map<String, dynamic> json) =>
      ConsiderableConfigModel(
        defaultValue: (json['defaultValue'] ?? 0).toDouble(),
        minValue: Map<String, dynamic>.from(
          json['minValue'] as Map? ?? <String, dynamic>{},
        ),
        maxValue: Map<String, dynamic>.from(
          json['maxValue'] as Map? ?? <String, dynamic>{},
        ),
        queryInput: UnityReference.fromJson(
          json['queryInput'] as Map<String, dynamic>?,
        ),
        field: (json['field'] ?? 0) as int,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'defaultValue': defaultValue,
    'minValue': minValue,
    'maxValue': maxValue,
    'queryInput': queryInput.toJson(),
    'field': field,
  };
}

class ConsiderableSOModel {
  const ConsiderableSOModel({this.config = const ConsiderableConfigModel()});

  final ConsiderableConfigModel config;

  factory ConsiderableSOModel.fromJson(Map<String, dynamic> json) =>
      ConsiderableSOModel(
        config: ConsiderableConfigModel.fromJson(
          Map<String, dynamic>.from(
            json['Config'] as Map? ?? <String, dynamic>{},
          ),
        ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'Config': config.toJson()};
}
