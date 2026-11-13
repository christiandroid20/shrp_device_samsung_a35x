#
# Galaxy A35 5G (a35x) — AERA-specific product configuration
# SPDX-License-Identifier: Apache-2.0
#

# Panel geometry and controls. Brightness range/path are inherited from the
# existing A35 TWRP/SHRP device configuration and must be confirmed at runtime.
AERA_SCREEN_H := 2340
AERA_BRIGHTNESS_PATH := "/sys/class/backlight/panel/brightness"
AERA_DEFAULT_BRIGHTNESS := 128
AERA_MAX_BRIGHTNESS := 510

# The stock A35 panel supports 120 Hz. AERA will select this mode only if the
# matching DRM mode is exposed by the recovery kernel.
AERA_DRM_FIXED_REFRESH_RATE := 120
