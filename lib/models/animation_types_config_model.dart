class AnimationTypeEntryModel {
  const AnimationTypeEntryModel({this.id = 0, this.name = ''});

  final int id;
  final String name;

  factory AnimationTypeEntryModel.fromJson(Map<String, dynamic> json) {
    return AnimationTypeEntryModel(
      id: (json['Id'] ?? json['id'] ?? 0) as int,
      name: (json['Name'] ?? json['name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'Id': id, 'Name': name};
}

class AnimationTypesConfigModel {
  const AnimationTypesConfigModel({
    this.types = const <AnimationTypeEntryModel>[],
  });

  final List<AnimationTypeEntryModel> types;

  factory AnimationTypesConfigModel.fromJson(Map<String, dynamic> json) {
    return AnimationTypesConfigModel(
      types: (json['types'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (dynamic e) => AnimationTypeEntryModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'types': types.map((e) => e.toJson()).toList(),
  };

  String nameForId(int id) {
    if (id == 0) return '(None)';
    for (final t in types) {
      if (t.id == id) return t.name;
    }
    return 'Type_$id';
  }

  AnimationTypesConfigModel copyWith({List<AnimationTypeEntryModel>? types}) {
    return AnimationTypesConfigModel(types: types ?? this.types);
  }
}

/// Loaded animation types config with file metadata for saving.
class AnimationTypesConfigFile {
  const AnimationTypesConfigFile({
    required this.path,
    required this.displayName,
    required this.guid,
    required this.model,
    this.factionId,
  });

  final String path;
  final String displayName;
  final String guid;
  final AnimationTypesConfigModel model;
  final int? factionId;
}
