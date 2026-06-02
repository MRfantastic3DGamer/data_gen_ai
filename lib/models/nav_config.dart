class NavigateConfigModel {
  const NavigateConfigModel({this.raw = const <String, dynamic>{}});
  final Map<String, dynamic> raw;

  factory NavigateConfigModel.fromJson(Map<String, dynamic>? json) =>
      NavigateConfigModel(
        raw: Map<String, dynamic>.from(json ?? const <String, dynamic>{}),
      );

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
