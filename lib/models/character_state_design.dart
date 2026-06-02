class CharacterStateDesignModel {
  const CharacterStateDesignModel({this.raw = const <String, dynamic>{}});

  final Map<String, dynamic> raw;

  factory CharacterStateDesignModel.fromJson(Map<String, dynamic>? json) {
    return CharacterStateDesignModel(
      raw: Map<String, dynamic>.from(json ?? <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
