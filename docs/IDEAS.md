# Ideas — how PD-SVAK can be better for users

These ideas come from the research units, mostly from user pain points with GrapheneOS, CalyxOS and /e/OS reported on forums, Reddit and GitHub. They are ranked by how much they would help users divided by how much effort they take.

## Tier A — build these first (they are why PD-SVAK should exist)

1. **Banking & attestation program**
   - Publish a signed `attestation.json` with our verified-boot key fingerprints and a timestamp, so that banks and app developers can allowlist us through hardware attestation.
   - Run an outreach tracker (public issue board) for each bank. About a dozen banks began allowing GrapheneOS in Oct 2026, which shows the approach works.
   - Ship an in-OS "Is my bank app compatible?" lookup.
2. **Public compatibility dashboard**
   - A crowdsourced matrix (app → works / works with sandboxed Play / broken + workaround), fed by an in-OS "report compatibility" button and a GitHub issue form.
   - It covers banking, Android Auto, RCS, NFC payments and eSIM.
3. **One-tap migration from stock Android**
   - A guided importer: contacts, SMS/call log, photos, app list → reinstall from F-Droid, Accrescent or Play.
   - Built on Seedvault, plus a desktop/USB helper.
   - Migration is one of the most common reasons people return to stock Android.
4. **The best installer on the market**
   - A WebUSB installer that detects carrier-locked SKUs before you start, recovers from USB re-enumeration errors, always relocks, and verifies the "SelfSigned" boot state at the end.
   - Each step comes with a video, and the installer is available in at least 10 languages at launch.
5. **Privacy-first setup wizard**
   - "Choose your app sources" (Accrescent, F-Droid, optional sandboxed Play in its own profile).
   - DNS choice, a location-provider choice, and a plain-language explanation of the Network and Sensors permissions.
   - An optional "Google profile" so Google apps live in their own profile.

## Tier B — v1.x

6. **Privacy dashboard++**
   - A per-app timeline of network, sensor, location, clipboard and scope usage.
   - "Which apps talked to the internet today", with a one-tap block.
7. **Managed / enterprise mode**
   - A privacy-respecting device-management (MDM) option for NGOs, journalists' newsrooms and small businesses.
   - GrapheneOS does not offer this, and it is a funding channel.
8. **Lockdown presets** — one tap to apply a set of settings:
   - "Travel / border": USB off, auto-reboot after 1 hour, biometrics off, duress PIN reminder.
   - "Protest": the above plus Bluetooth and Wi-Fi auto-off and LTE-only.
   - "Everyday": balanced defaults.
9. **Transparent build provenance**
   - Reproducible builds, a public build log, SBOM (software bill of materials) per release, and a signed changelog.
   - Users can verify that a build matches the source.
10. **App-source labels** — every app shows where it came from (F-Droid, Accrescent, Play, sideload), with update status.

## Tier C — later / exploratory

11. **Fairphone 6 "ethical tier"**
    - A clearly labelled lower security tier: no MTE, and bi-monthly patches after 2028.
    - It must pass relock safety checks (patch-level and firmware gating) before we ship it.
12. **OEM partnership**
    - Pursue a Motorola-style partnership for embargoed patch access and a non-Pixel device in 2027.
13. **On-device private assistant**
    - A local-only LLM assistant (no network permission) for settings help and "explain this permission".
    - It would run only where hardware allows.
14. **Community build mirrors**
    - Volunteers host OTA mirrors, verified by signed metadata, which lowers CDN costs.

## Explicitly rejected ideas

- **Supporting "200 devices" at one security level.** The Gold bar can't be kept across that many phones. Instead, we support many devices through honest Silver/Bronze tiers ([DEVICE-TIERS.md](DEVICE-TIERS.md)), adding them only as maintainers allow.
- **A Play Integrity spoof module** — it is fragile and undermines the security story.
- **Maintaining our own Chromium fork at launch** — we use Vanadium as the WebView; a browser fork is optional later.
- **Bundled cloud services** — they create the commercial coupling /e/OS is criticised for.
