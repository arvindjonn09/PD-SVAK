#!/usr/bin/env bash
# Sync the GrapheneOS tree, add PD-SVAK local manifests, and apply our patch set.
# Usage: build/sync.sh [--no-patches]
set -euo pipefail
source "$(dirname "$0")/config.sh"
pds_need repo

cd "$PDS_SRC"
if [[ ! -d .repo ]]; then
  # PDS_REPO_DEPTH=1 skips git history (saves ~100 GB). Fine for building; use a full
  # sync on the release builder, where the rebase assistant needs history.
  repo init -u "$PDS_MANIFEST_URL" -b "$PDS_MANIFEST_BRANCH" --git-lfs \
    ${PDS_REPO_DEPTH:+--depth="$PDS_REPO_DEPTH"}
fi

mkdir -p .repo/local_manifests
cp -f "$PDS_ROOT"/manifests/*.xml .repo/local_manifests/ 2>/dev/null || true

repo sync -j"$(nproc)" --force-sync --no-clone-bundle --no-tags

# Our product layer lives in this repo; mirror it into the tree (keeping downloaded prebuilts).
pds_need rsync
rsync -a --delete --exclude prebuilt/ "$PDS_ROOT/vendor/pdsvak/" "$PDS_SRC/vendor/pdsvak/"

[[ "${1:-}" == "--no-patches" ]] && exit 0
"$PDS_ROOT/build/apply-patches.sh"
