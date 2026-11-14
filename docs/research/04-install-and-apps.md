# Research Unit 4: Installer, app freedom, onboarding (2026-11-14)

## Installers
| Tool | License | Notes |
|---|---|---|
| GrapheneOS web installer (github.com/GrapheneOS/grapheneos.org) | MIT | WebUSB, Chromium browsers only, works on Win/macOS/Linux/ChromeOS/Android. Unlocks, flashes and **relocks**. Our UX reference. |
| kdrag0n/fastboot.js (npm `android-fastboot`) | MIT | WebUSB fastboot library: factory zips, dynamic partitions, custom AVB key. Maintenance unclear, so **fork it**. |
| kdrag0n/android-webinstall | MIT [U] | Ready-made UI built on fastboot.js. |
| CalyxOS device-flasher | Apache-2.0 | Go CLI fallback. |
| /e/OS Installer | — | WebUSB, but **leaves the bootloader unlocked**. That is our anti-pattern. |
| LineageOS 24 flash tool | — | New WebUSB tool. |

**Must-haves for a one-click installer:**
1. Device database.
2. Signed images with hash check.
3. Pre-flight wizard (OEM unlock, carrier-SKU warning, cable advice).
4. Unlock, flash, then `avb_custom_key` and relock, then verify SelfSigned.
5. Recovery from USB re-enumeration errors.
6. CLI fallback.

**Carrier restrictions:** carrier SKUs (e.g. Verizon Pixels) cannot unlock the bootloader. Detect this and warn the user up front.

## App freedom
- **Google developer verification:**
  - Enforced by Google Play services on *certified* devices.
  - Phase 1 started 2026-09-30 in BR/ID/SG/TH, covering participating stores only. Global rollout is planned for 2027.
  - ADB installs are exempt. An "advanced flow" with a 24-hour wait exists for experienced users.
  - An **uncertified fork without privileged GMS is not subject to it.** Never wire the verifier into our PackageInstaller.
- **F-Droid** opposes it (open letter, 2026-02-24). Accrescent registered with Google but still accepts unregistered developers.

| Store | Repo | License | Plan |
|---|---|---|---|
| Accrescent | github.com/accrescent/accrescent | Apache-2.0/ISC | **Preinstall** |
| F-Droid (official client) | gitlab.com/fdroid/fdroidclient | GPL-3.0 | One-tap install in setup wizard |
| Sandboxed Google Play | (GrapheneOS gmscompat) | Apache/MIT | Optional, per profile, off by default |
| Obtainium | github.com/ImranR98/Obtainium | GPL-3.0 [U] | Documented, not preinstalled |
| Aurora Store | gitlab.com/AuroraOSS/AuroraStore | GPL-3.0 | Documented, not preinstalled (violates Google ToS) |
| GrapheneOS AppStore | github.com/GrapheneOS/AppStore | MIT | Model for our system store |

## Banking / Play Integrity
- **Integrity verdicts:** aftermarket OSes only pass "basic". The "device" and "strong" verdicts fail by design.
- **What actually works:** hardware attestation allowlisting. The app checks `verifiedBootState` (Verified or SelfSigned) and `verifiedBootKey` against a signed, published fingerprint list. Reference: https://grapheneos.org/articles/attestation-compatibility-guide
- **Compatibility data:** the crowd list at privsec.dev has about 500 or more apps across about 60 countries.
- **Do not ship fingerprint spoofing.**

## Sources
- https://developer.android.com/developer-verification/guides/faq
- https://f-droid.org/2026/02/24/open-letter-opposing-developer-verification.html
- https://blog.accrescent.app/posts/android-developer-verification/
- https://grapheneos.org/install/web
- https://github.com/kdrag0n/fastboot.js
- https://github.com/CalyxOS/device-flasher
- https://privsec.dev/posts/android/banking-applications-compatibility-with-grapheneos/
