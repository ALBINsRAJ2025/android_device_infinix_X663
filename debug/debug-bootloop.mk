# SPDX-License-Identifier: Apache-2.0
# X663 first-boot debug configuration

X663_DEBUG_BOOTLOOP ?= true

ifeq ($(X663_DEBUG_BOOTLOOP),true)
ifneq ($(filter userdebug eng,$(TARGET_BUILD_VARIANT)),)

PRODUCT_PRODUCT_PROPERTIES += \
    ro.adb.secure=0 \
    ro.logd.kernel=true \
    ro.logd.size=1M \
    ro.logd.size.kernel=1M \
    persist.sys.usb.config=adb

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/debug/x663-logd.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/x663-logd.rc \
    $(LOCAL_PATH)/debug/x663-logd.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/x663-logd.sh \
    $(LOCAL_PATH)/debug/x663-logmirror.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/x663-logmirror.sh \
    $(LOCAL_PATH)/debug/x663-logreport.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/x663-logreport.sh

endif
endif
