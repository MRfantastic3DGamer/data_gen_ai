import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:equatable/equatable.dart';

sealed class GameDataEvent extends Equatable {
  const GameDataEvent();

  @override
  List<Object?> get props => [];
}

class GameDataStarted extends GameDataEvent {
  const GameDataStarted();
}

class GameDataSearchChanged extends GameDataEvent {
  const GameDataSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class GameDataCategoryFilterChanged extends GameDataEvent {
  const GameDataCategoryFilterChanged(this.category);
  final String? category;

  @override
  List<Object?> get props => [category];
}

class GameDataTypeFilterChanged extends GameDataEvent {
  const GameDataTypeFilterChanged(this.typeKey);
  final String? typeKey;

  @override
  List<Object?> get props => [typeKey];
}

class GameDataEntryUpdated extends GameDataEvent {
  const GameDataEntryUpdated(this.entry);
  final GameDataFileEntry entry;

  @override
  List<Object?> get props => [entry.path, entry.isDirty];
}

class GameDataCommitRequested extends GameDataEvent {
  const GameDataCommitRequested();
}

class GameDataCreateRequested extends GameDataEvent {
  const GameDataCreateRequested({required this.typeInfo, required this.name});
  final SOTypeInfo typeInfo;
  final String name;

  @override
  List<Object?> get props => [typeInfo.key, name];
}

class GameDataDeleteRequested extends GameDataEvent {
  const GameDataDeleteRequested(this.path);
  final String path;

  @override
  List<Object?> get props => [path];
}

class GameDataReloadRequested extends GameDataEvent {
  const GameDataReloadRequested();
}
