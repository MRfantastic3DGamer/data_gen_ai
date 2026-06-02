class WorkTypeEntryModel {
  const WorkTypeEntryModel({this.id = 0, this.name = ''});

  final int id;
  final String name;

  factory WorkTypeEntryModel.fromJson(Map<String, dynamic> json) =>
      WorkTypeEntryModel(
        id: (json['Id'] ?? json['id'] ?? 0) as int,
        name: (json['Name'] ?? json['name'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'Id': id, 'Name': name};
}

class WorkTypesConfigModel {
  const WorkTypesConfigModel({this.types = const <WorkTypeEntryModel>[]});

  final List<WorkTypeEntryModel> types;

  factory WorkTypesConfigModel.fromJson(Map<String, dynamic> json) =>
      WorkTypesConfigModel(
        types: (json['types'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (dynamic e) => WorkTypeEntryModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'types': types.map((e) => e.toJson()).toList(),
  };

  WorkTypesConfigModel copyWith({List<WorkTypeEntryModel>? types}) {
    return WorkTypesConfigModel(types: types ?? this.types);
  }
}
