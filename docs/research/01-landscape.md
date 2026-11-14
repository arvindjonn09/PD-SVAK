# Research Unit 1 — Existing privacy/security Android distributions (2026-11-14)

Items marked [U] are unverified.

## Comparison

| Project | Status 2026 | Base | Devices | Google apps | Relock | License | Source |
|---|---|---|---|---|---|---|---|
| GrapheneOS | Very active (tag 2026111300) | 17 (QPR1 withheld from AOSP) | 22 Pixels (6→10a, Fold, Tablet); Pixel 11 port nearly done; Motorola partner device ~2027 | Sandboxed Play (unprivileged, optional) | Yes + attestation | MIT (own code) + AOSP | github.com/GrapheneOS |
| CalyxOS | Paused Aug 2025 → back mid-2026; 8.0.x | 17 | Pixels 6–10a, Fairphone 5/6, some Moto, SHIFTphone 8 | microG (optional) | Yes on Pixels | Apache/GPL | gitlab.com/CalyxOS |
| LineageOS | Very active; 24.0 Oct 2026 | 17 | ~177 | None (user adds) | Generally no | Apache/GPL | github.com/LineageOS |
| /e/OS (Murena) | Active, commercial; 4.x | 16 | ~200+ | microG + App Lounge (anon Play) | Some | GPL/Apache | gitlab.e.foundation |
| iodéOS | Active; 7.x | 16 (Lineage 23) | 60+ | microG | Some | GPL/Apache | gitlab.com/iode |
| DivestOS | **Shut down** Dec 2024 (funding [U]) | — | many EOL | none | Yes where possible | GPL | archived |
| CopperheadOS | Closed/commercial; 2018 split over keys → GrapheneOS [U from memory] | — | — | — | — | proprietary | — |
| ProtonAOSP | Abandoned ~2023 | 12/13 | old Pixels | optional | — | Apache | github.com/ProtonAOSP |

## Reusable components

| Component | Repo | License |
|---|---|---|
| hardened_malloc | github.com/GrapheneOS/hardened_malloc | MIT |
| Vanadium | github.com/GrapheneOS/Vanadium | GPL-2.0 patches over BSD Chromium |
| Auditor / AttestationServer | github.com/GrapheneOS/Auditor, /AttestationServer | MIT |
| AppStore, Camera, PdfViewer | github.com/GrapheneOS/* | MIT |
| script (release signing), adevtool (vendor extraction) | github.com/GrapheneOS/script, /adevtool | MIT (adevtool [U]) |
| AppVerifier | github.com/soupslurpr/AppVerifier | ISC |
| Seedvault | github.com/seedvault-app/seedvault | Apache-2.0 (REUSE mix) |
| microG GmsCore | github.com/microg/GmsCore | Apache-2.0 |
| Datura firewall | gitlab.com/CalyxOS/platform_external_calyx_datura | Apache-2.0 |
| Sandboxed Play compat | inside GrapheneOS platform_frameworks_base | Apache/MIT |

## Upstream shocks that affect every project

- **June 2025.** Android 16 shipped without Pixel device trees, without the driver binaries, and with the kernel history squashed.
- **January 2026.** AOSP source drops cut to twice a year: Q2 (major) and Q4 (minor).
- **2026.**
  - Android 17 QPR1 was never published to AOSP, and it added APIs only available on Pixels.
  - QPR2 is expected in December 2026.
  - Under the Risk-Based Update System, monthly bulletins now carry only high-risk fixes; most fixes ship quarterly.

## Copy and avoid

**Copy:**
- GrapheneOS's security model.
- Sandboxed Play instead of signature spoofing.
- GrapheneOS's update pipeline and its published device hardware requirements.
- Seedvault and Datura.
- DivestOS's automated CVE patching idea.

**Avoid:**
- Unlocked or test-key builds.
- Claims of "200 devices".
- App stores that scrape Play.
- A bus factor of one.
- Leaving key ownership ambiguous.
- Maintaining your own browser fork without the staff for it.
