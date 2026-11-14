# Roadmap

Today is 2026-11-14. The target is a **public Developer Preview by 2026-12-31**, then Stable 1.0 in Q1 2027.

## Weeks 1–6 (to end of 2026)

| Week | Dates | Goals | Exit criteria |
|---|---|---|---|
| 1 | Nov 16–22 | Order hardware: a build server (32c/128 GB/4 TB NVMe) and test devices (Pixel 8, 8a, 9, 9a). Pick the final product name and check the trademark. Get a lawyer's opinion on redistributing vendor firmware. Mirror the GrapheneOS sources. | `repo sync` complete; an unmodified build boots on a Pixel 8 |
| 2 | Nov 23–29 | Key ceremony (offline machine, encrypted keys, two backups). Signed `user` builds. Relock with our AVB key. Self-hosted CI runner online. | Pixel 8/9 relocked, showing our key hash on the yellow boot screen |
| 3 | Nov 30–Dec 6 | Rebrand (name, boot animation, Updater URL, setup text). Update server on a static CDN. Full and delta OTA tested. Kernel GPL source publication pipeline. | Over-the-air update works A→B on a test device |
| 4 | Dec 7–13 | Our patches: Accrescent preinstalled, F-Droid one-tap in setup, privacy defaults, CI traffic audit at first boot. Agents: ASB tracker and rebase assistant live. | First boot makes no traffic to unexpected hosts |
| 5 | Dec 14–20 | WebUSB installer beta. Docs site. Absorb any Android 17 QPR2 / GrapheneOS rebase. Beta channel. | 5 external testers install successfully using only the docs |
| 6 | Dec 21–31 | Internal security review. Disclosure policy and `security@` contact. Donations live. **Developer Preview release.** | Signed release published, with source tags and kernel source |

**Release status for the preview:**
- It is a preview, not a "1.0". We publish it as a preview because we do not yet have a track record of monthly patches.
- If anything slips, cut scope (installer polish, extra devices). Never cut signing, relocking or update speed.

## Months 1–6 (Jan–Jun 2027)

- **M1–2:**
  - Ship monthly patch releases on time.
  - Survive the Dec/Mar quarterly merges.
  - Add Pixel 10 / 10 Pro / 10a.
  - Migration tool alpha.
- **M2–3:**
  - **Stable 1.0.**
  - External security audit, grant-funded (NLnet/NGI, OTF).
  - Compatibility dashboard live.
- **M3–4:**
  - Banking attestation outreach (target: 10 banks allowlisting).
  - Android Auto validated with sandboxed Play.
  - Migration tool GA.
- **M4–5:**
  - Decide on the Fairphone 6 tier.
  - Approach OEMs and resellers about access to embargoed patches.
- **M6:**
  - Foundation or association formed, with at least 3 maintainers who can sign releases.
  - Funding mix: donations, grants and an enterprise pilot.
  - Public roadmap v2.
