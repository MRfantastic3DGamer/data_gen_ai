import 'package:data_gen_ai/models/item_data.dart';
import 'package:equatable/equatable.dart';

class ItemState extends Equatable {
  const ItemState({
    this.loading = false,
    this.data = const ItemDataModel(),
    this.path,
    this.saved = false,
    this.error,
  });

  final bool loading;
  final ItemDataModel data;
  final String? path;
  final bool saved;
  final String? error;

  ItemState copyWith({
    bool? loading,
    ItemDataModel? data,
    String? path,
    bool? saved,
    String? error,
  }) {
    return ItemState(
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
