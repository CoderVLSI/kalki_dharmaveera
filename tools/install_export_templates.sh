#!/usr/bin/env bash
# Install Godot export templates (needed for APK/Web/Windows exports). ~1.3 GB download.
# Not persistent across cloud sessions, so run once per fresh container.
set -euo pipefail
V="${GODOT_VERSION:-4.7.2}"
D="/root/.local/share/godot/export_templates/${V}.stable"
if [ -f "$D/version.txt" ]; then echo "templates already installed: $(cat "$D/version.txt")"; exit 0; fi
B="https://github.com/godotengine/godot-builds/releases/download/${V}-stable"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/t.zip" "$B/Godot_v${V}-stable_export_templates.tpz"
curl -fsSL -o "$tmp/SUMS" "$B/SHA512-SUMS.txt"
grep " Godot_v${V}-stable_export_templates.tpz\$" "$tmp/SUMS" | awk '{print $1"  t.zip"}' | (cd "$tmp" && sha512sum -c -)
unzip -oq "$tmp/t.zip" -d "$tmp/x"
mkdir -p "$D" && cp -r "$tmp"/x/templates/* "$D/"
cat "$D/version.txt"
