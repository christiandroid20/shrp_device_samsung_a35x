# A35X AERA 16.0 bring-up notes

## Build target
- Manifest: https://github.com/AERA-Recovery/android_manifest.git
- Manifest branch: `aera-16.0`
- Device tree: `christiandroid20/shrp_device_samsung_a35x`
- Device tree branch: `aera16-a35x-bringup`
- Product/lunch: `twrp_a35x-bp2a-eng`
- Build target: `adbd recoveryimage`

## Repairs applied
1. Converted product naming from `omni_a35x` to the AERA reference convention `twrp_a35x`.
2. Added `Android.bp` Soong namespace and aligned `Android.mk` with the AERA reference tree.
3. Updated shipping API/VNDK metadata to API 34 (A35 launch level); Android 15 U4 remains the target installed firmware.
4. Moved supported AERA flags into BoardConfig/product makefiles and guarded packaging exports in `vendorsetup.sh`.
5. Removed hardcoded security patch values from BoardConfig and vendor.prop.
6. Kept the A35 boot header v2, prebuilt kernel/DTB/DTBO and physical recovery size; changed boot arguments to additive assignments.
7. Added `system_dlkm` to the dynamic partition list because it is present in the A35 fstab.
8. Centralized TEEGRIS, KeyMint, Gatekeeper and FKeymaster service definitions in `init.recovery.teegris.rc`; removed duplicate stock vendor service rc files that could start services before TEEGRIS readiness.
9. Preserved non-blocking EFS mounts and the existing real-vendor TA validation path.

## Deliberately not enabled
- Root Manager, WLAN, mobile data, ABL preservation and device-specific fastboot/slot preservation.
- No new /keydata or /keyrefuge fstab entries: block paths have not been verified.
- No graphics blobs imported from another SoC. Matching Exynos/Mali EGL/GLES and allocator dependencies remain a hardware bring-up item.
- No changes to prebuilt kernel, DTB, DTBO, firmware, bootloader, PIT, modem or partition layout.

## Validation status
- Static tree changes only.
- Not compiled.
- Not boot-tested.
- Decryption, touch, USB, MTP, fastbootd and graphics acceleration remain unverified.
