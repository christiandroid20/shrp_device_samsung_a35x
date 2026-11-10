#!/sbin/sh
#
# Samsung TEEGRIS TA extraction for Galaxy A35x recovery.
# crypto.ready is raised only after the required TA and driver files
# have been copied successfully from the mounted vendor logical partition.

OUT="/tmp/vendor"
SRC=""
OK=1
attempt=0

setprop crypto.ready 0

cleanup() {
    umount "$OUT" 2>/dev/null
    rm -rf "$OUT"
}

trap cleanup 0

# Wait for first-stage logical partition mapping, but do not block recovery forever.
while [ "$attempt" -lt 90 ] && [ ! -e /dev/block/mapper/vendor ]; do
    sleep 1
    attempt=$((attempt + 1))
done

if [ ! -e /dev/block/mapper/vendor ]; then
    echo "E:extract_ta: vendor mapper did not appear within 90 seconds" >> /tmp/recovery.log
    exit 1
fi

mkdir -p "$OUT" /vendor/tee/driver
if ! mount -o ro /dev/block/mapper/vendor "$OUT"; then
    echo "E:extract_ta: failed to mount vendor logical partition" >> /tmp/recovery.log
    exit 1
fi

model="$(getprop ro.boot.em.model)"
case "$model" in
    "SM-A546E")
        if [ -d "$OUT/tee_sea" ]; then
            SRC="$OUT/tee_sea"
        else
            SRC="$OUT/tee"
        fi
        ;;
    "SM-A546B")
        if [ -d "$OUT/tee_eur" ]; then
            SRC="$OUT/tee_eur"
        else
            SRC="$OUT/tee"
        fi
        ;;
    *)
        SRC="$OUT/tee"
        ;;
esac

copy_required() {
    source_file="$1"
    target_file="$2"
    if [ ! -s "$source_file" ]; then
        echo "E:extract_ta: required TEE file missing: $source_file" >> /tmp/recovery.log
        OK=0
        return 1
    fi
    if ! cp -p "$source_file" "$target_file"; then
        echo "E:extract_ta: failed to copy: $source_file" >> /tmp/recovery.log
        OK=0
        return 1
    fi
    return 0
}

# Crypto Manager Driver
copy_required "$SRC/driver/00000000-0000-0000-0000-53626f786476" \
    "/vendor/tee/driver/00000000-0000-0000-0000-53626f786476"
# ICCC Driver
copy_required "$SRC/driver/00000000-0000-0000-0000-494363447256" \
    "/vendor/tee/driver/00000000-0000-0000-0000-494363447256"
# KeyMint TA
copy_required "$SRC/00000000-0000-0000-0000-4b45594d5354" \
    "/vendor/tee/00000000-0000-0000-0000-4b45594d5354"
# TZ_ICCC TA
copy_required "$SRC/00000000-0000-0000-0000-0053545354ab" \
    "/vendor/tee/00000000-0000-0000-0000-0053545354ab"
# Gatekeeper TA
copy_required "$SRC/00000000-0000-0000-0000-474154454b45" \
    "/vendor/tee/00000000-0000-0000-0000-474154454b45"

if [ "$OK" -ne 1 ]; then
    echo "E:extract_ta: TEE extraction incomplete; crypto.ready remains 0" >> /tmp/recovery.log
    exit 1
fi

echo "I:extract_ta: required A35x TEE files copied successfully" >> /tmp/recovery.log
setprop crypto.ready 1
exit 0
