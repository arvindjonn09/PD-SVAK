#!/usr/bin/env bash
# Sync the GrapheneOS tree, add PD-SVAK local manifests, and apply our patch set.
# Usage: build/sync.sh [--no-patches]
set -euo pipefail
source "$(dirname "$0")/config.sh"
pds_need repo

cd "$PDS_SRC"
if [[ ! -d .repo ]]; then
  repo init -u "$PDS_MANIFEST_URL" -b "$PDS_MANIFEST_BRANCH" --git-lfs
fi

mkdir -p .repo/local_manifests
cp -f "$PDS_ROOT"/manifests/*.xml .repo/local_manifests/ 2>/dev/null || true

repo sync -j"$(nproc)" --force-sync --no-clone-bundle --no-tags

[[ "${1:-}" == "--no-patches" ]] && exit 0
"$PDS_ROOT/build/apply-patches.sh"
