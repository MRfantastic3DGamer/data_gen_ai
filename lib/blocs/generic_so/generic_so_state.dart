import 'package:data_gen_ai/models/unity_envelope.dart';
import 'package:equatable/equatable.dart';

class GenericSOState extends Equatable {
  const GenericSOState({
    this.loading = false,
    this.path,
    this.payload = const <String, dynamic>{},
    this.envelope,
    this.error,
    this.saved = false,
  });

  final bool loading;
  final String? path;
  final Map<String, dynamic> payload;
  final UnityEnvelope? envelope;
  final String? error;
  final bool saved;

  GenericSOState copyWith({
    bool? loading,
    String? path,
    Map<String, dynamic>? payload,
    UnityEnvelope? envelope,
    String? error,
    bool? saved,
  }) {
    return GenericSOState(
      loading: loading ?? this.loading,
      path: path ?? this.path,
      payload: payload ?? this.payload,
      envelope: envelope ?? this.envelope,
      error: error,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    loading,
    path,
    payload,
    envelope,
    error,
    saved,
  ];
}
