#!/sbin/sh
#
# Samsung TEEGRIS TA validation for Galaxy A35x recovery.
# The recovery.fstab mounts the real vendor logical partition at /vendor.
# TA files already live in /vendor/tee, so do not remount vendor elsewhere
# or attempt to copy files onto the read-only vendor partition.

VENDOR="/vendor"
TEE="$VENDOR/tee"
OK=1
attempt=0

setprop crypto.ready 0

# Wait for first-stage fstab mount of the logical vendor partition.
while [ "$attempt" -lt 90 ] && [ ! -d "$TEE" ]; do
    sleep 1
    attempt=$((attempt + 1))
done

if [ ! -d "$TEE" ]; then
    echo "E:extract_ta: /vendor/tee did not become available within 90 seconds" >> /tmp/recovery.log
    exit 1
fi

check_required() {
    source_file="$1"
    if [ ! -s "$source_file" ]; then
        echo "E:extract_ta: required TEE file missing: $source_file" >> /tmp/recovery.log
        OK=0
        return 1
    fi
    return 0
}

# Crypto Manager Driver
check_required "$TEE/driver/00000000-0000-0000-0000-53626f786476"
# ICCC Driver
check_required "$TEE/driver/00000000-0000-0000-0000-494363447256"
# KeyMint TA
check_required "$TEE/00000000-0000-0000-0000-4b45594d5354"
# TZ_ICCC TA
check_required "$TEE/00000000-0000-0000-0000-0053545354ab"
# Gatekeeper TA
check_required "$TEE/00000000-0000-0000-0000-474154454b45"

if [ "$OK" -ne 1 ]; then
    echo "E:extract_ta: TEE validation incomplete; crypto.ready remains 0" >> /tmp/recovery.log
    exit 1
fi

echo "I:extract_ta: required A35x TEE files found in the real /vendor mount" >> /tmp/recovery.log
setprop crypto.ready 1
exit 0
