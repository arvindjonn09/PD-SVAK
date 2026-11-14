#!/usr/bin/env bash
# Apply patches/<path/in/tree>/*.patch onto the matching project in $PDS_SRC.
# Example: patches/packages/apps/Updater/0001-Point-updater-at-PD-SVAK-server.patch
set -euo pipefail
source "$(dirname "$0")/config.sh"

shopt -s nullglob
fail=0
while IFS= read -r -d '' dir; do
  rel="${dir#"$PDS_ROOT/patches/"}"
  target="$PDS_SRC/$rel"
  patches=("$dir"/*.patch)
  (( ${#patches[@]} )) || continue
  [[ -d "$target/.git" || -f "$target/.git" ]] || { echo "skip: $rel (not a git project)"; continue; }
  echo ">> $rel (${#patches[@]} patches)"
  if ! git -C "$target" am --3way "${patches[@]}"; then
    echo "!! conflict in $rel. Resolve it, or run 'git -C $target am --abort'" >&2
    fail=1
  fi
done < <(find "$PDS_ROOT/patches" -mindepth 1 -type d -print0)

exit $fail
