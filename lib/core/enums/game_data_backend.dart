/// Where GameData JSON is read and written.
enum GameDataBackend {
  localFiles('local', 'Local JSON folder'),
  firebase('firebase', 'Firebase Realtime Database');

  const GameDataBackend(this.storageKey, this.label);

  final String storageKey;
  final String label;

  static GameDataBackend fromStorageKey(String? key) {
    return GameDataBackend.values.firstWhere(
      (b) => b.storageKey == key,
      orElse: () => GameDataBackend.firebase,
    );
  }
}
