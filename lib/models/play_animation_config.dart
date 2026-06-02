class PlayAnimationConfigModel {
  const PlayAnimationConfigModel({this.raw = const <String, dynamic>{}});
  final Map<String, dynamic> raw;

  factory PlayAnimationConfigModel.fromJson(Map<String, dynamic>? json) =>
      PlayAnimationConfigModel(
        raw: Map<String, dynamic>.from(json ?? const <String, dynamic>{}),
      );

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
