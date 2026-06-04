# GameData Editor (Flutter)

Mobile companion for editing Unity **GameData** ScriptableObjects as JSON, synced via **Firebase Realtime Database** or a local RAW folder.

## Quick start

1. Configure Firebase (see below).
2. Open **All Game Data** — browse the folder tree, edit entries, **Commit**.
3. In Unity: **Pull Firebase to RAW** → **Import JSON to GameData ScriptableObjects**.

Full sync details: [docs/FIREBASE_SYNC.md](docs/FIREBASE_SYNC.md)

## App navigation

| Entry | Description |
|-------|-------------|
| **All Game Data** | Folder tree of all JSON assets; search, category filters, create, swipe-delete, commit |
| **Registries** | Faction and animation type tables |
| **Settings** | Firebase vs local storage; global editor field padding |

Characters, Utility AI, action catalog, and all other ScriptableObject types are edited from **All Game Data** — use category filter chips or expand the matching folder in the tree (e.g. `Characters/`, `considerables/`, `action catalog/`).

There is no separate Characters or Utility AI screen.

## Folder tree & asset pickers

GameData entries are shown in an **expandable folder tree** grouped by JSON path (`beliefs/MyBelief.json` → folder `beliefs/`).

The same tree layout is used when picking **ScriptableObject references** in editor forms — assets are grouped by folder instead of showing opaque GUID strings.

## Editor settings

**Settings → Editor layout**

- **Field box padding** — padding inside every input/dropdown/reference field
- **Space between fields** — vertical gap between fields in a section

Applies globally across all typed editor forms.

## Firebase setup (local)

`lib/firebase_options.dart` and `android/app/google-services.json` are **gitignored**. After clone:

```bash
flutterfire configure --project=game-dev-data-sync
```

Or copy from `lib/firebase_options.dart.example` and `android/app/google-services.json.example`.

**CI builds** need [GitHub Secrets](docs/GITHUB_SECRETS.md) (`FIREBASE_OPTIONS_DART_B64`, `GOOGLE_SERVICES_JSON_B64`).

## Workflow (Firebase — recommended)

1. **Unity** — `Tools → Agent Actions → GameData Firebase → Push RAW to Firebase` (or pull first if the DB is the source of truth).
2. **Flutter** — **Settings** → **Firebase Realtime Database**. Open **All Game Data**, edit, **Commit**.
3. **Unity** — `Pull Firebase to RAW`, then **Import JSON to GameData ScriptableObjects**.

Deletions sync both ways: swipe-delete + Commit in Flutter, or remove assets/JSON in Unity then Push/Export.

## Workflow (local files)

1. **Unity export** — `Tools → Agent Actions → Export GameData ScriptableObjects to JSON` → `Assets/GameData/RAW/`.
2. Copy `RAW` to the device (optional if using Firebase).
3. **Flutter** — **Settings** → **Local JSON folder**, grant storage access, choose the `RAW` directory.
4. Edit and **Commit**; copy `RAW` back to Unity; **Import JSON to GameData ScriptableObjects**.

## Reference format (Flutter ↔ Unity)

Cross-asset references in JSON use logical paths, not Unity GUIDs:

```json
{
  "assetKey": "beliefs/MyBelief.json",
  "displayName": "MyBelief"
}
```

Legacy `{ "fileID", "guid", "type" }` refs are still read correctly. New saves use `assetKey`.

## Supported typed editors

Registered in `lib/core/so_type_registry.dart` with dedicated forms under `lib/widgets/editors/`:

| Category | Types |
|----------|-------|
| Actions | ActionableSO, BeliefSO, BeliefSelectionSO |
| Catalog | ActionCatalogEntrySO, ActionCatalogRegistry |
| Utility AI | ConsiderableSO, ConsiderationFunctionSO |
| Queries | All query view subtypes |
| Characters | CharacterData, CharacterStatsSO |
| Items | ItemData |
| Combat | ComboDataSO, MoveLibrarySO |
| Registries | FactionsConfig, AnimationTypesConfig, CharacterAnimationDatabase, AnimationRegistry, WorkTypesConfig |

Unregistered types open a raw JSON payload view.

## AI features

On-device LLM integration (`flutter_gemma`, `AIRepository`) is kept in the codebase for future use and is **not** wired into the main navigation.

## Keep docs in sync

When Unity ScriptableObject types or the JSON envelope format change, update:

- `lib/core/so_type_registry.dart` and editor forms in this repo
- [agent-actions `SCRIPTABLE_OBJECTS.md`](../agent-actions/SCRIPTABLE_OBJECTS.md) and [agent-actions `docs/GAMEDATA_SYNC.md`](../agent-actions/docs/GAMEDATA_SYNC.md)
