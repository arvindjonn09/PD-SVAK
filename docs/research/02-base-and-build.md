# Research Unit 2: Base choice and build tooling (2026-11-14)

## AOSP state
- **Development:** Trunk-based and internal since 2025, with source drops twice a year (Q2/Q4) since 2026. Use the `android-latest-release` manifest.
- **Latest release:** Android 17, released 2026-06-16 (`android17-release`).
- **QPR1:** Sept 2026, Pixel-only and not in AOSP. QPR2 is expected in Dec 2026 [U].
- **Pixel device trees:** Gone since Android 16. Google now points to Cuttlefish as the reference target. GrapheneOS generates the trees with adevtool.

## Base options
| Option | Verdict |
|---|---|
| Raw AOSP | You would have to rebuild device support yourself. Not feasible in 6 weeks. |
| **GrapheneOS fork** | **Recommended.** Strongest hardening, Pixel 6–10a support, signing, OTA, delta and reproducible builds already exist. It must be fully rebranded, and it ties us to their rebase cadence. |
| LineageOS | Broad device support, but a weak security model (unlocked bootloaders, userdebug-style builds). |
| GSI (TrebleDroid, etc.) | Cannot relock the bootloader and inherits stale vendor patches. Not suitable for a secure product. |

## Build requirements
- **AOSP's stated minimums:** x86_64 Linux, 64 GB RAM or more, 400 GB disk or more.
- **GrapheneOS guide:** 32 GiB RAM or more, 100 GiB plus 90–136 GiB for the sync. Debian bookworm, Ubuntu 24.04 or Arch.
- **adevtool:** needs Node 24 and yarn.
- **Build system:** Soong + Kati. Kernels build with Kleaf (Bazel). Platform Bazel appears stalled [U].
- **CI:**
  - Standard GitHub-hosted runners are too small.
  - Use a self-hosted bare-metal box (16–32 cores, 128 GB RAM, 2–4 TB NVMe; €100–250/mo [U]).
  - Expect about 1.5–3 h per clean multi-device build [estimate].
- **Reproducible builds:** pin `BUILD_DATETIME` and `BUILD_NUMBER`, and set `OFFICIAL_BUILD=true`.

## Signing and relock
- **Release keys:** generate with `development/tools/make_key`. Keep one set per device and encrypt them (GrapheneOS `script/encrypt-keys`).
- **AVB key:** an RSA-4096 key. Set it up and relock with:
  1. `avbtool extract_public_key` → `fastboot flash avb_custom_key pkmd.bin`
  2. `fastboot flashing lock`
- **Boot result:** the device boots with the yellow "SelfSigned" screen and keeps full verified boot, rollback protection and attestation.
- **Keys can't change without a wipe,** so key custody has to be settled on day 1.

## OTA
- **Mechanism:** update_engine with A/B partitions; payloads come from `ota_from_target_files`.
- **GrapheneOS tooling:** `generate-release.sh`, `generate-delta.sh`, a static update server with per-channel metadata, and the Updater app (repoint its URL in `res/values/config.xml`).
- **Hosting:** a static CDN (R2/S3 + CDN) with signed metadata.

## Kernels
- **GKI:** generic kernel plus vendor modules.
- **GrapheneOS kernel branches:** `kernel_pixel_6.1` covers Pixel 6–9 and 10a; `kernel_pixel` branch `17-muzel` covers Pixel 10.
- **Plan:** inherit GrapheneOS's kernel and don't do custom kernel work in the 6-week window.

## Rust
- **Support:** a first-class Soong language.
- **Policy:** write any new system daemons in Rust, using AIDL Rust bindings.

## Sources
- https://source.android.com/docs/whatsnew/android-17-release
- https://www.androidauthority.com/aosp-source-code-schedule-3630018/
- https://androidauthority.com/grapheneos-android-17-qpr1-security-patches-comments-3712218
- https://grapheneos.org/build
- https://source.android.com/docs/setup/start/requirements
- https://source.android.com/docs/security/features/verifiedboot/device-state
- https://github.com/GrapheneOS/platform_packages_apps_Updater
- https://source.android.com/docs/core/architecture/kernel/generic-kernel-image
