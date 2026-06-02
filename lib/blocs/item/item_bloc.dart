import 'package:data_gen_ai/blocs/item/item_event.dart';
import 'package:data_gen_ai/blocs/item/item_state.dart';
import 'package:data_gen_ai/models/item_data.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/services/json_converter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  ItemBloc(this._projectRepository, this._jsonConverter)
    : super(const ItemState()) {
    on<ItemLoaded>(_onLoaded);
    on<ItemUpdated>(_onUpdated);
    on<ItemSaved>(_onSaved);
    on<ItemSavedNew>(_onSavedNew);
  }

  final ProjectRepository _projectRepository;
  final JsonConverterService _jsonConverter;

  Future<void> _onLoaded(ItemLoaded event, Emitter<ItemState> emit) async {
    emit(state.copyWith(loading: true, saved: false));
    try {
      final envelope = await _projectRepository.loadEnvelope(event.path);
      final payload = _jsonConverter.extractPayload(envelope);
      emit(
        state.copyWith(
          loading: false,
          path: event.path,
          data: ItemDataModel.fromJson(payload),
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onUpdated(ItemUpdated event, Emitter<ItemState> emit) {
    emit(state.copyWith(data: event.data, saved: false));
  }

  Future<void> _onSaved(ItemSaved event, Emitter<ItemState> emit) async {
    try {
      final envelope = await _projectRepository.loadEnvelope(event.path);
      await _projectRepository.savePayload(
        path: event.path,
        baseEnvelope: envelope,
        payload: state.data.toJson(),
      );
      emit(state.copyWith(saved: true, path: event.path));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), saved: false));
    }
  }

  Future<void> _onSavedNew(
    ItemSavedNew event,
    Emitter<ItemState> emit,
  ) async {
    try {
      final path = await _projectRepository.createNewFile(
        typeName: 'ItemData',
        objectName: event.objectName,
        payload: state.data.toJson(),
      );
      emit(state.copyWith(saved: true, path: path));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), saved: false));
    }
  }
}
