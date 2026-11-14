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
```

## 2. Signing machine (offline)
```bash
build/make-keys.sh shiba               # once per device, ever; then encrypt + back up
build/sign-release.sh shiba 2026122900 # factory images + OTA
```

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
- **Layout:** our changes live in `patches/<project path>/NNNN-*.patch`. Create them with `git format-patch` inside the project in the source tree.
- **When a new GrapheneOS stable tag lands:** the `rebase-assistant` agent re-applies the patches with `build/apply-patches.sh` and opens draft PRs for any conflicts. A human reviews and merges them.

## Reproducible builds
For an official build, set `BUILD_DATETIME`, `BUILD_NUMBER` and `OFFICIAL_BUILD=true`. Anyone with the same source and keys should get bit-identical outputs, apart from the signatures.
