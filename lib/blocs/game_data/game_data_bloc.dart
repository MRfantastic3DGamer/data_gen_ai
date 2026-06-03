import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_state.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/services/asset_index_service.dart';
import 'package:data_gen_ai/services/game_data_defaults.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameDataBloc extends Bloc<GameDataEvent, GameDataState> {
  GameDataBloc(
    this._repository,
    this._registryCatalog,
    this._assetIndex,
  ) : super(const GameDataState()) {
    on<GameDataStarted>(_onStarted);
    on<GameDataSearchChanged>(_onSearchChanged);
    on<GameDataCategoryFilterChanged>(_onCategoryChanged);
    on<GameDataTypeFilterChanged>(_onTypeChanged);
    on<GameDataEntryUpdated>(_onEntryUpdated);
    on<GameDataCommitRequested>(_onCommit);
    on<GameDataCreateRequested>(_onCreate);
    on<GameDataReloadRequested>(_onStarted);
  }

  final ProjectRepository _repository;
  final RegistryCatalogService _registryCatalog;
  final AssetIndexService _assetIndex;

  Future<void> _onStarted(
    GameDataEvent event,
    Emitter<GameDataState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true, clearSavedMessage: true));
    try {
      await _registryCatalog.reload(_repository);
      final entries = await _repository.loadAllEntries();
      await _assetIndex.rebuild(entries);
      emit(state.copyWith(loading: false, entries: entries));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onSearchChanged(
    GameDataSearchChanged event,
    Emitter<GameDataState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onCategoryChanged(
    GameDataCategoryFilterChanged event,
    Emitter<GameDataState> emit,
  ) {
    emit(state.copyWith(categoryFilter: event.category));
  }

  void _onTypeChanged(
    GameDataTypeFilterChanged event,
    Emitter<GameDataState> emit,
  ) {
    emit(state.copyWith(typeFilter: event.typeKey));
  }

  void _onEntryUpdated(
    GameDataEntryUpdated event,
    Emitter<GameDataState> emit,
  ) {
    final updated = state.entries
        .map(
          (e) => e.path == event.entry.path
              ? event.entry.copyWith(isDirty: true)
              : e,
        )
        .toList();
    emit(state.copyWith(entries: updated, clearSavedMessage: true));
  }

  Future<void> _onCommit(
    GameDataCommitRequested event,
    Emitter<GameDataState> emit,
  ) async {
    final dirty = state.entries.where((e) => e.isDirty).toList();
    if (dirty.isEmpty) {
      emit(state.copyWith(savedMessage: 'No pending changes to commit.'));
      return;
    }

    emit(state.copyWith(committing: true, clearError: true));
    try {
      final count = await _repository.commitAll(dirty);
      await _registryCatalog.reload(_repository);
      final refreshed = await _repository.loadAllEntries();
      emit(
        state.copyWith(
          committing: false,
          entries: refreshed,
          lastCommitCount: count,
          savedMessage: 'Committed $count file(s) to JSON.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(committing: false, error: e.toString()));
    }
  }

  Future<void> _onCreate(
    GameDataCreateRequested event,
    Emitter<GameDataState> emit,
  ) async {
    try {
      await _registryCatalog.reload(_repository);
      final path = await _repository.createNewFile(
        typeInfo: event.typeInfo,
        objectName: event.name,
        payload: _defaultPayloadFor(event.typeInfo.key),
      );
      final entry = await _repository.loadEntry(path);
      await _registryCatalog.reload(_repository);
      final entries = await _repository.loadAllEntries();
      emit(
        state.copyWith(
          entries: entries,
          savedMessage: 'Created ${event.name}',
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Map<String, dynamic> _defaultPayloadFor(String typeKey) {
    return GameDataDefaults.payloadFor(typeKey);
  }
}
