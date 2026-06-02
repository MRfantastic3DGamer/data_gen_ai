import 'package:data_gen_ai/models/game_data_file_entry.dart';

/// Merges [modelJson] into the entry payload and marks dirty.
GameDataFileEntry mergeEntryPayload(
  GameDataFileEntry entry,
  Map<String, dynamic> modelJson,
) {
  final payload = Map<String, dynamic>.from(entry.payload)..addAll(modelJson);
  return entry.copyWith(payload: payload, isDirty: true);
}

String? queryViewTypeFromIdentifier(String? identifier) {
  if (identifier == null || identifier.isEmpty) return null;
  const prefix = 'Assembly-CSharp::AI.DataModels.QueryViews.';
  if (!identifier.contains('QueryViews.')) return null;
  final idx = identifier.lastIndexOf('.');
  if (idx < 0) return null;
  return identifier.substring(idx + 1);
}
