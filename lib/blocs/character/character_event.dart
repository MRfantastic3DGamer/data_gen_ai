import 'package:data_gen_ai/models/character_data.dart';
import 'package:equatable/equatable.dart';

sealed class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class CharacterLoaded extends CharacterEvent {
  const CharacterLoaded(this.path);
  final String path;
  @override
  List<Object?> get props => <Object?>[path];
}

class CharacterUpdated extends CharacterEvent {
  const CharacterUpdated(this.data);
  final CharacterDataModel data;
  @override
  List<Object?> get props => <Object?>[data];
}

class CharacterSaved extends CharacterEvent {
  const CharacterSaved({this.path, required this.fileName});

  final String? path;
  final String fileName;

  @override
  List<Object?> get props => <Object?>[path, fileName];
}
