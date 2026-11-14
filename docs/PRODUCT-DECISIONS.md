# Product decisions (2026-11-15)

How PD-SVAK behaves out of the box. These are decided; change one only with a reason, in a PR that updates this file.

## Identity and look

| Topic | Decision |
|---|---|
| Name | **PD-SVAK** (trademark check still pending, see `GOVERNANCE.md`) |
| Look | **Clean, close to stock.** Standard launcher and Material You theming, plus our name, boot animation, wallpaper and accent colour. No custom launcher: it would be more code to secure and rebase every month |
| Languages at launch | **English.** Our own screens (setup wizard, installer) are written so that translations can be added later |

## Apps

| Topic | Decision |
|---|---|
| Google Play | **Not installed by default.** The setup wizard offers **sandboxed Google Play** with one tap. That covers Google Maps, work authenticators that need push notifications, and other Play-only apps |
| App stores | **Accrescent** preinstalled. **F-Droid** one tap in setup. **Obtainium** offered in setup. No Aurora Store: it breaks Google's terms and stops working now and then, and sandboxed Play covers the same apps |
| Browser | **Vanadium** only (also the system WebView) |
| Calls and messaging | **Open-source** Phone and Messaging apps (SMS/MMS). For RCS, users install Google Messages through sandboxed Play, or use Signal |
| Work apps | Setup suggests a **separate work profile** with its own sandboxed Play, for the authenticator and work email. The profile can be paused after hours |

## Security and privacy defaults ("Balanced")

| Setting | Default |
|---|---|
| Auto-reboot when locked | 18 hours |
| USB-C port | Data off while locked; charging always works |
| Fingerprint unlock | Allowed (capped at 5 attempts; PIN scrambling available) |
| Encrypted DNS | DNS-over-TLS to **Quad9**, user-changeable |
| Network time, connectivity check | Through PD-SVAK proxies |
| GPS assistance (SUPL/PSDS) | Through **PD-SVAK proxies**, so Google never sees the user's IP address. Wi-Fi/cell network location only if the user installs sandboxed Play |
| Telemetry and crash reports | **Never sent.** Bugs are reported by people through GitHub |

## Updates

| Topic | Decision |
|---|---|
| Install policy | **Ask first.** The updater notifies; the user chooses when to download and install |
| Security updates | Same policy, but the notification stays visible until the update is installed, and says plainly that it fixes security issues. The 72-hour release target is ours; how fast phones install is the user's choice |
| Channels | Alpha / Beta / Stable, Stable by default |

## Where each decision is implemented

- Google Play, app stores, work profile: setup-wizard step (to do; see `vendor/pdsvak/README.md`).
- Accrescent: `vendor/pdsvak/pdsvak.mk` and `prebuilts.lock`.
- Obtainium: offered in setup, not preinstalled.
- DNS, proxies: `vendor/pdsvak/overlay/` and the proxy patches; hosts in `privacy/allowed-hosts.txt`.
- Update policy: an Updater overlay or patch, checked on the source tree with `build/check-overlays.sh`.
