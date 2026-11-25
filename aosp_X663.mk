# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
# aosp_X663.mk - Infinix Note 11 (X663)

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, device/infinix/X663/device.mk)

PRODUCT_NAME := aosp_X663
PRODUCT_DEVICE := X663
PRODUCT_BRAND := Infinix
PRODUCT_MODEL := Infinix X663
PRODUCT_MANUFACTURER := INFINIX MOBILITY LIMITED

PRODUCT_GMS_CLIENTID_BASE := android-infinix
