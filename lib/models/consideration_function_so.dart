class ConsiderationFunctionSOModel {
  const ConsiderationFunctionSOModel({this.config = const <String, dynamic>{}});

  final Map<String, dynamic> config;

  factory ConsiderationFunctionSOModel.fromJson(Map<String, dynamic> json) =>
      ConsiderationFunctionSOModel(
        config: Map<String, dynamic>.from(
          json['Config'] as Map? ?? <String, dynamic>{},
        ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'Config': config};
}
