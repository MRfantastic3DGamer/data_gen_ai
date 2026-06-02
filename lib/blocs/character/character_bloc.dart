import 'package:data_gen_ai/blocs/character/character_event.dart';
import 'package:data_gen_ai/blocs/character/character_state.dart';
import 'package:data_gen_ai/models/character_data.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/services/json_converter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  CharacterBloc(this._projectRepository, this._jsonConverter)
    : super(const CharacterState()) {
    on<CharacterLoaded>(_onLoaded);
    on<CharacterUpdated>(_onUpdated);
    on<CharacterSaved>(_onSaved);
  }

  final ProjectRepository _projectRepository;
  final JsonConverterService _jsonConverter;

  Future<void> _onLoaded(
    CharacterLoaded event,
    Emitter<CharacterState> emit,
  ) async {
    emit(state.copyWith(loading: true, saved: false));
    try {
      final envelope = await _projectRepository.loadEnvelope(event.path);
      final payload = _jsonConverter.extractPayload(envelope);
      emit(
        state.copyWith(
          loading: false,
          path: event.path,
          data: CharacterDataModel.fromJson(payload),
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onUpdated(CharacterUpdated event, Emitter<CharacterState> emit) {
    emit(state.copyWith(data: event.data, saved: false));
  }

  Future<void> _onSaved(
    CharacterSaved event,
    Emitter<CharacterState> emit,
  ) async {
    try {
      final envelope = await _projectRepository.loadEnvelope(event.path);
      await _projectRepository.savePayload(
        path: event.path,
        baseEnvelope: envelope,
        payload: state.data.toJson(),
      );
      emit(state.copyWith(saved: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), saved: false));
    }
  }
}
