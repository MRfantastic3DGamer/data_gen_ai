import 'package:data_gen_ai/models/item_data.dart';
import 'package:equatable/equatable.dart';

sealed class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ItemLoaded extends ItemEvent {
  const ItemLoaded(this.path);
  final String path;
  @override
  List<Object?> get props => <Object?>[path];
}

class ItemUpdated extends ItemEvent {
  const ItemUpdated(this.data);
  final ItemDataModel data;
  @override
  List<Object?> get props => <Object?>[data];
}

class ItemSaved extends ItemEvent {
  const ItemSaved(this.path);
  final String path;
  @override
  List<Object?> get props => <Object?>[path];
}

class ItemSavedNew extends ItemEvent {
  const ItemSavedNew(this.objectName);
  final String objectName;
  @override
  List<Object?> get props => <Object?>[objectName];
}
