# Research Unit 5: Devices, legal, AI workflow, sustainability (2026-11-14)

## Devices (support end dates per the GrapheneOS FAQ)
| Device | Minimum support end | Launch target? |
|---|---|---|
| Pixel 8 / 8 Pro | Oct 2030 | **Yes** |
| Pixel 8a | May 2031 | **Yes** |
| Pixel 9 / 9 Pro / 9 Pro XL / 9 Pro Fold | Aug 2031 | **Yes** |
| Pixel 9a | Apr 2032 | **Yes** |
| Pixel 10 / Pro / XL | Aug 2032 | Next, about Jan 2027. Separate kernel branch, more porting work |
| Pixel 10 Pro Fold | Oct 2032 | Next |
| Pixel 10a | Mar 2033 | Next |
| Pixel 6 / 6 Pro | Oct 2026 (ended) | No |
| Pixel 6a / 7 / 7a | 2027–2028 | No |
| Fairphone 5/6 | FP6: bi-monthly patches from 2028 | Later, as a labelled "ethical tier". No MTE. Relock bricks have been reported. |
| Motorola (GrapheneOS partner) | About 2027 | Talk to them in 2027 |
| Xiaomi, Samsung, budget MTK/Unisoc | — | **Avoid** |

**Device bar:**
- 5+ years of patches, each shipped within a week of release.
- Kernel GKI 6.12/6.18.
- MTE.
- Radios isolated behind an IOMMU.
- A/B updates with rollback protection.
- StrongBox and Weaver.
- USB data can be disabled in hardware.

## Legal (not legal advice)
- **GPLv2 kernel:** publish the full source for each build.
- **Apache-2.0 code:** keep the LICENSE and NOTICE files and mark files we modify.
- **Name:** no "Android" in the product name. "Runs Android apps" is fine.
- **Vendor blobs:**
  - Their legal status is unclear [U].
  - Others ship them and Google has tolerated it, but that is not a license.
  - Keep them out of git and only ship them inside device images.
- **Google apps:** never bundle GMS.

## AI agents in the workflow
**Good uses:**
- Tracking ASB/CVE advisories and opening an issue for each.
- Preparing rebases and drafting conflict fixes.
- Triaging CI failures.
- Triaging issues.
- Writing docs and release notes.
- Building the app-compatibility matrix.

**Limits:**
- They cannot test on real devices.
- Security-critical code needs expert human review.
- They never touch signing keys.
- They cannot reverse-engineer missing device trees.
- Their output carries licence-provenance risk.

**Evidence:** MSR '26 found 71% of AI-authored PRs accepted in Android projects. Rejections were mostly due to rebase conflicts and failing CI.

## Sustainability
- **Lessons from other projects:**
  - DivestOS: one maintainer funded only by donations, and it ended.
  - CalyxOS: paused for a year after its leads left.
  - Murena: sells devices, but its revenue figures are **[U]**.
  - Motorola–GrapheneOS: shows that OEMs will pay for hardening work.
- **Funding options:** grants (NLnet/NGI, OTF), enterprise/MDM support, donations.
- **Release cadence:**
  - Monthly releases within 72 h of each bulletin, plus out-of-band emergency fixes.
  - Extra merge work every quarter (Mar/Jun/Sep/Dec).

## User pain points (and our opening)
- Banking apps.
- NFC payments: Google Wallet doesn't work.
- Flaky RCS.
- Android Auto: broken on CalyxOS, works with sandboxed Play.
- Painful migration from stock.
- No MDM.
- Few supported devices.

These shape `../IDEAS.md`.

## Sources
- https://grapheneos.org/faq
- https://discuss.grapheneos.org/d/25099-pixel-10-support-for-grapheneos-is-now-available
- https://www.androidauthority.com/google-not-killing-aosp-3566882/
- https://androidauthority.com/android-risk-based-security-updates-3597466
- https://www.androidauthority.com/grapheneos-motorola-partnership-announced-3645710
- https://support.fairphone.com/hc/en-us/articles/24463713641234
- https://calyxos.org/news/2025/08/01/a-letter-to-our-community/
- https://wiki.lineageos.org/proprietary_blobs
- https://arxiv.org/html/2602.12144v1
