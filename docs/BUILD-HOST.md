# Build hosts

PD-SVAK builds **only on x86_64 Linux**. We have two machines:

| | **Primary: i9 PC with WSL2** | **Secondary: HP ProLiant Gen10 Plus** |
|---|---|---|
| CPU | i9-11900KB, 8 cores / 16 threads | Xeon E-2224, 4 cores / 4 threads |
| RAM | 64 GB (56 GB given to WSL) | 32 GB, the most this server supports |
| Build disk | New dedicated NVMe (1 TB minimum, 2 TB better) | 1 TB SSD (+ 1 TB HDD for archives only) |
| First build, one phone | about 5–7 h | about 12–16 h |
| Rebuild after monthly update | about 1–1.5 h | about 3–4 h |
| Role | Day-to-day builds and monthly releases | Second builder for monthly releases; CI runner; release archive |

Together they rebuild all 8 launch Pixels in about 8–10 h, well inside the 72-hour window. Each machine builds **one phone at a time**.

Neither machine ever holds signing keys. Signing happens on the offline laptop (see "Also needed").

---

## Primary: Windows PC with WSL2

WSL2 runs a real Linux kernel, and its disk is a real ext4 file system, so builds run at close to native speed. Google doesn't officially support building in WSL, but our builds are checked the same way either way: target-files are signed offline, and reproducible-build settings make the output independent of the host.

### Rules

- **Never build under `/mnt/c` or any `/mnt/<drive>` path.** Those are Windows drives reached through a slow file bridge (about 10× slower), and they are case-insensitive, which breaks the Android tree. `build/config.sh` refuses to run if `PDS_SRC` is there.
- **Shut down other VMs and heavy services during builds** (Hyper-V VMs, Docker Desktop, VirtualBox). They compete for RAM.

### 1. Add the NVMe and install WSL

1. Install the new NVMe. In Windows **Disk Management**, initialise it (GPT) and format it **NTFS** with a drive letter, e.g. `W:`. It only holds the Linux virtual disk, so the build data stays physically separate from Windows.
2. In an **admin** PowerShell:
   ```powershell
   wsl --install -d Ubuntu-24.04     # reboot when asked, then create your Linux user
   wsl --shutdown
   wsl --manage Ubuntu-24.04 --move W:\WSL\Ubuntu-24.04    # move the Linux disk onto the new NVMe
   ```
3. Give the Linux disk room to grow. In admin PowerShell, run `wsl --shutdown`, then `diskpart`:
   ```text
   select vdisk file="W:\WSL\Ubuntu-24.04\ext4.vhdx"
   expand vdisk maximum=1500000
   exit
   ```
   (1,500,000 MB is about 1.4 TB; use about 90% of the drive.) Then, inside Ubuntu: `sudo resize2fs $(findmnt -no SOURCE /)`.

### 2. Give WSL the resources

Create `C:\Users\<you>\.wslconfig`:

```ini
[wsl2]
memory=56GB
processors=16
swap=32GB
swapFile=W:\\WSL\\swap.vhdx

[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
```

Then `wsl --shutdown` and start Ubuntu again. Inside Ubuntu, `free -g` should show about 56 GB of memory and 32 GB of swap.

### 3. Keep Windows out of the way during builds

- **Power:** Settings → System → Power → Screen and sleep: **Never** while plugged in.
- **Windows Update:** set *Active hours* to cover build times, or pause updates during a monthly release. An update reboot kills a running build.
- **Defender:** add the folder exclusion `W:\WSL` (Windows Security → Virus & threat protection → Exclusions). Scanning the Linux disk file slows builds a lot. Keep Defender on for everything else.

### 4. Build

```bash
git clone https://github.com/arvindjonn09/PD-SVAK.git ~/pdsvak/repo
cd ~/pdsvak/repo
build/setup-host.sh
build/sync.sh
build/build.sh akita          # Pixel 8a, or tegu for a Pixel 9a
```

`PDS_SRC` defaults to `~/pdsvak/src`, which is inside the Linux disk on the new NVMe.

### 5. Flashing a test phone

Flashing doesn't have to happen in WSL. Copy the signed factory image to Windows and flash with Google's [platform-tools for Windows](https://developer.android.com/tools/releases/platform-tools) (`fastboot.exe`), or with our web installer in Chrome. If you'd rather flash from Linux, pass the phone through with [usbipd-win](https://github.com/dorssel/usbipd-win).

---

## Secondary: HP ProLiant Gen10 Plus

1. **Firmware:** update the BIOS and iLO with HPE's Service Pack for ProLiant. In the BIOS, set the workload profile to *General Throughput Compute* or *High Performance*, so the CPU isn't held back.
2. **OS:** install **Ubuntu 24.04 LTS** (Desktop is fine) on the **SSD**, using the whole disk, ext4.
3. **HDD:** format it ext4 and mount it at `/srv/pdsvak-archive` (add it to `/etc/fstab`). It's only for archives: finished releases, kernel source tarballs, backups. **Never build on it.**
4. **Swap:** 32 GB is the maximum RAM and the minimum for a build, so swap is required:
   ```bash
   sudo fallocate -l 32G /swapfile && sudo chmod 600 /swapfile
   sudo mkswap /swapfile && sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   sudo apt install -y zram-tools        # compressed RAM swap, used first
   ```
5. **Never sleep:** Settings → Power → Automatic suspend: off.
6. **Network:** wired Ethernet. The first sync downloads about 100 GB.
7. **Project:** same commands as step 4 above.
8. **CI (later):** register it as the self-hosted GitHub Actions runner with the label `pdsvak-builder` (see `.github/workflows/build.yml`).

If memory runs out during the final linking steps, check `dmesg` for "Out of memory", make sure swap and zram are on (`swapon --show`), and build over SSH with the desktop session closed.

---

## Also needed

| Item | Why | Rough cost |
|---|---|---|
| **NVMe SSD for the i9 PC**, 1–2 TB | Dedicated build disk for WSL | $70–150 |
| **Pixel 8a or 9a**, unlocked, **not Verizon** | Week 1 exit criterion: our build boots on a real Pixel. The Galaxy S20 can't do this, because it's on the later AOSP line | $300–500 used |
| Good USB-C cable | Flashing | $10 |
| **Offline signing machine**: any old laptop | Release keys are generated and used only on a machine that is never connected to a network. **Not** the ProLiant, and **not** the i9 PC | Free to $200 |
| 2 USB drives | Encrypted key backups, kept in two different places | $30 |

Until the Pixel arrives, either machine can still sync, build images and run every check. Only the boot test waits for the phone.
