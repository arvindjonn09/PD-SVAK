#!/usr/bin/env bash
# Package the exact kernel source used for a release, as GPL-2.0 requires.
# Runs on the build host. Needs no keys.
# Usage: build/publish-kernel-source.sh <codename> <build_number>
#
# Expects a kernel tree synced from the GrapheneOS kernel manifest for the device's
# kernel family (see https://grapheneos.org/build#kernel), at $PDS_KERNEL_SRC/<family>.
# VERIFY the family names and manifest repos upstream before each release.
#
# Output in $PDS_ROOT/releases/<build>/kernel-source/:
#   kernel-<family>-<build>.tar.gz     source tree, without .git, out/ or prebuilt toolchains
#   kernel-<family>-<build>.xml        repo manifest pinned to exact commits
#   SHA256SUMS
# Upload that directory next to the release images, and push the printed tags.
set -euo pipefail
source "$(dirname "$0")/config.sh"

DEVICE="${1:?usage: publish-kernel-source.sh <codename> <build_number>}"
BUILD="${2:?usage: publish-kernel-source.sh <codename> <build_number>}"
[[ "$BUILD" =~ ^[0-9]{10}$ ]] || pds_die "build number must be 10 digits (YYYYMMDDNN), got: $BUILD"
pds_require_gold_device "$DEVICE"

case "$DEVICE" in
  shiba|husky|akita)                family=zuma ;;
  tokay|caiman|komodo|comet|tegu)   family=zumapro ;;
  *) pds_die "no kernel family mapped for $DEVICE yet. Add it here once its kernel manifest is confirmed." ;;
esac

pds_need repo
pds_need tar
pds_need sha256sum

KSRC="${PDS_KERNEL_SRC:-$HOME/pdsvak/kernel}/$family"
[[ -d "$KSRC/.repo" ]] || pds_die "no repo checkout at $KSRC (sync the $family kernel manifest first)"

OUT="$PDS_ROOT/releases/$BUILD/kernel-source"
mkdir -p "$OUT"
base="kernel-$family-$BUILD"

cd "$KSRC"

# The published source must be exactly what was built: refuse local changes.
# shellcheck disable=SC2016  # expanded by repo forall, not here
dirty="$(repo forall -c 'if [ -n "$(git status --porcelain)" ]; then echo "$REPO_PATH"; fi')"
if [[ -n "$dirty" && "${PDS_ALLOW_DIRTY:-0}" != 1 ]]; then
  echo "$dirty" >&2
  pds_die "uncommitted changes in the projects above. Commit them, or set PDS_ALLOW_DIRTY=1 for a test run."
fi

echo ">> pinned manifest"
repo manifest -r -o "$OUT/$base.xml"

echo ">> source tarball (this takes a while)"
# Deterministic archive: fixed order, owner and mtime, so the same tree gives the same hash.
mtime="${BUILD_DATETIME:-$(date -u +%s)}"
tar --create --gzip --file "$OUT/$base.tar.gz" \
  --exclude-vcs --exclude=./.repo --exclude=./out --exclude=./prebuilts \
  --sort=name --owner=0 --group=0 --numeric-owner --mtime="@$mtime" \
  --transform "s,^\.,$base," \
  .

(cd "$OUT" && sha256sum "$base.tar.gz" "$base.xml" > SHA256SUMS)

tag="pdsvak-$BUILD"
echo ">> local tag $tag in every kernel project"
repo forall -c "git tag -f $tag HEAD >/dev/null"

cat <<EOF

Kernel source for $DEVICE ($family), build $BUILD:
  $OUT
Next steps (manual, needs network and push access):
  1. Upload $OUT/* next to the release images.
  2. Push the tags to our kernel mirrors:  repo forall -c 'git push <our-remote> $tag'
  3. Link both from the release notes.
EOF
