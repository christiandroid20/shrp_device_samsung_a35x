#!/sbin/sh
#
# A35x TEE trustlet extraction for recovery.
# Do not report crypto.ready=1 unless every required file was copied.
#

VENDOR_BLOCK="/dev/block/mapper/vendor"
VENDOR_MOUNT="/tmp/a35x_vendor"
TEE_TARGET="/vendor/tee"
MODEL="$(getprop ro.boot.em.model)"
TIMEOUT=120
ELAPSED=0
RESULT=1

log() {
    echo "extract_ta: $*" > /dev/kmsg 2>/dev/null
}

# The mapper can appear after first-stage logical partition setup.
while [ ! -e "$VENDOR_BLOCK" ]; do
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        log "timeout waiting for $VENDOR_BLOCK (model=$MODEL)"
        setprop crypto.ready 0
        setprop crypto.error "vendor_mapper_timeout"
        exit 1
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

mkdir -p "$VENDOR_MOUNT" "$TEE_TARGET/driver" || {
    setprop crypto.ready 0
    setprop crypto.error "mkdir_failed"
    exit 1
}

if ! mount -o ro "$VENDOR_BLOCK" "$VENDOR_MOUNT"; then
    log "unable to mount vendor"
    setprop crypto.ready 0
    setprop crypto.error "vendor_mount_failed"
    exit 1
fi

# Samsung firmware may place A35 trustlets in a regional tee_* folder.
# Select the source by the complete A35 trustlet UUID set, not by model name.
TEE_SOURCE=""
for candidate in "$VENDOR_MOUNT"/tee*; do
    [ -d "$candidate" ] || continue

    if [ -f "$candidate/driver/00000000-0000-0000-0000-53626f786476" ] &&
       [ -f "$candidate/driver/00000000-0000-0000-0000-494363447256" ] &&
       [ -f "$candidate/00000000-0000-0000-0000-4b45594d5354" ] &&
       [ -f "$candidate/00000000-0000-0000-0000-0053545354ab" ] &&
       [ -f "$candidate/00000000-0000-0000-0000-474154454b45" ]; then
        TEE_SOURCE="$candidate"
        break
    fi
done

if [ -z "$TEE_SOURCE" ]; then
    log "no tee directory contains all required A35 trustlets (model=$MODEL)"
    setprop crypto.ready 0
    setprop crypto.error "required_trustlets_missing"
else
    if cp -p "$TEE_SOURCE/driver/00000000-0000-0000-0000-53626f786476" "$TEE_TARGET/driver/" &&
       cp -p "$TEE_SOURCE/driver/00000000-0000-0000-0000-494363447256" "$TEE_TARGET/driver/" &&
       cp -p "$TEE_SOURCE/00000000-0000-0000-0000-4b45594d5354" "$TEE_TARGET/" &&
       cp -p "$TEE_SOURCE/00000000-0000-0000-0000-0053545354ab" "$TEE_TARGET/" &&
       cp -p "$TEE_SOURCE/00000000-0000-0000-0000-474154454b45" "$TEE_TARGET/"; then
        RESULT=0
    fi

    if [ "$RESULT" -eq 0 ]; then
        log "trustlets copied from $TEE_SOURCE for $MODEL"
        setprop crypto.error ""
        setprop crypto.ready 1
    else
        log "failed copying one or more trustlets from $TEE_SOURCE"
        setprop crypto.ready 0
        setprop crypto.error "trustlet_copy_failed"
    fi
fi

umount "$VENDOR_MOUNT"
rmdir "$VENDOR_MOUNT" 2>/dev/null

exit "$RESULT"
