#!/usr/bin/env bash
set -euo pipefail

# Turf Wars Live Build & Deploy to Pixel 10 Pro
GODOT_BIN="/Users/aj/local/godot-4.4.1/Godot.app/Contents/MacOS/Godot"
ADB_BIN="/Users/aj/Library/Android/sdk/platform-tools/adb"
APKSIGNER_BIN="/Users/aj/local/android-sdk/build-tools/36.0.0/apksigner"
JAVA_HOME_PATH="/Users/aj/local/jdk21/Contents/Home"
KEYSTORE_PATH="/Users/aj/Library/Application Support/Godot/keystores/debug.keystore"
DEVICE_SERIAL="62250DLCH003LE"
APK_PATH="build/TurfWars.apk"

echo "=== [1/4] Building APK with Godot 4.4.1 ==="
mkdir -p build
"$GODOT_BIN" --headless --export-debug "Android" "$APK_PATH"

echo "=== [2/4] Signing APK ==="
JAVA_HOME="$JAVA_HOME_PATH" "$APKSIGNER_BIN" sign \
  --ks "$KEYSTORE_PATH" \
  --ks-pass pass:android \
  --ks-key-alias androiddebugkey \
  --key-pass pass:android \
  "$APK_PATH"

echo "=== [3/4] Installing onto Pixel ($DEVICE_SERIAL) ==="
"$ADB_BIN" -s "$DEVICE_SERIAL" install -r "$APK_PATH"

echo "=== [4/4] Launching Turf Wars ==="
"$ADB_BIN" -s "$DEVICE_SERIAL" shell am start -n com.radixobsidian.turfwars/com.godot.game.GodotApp

echo "=== Live deploy complete! ==="
