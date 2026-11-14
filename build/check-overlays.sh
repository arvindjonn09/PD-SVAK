#!/usr/bin/env bash
# Fail if any resource we overlay in vendor/pdsvak/overlay no longer exists upstream.
# Without this, a renamed upstream resource makes our overlay a silent no-op, and a
# privacy default (NTP server, update URL) quietly falls back to the upstream value.
# Usage: build/check-overlays.sh      (needs a synced tree at $PDS_SRC)
set -euo pipefail
source "$(dirname "$0")/config.sh"

OVL="$PDS_ROOT/vendor/pdsvak/overlay"
fail=0
while IFS= read -r -d '' file; do
  rel="${file#"$OVL/"}"
  upstream="$PDS_SRC/$rel"
  if [[ ! -f "$upstream" ]]; then
    echo "MISSING FILE  $rel (upstream file not found)"; fail=1; continue
  fi
  while IFS= read -r name; do
    if grep -q "name=\"$name\"" "$upstream"; then
      echo "ok            $rel: $name"
    else
      echo "MISSING NAME  $rel: $name"; fail=1
    fi
  done < <(grep -o '<[a-z-]* name="[^"]*"' "$file" | sed 's/.*name="\([^"]*\)"/\1/')
done < <(find "$OVL" -name '*.xml' -print0)

(( fail == 0 )) || pds_die "overlay check failed: fix the names above before building"
