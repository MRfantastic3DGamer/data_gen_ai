import 'package:data_gen_ai/models/unity_reference.dart';

class MoveConfigModel {
  const MoveConfigModel({
    this.moveName = '',
    this.animation = 0,
    this.clip = const UnityReference(guid: '', fileId: 0),
    this.settings = const <String, dynamic>{},
  });

  final String moveName;
  final int animation;
  final UnityReference clip;
  final Map<String, dynamic> settings;

  factory MoveConfigModel.fromJson(Map<String, dynamic> json) =>
      MoveConfigModel(
        moveName: (json['MoveName'] ?? '') as String,
        animation: (json['Animation'] ?? 0) as int,
        clip: UnityReference.fromJson(json['Clip'] as Map<String, dynamic>?),
        settings: Map<String, dynamic>.from(
          json['Settings'] as Map? ?? <String, dynamic>{},
        ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'MoveName': moveName,
    'Animation': animation,
    'Clip': clip.toJson(),
    'Settings': settings,
  };

  MoveConfigModel copyWith({
    String? moveName,
    int? animation,
    UnityReference? clip,
    Map<String, dynamic>? settings,
  }) {
    return MoveConfigModel(
      moveName: moveName ?? this.moveName,
      animation: animation ?? this.animation,
      clip: clip ?? this.clip,
      settings: settings ?? this.settings,
    );
  }
}

class MoveLibrarySOModel {
  const MoveLibrarySOModel({
    this.moves = const <MoveConfigModel>[],
    this.defaultSettings = const <String, dynamic>{},
  });

  final List<MoveConfigModel> moves;
  final Map<String, dynamic> defaultSettings;

  factory MoveLibrarySOModel.fromJson(Map<String, dynamic> json) =>
      MoveLibrarySOModel(
        moves: (json['Moves'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (dynamic e) =>
                  MoveConfigModel.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList(),
        defaultSettings: Map<String, dynamic>.from(
          json['DefaultSettings'] as Map? ?? <String, dynamic>{},
        ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'Moves': moves.map((e) => e.toJson()).toList(),
    'DefaultSettings': defaultSettings,
  };

  MoveLibrarySOModel copyWith({
    List<MoveConfigModel>? moves,
    Map<String, dynamic>? defaultSettings,
  }) {
    return MoveLibrarySOModel(
      moves: moves ?? this.moves,
      defaultSettings: defaultSettings ?? this.defaultSettings,
    );
  }
}
