# PD-SVAK Web Installer (planned)

The installer is a static site that flashes PD-SVAK from Chrome or Edge using WebUSB. It needs no drivers on Windows 10/11, macOS, Linux or ChromeOS.

## Base

- **Flashing library:** a fork of [kdrag0n/fastboot.js](https://github.com/kdrag0n/fastboot.js) (MIT).
- **UX and flow:** modelled on the [GrapheneOS web installer](https://grapheneos.org/install/web) (MIT, source in GrapheneOS/grapheneos.org).
- **Command-line fallback:** derived from [CalyxOS/device-flasher](https://github.com/CalyxOS/device-flasher) (Apache-2.0, Go).

## Flow

1. **Check the browser.** If WebUSB is missing, show the "use Chrome/Edge" page.
2. **Pre-flight checks:**
   - Turn on developer options and OEM unlocking.
   - Detect carrier-locked models and warn about them (e.g. Verizon).
   - Give advice on cables and ports.
3. **Unlock the bootloader.** The user confirms on the device.
4. **Download and verify the image.** Download the signed factory image for the detected codename and verify its SHA-256 against signed metadata.
5. **Flash** the firmware, then the OS.
6. **Flash our key.** Write `avb_custom_key`.
7. **Relock the bootloader.** This step is mandatory.
8. **Verify after boot.** The yellow "SelfSigned" screen shows a key hash. Check it matches the published fingerprint.
9. **Recover from re-enumeration.** Handle USB re-enumeration after each reboot, with automatic reconnect and clear retry prompts.

## Code (`web/`)

| File | What |
|---|---|
| `index.html`, `style.css` | The step-by-step page |
| `app.js` | Step flow and the safety checks: launch-tier devices only, signed metadata + SHA-256 before any write, relock required |
| `fastboot-adapter.js` | The only file that talks to the phone; wraps the fastboot.js fork |
| `release-key.js` | Public key for release metadata, and the metadata URL |

**Before it can flash anything:**
1. Vendor the fastboot.js fork as `web/vendor/fastboot.mjs` and check the method names in `fastboot-adapter.js` against it.
2. After the key ceremony, put the metadata-signing **public** key in `release-key.js`.
3. At deploy time, copy `devices/devices.json` into the site root.
4. Publish `<channel>/<codename>.json` + `.sig` with `codename, build, image_url, image_sha256, image_size, avb_key_url, avb_key_sha256`.

Until steps 1 and 2 are done, the installer stops with a clear error instead of flashing.

## Non-goals

- Never leave the bootloader unlocked.
- Never flash devices that are not listed in `devices/devices.json` as `launch`.
