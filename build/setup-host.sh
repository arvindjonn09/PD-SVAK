#!/usr/bin/env bash
# Prepare an Ubuntu 24.04 / Debian bookworm x86_64 build host.
# Requirements: 32+ GiB RAM (64+ recommended) and 300+ GB free disk on fast NVMe.
set -euo pipefail
source "$(dirname "$0")/config.sh"

[[ "$(uname -m)" == "x86_64" ]] || pds_die "AOSP builds need an x86_64 Linux host"

sudo apt-get update
sudo apt-get install -y \
  git git-lfs repo curl unzip zip rsync python3 python3-protobuf \
  openssl libssl-dev signify-openbsd e2fsprogs \
  ccache build-essential fontconfig

# Node.js 24 and yarn are needed by adevtool (vendor extraction).
if ! command -v node >/dev/null || [[ "$(node -v | cut -d. -f1 | tr -d v)" -lt 24 ]]; then
  echo ">> Install Node.js 24 (e.g. from nodejs.org or NodeSource), then re-run."
fi
command -v yarn >/dev/null || echo ">> Install yarn: sudo npm install -g yarn"

git config --global user.name  >/dev/null || echo ">> set git user.name"
git config --global user.email >/dev/null || echo ">> set git user.email"

mkdir -p "$PDS_SRC"
echo "Host ready. Next: build/sync.sh"
