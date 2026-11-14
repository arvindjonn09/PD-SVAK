# Security policy

## Reporting a vulnerability

**Do not open a public issue for a security problem.** Report it privately, using one of these:

- **GitHub private vulnerability reporting:** the "Report a vulnerability" button on this repository's **Security** tab.
- **Email:** `security@pdsvak.example`. This is a placeholder until the project domain is registered. Until then, use GitHub reporting.

Please include:

- The affected PD-SVAK build number (Settings → About phone → Build number) and device model.
- What an attacker can do, and what access they need first (remote, local app, physical, USB).
- Steps to reproduce, or a proof of concept.
- Whether the problem is also in upstream GrapheneOS or AOSP (see "Upstream issues" below).

## What happens next

| Step | Target time |
|---|---|
| We confirm we received the report | 2 business days |
| We triage it and tell you our severity assessment | 7 days |
| Fix shipped for Critical/High issues | Next monthly release, or an out-of-band release if it is actively exploited |
| Public advisory | When the fix ships, or 90 days after the report, whichever comes first |

- We follow **coordinated disclosure** with a 90-day default deadline. We can agree a different date with you if a fix needs more time or an upstream project is involved.
- We credit reporters in the advisory and release notes, unless you ask us not to.
- We do not currently run a paid bug bounty.

## Scope

**In scope:** code and configuration that PD-SVAK adds or changes:

- Our patch set (`patches/`), build and release scripts (`build/`), and signing process.
- The web installer and CLI installer (`installer/`).
- Our update server, update metadata and privacy proxies (connectivity check, NTP, SUPL, PSDS).
- Privacy regressions: a default install contacting a host not in [privacy/allowed-hosts.txt](privacy/allowed-hosts.txt).
- A PD-SVAK release that fails to relock, or that verifies with a key other than our published fingerprint.

**Out of scope:**

- Apps that users install themselves, including sandboxed Google Play.
- Attacks that need an unlocked bootloader or a device the user rooted.
- Findings from automated scanners with no demonstrated impact.

## Upstream issues

PD-SVAK is a downstream of GrapheneOS, which is built on AOSP. If the bug is in code we inherit unchanged:

- **GrapheneOS:** report it to GrapheneOS as well, following https://grapheneos.org/contact.
- **AOSP / Pixel:** report it to the Android Security Rewards Program at https://bughunters.google.com.

Tell us when you do, so we can ship the fix as soon as upstream does. We will not publish details of an upstream bug before upstream does.

## Supported versions

Only the latest release on each channel (Stable, Beta) gets security fixes. Monthly security releases ship within 72 hours of the Android/Pixel security bulletin. Supported devices and their end-of-support dates are in [devices/devices.json](devices/devices.json).

## Verifying releases

- Release images are signed offline with PD-SVAK keys. No CI system or cloud machine holds them.
- The verified-boot key fingerprint (`avb_pkmd.sha256`) is published with every release. On boot, the yellow notice on your phone must show that same hash.
