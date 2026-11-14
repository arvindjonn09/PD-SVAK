// Public key that signs release metadata (ECDSA P-256, JWK). Public only: the private key stays offline.
// Must be filled in after the key ceremony (ROADMAP week 2). While it is null, the installer refuses to download.
export const RELEASE_METADATA_KEY = null;

// Where release metadata lives: <base>/<channel>/<codename>.json and <codename>.json.sig
// The .sig file is a base64 raw (IEEE P1363) ECDSA-P256-SHA256 signature over the exact JSON bytes.
export const METADATA_BASE = "https://updates.pdsvak.example/installer";
export const CHANNEL = "stable";
