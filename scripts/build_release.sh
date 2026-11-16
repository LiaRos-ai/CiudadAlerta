#!/usr/bin/env bash
# Día 10 / HU-12: build release verificable de CiudadAlerta.
# Genera el APK instalable SOLO si analyze y la suite pasan en verde.
set -euo pipefail
cd "$(dirname "$0")/../app"

echo "[1/6] flutter clean"
fvm flutter clean

echo "[2/6] flutter pub get"
fvm flutter pub get

echo "[3/6] flutter analyze (0 issues esperados)"
fvm flutter analyze

echo "[4/6] flutter test (59 pruebas verdes)"
fvm flutter test

echo "[5/6] flutter build apk --release"
fvm flutter build apk --release

echo "[6/6] resumen del artefacto"
ls -lh build/app/outputs/flutter-apk/app-release.apk
sha256sum build/app/outputs/flutter-apk/app-release.apk

echo "HU-12: instala y prueba con"
echo "  adb install -r build/app/outputs/flutter-apk/app-release.apk"
