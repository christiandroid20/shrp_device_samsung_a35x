#!/system/bin/sh
# SOLO LECTURA. No monta, no formatea, no escribe en particiones.
# Uso:  adb push a35_diag.sh /tmp/  &&  adb shell sh /tmp/a35_diag.sh  &&  adb pull /tmp/a35_diag.txt
O=/tmp/a35_diag.txt
{
echo "### build"; getprop ro.build.fingerprint; getprop ro.build.date
echo "### nodos de bloque"; ls -l /dev/block/by-name/userdata /dev/block/by-name/metadata /dev/block/bootdevice 2>&1
echo "### by-name (existe?)"; ls -ld /dev/block/by-name 2>&1; ls /dev/block/by-name 2>&1 | head -60
echo "### filesystems del kernel"; grep -E "f2fs|ext4|erofs" /proc/filesystems
echo "### mount"; mount | grep -E " /data| /metadata| /efs| /mnt/vendor"
echo "### /metadata"; ls -la /metadata /metadata/vold 2>&1 | head -30
echo "### /data"; ls -la /data 2>&1 | head
echo "### props crypto"; getprop | grep -iE "crypto|vold|fbe|tzdaemon|tzts|TEEGRIS|keymint|gatekeeper"
echo "### servicios"; getprop | grep -E "init.svc\.(tz_service|tzts_service|vendor.keymint|vendor.gatekeeper|extract_ta|tee_)"
echo "### ANDROID_ROOT"; echo "$ANDROID_ROOT"; ls -ld /system_root 2>&1
echo "### dmesg f2fs/crypto/tee"; dmesg | grep -iE "f2fs|fscrypt|blk-crypto|keymint|keymaster|gatekeeper|teegris|tzdaemon|iccc|userdata|metadata" | tail -80
echo "### linterna"; lsmod 2>/dev/null | grep -iE "fled|fimc|is_flash|sm5714"
ls -la /sys/class/camera /sys/class/leds /sys/devices/virtual/camera 2>&1 | head -40
dmesg | grep -iE "sm5714|fled|fimc|camera|flash" | tail -60
echo "### recovery.log (crypto/data)"; grep -iE "crypt|fbe|keymint|gatekeeper|/data|userdata|metadata|mount" /tmp/recovery.log | tail -120
} > $O 2>&1
echo "listo: $O"
