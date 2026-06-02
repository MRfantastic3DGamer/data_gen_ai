import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/models/unity_envelope.dart';
import 'package:equatable/equatable.dart';

class GameDataFileEntry extends Equatable {
  const GameDataFileEntry({
    required this.path,
    required this.fileName,
    required this.typeInfo,
    required this.envelope,
    required this.payload,
    this.isDirty = false,
  });

  final String path;
  final String fileName;
  final SOTypeInfo? typeInfo;
  final UnityEnvelope envelope;
  final Map<String, dynamic> payload;
  final bool isDirty;

  String get displayName => envelope.name.isNotEmpty ? envelope.name : fileName;

  String get typeLabel => typeInfo?.displayName ?? 'Unknown';

  String get category => typeInfo?.category ?? 'Other';

  GameDataFileEntry copyWith({
    UnityEnvelope? envelope,
    Map<String, dynamic>? payload,
    bool? isDirty,
  }) {
    return GameDataFileEntry(
      path: path,
      fileName: fileName,
      typeInfo: typeInfo,
      envelope: envelope ?? this.envelope,
      payload: payload ?? this.payload,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => <Object?>[path, fileName, isDirty, envelope.name];
}
