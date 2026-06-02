class ActionDataSOModel {
  const ActionDataSOModel({this.action = 0, this.variant = 0});

  final int action;
  final int variant;

  factory ActionDataSOModel.fromJson(Map<String, dynamic> json) =>
      ActionDataSOModel(
        action: (json['action'] ?? 0) as int,
        variant: (json['variant'] ?? 0) as int,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'action': action,
    'variant': variant,
  };
}
