# Build host: HP ProLiant Gen10 Plus

PD-SVAK builds **only on x86_64 Linux**. Windows can't build Android, and WSL2 isn't reliable enough for releases.

## The machine

| Part | What we have | Is it enough? |
|---|---|---|
| CPU | Xeon E-2224, 4 cores / 4 threads | Works, but slow: first build about 12–16 h per phone, rebuilds about 3–4 h |
| RAM | 32 GB, **the most this server supports** | The minimum for a build. Can't be upgraded, so the swap settings below are required |
| SSD | 1 TB | Holds the source tree (about 300 GB) plus build output for 2–3 phones |
| HDD | 1 TB | Only for archives: finished releases, kernel source tarballs, backups. **Never build on it** |

It's good enough to start (ROADMAP weeks 1–4). It's tight for monthly releases: 8 launch Pixels × 3–4 h is about 30 h of our 72-hour window. Its RAM is already at the maximum, so the way to speed up is a **second builder**, not upgrades:

- **Plan:** before the first monthly release (January 2027), dual-boot the i9 desktop (8c/16t, 64 GB, NVMe) into Ubuntu 24.04 and split the Pixels between the two machines. Together they rebuild all 8 phones in about 12–15 h.
- **Until then:** the ProLiant builds one phone at a time. Never run two builds at once on it, because 32 GB isn't enough for that.
- **If memory still runs out** during the final linking steps, check `dmesg` for "Out of memory", make sure swap and zram are on (`swapon --show`), and close the desktop session (build over SSH).

## Setup

1. **Firmware:** update the BIOS and iLO with HPE's Service Pack for ProLiant. In the BIOS, set the workload profile to *General Throughput Compute* or *High Performance*, so the CPU isn't held back.
2. **OS:** install **Ubuntu 24.04 LTS** (Desktop is fine) on the **SSD**, using the whole disk, ext4.
3. **HDD:** format it ext4 and mount it at `/srv/pdsvak-archive` (add it to `/etc/fstab`).
4. **Swap:** with 32 GB of RAM, the final linking steps can run out of memory.
   ```bash
   sudo fallocate -l 32G /swapfile && sudo chmod 600 /swapfile
   sudo mkswap /swapfile && sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   sudo apt install -y zram-tools        # compressed RAM swap, used first
   ```
5. **Never sleep:** Settings → Power → Automatic suspend: off. Builds run for many hours.
6. **Network:** wired Ethernet. The first sync downloads about 100 GB.
7. **Project:**
   ```bash
   git clone https://github.com/arvindjonn09/PD-SVAK.git ~/pdsvak/repo
   cd ~/pdsvak/repo
   build/setup-host.sh
   build/sync.sh
   build/build.sh akita          # Pixel 8a, or tegu for a Pixel 9a
   ```
   `PDS_SRC` defaults to `~/pdsvak/src`, which is on the SSD.
8. **CI (optional, later):** register the machine as the self-hosted GitHub Actions runner with the label `pdsvak-builder` (see `.github/workflows/build.yml`).

## Also needed

| Item | Why | Rough cost |
|---|---|---|
| **Pixel 8a or 9a**, unlocked, **not Verizon** | Week 1 exit criterion: our build boots on a real Pixel. The Galaxy S20 can't do this, because it's on the later AOSP line | $300–500 used |
| Good USB-C cable | Flashing | $10 |
| **Offline signing machine**: any old laptop | Release keys are generated and used only on a machine that is never connected to a network. **Not** the ProLiant, and **not** the Windows PC | Free to $200 |
| 2 USB drives | Encrypted key backups, kept in two different places | $30 |

Until the Pixel arrives, the server can still sync, build images and run every check. Only the boot test waits for the phone.
