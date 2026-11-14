#!/usr/bin/env python3
"""Signed release metadata for the web installer. Runs on the OFFLINE signing machine.

  sign    write <out>/<channel>/<codename>.json and .json.sig for one release
  pubjwk  print the metadata public key as JWK, for installer/web/release-key.js

  make-release-metadata.py sign --key $PDS_KEYS/metadata.pem --codename shiba --build 2026122900 \\
      --channel beta --image shiba-factory-2026122900.zip --avb-key $PDS_KEYS/shiba/avb_pkmd.bin \\
      --base-url https://updates.pdsvak.example/releases --out releases/installer
  make-release-metadata.py pubjwk --key $PDS_KEYS/metadata.pem

The signature is ECDSA P-256 / SHA-256 over the exact JSON bytes, stored as base64 of the raw
r||s form (IEEE P1363), which is what the browser's WebCrypto verify() expects.
Needs only openssl and the Python standard library.
"""
import argparse
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def openssl(*args, data=None):
    return subprocess.run(["openssl", *args], input=data, capture_output=True, check=True).stdout


def der_sig_to_raw(der, size=32):
    """ECDSA-Sig-Value ::= SEQUENCE { r INTEGER, s INTEGER }  ->  r||s, fixed width."""
    if der[0] != 0x30:
        raise ValueError("not a DER sequence")
    i = 2 if der[1] < 0x80 else 2 + (der[1] & 0x7F)
    out = b""
    for _ in range(2):
        if der[i] != 0x02:
            raise ValueError("expected DER integer")
        n = der[i + 1]
        val = der[i + 2:i + 2 + n].lstrip(b"\0")
        if len(val) > size:
            raise ValueError("integer too large for curve")
        out += val.rjust(size, b"\0")
        i += 2 + n
    return out


def b64url(b):
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode()


def cmd_pubjwk(a):
    spki = openssl("pkey", "-in", a.key, "-pubout", "-outform", "DER")
    point = spki[-65:]
    if point[0] != 0x04:
        raise SystemExit("error: not an uncompressed P-256 public key")
    jwk = {"kty": "EC", "crv": "P-256", "x": b64url(point[1:33]), "y": b64url(point[33:]), "ext": True}
    print(json.dumps(jwk))


def cmd_sign(a):
    if not re.fullmatch(r"\d{10}", a.build):
        raise SystemExit("error: --build must be 10 digits (YYYYMMDDNN)")
    if a.channel not in ("alpha", "beta", "stable"):
        raise SystemExit("error: --channel must be alpha, beta or stable")
    image, avb = Path(a.image), Path(a.avb_key)
    base = a.base_url.rstrip("/")
    meta = {
        "codename": a.codename,
        "build": a.build,
        "channel": a.channel,
        "image_url": f"{base}/{a.build}/{image.name}",
        "image_sha256": sha256_file(image),
        "image_size": image.stat().st_size,
        "avb_key_url": f"{base}/{a.build}/{a.codename}-avb_pkmd.bin",
        "avb_key_sha256": sha256_file(avb),
    }
    body = (json.dumps(meta, indent=2, sort_keys=True) + "\n").encode()
    raw = der_sig_to_raw(openssl("dgst", "-sha256", "-sign", a.key, data=body))

    out = Path(a.out) / a.channel
    out.mkdir(parents=True, exist_ok=True)
    (out / f"{a.codename}.json").write_bytes(body)
    (out / f"{a.codename}.json.sig").write_text(base64.b64encode(raw).decode() + "\n")
    print(f"wrote {out}/{a.codename}.json(.sig)")
    print(f"upload {image.name} and {avb.name} (as {a.codename}-avb_pkmd.bin) to {base}/{a.build}/")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("sign")
    for opt in ("--key", "--codename", "--build", "--channel", "--image", "--avb-key", "--base-url", "--out"):
        s.add_argument(opt, required=True)
    p = sub.add_parser("pubjwk")
    p.add_argument("--key", required=True)
    a = ap.parse_args()
    try:
        {"sign": cmd_sign, "pubjwk": cmd_pubjwk}[a.cmd](a)
    except subprocess.CalledProcessError as e:
        sys.exit(f"error: openssl failed: {e.stderr.decode().strip()}")


if __name__ == "__main__":
    main()
