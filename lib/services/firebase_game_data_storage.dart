import 'package:data_gen_ai/core/firebase_constants.dart';
import 'package:data_gen_ai/core/game_data_path.dart';
import 'package:data_gen_ai/services/game_data_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseGameDataStorage implements GameDataStorage {
  FirebaseGameDataStorage({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference get _filesRoot => _database.ref(
    FirebaseGameDataConstants.filesRoot,
  );

  @override
  Future<String> displayLocation() async =>
      FirebaseGameDataConstants.databaseUrl;

  @override
  Future<List<String>> listJsonKeys() async {
    final snapshot = await _filesRoot.get();
    if (!snapshot.exists || snapshot.value == null) {
      return <String>[];
    }
    final keys = <String>[];
    _collectKeys(snapshot.value, <String>[], keys);
    keys.sort();
    return keys;
  }

  void _collectKeys(
    Object? node,
    List<String> prefixSegments,
    List<String> outKeys,
  ) {
    if (node is! Map) return;

    if (node.containsKey(FirebaseGameDataConstants.contentField)) {
      final fileName = prefixSegments.isEmpty
          ? 'unknown.json'
          : '${prefixSegments.last}.json';
      final dirSegments = prefixSegments.length > 1
          ? prefixSegments.sublist(0, prefixSegments.length - 1)
          : <String>[];
      final key = dirSegments.isEmpty
          ? fileName
          : '${dirSegments.join('/')}/$fileName';
      outKeys.add(GameDataPath.normalizeKey(key));
      return;
    }

    for (final entry in node.entries) {
      final segment = entry.key.toString();
      if (segment == FirebaseGameDataConstants.updatedAtField) continue;
      _collectKeys(
        entry.value,
        <String>[...prefixSegments, segment],
        outKeys,
      );
    }
  }

  DatabaseReference _entryRef(String key) {
    final segments = GameDataPath.rtdbSegmentsFromKey(key);
    return _filesRoot.child(segments.join('/'));
  }

  @override
  Future<String> readContent(String key) async {
    final snapshot = await _entryRef(
      key,
    ).child(FirebaseGameDataConstants.contentField).get();
    if (!snapshot.exists || snapshot.value == null) {
      throw StateError('No Firebase content for $key');
    }
    return snapshot.value.toString();
  }

  @override
  Future<void> writeContent(String key, String content) async {
    await _entryRef(key).set(<String, Object?>{
      FirebaseGameDataConstants.contentField: content,
      FirebaseGameDataConstants.updatedAtField:
          DateTime.now().millisecondsSinceEpoch,
    });
  }
}
