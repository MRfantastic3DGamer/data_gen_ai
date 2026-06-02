import 'package:data_gen_ai/blocs/generic_so/generic_so_event.dart';
import 'package:data_gen_ai/blocs/generic_so/generic_so_state.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/services/json_converter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GenericSOBloc extends Bloc<GenericSOEvent, GenericSOState> {
  GenericSOBloc(this._projectRepository, this._jsonConverter)
    : super(const GenericSOState()) {
    on<GenericSOLoaded>(_onLoaded);
    on<GenericSOUpdated>(_onUpdated);
    on<GenericSOSaved>(_onSaved);
  }

  final ProjectRepository _projectRepository;
  final JsonConverterService _jsonConverter;

  Future<void> _onLoaded(
    GenericSOLoaded event,
    Emitter<GenericSOState> emit,
  ) async {
    emit(state.copyWith(loading: true, saved: false));
    try {
      final envelope = await _projectRepository.loadEnvelope(event.path);
      emit(
        state.copyWith(
          loading: false,
          path: event.path,
          envelope: envelope,
          payload: _jsonConverter.extractPayload(envelope),
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onUpdated(GenericSOUpdated event, Emitter<GenericSOState> emit) {
    emit(state.copyWith(payload: event.payload, saved: false));
  }

  Future<void> _onSaved(
    GenericSOSaved event,
    Emitter<GenericSOState> emit,
  ) async {
    if (state.envelope == null) return;
    try {
      await _projectRepository.savePayload(
        path: event.path,
        baseEnvelope: state.envelope!,
        payload: state.payload,
      );
      emit(state.copyWith(saved: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
