#!/usr/bin/env bash
# Generate release and AVB keys for one device. RUN ONLY ON THE AIR-GAPPED SIGNING MACHINE.
# Usage: build/make-keys.sh <codename>
# Afterwards, encrypt the keys (GrapheneOS script/encrypt-keys) and make 2 offline backups.
# See docs/GOVERNANCE.md. Keys can never be rotated without wiping every user's device.
set -euo pipefail
source "$(dirname "$0")/config.sh"
DEVICE="${1:?usage: make-keys.sh <codename>}"

if ip route 2>/dev/null | grep -q default; then
  pds_die "this machine has a network route; generate keys on an air-gapped host"
fi

OUT="$PDS_KEYS/$DEVICE"
[[ -e "$OUT" ]] && pds_die "$OUT already exists; refusing to overwrite keys"
mkdir -p "$OUT"; cd "$OUT"

CN="${PDS_KEY_CN:-PD-SVAK}"
SUBJ="/CN=$CN/"
for k in releasekey platform shared media networkstack bluetooth sdk_sandbox nfc; do
  # make_key prompts for a key passphrase and can exit non-zero even on success, so check the output files.
  "$PDS_SRC/development/tools/make_key" "$k" "$SUBJ" || true
  [[ -f "$k.pk8" && -f "$k.x509.pem" ]] || pds_die "failed to create key $k"
done

openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out avb.pem
"$PDS_SRC/external/avb/avbtool.py" extract_public_key --key avb.pem --output avb_pkmd.bin

ssh-keygen -t ed25519 -f id_ed25519 -C "$CN factory images $DEVICE"

sha256sum avb_pkmd.bin | tee avb_pkmd.sha256

# One project-wide key signs the installer's release metadata (build/make-release-metadata.py).
if [[ ! -f "$PDS_KEYS/metadata.pem" ]]; then
  echo ">> creating the release-metadata signing key (asks for a passphrase)"
  openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -aes-256-cbc -out "$PDS_KEYS/metadata.pem"
  python3 "$PDS_ROOT/build/make-release-metadata.py" pubjwk --key "$PDS_KEYS/metadata.pem" \
    | tee "$PDS_KEYS/metadata.pub.jwk"
  echo ">> put metadata.pub.jwk (public) into installer/web/release-key.js"
fi
echo "Done. Publish ONLY avb_pkmd.sha256 and the public keys. Encrypt this directory now."
