# Encodes local Firebase config for GitHub Actions secrets (run locally; do not commit output).
# Usage (from repo root): .\tool\encode_firebase_secrets.ps1

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$dart = Join-Path $root 'lib\firebase_options.dart'
$json = Join-Path $root 'android\app\google-services.json'

foreach ($path in @($dart, $json)) {
    if (-not (Test-Path $path)) {
        Write-Error "Missing file: $path — run: flutterfire configure --project=game-dev-data-sync"
    }
}

$dartB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($dart))
$jsonB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($json))

Write-Host ""
Write-Host "Add these GitHub repository secrets (Settings → Secrets and variables → Actions):"
Write-Host ""
Write-Host "Name: FIREBASE_OPTIONS_DART_B64"
Write-Host "Value:"
Write-Host $dartB64
Write-Host ""
Write-Host "Name: GOOGLE_SERVICES_JSON_B64"
Write-Host "Value:"
Write-Host $jsonB64
Write-Host ""
Write-Host "Done. Do not commit these values or paste them in public channels."
