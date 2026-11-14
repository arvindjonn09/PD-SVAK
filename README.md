# PD-SVAK

**A privacy-first, security-hardened mobile OS that runs Android apps. Anyone can install it from a browser, and you install whatever apps you want.**

> Status: **pre-alpha / planning**. Target: public **Developer Preview by 2026-12-31** on Pixel 8 and 9 series phones.
> PD-SVAK is a working codename. It is not affiliated with Google, and "Android" is a trademark of Google LLC.

## What it is

- **Secure by default.** Your own verified-boot keys with a **relocked bootloader**, a hardened memory allocator and MTE, USB-C port lockdown, an auto-reboot timer, and monthly patches within 72 h.
- **Private by default.** No Google apps or telemetry. Network and Sensors permissions apply per app. Connectivity checks, time sync and location assistance (NTP/SUPL) go through privacy proxies, and encrypted DNS is on.
- **Your apps, your choice.** Accrescent comes preinstalled. F-Droid installs in one tap. **Sandboxed** Google Play is optional and can run in its own profile. There is no sideloading gate.
- **Easy to install.** A browser-based (WebUSB) one-click installer, plus a CLI fallback.

## How it is built

PD-SVAK is a **downstream of [GrapheneOS](https://grapheneos.org)**, fully rebranded. We add UX, compatibility and ecosystem work on top. The reasoning is in [docs/STRATEGY.md](docs/STRATEGY.md).

## Documents

| Doc | What |
|---|---|
| [STRATEGY.md](docs/STRATEGY.md) | Decisions, rules and risks |
| [IDEAS.md](docs/IDEAS.md) | Ranked differentiating ideas |
| [ROADMAP.md](docs/ROADMAP.md) | Week-by-week plan to Dec 31, then a 6-month plan |
| [PRODUCT-DECISIONS.md](docs/PRODUCT-DECISIONS.md) | How the OS behaves out of the box: apps, defaults, updates |
| [BUILD-HOST.md](docs/BUILD-HOST.md) | Build server hardware and setup |
| [DEVICE-TIERS.md](docs/DEVICE-TIERS.md) | Device security tiers: Gold / Silver / Bronze |
| [SECURITY-FEATURES.md](docs/SECURITY-FEATURES.md) | Feature tiers (MVP / v1.1 / later) |
| [GOVERNANCE.md](docs/GOVERNANCE.md) | Key custody, releases, funding, legal checklist |
| [AGENTS.md](docs/AGENTS.md) | Multi-agent research and engineering workflow |
| [docs/research/](docs/research/) | Raw findings from the five research units, with sources |
| [docs/BUILDING.md](docs/BUILDING.md) | How to build |

## Repository layout

```
build/      host setup, sync, build, sign, release scripts (Linux build host)
devices/    supported device list
patches/    our patch set applied on top of the GrapheneOS tree
manifests/  local repo manifest additions
installer/  WebUSB installer (planned)
.claude/agents/  AI engineering agents (ASB tracker, rebase, triage, audit, docs)
.github/    CI workflows and issue forms
```

## Supported devices

The aim is to bring PD-SVAK to as many Android phones as possible, each one as secure as its hardware allows. Every device has a **security tier** (Gold / Silver / Bronze) that says exactly what it protects against. See [docs/DEVICE-TIERS.md](docs/DEVICE-TIERS.md).

- **Developer Preview (Gold):** Pixel 8, 8 Pro, 8a, 9, 9 Pro, 9 Pro XL, 9 Pro Fold and 9a. The Pixel 10 series follows in early 2027.
- **2027:** Fairphone 5 (Silver), then Galaxy S24 / S25 international models and A55 (Bronze), then more by demand.

The full list is in [devices/devices.json](devices/devices.json).

## Credits

PD-SVAK builds on GrapheneOS, AOSP, Seedvault, Accrescent, F-Droid and others. See [docs/research/01-landscape.md](docs/research/01-landscape.md).
