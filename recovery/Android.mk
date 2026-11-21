# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
# Recovery ramdisk modules

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := init.recovery.mt6768.rc
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := root/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_OUT)/root
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := mtk_plpath_utils
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES := root/system/bin/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_OUT)/root/system/bin
LOCAL_MULTILIB := 64
LOCAL_CHECK_ELF_FILES := false
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := mtk-plpath-utils.rc
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := root/system/etc/init/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_OUT)/root/system/etc/init
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := mtk-usb.rc
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := root/system/etc/init/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_OUT)/root/system/etc/init
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := ueventd.mt6768.rc
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := root/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_OUT)/root
include $(BUILD_PREBUILT)

# MTK boot HAL for recovery
include $(CLEAR_VARS)
LOCAL_MODULE := android.hardware.boot@1.2.so
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_SRC_FILES := ../../../../vendor/infinix/X663/proprietary/lib64/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_OUT)/root/system/lib64
LOCAL_MULTILIB := 64
LOCAL_CHECK_ELF_FILES := false
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libmtk_bsg.so
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_SRC_FILES := ../../../../vendor/infinix/X663/proprietary/lib64/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_OUT)/root/system/lib64
LOCAL_MULTILIB := 64
LOCAL_CHECK_ELF_FILES := false
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libhardware.so
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_SRC_FILES := root/system/lib64/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_OUT)/root/system/lib64
LOCAL_MULTILIB := 64
LOCAL_CHECK_ELF_FILES := false
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := android.hardware.boot@1.0-impl-1.2-mtkimpl.so
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_SRC_FILES := ../../../../vendor/infinix/X663/proprietary/lib64/hw/$(LOCAL_MODULE)
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_OUT)/root/system/lib64/hw
LOCAL_MULTILIB := 64
LOCAL_CHECK_ELF_FILES := false
include $(BUILD_PREBUILT)
