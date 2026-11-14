# Security & privacy feature plan

Most of these features are inherited from GrapheneOS. "Ours" marks work PD-SVAK must do itself.

## MVP (Developer Preview, Dec 2026)

| Feature | Threat addressed | Source |
|---|---|---|
| Verified boot, custom AVB key, relocked bootloader | Evil maid attacks, persistent tampering | AOSP avb + **ours** (keys/CI) |
| Monthly patch pipeline (≤72h) | Known exploits | **ours** (ASB agent + release process) |
| hardened_malloc + MTE (Pixel 8+) | Heap memory corruption, the core of 0-click and forensic exploit chains | GrapheneOS (MIT) |
| Kernel hardening (kCFI, SCS, PAC/BTI, init_on_alloc, zero-on-free) | Kernel privilege escalation | GrapheneOS kernels (GPL-2.0) |
| USB-C port control (default: charging-only when locked) | Cellebrite-style USB exploit chains (e.g. CVE-2024-53104, used in Serbia in 2025) | GrapheneOS |
| Auto-reboot timer (18h default) | Extraction while unlocked since boot (keys are in memory) | GrapheneOS |
| Network and Sensors permissions | App exfiltration and sensor side channels | GrapheneOS |
| Per-connection MAC randomization | Wi-Fi tracking | GrapheneOS |
| Connectivity check / NTP / SUPL / PSDS routed through **our** proxies | Google telemetry, IP and location leaks | **ours** (servers) + GrapheneOS overlays |
| DNS-over-TLS default (user-overridable) | DNS snooping | AOSP |
| Vanadium WebView | Browser exploits | GrapheneOS (GPL-2.0 patches) |
| Auditor fork with our key fingerprints | Tampering and OS downgrade | GrapheneOS Auditor (MIT) |
| Seedvault encrypted backup | Cloud backup exposure | seedvault-app (Apache-2.0) |
| PIN scrambling, fingerprint capped at 5 attempts | Shoulder surfing, biometric brute force | GrapheneOS |
| CI first-boot traffic audit | Telemetry regressions | **ours** |

## v1.1

- Duress PIN/password. Ship it with a legal-risk note, since some jurisdictions may treat wiping as evidence destruction.
- Storage Scopes and Contact Scopes.
- Sandboxed Google Play compatibility layer: it ships with the GrapheneOS base, so the v1.1 work is UX and defaults.
- Datura-style per-app firewall (CalyxOS, Apache-2.0).
- Two-factor fingerprint unlock.
- Bluetooth and Wi-Fi auto-off timers.
- Restrictions on dynamic code loading.
- Profile and Private Space hardening.
- Lockdown presets (see `IDEAS.md`).

## Later

- Self-hosted AttestationServer with scheduled remote verification.
- Optional microG build variant, with signature spoofing restricted to microG only.
- Second bundled browser (Cromite or IronFox).
- Non-Pixel tiers with documented weaker guarantees.

## Forensics reality check (2025–2026)

- **What the leaks show:** Leaked Cellebrite support matrices list GrapheneOS Pixels (patched from late 2022) as *not supported* before first unlock, while stock Pixels are supported.
- **Mitigations that matter most:** In order:
  1. USB port control
  2. Auto-reboot back to the before-first-unlock state
  3. Secure-element-throttled PIN, with long passphrases encouraged
  4. hardened_malloc + MTE
  5. Fast patches
  6. Duress wipe
- **Release priority:** Our release process must never regress these.
