class WaitConfigModel {
  const WaitConfigModel({this.raw = const <String, dynamic>{}});
  final Map<String, dynamic> raw;

  factory WaitConfigModel.fromJson(Map<String, dynamic>? json) =>
      WaitConfigModel(
        raw: Map<String, dynamic>.from(json ?? const <String, dynamic>{}),
      );

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
