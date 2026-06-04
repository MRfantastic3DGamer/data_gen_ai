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

## Reference format

ScriptableObject cross-references use logical JSON keys instead of Unity GUIDs:

```json
{
  "assetKey": "beliefs/MyBelief.json",
  "displayName": "MyBelief"
}
```

Null / empty reference:

```json
{ "assetKey": "" }
```

Legacy `{ "fileID", "guid", "type" }` refs are still accepted on read. Unity export/import converts them via `GameDataAssetRefCodec` (Unity) and `UnityReference` normalization (Flutter).

## Deletion sync

Deletions propagate when you commit or run a Unity sync — stale entries are removed on both sides.

| Action | Effect |
|--------|--------|
| **Flutter** swipe-delete → **Commit** | Removes the RTDB node (or local JSON file) |
| **Unity Push RAW to Firebase** | Uploads local files, then **deletes remote** entries absent from RAW |
| **Unity Pull Firebase to RAW** | Downloads remote files, then **deletes local RAW JSON** absent from Firebase |
| **Unity Export to JSON** | Removes stale RAW `.json` (and `.meta`) when the matching `.asset` was deleted |

## Flutter app

### Navigation

| Screen | Route | Purpose |
|--------|-------|---------|
| Home | `/` | Launch hub |
| All Game Data | `/actions` | Folder tree of every JSON entry; search, category filters, create, delete, commit |
| SO editor | `/so-edit` | Typed form per ScriptableObject type |
| Settings | `/data-folder` | Firebase vs local backend, editor padding |
| Registries | `/registries/*` | Faction / animation type tables |

Legacy routes:

- `/browser` redirects to `/actions`
- Dedicated **Characters** and **All JSON files** home entries were removed — use **All Game Data** (filter by **Characters** or browse the `Characters/` folder in the tree)

### Folder tree UI

The **All Game Data** screen and **asset reference pickers** show an expandable folder tree grouped by JSON path (e.g. `beliefs/`, `action catalog/`, `characters/`, `considerables/`).

- Tap a folder to expand/collapse
- Tap a file row to open the typed editor (or pick an asset in reference fields)
- Search auto-expands folders that contain matches
- Category filter chips (Actions, Catalog, Utility AI, Characters, …) filter the tree

### Editing workflow

1. Firebase is initialized on startup (`main.dart`).
2. Open **Settings** and choose **Firebase Realtime Database** (default) or **Local JSON folder**.
3. Open **All Game Data** — browse the folder tree or use category/search filters.
4. Edit an entry; changes are marked unsaved until **Commit**.
5. Swipe an entry left to mark it for deletion; **Commit** removes it from storage/Firebase.

### Editor layout (Settings)

Global spacing for all field boxes and forms:

- **Field box padding** — inside every `InputDecoration` (text fields, dropdowns, reference pickers)
- **Space between fields** — gap inside section cards and field groups

Values persist in SharedPreferences and apply app-wide via `EditorPreferencesService`.

### Asset references in the app

Reference fields open a searchable folder tree of loaded GameData assets (by `assetKey` path). Firebase mode does not require `.meta` files for picking — refs resolve by logical JSON key.

## Unity editor

### Menus

**Tools → Agent Actions**

| Menu item | Effect |
|-----------|--------|
| Export GameData ScriptableObjects to JSON | SO → `Assets/GameData/RAW/**/*.json`; converts refs to `assetKey` format; prunes stale RAW JSON |
| Import JSON to GameData ScriptableObjects | RAW JSON → `.asset` files; converts `assetKey` refs back to Unity GUIDs |
| **GameData Firebase → Pull Firebase to RAW** | Download RTDB → RAW; delete local files missing remotely |
| **GameData Firebase → Push RAW to Firebase** | Upload RAW → RTDB; delete remote entries missing locally |
| **GameData Firebase → Set Firebase Auth Token…** | Optional auth for REST calls |

### Typical loop (Firebase)

1. Ensure JSON exists under `Assets/GameData/RAW/` (export from SOs or pull from Firebase).
2. **Pull Firebase to RAW** — download latest (optional if Flutter edited in cloud).
3. **Import JSON to GameData ScriptableObjects** — apply onto `.asset` files.
4. Edit in Unity or Flutter.
5. **Export** (if edited in Unity) or rely on Flutter commits.
6. **Push RAW to Firebase** — publish to RTDB.

If database rules require auth, use **Set Firebase Auth Token…** (paste token into a `.txt` file and select it).

See also: [agent-actions `docs/GAMEDATA_SYNC.md`](https://github.com/MRfantastic3DGamer/agent-actions/blob/main/docs/GAMEDATA_SYNC.md) (Unity-side details).

## Security rules (development)

`database.rules.json` in this repo opens `gameData/v1/files` for read/write. Deploy only for development:

```bash
npx -y firebase-tools@latest deploy --only database --project game-dev-data-sync
```

Tighten rules before shipping (Firebase Auth, per-user paths, etc.).
