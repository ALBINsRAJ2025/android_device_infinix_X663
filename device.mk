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
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_retrofit.mk)

# Updatable APEX
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# A/B OTA
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

# Userspace fastboot
PRODUCT_PACKAGES += \
    fastbootd

# Recovery passthrough HALs
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl.recovery \
    android.hardware.fastboot@1.1-impl-mock \
    android.hardware.health@2.1-impl.recovery

PRODUCT_SHIPPING_API_LEVEL := 30
PRODUCT_CHARACTERISTICS := phone

ifeq ($(PLATFORM_SDK_VERSION),32)
PRODUCT_EXTRA_VNDK_VERSIONS := 31
PRODUCT_VENDOR_PROPERTIES += ro.vndk.version=31
endif

# SoC model properties
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.soc.manufacturer=Mediatek \
    ro.vendor.soc.model=MT6768 \
    ro.vendor.soc.model_ready=1

PRODUCT_PRECOMPILED_SEPOLICY := false

# Recovery-as-boot fstab
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_RECOVERY)/root/first_stage_ramdisk/fstab.mt6768

# Stock carrier APN database
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/apns-conf.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/apns-conf.xml

# Recovery ramdisk
PRODUCT_PACKAGES += \
    init.recovery.mt6768.rc \
    mcDriverDaemon \
    mtk_plpath_utils \
    mtk-plpath-utils.rc \
    mtk-usb.rc \
    ueventd.mt6768.rc

ifeq ($(wildcard vendor/lineage/build/tasks/kernel.mk),)
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/kernel/Image.gz:kernel
endif

# First-boot debug logging
include $(LOCAL_PATH)/debug/debug-bootloop.mk
