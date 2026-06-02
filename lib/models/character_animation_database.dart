import 'package:data_gen_ai/models/unity_reference.dart';

class AnimationEntryModel {
  const AnimationEntryModel({
    this.animationTypeId = 0,
    this.clip = const UnityReference(guid: '', fileId: 0),
  });

  final int animationTypeId;
  final UnityReference clip;

  factory AnimationEntryModel.fromJson(Map<String, dynamic> json) =>
      AnimationEntryModel(
        animationTypeId: (json['animationTypeId'] ?? 0) as int,
        clip: UnityReference.fromJson(json['clip'] as Map<String, dynamic>?),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'animationTypeId': animationTypeId,
    'clip': clip.toJson(),
  };

  AnimationEntryModel copyWith({int? animationTypeId, UnityReference? clip}) {
    return AnimationEntryModel(
      animationTypeId: animationTypeId ?? this.animationTypeId,
      clip: clip ?? this.clip,
    );
  }
}

class CharacterAnimationDatabaseModel {
  const CharacterAnimationDatabaseModel({
    this.characterFaction = 0,
    this.animationTypes = const UnityReference(guid: '', fileId: 0),
    this.animations = const <AnimationEntryModel>[],
    this.animationDataJson = const UnityReference(guid: '', fileId: 0),
  });

  final int characterFaction;
  final UnityReference animationTypes;
  final List<AnimationEntryModel> animations;
  final UnityReference animationDataJson;

  factory CharacterAnimationDatabaseModel.fromJson(
    Map<String, dynamic> json,
  ) => CharacterAnimationDatabaseModel(
    characterFaction: (json['characterFaction'] ?? 0) as int,
    animationTypes: UnityReference.fromJson(
      json['animationTypes'] as Map<String, dynamic>?,
    ),
    animations:
        (json['animations'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (dynamic e) => AnimationEntryModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
    animationDataJson: UnityReference.fromJson(
      json['animationDataJson'] as Map<String, dynamic>?,
    ),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'characterFaction': characterFaction,
    'animationTypes': animationTypes.toJson(),
    'animations': animations.map((e) => e.toJson()).toList(),
    'animationDataJson': animationDataJson.toJson(),
  };

  CharacterAnimationDatabaseModel copyWith({
    int? characterFaction,
    UnityReference? animationTypes,
    List<AnimationEntryModel>? animations,
    UnityReference? animationDataJson,
  }) {
    return CharacterAnimationDatabaseModel(
      characterFaction: characterFaction ?? this.characterFaction,
      animationTypes: animationTypes ?? this.animationTypes,
      animations: animations ?? this.animations,
      animationDataJson: animationDataJson ?? this.animationDataJson,
    );
  }
}
