#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SRC="$ROOT/stock_rom/fs_unpacked"
DST="$ROOT/device/infinix/X663"

mkdir -p "$DST/configs/audio" "$DST/configs/media" "$DST/configs/wifi" \
         "$DST/configs/seccomp" "$DST/configs/permissions" "$DST/configs/vintf" \
         "$DST/sepolicy/vendor"

cp -f "$SRC/vendor/etc/audio_device.xml" "$DST/configs/audio/"
cp -f "$SRC/vendor/etc/audio_effects.xml" "$DST/configs/audio/"
cp -f "$SRC/vendor/etc/audio_em.xml" "$DST/configs/audio/"
cp -f "$SRC/vendor/etc/audio_policy.conf" "$DST/configs/audio/"
cp -f "$SRC/vendor/etc/audio_policy_configuration.xml" "$DST/configs/audio/"
cp -f "$SRC/vendor/etc/audio_policy_configuration_bluetooth_legacy_hal.xml" "$DST/configs/audio/"
cp -f "$SRC/vendor/etc/audio_policy_volumes.xml" "$DST/configs/audio/"

cp -f "$SRC/vendor/etc/media_codecs.xml" "$DST/configs/media/"
cp -f "$SRC/vendor/etc/media_codecs_c2.xml" "$DST/configs/media/"
cp -f "$SRC/vendor/etc/media_codecs_mediatek_audio.xml" "$DST/configs/media/"
cp -f "$SRC/vendor/etc/media_codecs_mediatek_video.xml" "$DST/configs/media/"
cp -f "$SRC/vendor/etc/media_codecs_performance.xml" "$DST/configs/media/"
cp -f "$SRC/vendor/etc/media_codecs_google_audio.xml" "$DST/configs/media/"
cp -f "$SRC/vendor/etc/media_codecs_google_video_le.xml" "$DST/configs/media/"
cp -f "$SRC/vendor/etc/media_profiles_V1_0.xml" "$DST/configs/media/"

cp -f "$SRC/vendor/etc/wifi/p2p_supplicant_overlay.conf" "$DST/configs/wifi/"
cp -f "$SRC/vendor/etc/wifi/wpa_supplicant.conf" "$DST/configs/wifi/"
cp -f "$SRC/vendor/etc/wifi/wpa_supplicant_overlay.conf" "$DST/configs/wifi/"

cp -f "$SRC/vendor/etc/seccomp_policy/android.hardware.media.c2@1.2-extended-seccomp-policy" "$DST/configs/seccomp/"
cp -f "$SRC/vendor/etc/seccomp_policy/android.hardware.media.c2@1.2-mediatek-seccomp-policy" "$DST/configs/seccomp/"
cp -f "$SRC/vendor/etc/seccomp_policy/mediacodec.policy" "$DST/configs/seccomp/"
cp -f "$SRC/vendor/etc/seccomp_policy/mediaextractor.policy" "$DST/configs/seccomp/"
cp -f "$SRC/vendor/etc/seccomp_policy/mediaswcodec.policy" "$DST/configs/seccomp/"

cp -f "$SRC/vendor/etc/public.libraries.txt" "$DST/configs/public.libraries.txt"
cp -f "$SRC/system/system/etc/permissions/privapp-permissions-mediatek.xml" "$DST/configs/permissions/"
cp -f "$SRC/vendor/etc/vintf/manifest.xml" "$DST/configs/vintf/"
cp -f "$SRC/vendor/etc/vintf/compatibility_matrix.xml" "$DST/configs/vintf/"
cp -f "$SRC/vendor/etc/ueventd.rc" "$DST/rootdir/etc/ueventd.mtk.rc"

cp -f "$SRC/vendor/etc/selinux/vendor_file_contexts" "$DST/sepolicy/vendor/file_contexts"
cp -f "$SRC/vendor/etc/selinux/vendor_hwservice_contexts" "$DST/sepolicy/vendor/hwservice_contexts"
cp -f "$SRC/vendor/etc/selinux/vendor_property_contexts" "$DST/sepolicy/vendor/property_contexts"
cp -f "$SRC/vendor/etc/selinux/vendor_seapp_contexts" "$DST/sepolicy/vendor/seapp_contexts"
cp -f "$SRC/vendor/etc/selinux/vendor_service_contexts" "$DST/sepolicy/vendor/service_contexts"
cp -f "$SRC/vendor/etc/selinux/vndservice_contexts" "$DST/sepolicy/vendor/vndservice_contexts"
cp -f "$SRC/vendor/etc/selinux/vendor_mac_permissions.xml" "$DST/sepolicy/vendor/mac_permissions.xml"

echo "Stock-backed X663 device assets synced into device tree."
