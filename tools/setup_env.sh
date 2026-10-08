#!/usr/bin/env bash
# Rebuild the Kalki Dharmaveera dev environment on a fresh Ubuntu 24.04 box
# (the Claude Code cloud container is ephemeral). Idempotent.
#
#   Godot 4.7.2 (SHA512-verified)  -> /usr/local/bin/godot
#   Blender (apt)                  -> /usr/bin/blender
#   Godot MCP   (@coding-solo/godot-mcp)
#   Blender MCP (mcp-for-blender, formerly blender-mcp) + Blender add-on
#
# Run as root. Needs outbound access to github.com (godot-builds release
# assets), archive.ubuntu.com, registry.npmjs.org and pypi.org.
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.7.2}"
GODOT_MCP_VERSION="${GODOT_MCP_VERSION:-0.1.1}"
GODOT_BASE="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable"
GODOT_ZIP="Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() { printf '\n==> %s\n' "$*"; }

log "Godot ${GODOT_VERSION}"
if ! command -v godot >/dev/null || ! godot --headless --version 2>/dev/null | grep -q "^${GODOT_VERSION}"; then
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/godot.zip" "${GODOT_BASE}/${GODOT_ZIP}"
  curl -fsSL -o "$tmp/SUMS" "${GODOT_BASE}/SHA512-SUMS.txt"
  (cd "$tmp" && grep " ${GODOT_ZIP}\$" SUMS | awk '{print $1"  godot.zip"}' | sha512sum -c -)
  mkdir -p /opt/godot
  unzip -oq "$tmp/godot.zip" -d /opt/godot
  chmod +x "/opt/godot/Godot_v${GODOT_VERSION}-stable_linux.x86_64"
  ln -sf "/opt/godot/Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/local/bin/godot
  rm -rf "$tmp"
fi
godot --headless --version

log "Blender + Xvfb"
if ! command -v blender >/dev/null; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq blender xvfb python3-requests python3-numpy
fi
blender --version | head -1

log "Godot MCP"
npm install -g "@coding-solo/godot-mcp@${GODOT_MCP_VERSION}"

log "Blender MCP add-on"
command -v uvx >/dev/null || pip install --quiet uv
bver="$(blender --version | head -1 | sed -E 's/Blender ([0-9]+\.[0-9]+).*/\1/')"
addons="${HOME}/.config/blender/${bver}/scripts/addons"
mkdir -p "$addons"
uvx mcp-for-blender install-addon --addons-dir "$addons"

log "Done"
cat <<MSG
Start Blender with the MCP socket server (headless, port 9876):
  xvfb-run -a blender --python ${REPO_DIR}/tools/blender_mcp_launcher.py &
MCP client config is in ${REPO_DIR}/.mcp.json (picked up by Claude Code).
MSG
