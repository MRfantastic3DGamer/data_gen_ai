class EatConfigModel {
  const EatConfigModel({this.raw = const <String, dynamic>{}});
  final Map<String, dynamic> raw;

  factory EatConfigModel.fromJson(Map<String, dynamic>? json) => EatConfigModel(
    raw: Map<String, dynamic>.from(json ?? const <String, dynamic>{}),
  );

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
