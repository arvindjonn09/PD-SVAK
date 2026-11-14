# Patch set

Put patches at `patches/<project path in the source tree>/NNNN-Description.patch`. `build/apply-patches.sh` applies them in order with `git am --3way`.

## Planned for the Developer Preview

| Project | Patch |
|---|---|
| `packages/apps/Updater` | Point update URLs at the PD-SVAK update server (`res/values/config.xml`) |
| `frameworks/base` + overlays | Connectivity check, NTP, SUPL and PSDS defaults → PD-SVAK proxies |
| `vendor/*` / product makefiles | Branding: name, boot animation, about screen. No upstream name or trademarks |
| product packages | Preinstall Accrescent. Add a setup-wizard step for one-tap F-Droid and optional sandboxed Play |
| `packages/apps/Auditor` | Add PD-SVAK verified-boot key fingerprints |

## Rules

- Keep each patch small and single-purpose, so it rebases easily every month.
- Generic fixes go **upstream** to GrapheneOS first, where they would be accepted.
- Any patch that touches SELinux, verified boot, the kernel or memory safety needs a second reviewer.
