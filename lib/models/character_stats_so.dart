class CharacterStatsSOModel {
  const CharacterStatsSOModel({this.baseStats = const <String, dynamic>{}});

  final Map<String, dynamic> baseStats;

  factory CharacterStatsSOModel.fromJson(Map<String, dynamic> json) =>
      CharacterStatsSOModel(
        baseStats: Map<String, dynamic>.from(
          json['baseStats'] as Map? ?? <String, dynamic>{},
        ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'baseStats': baseStats};

  CharacterStatsSOModel copyWith({Map<String, dynamic>? baseStats}) {
    return CharacterStatsSOModel(baseStats: baseStats ?? this.baseStats);
  }
}
