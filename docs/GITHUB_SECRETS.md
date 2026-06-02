# GitHub Actions — Firebase secrets

Firebase client config is **not** stored in this repository. CI injects it at build time from encrypted GitHub Secrets.

## One-time setup

1. Generate config locally (if you do not already have the files):

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=game-dev-data-sync
   ```

   This creates `lib/firebase_options.dart` and `android/app/google-services.json` locally (both gitignored).

2. Encode secrets for GitHub (PowerShell, from repo root):

   ```powershell
   .\tool\encode_firebase_secrets.ps1
   ```

3. In GitHub: **Settings → Secrets and variables → Actions → New repository secret**

   | Secret name | Value |
   |-------------|--------|
   | `FIREBASE_OPTIONS_DART_B64` | Output from script (full base64 line) |
   | `GOOGLE_SERVICES_JSON_B64` | Output from script (full base64 line) |

4. Push code — the workflow decodes these files before `flutter build`.

## Local development

Copy the example and fill in values, or run `flutterfire configure`:

```bash
cp lib/firebase_options.dart.example lib/firebase_options.dart
# edit placeholders, or use flutterfire configure
cp android/app/google-services.json.example android/app/google-services.json
```

## If keys were ever committed

Firebase **API keys in mobile apps are not secret** (they ship inside the APK), but you should still:

1. Remove them from git history if they were pushed.
2. Restrict keys in [Google Cloud Console](https://console.cloud.google.com/) (Android app + SHA-1, package name).
3. Lock down [Realtime Database rules](https://console.firebase.google.com/) — never rely on key hiding alone.

## Security model

- **Git**: no `firebase_options.dart`, no `google-services.json`
- **CI**: secrets injected per build, not logged
- **APK**: keys are present (normal for Firebase client SDKs); protect data with RTDB rules + Auth
