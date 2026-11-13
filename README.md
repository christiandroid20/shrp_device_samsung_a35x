# AERA Recovery — Samsung Galaxy A35 5G (a35x)

**Status: experimental bring-up. Not yet compiled or tested on hardware.**

Target: Samsung Galaxy A35 5G, initially SM-A356E / Exynos 1380 (s5e8835), Android 15 U4 / bootloader binary B:4. This tree is intended for the AERA 16.0 manifest and core, not the SHRP 12.1 build environment.

## Build with the official AERA 16.0 manifest

Use a fresh shell and a clean AERA source checkout:

```bash
mkdir -p ~/android/AERA_16.0
cd ~/android/AERA_16.0

repo init -u https://github.com/AERA-Recovery/android_manifest.git -b aera-16.0
repo sync -c --force-sync --no-clone-bundle --no-tags -j"$(nproc)"

git clone -b aera16-a35x-bringup \
  https://github.com/christiandroid20/shrp_device_samsung_a35x.git \
  device/samsung/a35x

# This selector must be exported BEFORE envsetup is sourced.
export AERA_BUILD_DEVICE=a35x
source build/envsetup.sh
lunch twrp_a35x-bp2a-eng

# Adjust -j2 to the actual RAM/CPU available on the build host.
m -j2 adbd recoveryimage
```

Expected output: `out/target/product/a35x/recovery.img`.

Do not use the existing `SkyHawk [SHRP]` workflow for this branch: that workflow syncs the SHRP 12.1 manifest and installs the SHRP android-12.1 recovery core. AERA requires the AERA `aera-16.0` manifest and AERA recovery source.

## First boot validation

The first goal is a non-destructive boot test, not a full feature release.

1. Confirm the image is no larger than the physical recovery partition (100,663,296 bytes); do not increase the configured partition size.
2. Record SHA-256 and build commit IDs.
3. Test boot, native UI, touch, ADB, USB reconnection, MTP/sideload and partition discovery.
4. Check storage mounts without formatting or wiping anything.
5. Treat /data decryption as unverified until tested against the exact installed U4 firmware and a real PIN-protected user.
6. Do not flash BL, PIT, modem, vbmeta or other boot-chain partitions; do not update the device firmware or binary revision for this bring-up.

## Known limitations before first build

- The tree retains the A35 prebuilt kernel, DTB and DTBO. Their compatibility with the AERA 16.0 image packaging still requires a successful build and hardware boot.
- The A35 fstab describes FBE v2 and metadata encryption, but /keydata and /keyrefuge are not added because their block-device paths have not been verified on this firmware.
- TEEGRIS, KeyMint, Gatekeeper and FKeymaster are started from one recovery init sequence after TA validation. Duplicate stock vendor init service declarations were removed to prevent early/racing starts.
- The TA validation script currently expects the installed U4 vendor logical partition at dm-4. If the mapping differs, crypto stays unready rather than trusting ramdisk copies.
- Matching A35 Mali EGL/GLES, allocator/gralloc and dependency libraries are not yet packaged. AERA's native graphics path requires a compatible vendor graphics stack for GPU acceleration; do not copy Qualcomm/OnePlus graphics blobs into this Exynos tree.
- Root Manager, WLAN, mobile data and ABL preservation are intentionally not enabled in the first bring-up build. They can be added after boot, image-size and hardware dependencies are validated.

## Security patch handling

No fixed OS/vendor security patch values are injected by this tree. KeyMint must observe the actual installed ROM's OS and security patch properties; placeholders or stale values can invalidate keyblob upgrades.

## Project direction

After a stable AERA boot, extend this device tree with the A35X-specific GSI Manager / ROM Adaptation Studio. Keep that work separate from the initial recovery bring-up.
