#!/usr/bin/env bash
# Download the preinstalled APKs listed in vendor/pdsvak/prebuilts.lock and check their SHA-256.
# Usage: build/fetch-prebuilts.sh
set -euo pipefail
source "$(dirname "$0")/config.sh"
pds_need curl
pds_need sha256sum

LOCK="$PDS_ROOT/vendor/pdsvak/prebuilts.lock"
DEST="$PDS_SRC/vendor/pdsvak/prebuilt"
mkdir -p "$DEST"

while read -r name url sha; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  [[ "$url" == *REPLACE* || "$sha" == *REPLACE* ]] && pds_die "$name is not pinned yet in prebuilts.lock"
  [[ "$url" == https://* ]] || pds_die "$name: URL must be https"
  if [[ -f "$DEST/$name" ]] && echo "$sha  $DEST/$name" | sha256sum -c --quiet 2>/dev/null; then
    echo "ok (cached)  $name"; continue
  fi
  curl -fsSL --proto '=https' -o "$DEST/$name.tmp" "$url"
  echo "$sha  $DEST/$name.tmp" | sha256sum -c --quiet || { rm -f "$DEST/$name.tmp"; pds_die "$name: SHA-256 mismatch"; }
  mv "$DEST/$name.tmp" "$DEST/$name"
  echo "ok           $name"
done < "$LOCK"
