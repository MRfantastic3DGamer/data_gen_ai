# GameData Editor (Flutter)

Mobile companion for editing Unity **GameData** ScriptableObjects as JSON files.

## Workflow

1. **Unity export** — `Tools → Agent Actions → Export GameData ScriptableObjects to JSON`  
   Writes mirrored JSON under `Assets/GameData/RAW/` in the Unity project.

2. **Transfer** — Copy the entire `RAW` folder to your phone (USB, cloud, etc.).

3. **Flutter app** — Grant **storage / all files access** when prompted, then open **JSON data folder** and select that `RAW` directory.  
   Use **Registries** to edit the factions and animation-type tables (same ids as Unity dropdowns).  
   Use **Actions & Beliefs** to search, filter, and edit entries. Tap **Commit** to write changes back to JSON files.

4. **Transfer back** — Copy the edited `RAW` folder into the Unity project at `Assets/GameData/RAW/`.

5. **Unity import** — `Tools → Agent Actions → Import JSON to GameData ScriptableObjects`  
   Applies JSON onto existing `.asset` files (or creates missing assets).

## AI features

On-device LLM integration (`flutter_gemma`, `AIRepository`) is kept in the codebase for future use and is **not** wired into the main navigation.

## Supported typed editors

- `ActionableSO` — action id, beliefs, cost/time
- `BeliefSO` — query, field, condition, values

Other types open a raw JSON payload view until dedicated forms are added.
