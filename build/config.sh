#!/usr/bin/env bash
# Shared configuration for PD-SVAK build scripts. Source this file; don't execute it.

# Upstream GrapheneOS manifest. Track the development branch, or pin a stable tag for releases.
export PDS_MANIFEST_URL="${PDS_MANIFEST_URL:-https://github.com/GrapheneOS/platform_manifest.git}"
export PDS_MANIFEST_BRANCH="${PDS_MANIFEST_BRANCH:-17}"

# Optional: PDS_REPO_DEPTH=1 makes build/sync.sh skip git history (saves ~100 GB of disk).
# Optional: PDS_SYNC_JOBS=4 lowers parallel fetches if Google's servers return HTTP 429.

# Where the full source tree lives on the build host. Needs about 300+ GB free.
export PDS_SRC="${PDS_SRC:-$HOME/pdsvak/src}"

# AOSP line (Silver/Bronze devices, e.g. the Galaxy S20 dev device): a separate LineageOS-based
# tree, because those devices have no GrapheneOS support. Built by build/aosp-sync.sh and
# build/aosp-build.sh. See docs/DEVICE-TIERS.md.
export PDS_AOSP_SRC="${PDS_AOSP_SRC:-$HOME/pdsvak/aosp}"
export PDS_AOSP_MANIFEST_URL="${PDS_AOSP_MANIFEST_URL:-https://github.com/LineageOS/android.git}"
export PDS_AOSP_BRANCH="${PDS_AOSP_BRANCH:-lineage-24.0}"

# Repo root of this project. Resolved from this file's location.
PDS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PDS_ROOT

# Build variant. Release builds are always "user".
export PDS_VARIANT="${PDS_VARIANT:-user}"

# Release config prefix used by the GrapheneOS lunch targets.
# VERIFY against https://grapheneos.org/build for the current branch.
export PDS_RELEASE="${PDS_RELEASE:-cur}"

# Pin these for reproducible builds. Leave them empty for dev builds.
# Exported only when set: an exported empty BUILD_NUMBER stops Soong from writing
# out/soong/build_number.txt (LineageOS builds then fail; GrapheneOS's envsetup sets both).
[[ -n "${BUILD_DATETIME:-}" ]] && export BUILD_DATETIME || unset BUILD_DATETIME
[[ -n "${BUILD_NUMBER:-}" ]] && export BUILD_NUMBER || unset BUILD_NUMBER

# Signing keys live OFFLINE. This path is used only on the air-gapped signing machine.
export PDS_KEYS="${PDS_KEYS:-$HOME/pdsvak/keys}"

pds_die() { echo "error: $*" >&2; exit 1; }

# WSL: Windows drives under /mnt/<letter> are slow and case-insensitive, which breaks the tree.
for _d in "$PDS_SRC" "$PDS_AOSP_SRC"; do
  case "$_d" in
    /mnt/[a-zA-Z]|/mnt/[a-zA-Z]/*)
      pds_die "$_d is on a Windows drive. Use a path inside the Linux disk, e.g. ~/pdsvak/src (docs/BUILD-HOST.md)" ;;
  esac
done
unset _d
pds_need() { command -v "$1" >/dev/null 2>&1 || pds_die "missing tool: $1"; }

# Die unless $1 is a launch/next device on the Gold (GrapheneOS) line in devices/devices.json.
# Silver/Bronze devices are built by the separate AOSP line, not by these scripts.
pds_require_gold_device() {
  pds_need python3
  python3 - "$1" "$PDS_ROOT/devices/devices.json" <<'PY' || exit 1
import json, sys
name, path = sys.argv[1], sys.argv[2]
d = next((x for x in json.load(open(path))["devices"] if x["codename"] == name), None)
if d is None:
    sys.exit(f"error: unknown device {name} (not in devices/devices.json)")
if d.get("line") != "gold" or d.get("tier") not in ("launch", "next"):
    sys.exit(f"error: {name} is tier '{d.get('tier')}', security '{d.get('security')}', line '{d.get('line')}'. "
             "These scripts build only Gold-line launch/next devices.")
PY
}

# For the AOSP line: die unless $1 is a line "aosp" device that isn't tier "no"; print its
# security tier (silver|bronze). Dev and planned devices build locally but are never published.
pds_require_aosp_device() {
  pds_need python3
  python3 - "$1" "$PDS_ROOT/devices/devices.json" <<'PY' || exit 1
import json, sys
name, path = sys.argv[1], sys.argv[2]
d = next((x for x in json.load(open(path))["devices"] if x["codename"] == name), None)
if d is None:
    sys.exit(f"error: unknown device {name} (not in devices/devices.json)")
if d.get("line") != "aosp" or d.get("tier") == "no":
    sys.exit(f"error: {name} is line '{d.get('line')}', tier '{d.get('tier')}'. "
             "The AOSP-line scripts build only line 'aosp' devices.")
print(d["security"])
PY
}
