# Governance, key custody and sustainability

Privacy OS projects tend to fail on people, money and keys rather than on code. Three examples:

- **CopperheadOS (2018):** the founders split over control of the signing keys and the money.
- **DivestOS (shut down Dec 2024):** a single maintainer funded only by donations.
- **CalyxOS (paused Aug 2025 – mid-2026):** stalled after its leads left.

## Key custody

- **Key sets:**
  - One set of release keys per device family: releasekey, platform, shared, media, networkstack, bluetooth, sdk_sandbox, nfc.
  - Plus an RSA-4096 AVB key.
- **Where keys are generated and used:** on an **air-gapped machine**, encrypted with a strong passphrase.
- **Who can sign:** at least 2 people can unlock the keys. They hold the passphrase split between them, either with Shamir secret sharing (k-of-n) or as two halves.
- **Backups:** 2 offline backups held in different locations.
- **What signing outputs:** signing produces the release artifacts on the air-gapped machine. Only the *signed outputs* leave it.
- **What never touches the keys:** CI, cloud machines and AI agents. CI produces only unsigned `target-files`.
- **Ceremony log:** every key ceremony is documented and published. Publish the hashes, never the secrets.
- **Lost keys:** if the keys are lost, every user has to wipe and reflash. Treat key loss as the worst-case incident.

## Releases

- **Who approves:** each release needs 2 maintainer approvals.
- **Tags and sources:** each release is tagged in every repo we fork. Kernel source is published for each build (GPLv2 requires it).
- **Channels:** Alpha → Beta → Stable.
  - Promote to Stable only after at least 24 hours on Beta without regressions.
  - Emergency security releases can skip the wait, but still need 2 approvals.

## Funding (target mix by M6)

- Donations (Open Collective / GitHub Sponsors)
- Grants (NLnet/NGI, Open Technology Fund)
- Enterprise or managed-mode support contracts
- Later: a hardware reseller channel, with pre-flashed Pixels or Fairphones

## Legal checklist (get a lawyer's review)

- [ ] Product name and trademark search. Keep "Android" out of the name; use "runs Android apps".
- [ ] GPLv2 kernel source published per build.
- [ ] Apache-2.0 LICENSE/NOTICE files preserved, and modified files marked.
- [ ] Vendor firmware blobs are kept out of git. They are extracted at build time and shipped only inside device images.
- [ ] No Google apps bundled.
- [ ] Attribution to upstream projects. Follow GrapheneOS's rebrand requirement: don't use their name in ours.
- [ ] Disclosure policy and `security@` contact.
- [ ] Duress-wipe legal note for users.
