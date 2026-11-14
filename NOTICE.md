# Notices and attribution

PD-SVAK is built on the work of other open-source projects. This file lists the upstream projects we ship or derive from, and the rules we follow for their licenses.

PD-SVAK is **not affiliated with or endorsed by** GrapheneOS, Google, or any project listed here. "Android" and "Pixel" are trademarks of Google LLC. GrapheneOS asks downstream projects not to use its name in their own branding, and we follow that: the GrapheneOS name appears only here and in attribution, never in our product name, UI or update infrastructure.

## Shipped in PD-SVAK images

| Project | Source | License | How we use it |
|---|---|---|---|
| Android Open Source Project | https://source.android.com | Apache-2.0 (mostly), others per project | OS base |
| GrapheneOS OS tree | https://github.com/GrapheneOS | MIT (GrapheneOS code) + upstream licenses | Our base; we rebrand it and apply `patches/` on top |
| GrapheneOS kernels | https://github.com/GrapheneOS | GPL-2.0 | Kernel; source published with every build (see below) |
| hardened_malloc | https://github.com/GrapheneOS/hardened_malloc | MIT | System memory allocator |
| Vanadium | https://github.com/GrapheneOS/Vanadium | GPL-2.0 patches on BSD-3-Clause Chromium | Browser and WebView |
| Auditor | https://github.com/GrapheneOS/Auditor | MIT | Forked, with PD-SVAK key fingerprints added |
| AppStore, Camera, PdfViewer | https://github.com/GrapheneOS | MIT | System apps |
| Seedvault | https://github.com/seedvault-app/seedvault | Apache-2.0 (REUSE, mixed) | Encrypted backup |
| Accrescent | https://github.com/accrescent | See upstream | Preinstalled app store |

## Used to build or install PD-SVAK

| Project | Source | License | How we use it |
|---|---|---|---|
| GrapheneOS `script` | https://github.com/GrapheneOS/script | MIT | Release signing (`build/sign-release.sh` wraps it) |
| adevtool | https://github.com/GrapheneOS/adevtool | MIT (to be confirmed) | Extracts vendor files at build time |
| fastboot.js | https://github.com/kdrag0n/fastboot.js | MIT | WebUSB flashing library for the web installer |
| GrapheneOS web installer | https://github.com/GrapheneOS/grapheneos.org | MIT | UX reference for the web installer |
| CalyxOS device-flasher | https://github.com/CalyxOS/device-flasher | Apache-2.0 | Basis for the CLI installer |

## Planned (not yet shipped)

| Project | Source | License |
|---|---|---|
| Datura firewall | https://gitlab.com/CalyxOS/platform_external_calyx_datura | Apache-2.0 |
| AppVerifier | https://github.com/soupslurpr/AppVerifier | ISC |
| microG GmsCore (optional variant only) | https://github.com/microg/GmsCore | Apache-2.0 |

F-Droid is **not** bundled. The setup wizard only offers to download it.
No Google apps are bundled. Sandboxed Google Play is downloaded by the user on request.

## License compliance rules

1. **Keep upstream notices.** Never delete or edit upstream `LICENSE`, `NOTICE` or copyright headers. AOSP's build collects them into the on-device notice screen (Settings → About phone → Legal information); our branding patches must not remove that screen.
2. **Mark modified files.** Every patch in `patches/` that changes an Apache-2.0 file must leave the original header in place. The patch's commit message states what was changed, which, together with the published patch set, meets Apache-2.0 §4(b).
3. **Publish GPL source.** For every release, we publish the exact kernel source and the Vanadium patch set used, tagged with the build number (`build/publish-kernel-source.sh`).
4. **No vendor blobs in git.** Pixel vendor firmware is extracted at build time with adevtool and ships only inside device images (see `.gitignore`).
5. **New dependencies** need their license added to this file in the same PR.

Items marked "to be confirmed" or "see upstream" must be checked against the upstream repository before the Developer Preview, as part of the legal review in [docs/GOVERNANCE.md](docs/GOVERNANCE.md).
