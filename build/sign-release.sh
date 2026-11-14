#!/usr/bin/env bash
# Sign a release and produce factory images plus a full OTA. Runs on the OFFLINE signing machine.
# Usage: build/sign-release.sh <codename> <build_number>
# Wraps GrapheneOS script/generate-release.sh. VERIFY its argument order upstream before use.
set -euo pipefail
source "$(dirname "$0")/config.sh"
DEVICE="${1:?codename}"; BUILD="${2:?build number}"

[[ -d "$PDS_KEYS/$DEVICE" ]] || pds_die "no keys for $DEVICE at $PDS_KEYS/$DEVICE"

cd "$PDS_SRC"
ln -sfn "$PDS_KEYS" keys
script/generate-release.sh "$DEVICE" "$BUILD"

echo "Release artifacts are in: $PDS_SRC/releases/$BUILD/release-$DEVICE-$BUILD/"
echo "For deltas, run script/generate-delta.sh against the previous release."
echo "Copy ONLY the signed outputs off this machine (never keys/)."
