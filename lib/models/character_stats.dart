class CharacterStatsModel {
  const CharacterStatsModel({
    this.satiety = 1,
    this.hydration = 1,
    this.energy = 1,
    this.vitality = 100,
    this.wasts = 1,
    this.maxSatiety = 100,
  });

  final double satiety;
  final double hydration;
  final double energy;
  final double vitality;
  final double wasts;
  final double maxSatiety;

  factory CharacterStatsModel.fromJson(Map<String, dynamic>? json) {
    return CharacterStatsModel(
      satiety: (json?['Satiety'] ?? 1).toDouble(),
      hydration: (json?['Hydration'] ?? 1).toDouble(),
      energy: (json?['Energy'] ?? 1).toDouble(),
      vitality: (json?['Vitality'] ?? 100).toDouble(),
      wasts: (json?['Wasts'] ?? 1).toDouble(),
      maxSatiety: (json?['MaxSatiety'] ?? 100).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'Satiety': satiety,
    'Hydration': hydration,
    'Energy': energy,
    'Vitality': vitality,
    'Wasts': wasts,
    'MaxSatiety': maxSatiety,
  };
}
