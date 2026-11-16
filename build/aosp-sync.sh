#!/usr/bin/env bash
# AOSP line: sync the LineageOS tree into $PDS_AOSP_SRC with our device manifests, and add the
# PD-SVAK product layer. Usage: build/aosp-sync.sh
# Same knobs as build/sync.sh: PDS_REPO_DEPTH=1 (no history), PDS_SYNC_JOBS (lower on HTTP 429).
set -euo pipefail
source "$(dirname "$0")/config.sh"
pds_need repo
pds_need rsync

mkdir -p "$PDS_AOSP_SRC"
cd "$PDS_AOSP_SRC"
if [[ ! -d .repo ]]; then
  repo init -u "$PDS_AOSP_MANIFEST_URL" -b "$PDS_AOSP_BRANCH" --git-lfs --no-clone-bundle \
    ${PDS_REPO_DEPTH:+--depth="$PDS_REPO_DEPTH"}
fi

mkdir -p .repo/local_manifests
cp -f "$PDS_ROOT"/manifests/aosp/*.xml .repo/local_manifests/

jobs="${PDS_SYNC_JOBS:-$(nproc)}"
for attempt in 1 2 3; do
  repo sync -c -j"$jobs" --force-sync --no-clone-bundle --no-tags && break
  (( attempt < 3 )) || pds_die "repo sync failed 3 times. Try PDS_SYNC_JOBS=2"
  echo ">> sync attempt $attempt failed; waiting 5 minutes before retrying (rate limits)"
  sleep 300
done

# PD-SVAK layer, hooked in through LineageOS's vendor/extra/product.mk (no patch needed).
rsync -a --delete --exclude prebuilt/ "$PDS_ROOT/vendor/pdsvak/" vendor/pdsvak/
mkdir -p vendor/extra
cat > vendor/extra/product.mk <<'MK'
# Written by PD-SVAK build/aosp-sync.sh. Do not edit; edit vendor/pdsvak/aosp.mk instead.
$(call inherit-product, vendor/pdsvak/aosp.mk)
MK
echo "AOSP-line tree ready at $PDS_AOSP_SRC"
