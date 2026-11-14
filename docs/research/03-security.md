# Research Unit 3 — Security & privacy feature catalog (2026-11-14)

The prioritized plan is in [`../SECURITY-FEATURES.md`](../SECURITY-FEATURES.md). This file keeps the evidence behind it.

## Where each feature comes from

| Feature | Source repo | License |
|---|---|---|
| Hardened memory allocator | github.com/GrapheneOS/hardened_malloc | MIT |
| Vendor extraction / tooling | github.com/GrapheneOS/adevtool | MIT |
| AVB reference implementation | github.com/chenxiaolong/avbroot | GPL-3.0 (use as reference only) |
| Auditor + AttestationServer | github.com/GrapheneOS/Auditor, AttestationServer | MIT |
| Per-app firewall | github.com/CalyxOS/platform_packages_apps_Firewall | Apache-2.0 |
| Firewall UI (reference only) | github.com/ukanth/afwall | GPL-3.0, root-centric |
| Vanadium browser/WebView | github.com/GrapheneOS/Vanadium | GPL-2.0-only patches |
| Cromite browser | github.com/uazo1/cromite | GPL-3.0 [U] |
| IronFox browser (Gecko, successor to Mull) | gitlab.com/ironfox-oss | MPL-2.0 [U] |
| Encrypted backups (Seedvault) | github.com/seedvault-app/seedvault | Apache-2.0 |
| microG | github.com/microg/GmsCore | Apache-2.0 (needs signature spoofing) |

GrapheneOS platform forks report their license as NOASSERTION. Check the per-file headers before relicensing anything.

## Forensics evidence

- **Cellebrite support-matrix leaks** (Feb and Oct 2025, reported by 404 Media):
  - Stock Pixel 9 is supported before first unlock.
  - GrapheneOS Pixels running patches from late 2022 or later are *not* supported before first unlock.
  - Extraction after first unlock is limited on GrapheneOS [U].
- **Amnesty, Feb 2025 (Serbia):** police used a Cellebrite zero-day chain through Linux USB drivers (CVE-2024-53104, -53197, -50302).
- **Mitigations ranked by impact:**
  1. USB-C port control
  2. Auto-reboot back to before-first-unlock state
  3. Secure-element-throttled PIN
  4. hardened_malloc + MTE
  5. Patch speed
  6. Duress wipe

## Sources
- https://grapheneos.org/features
- https://www.androidauthority.com/cellebrite-leak-google-pixel-grapheneos-security-3611794
- https://thehackernews.com/2025/02/amnesty-finds-cellebrites-zero-day.html
- https://www.securityweek.com/amnesty-reveals-cellebrite-zero-day-android-exploit-on-serbian-student-activist/
- https://pitg.gitlab.io/news/techdive/2026/04/17/phone-unlocking.html
