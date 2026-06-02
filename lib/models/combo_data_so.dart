import 'package:data_gen_ai/models/unity_reference.dart';

class ComboStateModel {
  const ComboStateModel({this.slots = const <int>[]});

  final List<int> slots;

  factory ComboStateModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ComboStateModel();
    final slots = <int>[];
    for (var i = 0; i < 12; i++) {
      slots.add((json['int$i'] ?? 0) as int);
    }
    return ComboStateModel(slots: slots);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    for (var i = 0; i < slots.length && i < 12; i++) {
      map['int$i'] = slots[i];
    }
    for (var i = slots.length; i < 12; i++) {
      map['int$i'] = 0;
    }
    return map;
  }

  ComboStateModel copyWith({List<int>? slots}) {
    return ComboStateModel(slots: slots ?? this.slots);
  }
}

class ComboDataSOModel {
  const ComboDataSOModel({
    this.comboState = const ComboStateModel(),
    this.animationClip = const UnityReference(guid: '', fileId: 0),
    this.comboDescription = '',
    this.priority = 0,
    this.referencedCombo = const UnityReference(guid: '', fileId: 0),
  });

  final ComboStateModel comboState;
  final UnityReference animationClip;
  final String comboDescription;
  final int priority;
  final UnityReference referencedCombo;

  factory ComboDataSOModel.fromJson(Map<String, dynamic> json) =>
      ComboDataSOModel(
        comboState: ComboStateModel.fromJson(
          json['comboState'] as Map<String, dynamic>?,
        ),
        animationClip: UnityReference.fromJson(
          json['animationClip'] as Map<String, dynamic>?,
        ),
        comboDescription: (json['comboDescription'] ?? '') as String,
        priority: (json['priority'] ?? 0) as int,
        referencedCombo: UnityReference.fromJson(
          json['referencedCombo'] as Map<String, dynamic>?,
        ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'comboState': comboState.toJson(),
    'animationClip': animationClip.toJson(),
    'comboDescription': comboDescription,
    'priority': priority,
    'referencedCombo': referencedCombo.toJson(),
  };

  ComboDataSOModel copyWith({
    ComboStateModel? comboState,
    UnityReference? animationClip,
    String? comboDescription,
    int? priority,
    UnityReference? referencedCombo,
  }) {
    return ComboDataSOModel(
      comboState: comboState ?? this.comboState,
      animationClip: animationClip ?? this.animationClip,
      comboDescription: comboDescription ?? this.comboDescription,
      priority: priority ?? this.priority,
      referencedCombo: referencedCombo ?? this.referencedCombo,
    );
  }
}
