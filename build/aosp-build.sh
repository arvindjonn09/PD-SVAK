#!/usr/bin/env bash
# AOSP line: build a LineageOS-based PD-SVAK image for a Silver/Bronze device.
# Usage: build/aosp-build.sh <codename>     e.g. build/aosp-build.sh x1s
#
# Output: $PDS_AOSP_SRC/out/target/product/<codename>/ (flashable zip, boot and recovery images).
# These builds are signed with LineageOS test keys and are userdebug: for the maintainer's own
# test device only. They are never published (docs/DEVICE-TIERS.md, rule 6).
set -euo pipefail
source "$(dirname "$0")/config.sh"

DEVICE="${1:?usage: aosp-build.sh <codename>}"
security="$(pds_require_aosp_device "$DEVICE")"
export PDS_SECURITY_TIER="$security"
export PDS_CHANNEL="${PDS_CHANNEL:-dev}"

# Prebuilts first: Soong parses vendor/pdsvak/Android.bp on any build.
PDS_SRC="$PDS_AOSP_SRC" "$PDS_ROOT/build/fetch-prebuilts.sh"

cd "$PDS_AOSP_SRC"
[[ -f vendor/extra/product.mk ]] || pds_die "run build/aosp-sync.sh first"

# envsetup.sh, breakfast and m reference unset variables, so keep -u off around them.
set +u
source build/envsetup.sh
breakfast "$DEVICE" "${PDS_AOSP_VARIANT:-userdebug}"
m bacon
set -u

echo "Images are in: $PDS_AOSP_SRC/out/target/product/$DEVICE/"
