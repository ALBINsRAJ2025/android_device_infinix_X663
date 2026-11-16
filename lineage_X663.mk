# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
#
# lineage_X663.mk - Infinix Note 11 (X663)
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
$(call inherit-product, device/infinix/X663/device.mk)

# LineageOS-only resource overlay.  lineage-sdk defines resources that plain
# AOSP does not have (lineage-sdk/lineage/res/res/values/config.xml of
# LineageOS 19.1), so this directory is applied to the Lineage product only.
# build/make/core/soong_config.mk:80 turns DEVICE_PACKAGE_OVERLAYS into Soong's
# DeviceResourceOverlays, the same mechanism device.mk uses for overlay/.
DEVICE_PACKAGE_OVERLAYS += device/infinix/X663/overlay-lineage

# Lineage's APN module writes the same path as the stock APN copy.
PRODUCT_PACKAGES := $(filter-out apns-conf.xml,$(PRODUCT_PACKAGES))

PRODUCT_NAME := lineage_X663
PRODUCT_DEVICE := X663
PRODUCT_BRAND := Infinix
PRODUCT_MODEL := Infinix X663
PRODUCT_MANUFACTURER := INFINIX MOBILITY LIMITED

PRODUCT_GMS_CLIENTID_BASE := android-infinix
