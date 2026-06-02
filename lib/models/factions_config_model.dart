class FactionDefinitionModel {
  const FactionDefinitionModel({
    this.id = 0,
    this.name = 'Faction',
    this.editorColor = const <String, dynamic>{
      'r': 0.5,
      'g': 0.5,
      'b': 0.5,
      'a': 1,
    },
  });

  final int id;
  final String name;
  final Map<String, dynamic> editorColor;

  factory FactionDefinitionModel.fromJson(Map<String, dynamic> json) {
    return FactionDefinitionModel(
      id: (json['Id'] ?? json['id'] ?? 0) as int,
      name: (json['Name'] ?? json['name'] ?? '') as String,
      editorColor: Map<String, dynamic>.from(
        json['EditorColor'] as Map? ?? json['editorColor'] as Map? ?? <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'Id': id,
    'Name': name,
    'EditorColor': editorColor,
  };
}

class FactionRelationshipModel {
  const FactionRelationshipModel({this.a = 0, this.b = 0, this.type = 1});

  final int a;
  final int b;
  final int type;

  factory FactionRelationshipModel.fromJson(Map<String, dynamic> json) =>
      FactionRelationshipModel(
        a: (json['A'] ?? 0) as int,
        b: (json['B'] ?? 0) as int,
        type: (json['Type'] ?? 1) as int,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'A': a, 'B': b, 'Type': type};
}

class FactionsConfigModel {
  const FactionsConfigModel({
    this.factions = const <FactionDefinitionModel>[],
    this.relationships = const <FactionRelationshipModel>[],
    this.bakeVersion = 0,
  });

  final List<FactionDefinitionModel> factions;
  final List<FactionRelationshipModel> relationships;
  final int bakeVersion;

  factory FactionsConfigModel.fromJson(Map<String, dynamic> json) {
    return FactionsConfigModel(
      factions:
          (json['factions'] as List<dynamic>? ?? const <dynamic>[])
              .map(
                (dynamic e) => FactionDefinitionModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
      relationships:
          (json['relationships'] as List<dynamic>? ?? const <dynamic>[])
              .map(
                (dynamic e) => FactionRelationshipModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
      bakeVersion: (json['bakeVersion'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'factions': factions.map((e) => e.toJson()).toList(),
    'relationships': relationships.map((e) => e.toJson()).toList(),
    'bakeVersion': bakeVersion,
  };

  String nameForId(int id) {
    for (final f in factions) {
      if (f.id == id) return f.name;
    }
    return id == 0 ? 'NONE' : 'Faction_$id';
  }

  FactionsConfigModel copyWith({
    List<FactionDefinitionModel>? factions,
    List<FactionRelationshipModel>? relationships,
    int? bakeVersion,
  }) {
    return FactionsConfigModel(
      factions: factions ?? this.factions,
      relationships: relationships ?? this.relationships,
      bakeVersion: bakeVersion ?? this.bakeVersion,
    );
  }
}
