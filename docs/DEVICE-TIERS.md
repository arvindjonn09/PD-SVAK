# Device security tiers (decided 2026-11-14)

**Goal:** PD-SVAK on as many Android phones as possible, each one as secure as its hardware allows, and **honest about the difference**.

Security on a phone depends partly on hardware and on the bootloader the manufacturer ships, which no OS can change. So every device gets a security tier, shown in the installer, on the download page, and in Settings → About phone.

## Tiers

| Tier | Requirements | What it protects against | Base |
|---|---|---|---|
| **Gold** | Relocks with our AVB key; hardware memory tagging (MTE); secure element that throttles PIN guessing (Weaver/StrongBox); vendor firmware updated monthly; at least 4 years of vendor support left | Remote exploits, malicious apps, telemetry, **and** an attacker with the phone in hand (theft, border search, forensic tools) | GrapheneOS downstream |
| **Silver** | Relocks with our AVB key; vendor firmware still supported. Missing at least one other Gold requirement | Remote exploits, malicious apps, telemetry, and casual physical tampering. **Weaker** against forensic extraction | PD-SVAK AOSP line (our own device builds) |
| **Bronze** | Bootloader unlocks but **cannot relock** with our key | Telemetry, malicious apps, OS-level remote exploits (patched monthly). **No protection** against someone with the phone in hand: they can replace the OS | PD-SVAK AOSP line (LineageOS-style device builds) |
| **None** | Bootloader cannot be unlocked (US carrier models, US Samsung Snapdragon models, etc.) | Not installable. The installer says why | None |

## Rules

1. **The tier is always visible.** The installer shows it before anything is erased. Settings → About phone shows it for the whole time the phone runs PD-SVAK. Bronze phones also show a one-time setup screen explaining the physical-access risk.
2. **No tier inflation.** Marketing, docs and release notes never describe a Silver or Bronze phone with Gold claims. A device's tier only goes up if it passes every check for the new tier on real hardware.
3. **Gold comes first.** Gold devices get patches within 72 h. Silver/Bronze patches follow within 7 days of the bulletin, because their device builds depend on vendor kernel and firmware releases.
4. **End of support.** When the vendor stops shipping firmware, a device drops to Bronze at most and is marked end-of-life 6 months later.
5. **Device count follows maintainers.** Each Silver/Bronze device needs a named maintainer with the hardware. No maintainer, no release.
6. **Dev devices.** A phone with release status `dev` in `devices/devices.json` is a maintainer's test device for bringing up a line, for example an end-of-life phone with mature LineageOS device code. It is built and tested, but never published, never offered by the installer, and never counted as supported. The first one is the Galaxy S20 5G (SM-G981B, `x1s`), used to bring up the AOSP line.

## Two OS lines, one product

- **Gold line:** rebranded GrapheneOS plus `patches/`. Pixel only for now.
- **AOSP line:** our own build from AOSP with per-device trees, kernels and vendor extraction, starting from LineageOS device trees where licenses allow. The PD-SVAK patch set is ported to it (branding, privacy proxies, Accrescent, F-Droid one-tap, no Google apps). GrapheneOS-only hardening (hardened_malloc, sandboxed Play, Network/Sensors permissions) is ported only where its license and design allow; each port is listed in the release notes.

## Rollout

| When | What |
|---|---|
| 2026-12-31 | Developer Preview: **Gold only** (Pixel 8/9 series) |
| Q1 2027 | AOSP line build system, brought up first on the Galaxy S20 dev device; then the first Silver device (Fairphone 5) |
| Q2 2027 | First Bronze devices: Galaxy S24/S25 international (Exynos/SM-xxxB) and A55 |
| H2 2027 | Grow to the 10 most-requested devices, depending on maintainers and funding |
