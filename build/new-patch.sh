#!/usr/bin/env bash
# Turn uncommitted changes in one source-tree project into the next numbered patch in patches/.
# Usage: build/new-patch.sh <project path in tree> "<one-line description>"
#   e.g. build/new-patch.sh packages/modules/NetworkStack "Use PD-SVAK connectivity check"
set -euo pipefail
source "$(dirname "$0")/config.sh"

PROJ="${1:?usage: new-patch.sh <project path> \"<description>\"}"
DESC="${2:?usage: new-patch.sh <project path> \"<description>\"}"
SRC="$PDS_SRC/$PROJ"
[[ -d "$SRC/.git" || -f "$SRC/.git" ]] || pds_die "$PROJ is not a git project in $PDS_SRC"
[[ -n "$(git -C "$SRC" status --porcelain)" ]] || pds_die "no changes in $PROJ"

case "$PROJ" in
  *selinux*|*sepolicy*|external/avb*|kernel/*|*hardened_malloc*|bootable/*)
    echo "!! $PROJ is security-critical: this patch needs a second reviewer (patches/README.md)." ;;
esac

OUT="$PDS_ROOT/patches/$PROJ"
mkdir -p "$OUT"
n=$(( $(find "$OUT" -maxdepth 1 -name '[0-9][0-9][0-9][0-9]-*.patch' | wc -l) + 1 ))

git -C "$SRC" add -A
git -C "$SRC" commit -q -m "$DESC" -m "PD-SVAK patch. Modified from upstream; see NOTICE.md."
git -C "$SRC" format-patch -1 --start-number "$n" -o "$OUT" HEAD
echo "Review the patch, then commit it to the PD-SVAK repo."
