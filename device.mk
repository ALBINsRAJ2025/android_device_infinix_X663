# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
# device.mk - Infinix Note 11 (X663)

LOCAL_PATH := device/infinix/X663
X663_INIT_OUT := $(if $(OUT_DIR),$(OUT_DIR),out)/target/product/$(if $(TARGET_DEVICE),$(TARGET_DEVICE),X663)/obj/X663-INIT

# Stock vendor payload
$(call inherit-product, vendor/infinix/X663/X663-vendor.mk)

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6768 \
    $(LOCAL_PATH)/rootdir/etc/init.x663.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.x663.rc \
    $(LOCAL_PATH)/rootdir/etc/chipinfo_init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/chipinfo_init.rc \
    $(LOCAL_PATH)/rootdir/etc/odm_sepolicy.cil:$(TARGET_COPY_OUT_VENDOR)/odm/etc/selinux/odm_sepolicy.cil \
    $(LOCAL_PATH)/rootdir/etc/odm_property_contexts:$(TARGET_COPY_OUT_VENDOR)/odm/etc/selinux/odm_property_contexts \
    $(LOCAL_PATH)/rootdir/etc/android.hardware.keymaster@4.1-service.trustonic.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/android.hardware.keymaster@4.1-service.trustonic.rc \
    $(LOCAL_PATH)/rootdir/etc/trustonic.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/trustonic.rc \
    $(X663_INIT_OUT)/init.mt6768.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mt6768.rc \
    $(X663_INIT_OUT)/factory_init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/factory_init.rc \
    $(X663_INIT_OUT)/meta_init.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/meta_init.rc

# Framework resource overlay
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Virtual A/B
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_SUPER_PARTITION := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch.mk)

# Dynamic partition sizes
PRODUCT_BUILD_PRODUCT_IMAGE := true
PRODUCT_BUILD_SYSTEM_IMAGE := true
PRODUCT_BUILD_SYSTEM_EXT_IMAGE := true
PRODUCT_BUILD_VENDOR_IMAGE := true
PRODUCT_BUILD_ODM_IMAGE := false

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock.recovery \
    fastbootd

# Update engine
PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

# Recovery tools
PRODUCT_PACKAGES += \
    recovery_ui \
    e2fsck.recovery \
    fsck.f2fs.recovery \
    make_f2fs.recovery \
    tune2fs.recovery \
    wait_for_key \
    touch_test

# Sideload and ramdisk binaries
PRODUCT_PACKAGES += \
    libhardware \
    mtk_plpath_utils \
    mcDriverDaemon \
    mtk-plpath-utils.rc \
    mtk-usb.rc

# Overlays
PRODUCT_PACKAGES += \
    CarrierConfigResCommon \
    LineageSDKOverlay \
    LineageSettingsOverlay \
    SettingsProviderOverlay \
    TelephonyOverlay \
    WifiOverlay

# Lineage health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl-lineage \
    android.hardware.health@2.1-service

# Lights
PRODUCT_PACKAGES += \
    android.hardware.lights-service.lineage

# Touch
PRODUCT_PACKAGES += \
    libinput \
    libhidlbase

# Lineage namespaces
PRODUCT_SOONG_NAMESPACES += $(LOCAL_PATH)
