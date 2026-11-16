#!/usr/bin/env bash
# Build or run PD-SVAK on the Android emulator, for fast testing of our layer without a phone.
# Usage: build/emulator.sh build      # images into $PDS_SRC/out/target/product/emu64x/
#        build/emulator.sh run [args] # start the emulator (WSLg/X11 window; add -no-window for headless)
# Needs /dev/kvm (on WSL: add yourself to the kvm group). Not a security target.
set -euo pipefail
source "$(dirname "$0")/config.sh"

mode="${1:-build}"; shift || true
[[ "$mode" == build ]] && "$PDS_ROOT/build/fetch-prebuilts.sh"

cd "$PDS_SRC"
# envsetup.sh, lunch, m and emulator reference unset variables, so keep -u off around them.
set +u
source build/envsetup.sh
lunch "pdsvak_emulator-${PDS_RELEASE}-userdebug"
case "$mode" in
  build) m ;;
  run)   [[ -r /dev/kvm && -w /dev/kvm ]] || pds_die "no access to /dev/kvm (sudo usermod -aG kvm \$USER, then restart WSL)"
         emulator -no-snapshot -gpu swiftshader_indirect "$@" ;;
  *)     pds_die "usage: emulator.sh build | run [emulator args]" ;;
esac
