# vendor/pdsvak: the PD-SVAK product layer

Our branding, privacy defaults and preinstalled apps, kept **outside** upstream projects so monthly rebases stay small. `build/sync.sh` copies this directory to `$PDS_SRC/vendor/pdsvak`.

| Path | What |
|---|---|
| `pdsvak.mk` | Product config: branding properties, overlays, preinstalled packages |
| `overlay/` | Static resource overlays (NTP server, updater URL) |
| `Android.bp` + `prebuilts.lock` | Accrescent, preinstalled unprivileged, hash-pinned |
| `bootanimation/` | Put `bootanimation.zip` here when the design is ready (it is optional; the build skips it if missing) |

## Hooking it into the device products (one-time, on the build host)

Each Gold device product needs one line. Add it, then turn it into a patch with `build/new-patch.sh`:

```bash
cd "$PDS_SRC/device/google/<family>"        # e.g. shusky (Pixel 8/8 Pro), caimito (Pixel 9 series)
# add to the device's product makefile:
#   $(call inherit-product, vendor/pdsvak/pdsvak.mk)
"$PDS_ROOT/build/new-patch.sh" device/google/<family> "Inherit the PD-SVAK product layer"
```

## Still to do in this layer

These need the source tree to find the right hook, so they are done on the build host:

- **Connectivity check, SUPL and PSDS.** GrapheneOS sets these in its own framework and NetworkStack code, not in plain resources. Change them with a small patch per project, made with `build/new-patch.sh`. Our proxy hostnames are in `privacy/allowed-hosts.txt`.
- **Auditor fingerprints.** Add our `avb_pkmd.sha256` values to the Auditor fork after the key ceremony.
- **Setup wizard step** for one-tap F-Droid and optional sandboxed Play.
