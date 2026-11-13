#
# Galaxy A35 5G (a35x) — AERA Recovery 16.0 packaging options
# SPDX-License-Identifier: Apache-2.0
#
# IMPORTANT: in a fresh build shell, export AERA_BUILD_DEVICE=a35x BEFORE
# sourcing build/envsetup.sh. This file must not set that selector itself.

if [ "$AERA_BUILD_DEVICE" = "a35x" ]; then
    export LC_ALL="C"
    export AERA_PRODUCT_PREFIX=AERA
    export AERA_BUILD_STATUS=Unofficial
    export AERA_BUILD_TYPE=Beta
    export AERA_VANILLA_BUILD=1

    export AERA_USE_TAR_BINARY=1
    export AERA_USE_SED_BINARY=1
    export AERA_USE_LZ4_BINARY=1
    export AERA_USE_ZSTD_BINARY=1
    export AERA_USE_DATE_BINARY=1
    export AERA_USE_GREP_BINARY=1
    export AERA_USE_BUSYBOX_BINARY=1
    export AERA_USE_XZ_UTILS=1
    export AERA_USE_UPDATED_MAGISKBOOT=1
    export AERA_USE_FSCK_EROFS_BINARY=1
    export AERA_USE_PATCHELF_BINARY=1
    export AERA_USE_DMSETUP=1

    export AERA_SETTINGS_ROOT_DIRECTORY=/data/recovery
    export AERA_MISCELLANEOUS_ROOT_DIRECTORY=/sdcard

    # Root Manager, WLAN, mobile data and ABL preservation stay disabled for
    # the first boot bring-up. Enable only after their device dependencies,
    # image size and hardware behavior have been verified.
fi
