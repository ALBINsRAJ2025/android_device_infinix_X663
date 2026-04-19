LOCAL_PATH := device/infinix/X663

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6768 \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6768:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6768 \
    $(LOCAL_PATH)/rootdir/etc/init.mt6768.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.mt6768.rc

PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    kernel/infinix/X663 \
    vendor/infinix/X663

PRODUCT_COPY_FILES += \
    $(foreach module,$(wildcard kernel/infinix/X663/modules/*.ko),$(module):$(TARGET_COPY_OUT_VENDOR)/lib/modules/$(notdir $(module)))
