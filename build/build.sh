#!/usr/bin/env bash
# Build UNSIGNED target-files for a device. Signing happens offline (build/sign-release.sh).
# Usage: build/build.sh <codename>     e.g. build/build.sh shiba
#
# The steps follow https://grapheneos.org/build. VERIFY the commands against that page
# for the current branch before each release, because upstream changes them occasionally.
set -euo pipefail
source "$(dirname "$0")/config.sh"

DEVICE="${1:?usage: build.sh <codename>}"
pds_require_gold_device "$DEVICE"

# 1. Hash-checked prebuilts first: Soong parses every Android.bp (ours too) on any build,
#    so vendor/pdsvak/prebuilt/ must exist before even the adevtool helper build below.
"$PDS_ROOT/build/fetch-prebuilts.sh"

cd "$PDS_SRC"

# 2. Generate vendor files from the Pixel factory images with adevtool.
#    Vendor blobs are never committed to git. They exist only in the build tree and images.
#    The generated module records the vendor/adevtool commit it was made with and refuses to
#    build otherwise. Our adevtool patch gets a new commit hash on every sync, so regenerate
#    whenever that recorded hash is stale (not only when the module is missing).
vcheck="vendor/google_devices/$DEVICE/adevtool-version-check.mk"
if [[ ! -f "$vcheck" || "${PDS_REGEN_VENDOR:-0}" == 1 ]] \
   || ! grep -q "$(git -C vendor/adevtool rev-parse HEAD)" "$vcheck"; then
  yarn install --cwd vendor/adevtool/
  # envsetup.sh, lunch and m reference unset variables, so keep -u off around them.
  set +u; source build/envsetup.sh
  lunch "sdk_phone64_x86_64-${PDS_RELEASE}-${PDS_VARIANT}"
  m aapt2
  set -u
  vendor/adevtool/bin/run generate-all -d "$DEVICE"
fi

# 3. PD-SVAK overlays must still match upstream resource names.
"$PDS_ROOT/build/check-overlays.sh"

# 4. Build the OS.
set +u; source build/envsetup.sh
lunch "${DEVICE}-${PDS_RELEASE}-${PDS_VARIANT}"
m vendorbootimage vendorkernelbootimage target-files-package
set -u

echo "Unsigned target-files are in: $PDS_SRC/out/target/product/$DEVICE/obj/PACKAGING/target_files_intermediates/"
echo "Move them to the offline signing machine and run build/sign-release.sh"
