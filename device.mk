LOCAL_PATH := device/infinix/X663

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6768 \
    $(LOCAL_PATH)/rootdir/etc/init.mt6768.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.mt6768.rc

# Disable NFC components for X663 variant.
PRODUCT_PACKAGES += \
    android.hardware.health-service.mediatek
