class ReserveSlotConfigModel {
  const ReserveSlotConfigModel({this.raw = const <String, dynamic>{}});
  final Map<String, dynamic> raw;

  factory ReserveSlotConfigModel.fromJson(Map<String, dynamic>? json) =>
      ReserveSlotConfigModel(
        raw: Map<String, dynamic>.from(json ?? const <String, dynamic>{}),
      );

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
