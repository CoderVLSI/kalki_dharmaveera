#!/usr/bin/env bash
# Build a signed arm64 APK without the official Android SDK (dl.google.com is
# blocked in the cloud sandbox): uses Debian/Ubuntu apksigner + zipalign + adb
# behind a minimal fake SDK layout, Godot's prebuilt Android template, and a
# throwaway DEBUG keystore. Fine for sideload testing; NOT for Play Store.
# Needs: godot 4.7.2 with export templates installed, run as root.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openjdk-17-jdk-headless apksigner zipalign adb >/dev/null
SDK=/opt/android-sdk
mkdir -p $SDK/build-tools/34.0.0 $SDK/platform-tools $SDK/cmdline-tools/latest/bin $SDK/platforms/android-34
ln -sf /usr/bin/apksigner $SDK/build-tools/34.0.0/apksigner
ln -sf /usr/bin/zipalign  $SDK/build-tools/34.0.0/zipalign
ln -sf /usr/bin/adb       $SDK/platform-tools/adb
printf '#!/bin/sh\nexit 0\n' > $SDK/cmdline-tools/latest/bin/sdkmanager; chmod +x $SDK/cmdline-tools/latest/bin/sdkmanager
mkdir -p /root/Android && ln -sfn $SDK /root/Android/Sdk          # Godot's default SDK path
KS=/root/debug.keystore
[ -f $KS ] || keytool -genkeypair -keystore $KS -storepass android -alias androiddebugkey \
  -keypass android -keyalg RSA -keysize 2048 -validity 9999 -dname "CN=Android Debug,O=Android,C=US"
mkdir -p /root/.local/share/godot/keystores && cp $KS /root/.local/share/godot/keystores/debug.keystore
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=$KS GODOT_ANDROID_KEYSTORE_RELEASE_USER=androiddebugkey GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=android
cd "$REPO_DIR"
godot --headless --path . --import >/dev/null 2>&1 || true
mkdir -p build/android dist
godot --headless --path . --export-release "Android"
cp build/android/KalkiDharmaveera.apk dist/KalkiDharmaveera-v0.3.0-android.apk
sha256sum dist/*.apk
