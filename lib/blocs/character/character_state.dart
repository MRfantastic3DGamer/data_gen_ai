import 'package:data_gen_ai/models/character_data.dart';
import 'package:equatable/equatable.dart';

class CharacterState extends Equatable {
  const CharacterState({
    this.loading = false,
    this.data = const CharacterDataModel(),
    this.path,
    this.saved = false,
    this.error,
  });

  final bool loading;
  final CharacterDataModel data;
  final String? path;
  final bool saved;
  final String? error;

  CharacterState copyWith({
    bool? loading,
    CharacterDataModel? data,
    String? path,
    bool? saved,
    String? error,
  }) {
    return CharacterState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      path: path ?? this.path,
      saved: saved ?? this.saved,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[loading, data, path, saved, error];
}
