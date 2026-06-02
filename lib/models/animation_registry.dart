import 'package:data_gen_ai/models/unity_reference.dart';

class AnimationRegistryModel {
  const AnimationRegistryModel({
    this.characterDatabases = const <UnityReference>[],
  });

  final List<UnityReference> characterDatabases;

  factory AnimationRegistryModel.fromJson(Map<String, dynamic> json) =>
      AnimationRegistryModel(
        characterDatabases:
            (json['characterDatabases'] as List<dynamic>? ?? const <dynamic>[])
                .map(
                  (dynamic e) =>
                      UnityReference.fromJson(e as Map<String, dynamic>?),
                )
                .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'characterDatabases': characterDatabases.map((e) => e.toJson()).toList(),
  };

  AnimationRegistryModel copyWith({List<UnityReference>? characterDatabases}) {
    return AnimationRegistryModel(
      characterDatabases: characterDatabases ?? this.characterDatabases,
    );
  }
}
