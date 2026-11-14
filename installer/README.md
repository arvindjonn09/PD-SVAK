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

## Non-goals

- Never leave the bootloader unlocked.
- Never flash devices that are not listed in `devices/devices.json` as `launch`.
