# Informe BUILD A vs BUILD B (SHRP a35x)
Análisis estático de recovery_A.tar (build 17/08/2026) y recovery_B.tar (build 31/10/2026). Nada se probó en el teléfono.

## Confirmado (medido en las imágenes)
- Cabecera, kernel, DTB y DTBO IDÉNTICOS en A y B (kernel sha 7617639544b7be8c). El kernel NO es la diferencia.
- recovery.fstab IDÉNTICO en A y B. El kernel soporta F2FS y las opciones usadas (whint_mode, inlinecrypt, fsync_mode, reserve_root, resgid, usrquota/grpquota, checkpoint, compress_algorithm).
- Permisos/propietarios: 0 diferencias. Archivos: 100 quitados, 158 añadidos, 15 modificados.
- usb.rc idéntico: USB/ADB no dependen de nada que cambió salvo init de TEEGRIS.

## Regresión DATA
- El binario recovery pasó de 2,695,696 a 2,351,496 bytes. Cadenas "fscrypt" 66→0, "keystore2" 20→0, "TW_INCLUDE_CRYPTO" 1→0.
- Faltan en B (estaban en A): keystore2, fscryptpolicyget, libkeymint, libkeymaster*, libgatekeeper*, libkeystore2*, libhardware_legacy, libsqlite, libxml2, libservices, libfuse-lite, libincfs, libgpt_twrp, avbctl, magiskboot, ntfs-3g.
- Conclusión: B se compiló SIN la pila de cifrado. Con fstab latemount + metadata_encryption eso explica "Failed to mount data" (hipótesis fuerte, no probada en equipo).
- Las ramas visibles tienen TW_INCLUDE_CRYPTO := true, así que el flag escrito no lo explica. La rama gitgud-crypto-test (cabeza) tiene init.recovery.*.rc idénticos a A, no a B: B salió de otro estado del árbol. Falta su BoardConfig.mk, device.mk y commit.
- /system/system/* (17 MB: apk, odex, vdex, apex, fuentes, audio) está en B y no en A. Ruta no estándar, probablemente inerte; ocupa espacio.

## Regresión linterna
- SHRP_FONP_1 = /sys/devices/virtual/camera/flash/rear_flash (igual en todas las ramas).
- La cadena rear_flash vive en leds-sm5714-fled.ko (no se podó, está en la lista de carga de B).
- fimc-is.ko DEFINE el símbolo camera_class; is-flash-sm5714.ko lo IMPORTA. Ambos y sus dependencias propias (pablo-hws/libs/icpu/smc, votf) se podaron en B (22 módulos, paso "Prune" del workflow). En A estaban cargados.
- No está probado que la sola ausencia de esos 7 módulos impida el nodo; falta el dmesg de fled en B.

## Otros cambios A→B
- init.recovery.teegris.rc: wait_for_prop → triggers (fix 2, intencional). Además B QUITÓ setenv LD_LIBRARY_PATH solo del servicio vendor.gatekeeper-1-0 (los demás lo conservan): sin motivo visible.
- init.recovery.s5e8835.rc: B añade symlinks de by-name/param y export ANDROID_ROOT /system_root. /system_root NO existe en el ramdisk de B. No es causa demostrada del fallo.
- prop.default: ro.vendor.build.security_patch vacío → 2025-04-01.

## Cambios propuestos (mínimos)
1. 01-builder: conservar los 7 módulos de la ruta de linterna (sigue podando los otros 15).
2. 02-teegris: restaurar LD_LIBRARY_PATH en gatekeeper (archivo completo incluido).
3. DATA: sin parche hasta tener BoardConfig.mk/device.mk/commit de B y salida de a35_diag.sh.

## Riesgos
- Restaurar los 7 módulos suma 9.6 MB sin comprimir; partición 100,663,296 B, B ocupa 95,125,504. Hay que compensar quitando /system/system.
- fimc-is.ko inicializa hardware de cámara; en A arrancaba bien, pero hay que verificar ADB tras la build.
