# Building PD-SVAK

You need two machines:
- An online **build host**: x86_64 Linux, 64 GB RAM, 300+ GB NVMe.
- An air-gapped **signing machine**.

PD-SVAK builds on the GrapheneOS tree. Read https://grapheneos.org/build first; our scripts are thin wrappers around it.

## 1. Build host (online)
```bash
build/setup-host.sh          # install packages (Ubuntu 24.04 / Debian bookworm)
build/sync.sh                # repo init + sync GrapheneOS, add manifests/, apply patches/
build/build.sh shiba         # unsigned target-files for Pixel 8
                             #   (also runs fetch-prebuilts.sh and check-overlays.sh)
build/publish-kernel-source.sh shiba 2026122900   # GPL kernel source for the release
```

`build.sh` refuses any device that isn't a Gold-line `launch`/`next` device in `devices/devices.json`. Silver and Bronze devices are built by the AOSP line instead ([DEVICE-TIERS.md](DEVICE-TIERS.md)). Our branding, privacy defaults and preinstalled apps live in [vendor/pdsvak/](../vendor/pdsvak/README.md).

## 2. Signing machine (offline)
```bash
build/make-keys.sh shiba               # once per device, ever; then encrypt + back up
build/sign-release.sh shiba 2026122900 # factory images + OTA
python3 build/make-release-metadata.py sign --key "$PDS_KEYS/metadata.pem" \
  --codename shiba --build 2026122900 --channel beta \
  --image <factory zip> --avb-key "$PDS_KEYS/shiba/avb_pkmd.bin" \
  --base-url https://updates.pdsvak.example/releases --out releases/installer
```
`make-keys.sh` also creates the project-wide installer metadata key the first time it runs; put the printed public JWK into `installer/web/release-key.js`.

## 3. Flash and relock (test device)
```bash
fastboot flashing unlock
./flash-all.sh                       # from the signed factory image
fastboot erase avb_custom_key
fastboot flash avb_custom_key avb_pkmd.bin
fastboot flashing lock
```
The phone should boot with a yellow notice that shows **our** key hash. Check that it matches the published `avb_pkmd.sha256`.

## Patch workflow
- **Layout:** our changes live in `patches/<project path>/NNNN-*.patch`. Prefer overlays in `vendor/pdsvak/` when a resource will do. Otherwise edit the project in the tree and run `build/new-patch.sh <project path> "<description>"`.
- **When a new GrapheneOS stable tag lands:** the `rebase-assistant` agent re-applies the patches with `build/apply-patches.sh` and opens draft PRs for any conflicts. A human reviews and merges them.

## Reproducible builds
For an official build, set `BUILD_DATETIME`, `BUILD_NUMBER` and `OFFICIAL_BUILD=true`. Anyone with the same source and keys should get bit-identical outputs, apart from the signatures.
