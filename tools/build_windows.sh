#!/usr/bin/env bash
# Windows x86_64 build (single .exe with the .pck embedded) zipped into dist/. Unsigned: Windows
# SmartScreen will warn ("More info" > "Run anyway"). Needs godot 4.7.2 + export templates.
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VER=$(grep -m1 'version/name' export_presets.cfg | cut -d'"' -f2)
mkdir -p build/windows dist
godot --headless --path . --import >/dev/null 2>&1 || true
godot --headless --path . --export-release "Windows Desktop"
rm -f "dist/KalkiDharmaveera-v${VER}-windows.zip"
(cd build/windows && zip -q -9 "../../dist/KalkiDharmaveera-v${VER}-windows.zip" KalkiDharmaveera.exe)
ls -la dist/*windows*
