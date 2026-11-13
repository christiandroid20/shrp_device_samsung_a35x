#
# Galaxy A35 5G (a35x) — AERA Recovery 16.0 product
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_PLATFORM := erd8835
PRODUCT_RELEASE_NAME := a35x

BOARD_VENDOR := samsung

PRODUCT_DEVICE := a35x
PRODUCT_NAME := twrp_a35x
PRODUCT_BRAND := samsung
PRODUCT_MODEL := Samsung Galaxy A35 5G
PRODUCT_MANUFACTURER := samsung

DEVICE_PATH := device/samsung/a35x

$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(DEVICE_PATH)/device.mk)
