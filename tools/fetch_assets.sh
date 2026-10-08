#!/usr/bin/env bash
# Download the Kalki model drop from the GitHub release tagged `kalki` and
# unpack it into assets/source/kalki/ (git-ignored; the release is the
# source of truth, so the repo history stays small). Verifies SHA-256.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO_DIR/assets/source/kalki"
BASE="https://github.com/CoderVLSI/kalki_dharmaveera/releases/download/kalki"

# name | sha256 | unpack subdir
ASSETS=(
  "c35be06a-4ae5-4b71-b85a-241815f88fca.zip|844d360347de931ba6a7db513ca7368edb99176181e11b14e31ea11f060bff00|glb"
  "528ef542-5708-41da-a5cd-19858fcfb159.2.zip|3e34c463303ae996168b77a2d891ef13189c20a49e5acee9b49399411e2a518a|obj_pbr"
)

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
for entry in "${ASSETS[@]}"; do
  IFS='|' read -r name sha sub <<<"$entry"
  echo "==> $name -> $sub/"
  curl -fsSL -o "$tmp/$name" "$BASE/$name"
  echo "$sha  $tmp/$name" | sha256sum -c -
  mkdir -p "$DEST/$sub"
  unzip -oq "$tmp/$name" -d "$DEST/$sub"
done
echo "Done. Files in $DEST"
