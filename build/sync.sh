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

# Google's AOSP servers rate-limit (HTTP 429) too many parallel fetches. Lower PDS_SYNC_JOBS
# if that happens; repo only re-fetches what's missing. Retries a few times before giving up.
jobs="${PDS_SYNC_JOBS:-$(nproc)}"
for attempt in 1 2 3; do
  repo sync -j"$jobs" --force-sync --no-clone-bundle --no-tags && break
  (( attempt < 3 )) || pds_die "repo sync failed 3 times. Try PDS_SYNC_JOBS=2"
  echo ">> sync attempt $attempt failed; waiting 5 minutes before retrying (rate limits)"
  sleep 300
done

# Our product layer lives in this repo; mirror it into the tree (keeping downloaded prebuilts).
pds_need rsync
rsync -a --delete --exclude prebuilt/ "$PDS_ROOT/vendor/pdsvak/" "$PDS_SRC/vendor/pdsvak/"

[[ "${1:-}" == "--no-patches" ]] && exit 0
"$PDS_ROOT/build/apply-patches.sh"
