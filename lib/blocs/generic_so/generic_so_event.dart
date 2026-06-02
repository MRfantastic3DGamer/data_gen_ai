import 'package:equatable/equatable.dart';

sealed class GenericSOEvent extends Equatable {
  const GenericSOEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class GenericSOLoaded extends GenericSOEvent {
  const GenericSOLoaded(this.path);
  final String path;
  @override
  List<Object?> get props => <Object?>[path];
}

class GenericSOUpdated extends GenericSOEvent {
  const GenericSOUpdated(this.payload);
  final Map<String, dynamic> payload;
  @override
  List<Object?> get props => <Object?>[payload];
}

class GenericSOSaved extends GenericSOEvent {
  const GenericSOSaved(this.path);
  final String path;
  @override
  List<Object?> get props => <Object?>[path];
}
