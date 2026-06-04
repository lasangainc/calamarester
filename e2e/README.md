# esterOS Calamares — end-to-end test environment

This directory holds configuration for exercising the full esterOS installer
flow (UI + install jobs) on a development machine or cloud VM.

## One-time setup

From the repository root:

```bash
./ci/e2e-setup.sh
```

This will:

1. Install missing build dependencies (if needed)
2. Configure and build Calamares in `/workspace/build`
3. Build `example.sqfs` (sample target root filesystem)
4. Create an 8 GiB loopback disk image at `e2e/target-disk.img`
5. Attach it to a free `/dev/loopN` device

## UI walkthrough (no root)

Browse every esterOS page without performing an install:

```bash
./ci/e2e-run-gui.sh
```

Uses `calamares -d` from the build tree with the esterOS branding in
`settings.conf`. The partition step is optional in debug mode when no
suitable disk is available.

## Full install (root required)

Install esterOS onto the loopback test disk:

```bash
./ci/e2e-run-install.sh
```

This runs `sudo calamares -d -c e2e/` with a virtual framebuffer. In the
partition step, pick the **loop** device created by setup (shown as
`/dev/loopN`, often ~8 GiB) and choose **Erase disk**.

The install exec phase uses a reduced module set that works on Ubuntu test
hosts (partition → mount → unpackfs → users → umount). Host-specific jobs
such as `bootloader`, `initcpio`, and `initramfs` are omitted because they
require real firmware, kernels, and distribution tooling.

## Loopback disk

The test disk is a **block device**, not a mounted filesystem:

- `./ci/e2e-setup.sh` attaches `e2e/target-disk.img` to `/dev/loopN` with `losetup`
- It should **not** have a mount point before install — Calamares partitions and mounts it during the install jobs
- Check status anytime with `./ci/e2e-status.sh`

In debug mode (`calamares -d`), loopback devices are included in the partition
device list so the test disk appears in the installer UI.

**Requirements for the partition page to list disks:**

- `fdisk` package installed (`sfdisk` is used by KPMCore to scan devices)
- Install test run as root via `./ci/e2e-run-install.sh` (the GUI walkthrough
  without root can skip the partition step in debug mode)

## Cleanup

```bash
./ci/e2e-teardown.sh
```

Detaches the loop device. The disk image is kept so you can re-run installs.

## Files

| Path | Purpose |
|------|---------|
| `settings.conf` | esterOS module sequence for install testing |
| `modules/unpackfs.conf` | Unpacks `build/example.sqfs` into the target |
| `modules/welcomeq.conf` | Low storage/RAM requirements for loop disks |
| `branding/esteros/` | Symlink to `src/branding/esteros/` |
| `qml/` | Symlink to `build/src/qml/` (needed for `-c e2e/`) |
| `target-disk.img` | Loopback install target (created by setup) |
| `.loop-device` | Attached loop device path (created by setup) |
