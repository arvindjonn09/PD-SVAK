#!/usr/bin/env bash
# Build UNSIGNED target-files for a device. Signing happens offline (build/sign-release.sh).
# Usage: build/build.sh <codename>     e.g. build/build.sh shiba
#
# The steps follow https://grapheneos.org/build. VERIFY the commands against that page
# for the current branch before each release, because upstream changes them occasionally.
set -euo pipefail
source "$(dirname "$0")/config.sh"

DEVICE="${1:?usage: build.sh <codename>}"
grep -q "\"codename\": \"$DEVICE\"" "$PDS_ROOT/devices/devices.json" || pds_die "unknown device $DEVICE"

cd "$PDS_SRC"

# 1. Generate vendor files from the Pixel factory images with adevtool.
#    Vendor blobs are never committed to git. They exist only in the build tree and images.
if [[ ! -d "vendor/google_devices/$DEVICE" || "${PDS_REGEN_VENDOR:-0}" == 1 ]]; then
  yarn install --cwd vendor/adevtool/
  set +u; source build/envsetup.sh; set -u
  lunch "sdk_phone64_x86_64-${PDS_RELEASE}-${PDS_VARIANT}"
  m aapt2
  vendor/adevtool/bin/run generate-all -d "$DEVICE"
fi

# 2. Build the OS.
set +u; source build/envsetup.sh; set -u
lunch "${DEVICE}-${PDS_RELEASE}-${PDS_VARIANT}"
m vendorbootimage vendorkernelbootimage target-files-package

echo "Unsigned target-files are in: $PDS_SRC/out/target/product/$DEVICE/obj/PACKAGING/target_files_intermediates/"
echo "Move them to the offline signing machine and run build/sign-release.sh"
