#!/usr/bin/env bash
# Shared configuration for PD-SVAK build scripts. Source this file; don't execute it.

# Upstream GrapheneOS manifest. Track the development branch, or pin a stable tag for releases.
export PDS_MANIFEST_URL="${PDS_MANIFEST_URL:-https://github.com/GrapheneOS/platform_manifest.git}"
export PDS_MANIFEST_BRANCH="${PDS_MANIFEST_BRANCH:-17}"

# Where the full source tree lives on the build host. Needs about 300+ GB free.
export PDS_SRC="${PDS_SRC:-$HOME/pdsvak/src}"

# Repo root of this project. Resolved from this file's location.
export PDS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Build variant. Release builds are always "user".
export PDS_VARIANT="${PDS_VARIANT:-user}"

# Release config prefix used by the GrapheneOS lunch targets.
# VERIFY against https://grapheneos.org/build for the current branch.
export PDS_RELEASE="${PDS_RELEASE:-cur}"

# Pin these for reproducible builds. Leave them empty for dev builds.
export BUILD_DATETIME="${BUILD_DATETIME:-}"
export BUILD_NUMBER="${BUILD_NUMBER:-}"

# Signing keys live OFFLINE. This path is used only on the air-gapped signing machine.
export PDS_KEYS="${PDS_KEYS:-$HOME/pdsvak/keys}"

pds_die() { echo "error: $*" >&2; exit 1; }
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
