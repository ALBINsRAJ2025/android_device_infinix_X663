LOCAL_PATH := device/infinix/X663

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6768 \
    $(LOCAL_PATH)/rootdir/etc/init.mt6768.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.mt6768.rc
