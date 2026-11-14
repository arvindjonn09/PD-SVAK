# PD-SVAK Strategy (decided 2026-11-14)

This is the synthesis of five parallel research units (see `docs/research/`). It is the
"what we build and why" document. Every decision here has a reason; change the decision
only by changing the reason.

## TL;DR

| Decision | Choice | Why |
|---|---|---|
| Base | **Downstream of GrapheneOS** (`17` branch / stable tags), fully rebranded | Best security model available, MIT/Apache, already solves Pixel bring-up after Google removed Pixel trees from AOSP (Jun 2025). Raw AOSP bring-up is impossible in 6 weeks. |
| Devices | **Pixel 8 / 8 Pro / 8a, Pixel 9 / 9 Pro / 9 Pro XL / 9a** at launch; Pixel 10 series next | Relockable with custom AVB keys, MTE, StrongBox, Weaver, support to 2030–2032. |
| Google apps | **Never bundled.** Optional *sandboxed* Google Play (unprivileged, per profile), off by default | Keeps privilege model intact; best app/banking compatibility. microG needs signature spoofing → rejected as default. |
| App freedom | Preinstall **Accrescent**; one-tap **F-Droid** in setup wizard; optional sandboxed Play; **no** Google developer-verification gate in our PackageInstaller | "Install whatever you want" — sideloading stays a per-installer prompt with no waiting period. |
| Installer | **WebUSB browser installer** (fork of MIT `fastboot.js`, UX modelled on GrapheneOS web installer) + Go CLI fallback (from CalyxOS `device-flasher`, Apache-2.0) | Anyone with Chrome/Edge can install. Bootloader **must** be relocked with our AVB key — never leave users unlocked. |
| Updates | A/B seamless OTA + deltas, Alpha/Beta/Stable channels, static CDN with signed metadata | Proven model; cheap to host. |
| Differentiation | UX, compatibility, migration, transparency — **not** competing on raw hardening | A small team cannot out-harden GrapheneOS; it *can* out-serve users on banking, migration and onboarding. |
| First release | **Public Developer Preview by 2026-12-31**; Stable 1.0 ~Q1 2027 | 6 weeks is enough for a signed, relockable, rebranded, OTA-updating build — not for a "1.0" security promise. |

## Why not the alternatives

- **Raw AOSP:** No Pixel device trees, blobs or kernel history since Android 16. Source drops are twice a year (Q2/Q4), and Android 17 QPR1 never reached AOSP. You would have to rebuild adevtool before anything else.
- **LineageOS base:** It supports 177 devices, but builds are userdebug-style, many use test keys, and the bootloader usually stays unlocked. Bringing it up to our security bar costs more than starting from GrapheneOS.
- **GSI (Treble generic image):** It can't relock with our keys on most devices, and vendor/kernel patch levels stay whatever the OEM shipped. Fine for hobbyists, not as a secure product.
- **/e/OS / iodéOS model:** It lags a full Android version behind, leaves bootloaders unlocked, and its Play-scraping store weakens the privacy claim.

## Hard rules (non-negotiable)

1. Relocked bootloader with our own AVB key on every supported device. No device ships unless it can relock.
2. Monthly security release within **72 h** of the Pixel/Android bulletin, plus out-of-band emergency releases.
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
| Upstream relationship friction | Be a good downstream: rebrand fully, don't use their servers, credit them, upstream fixes. |
