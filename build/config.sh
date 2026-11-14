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
