# GameData Editor (Flutter)

Mobile companion for editing Unity **GameData** ScriptableObjects as JSON, synced via **Firebase Realtime Database** or a local RAW folder.

## Firebase setup (local)

`lib/firebase_options.dart` and `android/app/google-services.json` are **gitignored**. After clone:

```bash
flutterfire configure --project=game-dev-data-sync
```

Or copy from `lib/firebase_options.dart.example` and `android/app/google-services.json.example`.

**CI builds** need [GitHub Secrets](docs/GITHUB_SECRETS.md) (`FIREBASE_OPTIONS_DART_B64`, `GOOGLE_SERVICES_JSON_B64`).

## Workflow (Firebase — recommended)

1. **Unity** — `Tools → Agent Actions → GameData Firebase → Push RAW to Firebase` (or pull first if the DB is the source of truth).
2. **Flutter** — Open **Data source**, select **Firebase Realtime Database**. Edits **Commit** directly to the cloud.
3. **Unity** — `Tools → Agent Actions → GameData Firebase → Pull Firebase to RAW`, then import JSON onto ScriptableObjects.

See [docs/FIREBASE_SYNC.md](docs/FIREBASE_SYNC.md) for RTDB layout and security rules.

## Workflow (local files)

1. **Unity export** — `Tools → Agent Actions → Export GameData ScriptableObjects to JSON` → `Assets/GameData/RAW/`.
2. Copy `RAW` to the device (optional if using Firebase).
3. **Flutter** — **Data source** → **Local JSON folder**, grant storage access, choose the `RAW` directory.
4. Edit and **Commit**; copy `RAW` back to Unity; **Import JSON to GameData ScriptableObjects**.

## AI features

On-device LLM integration (`flutter_gemma`, `AIRepository`) is kept in the codebase for future use and is **not** wired into the main navigation.

## Supported typed editors

- `ActionableSO` — action id, beliefs, cost/time
- `BeliefSO` — query, field, condition, values

Other types open a raw JSON payload view until dedicated forms are added.

# Keep this up to date!
## WHENEVER THE GAME SCRIPTABLE OBJECTS ARE UPDATED, THIS ALSO NEEDS TO BE UPDATED