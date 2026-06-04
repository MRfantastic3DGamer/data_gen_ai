# Firebase GameData sync

Project: **game-dev-data-sync**  
Realtime Database: [console](https://console.firebase.google.com/u/0/project/game-dev-data-sync/database/game-dev-data-sync-default-rtdb/data)

URL: `https://game-dev-data-sync-default-rtdb.asia-southeast1.firebasedatabase.app`

## Data layout

Both Flutter and Unity use the same tree:

```
gameData/v1/files/{folder...}/{assetName}/
  content: "<full JSON file text>"
  updatedAt: <unix ms>
```

Example logical key `beliefs/MyBelief.json` → RTDB path `gameData/v1/files/beliefs/MyBelief/content`.

## Flutter app

1. Firebase is initialized on startup (`main.dart`).
2. Open **Data source** and choose **Firebase Realtime Database** (default).
3. Edit entries and **Commit** — writes go directly to RTDB.
4. Swipe an entry left to delete it; **Commit** removes it from storage/Firebase.

Local **RAW folder** mode remains available for offline/USB workflows.

## Reference format

ScriptableObject cross-references use logical JSON keys instead of Unity GUIDs:

```json
{
  "assetKey": "beliefs/MyBelief.json",
  "displayName": "MyBelief"
}
```

Legacy `{ "fileID", "guid", "type" }` refs are still accepted on import. Unity export converts them automatically.

## Deletion sync

- **Flutter**: swipe-delete an entry, then **Commit** — removes the RTDB node (or local JSON file).
- **Unity Push RAW to Firebase**: uploads local files, then deletes remote entries that no longer exist locally.
- **Unity Pull Firebase to RAW**: downloads remote files, then deletes local RAW JSON absent from Firebase.
- **Unity Export to JSON**: removes stale RAW JSON files whose `.asset` was deleted.

## Unity editor

1. Ensure JSON exists under `Assets/GameData/RAW/` (export from SOs or pull from Firebase).
2. **Tools → Agent Actions → GameData Firebase → Pull Firebase to RAW** — download latest.
3. **Import JSON to GameData ScriptableObjects** (when import menu exists).
4. After editing in Unity or Flutter, **Push RAW to Firebase** to publish.

If database rules require auth, use **Set Firebase Auth Token…** (paste token into a `.txt` file and select it).

## Security rules (development)

`database.rules.json` in this repo opens `gameData/v1/files` for read/write. Deploy only for development:

```bash
npx -y firebase-tools@latest deploy --only database --project game-dev-data-sync
```

Tighten rules before shipping (Firebase Auth, per-user paths, etc.).
