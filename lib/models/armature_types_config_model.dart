import 'package:data_gen_ai/models/unity_envelope.dart';

class ArmatureTypeEntryModel {
  const ArmatureTypeEntryModel({this.id = 0, this.name = ''});

  final int id;
  final String name;

  factory ArmatureTypeEntryModel.fromJson(Map<String, dynamic> json) {
    return ArmatureTypeEntryModel(
      id: (json['Id'] ?? json['id'] ?? 0) as int,
      name: (json['Name'] ?? json['name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'Id': id, 'Name': name};
}

class ArmatureTypesConfigModel {
  const ArmatureTypesConfigModel({
    this.armatures = const <ArmatureTypeEntryModel>[],
  });

  final List<ArmatureTypeEntryModel> armatures;

  factory ArmatureTypesConfigModel.fromJson(Map<String, dynamic> json) {
    return ArmatureTypesConfigModel(
      armatures:
          (json['armatures'] as List<dynamic>? ?? const <dynamic>[])
              .map(
                (dynamic e) => ArmatureTypeEntryModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'armatures': armatures.map((e) => e.toJson()).toList(),
  };

  ArmatureTypesConfigModel copyWith({List<ArmatureTypeEntryModel>? armatures}) {
    return ArmatureTypesConfigModel(armatures: armatures ?? this.armatures);
  }
}

class ArmatureTypesConfigFile {
  const ArmatureTypesConfigFile({
    required this.path,
    required this.displayName,
    required this.envelope,
    required this.model,
  });

  final String path;
  final String displayName;
  final UnityEnvelope envelope;
  final ArmatureTypesConfigModel model;
}
