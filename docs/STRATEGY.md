# PD-SVAK Strategy (decided 2026-11-14)

This is the synthesis of five parallel research units (see `docs/research/`). It is the
"what we build and why" document. Every decision here has a reason; change the decision
only by changing the reason.

## TL;DR

| Decision | Choice | Why |
|---|---|---|
| Goal | **As many Android phones as possible, each as secure as its hardware allows**, with security tiers (Gold / Silver / Bronze) shown honestly, see `DEVICE-TIERS.md` | Security depends partly on hardware and the vendor's bootloader. One OS can reach every phone; it can't give every phone the same protection. |
| Base | **Gold:** downstream of GrapheneOS (`17` branch / stable tags), fully rebranded. **Silver/Bronze:** our own AOSP line with per-device builds (from 2027) | GrapheneOS is the best security model available and already solves Pixel bring-up after Google removed Pixel trees from AOSP (Jun 2025). It only supports Pixels, so other phones need our own line. |
| Devices | **Preview (Gold):** Pixel 8 / 8 Pro / 8a, Pixel 9 / 9 Pro / 9 Pro XL / 9 Pro Fold / 9a; Pixel 10 series next. **2027:** Fairphone 5 (Silver), Galaxy S24/S25/A55 international (Bronze), then more by demand | Pixels relock with custom AVB keys and have MTE, StrongBox and Weaver, with support to 2030–2032. Others are added as maintainers and hardware allow. |
| Google apps | **Never bundled.** Optional *sandboxed* Google Play (unprivileged, per profile), off by default | Keeps privilege model intact; best app/banking compatibility. microG needs signature spoofing → rejected as default. |
| App freedom | Preinstall **Accrescent**; one-tap **F-Droid** in setup wizard; optional sandboxed Play; **no** Google developer-verification gate in our PackageInstaller | "Install whatever you want" — sideloading stays a per-installer prompt with no waiting period. |
| Installer | **WebUSB browser installer** (fork of MIT `fastboot.js`, UX modelled on GrapheneOS web installer) + Go CLI fallback (from CalyxOS `device-flasher`, Apache-2.0) | Anyone with Chrome/Edge can install. Bootloader **must** be relocked with our AVB key — never leave users unlocked. |
| Updates | A/B seamless OTA + deltas, Alpha/Beta/Stable channels, static CDN with signed metadata | Proven model; cheap to host. |
| Differentiation | UX, compatibility, migration, transparency — **not** competing on raw hardening | A small team cannot out-harden GrapheneOS; it *can* out-serve users on banking, migration and onboarding. |
| First release | **Public Developer Preview by 2026-12-31**; Stable 1.0 ~Q1 2027 | 6 weeks is enough for a signed, relockable, rebranded, OTA-updating build — not for a "1.0" security promise. |

## Why not the alternatives

- **Raw AOSP:** No Pixel device trees, blobs or kernel history since Android 16. Source drops are twice a year (Q2/Q4), and Android 17 QPR1 never reached AOSP. You would have to rebuild adevtool before anything else.
- **LineageOS as the only base:** It supports 177 devices, but builds are userdebug-style, many use test keys, and the bootloader usually stays unlocked. Bringing it up to Gold costs more than starting from GrapheneOS. We do reuse its device trees for our Silver/Bronze AOSP line, with `user` builds and our own keys.
- **GSI (Treble generic image):** It can't relock with our keys on most devices, and vendor/kernel patch levels stay whatever the OEM shipped. Fine for hobbyists, not as a secure product.
- **/e/OS / iodéOS model:** It lags a full Android version behind, leaves bootloaders unlocked, and its Play-scraping store weakens the privacy claim.

## Hard rules (non-negotiable)

1. **Every device shows its security tier honestly** (`DEVICE-TIERS.md`). Any device that *can* relock with our AVB key ships relocked, and the installer never leaves it unlocked. Devices that can't relock ship only as Bronze, with the physical-access risk shown before install and in Settings. No Gold claims for non-Gold devices.
2. Monthly security release within **72 h** of the Pixel/Android bulletin for Gold devices, and within 7 days for Silver/Bronze. Plus out-of-band emergency releases.
3. Signing keys are offline (or in an HSM). **No agent, CI job or cloud machine ever touches them.**
4. No Google apps, no "Android" in the product name, kernel GPL source published per build.
5. Never point our builds at GrapheneOS update/proxy servers. Respect their rebrand requirement and attribute.
6. No Play Integrity spoofing (PlayIntegrityFix-style). Banking compatibility comes via hardware-attestation allowlisting only.
7. No preinstalled telemetry. CI captures first-boot network traffic and fails on unexpected hosts.

## Honest risks

| Risk | Mitigation |
|---|---|
| Android 17 QPR2 (expected Dec 2026) lands inside our release window | Budget a forced rebase in week 5–6. Ship preview on whatever GrapheneOS stable is current. |
| Google tightens further (more withheld source, Pixel lock-down) | Track GrapheneOS closely; pursue OEM partnership (Motorola-style) in 2027. |
| A rebranded GrapheneOS adds little security value | Our value is the differentiators in `IDEAS.md`. Upstream generic fixes to GrapheneOS where welcome. |
| Bus factor / funding (DivestOS shut down, CalyxOS stalled for a year, Copperhead key fight) | ≥2 people who can sign releases from day 1; governance + key custody written down (`GOVERNANCE.md`). |
| Lost or leaked signing key bricks the update path | Offline keys, encrypted, two geographic backups, documented ceremony. |
| Every Silver/Bronze device is ongoing work (device tree, kernel, monthly merges); too many devices for too few maintainers | One named maintainer with the hardware per device; no maintainer, no release. Start with the 5–10 most-requested models. |
| Users treat a Bronze phone as Gold-level secure | Tier shown in the installer, the setup wizard and Settings; no tier inflation in marketing. |
| Upstream relationship friction | Be a good downstream: rebrand fully, don't use their servers, credit them, upstream fixes. |
