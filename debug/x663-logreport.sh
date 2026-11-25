#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
# First-boot debug report

SRC=/metadata/x663-logs
DST=/data/local/tmp/x663-logs

find_ext() {
    if [ -d /mnt/sdcard_debug/x663-logs ]; then
        echo "/mnt/sdcard_debug/x663-logs"
        return 0
    fi

    for base in /storage/* /mnt/media_rw/* /mnt/expand/*; do
        case "$base" in
            /storage/emulated|/storage/emulated/*|/storage/self|/storage/self/*)
                continue
                ;;
        esac
        [ -d "$base" ] || continue
        d="$base/x663-logs"
        mkdir -p "$d" 2>/dev/null || continue
        : > "$d/.x663-write-test" 2>/dev/null || continue
        rm -f "$d/.x663-write-test" 2>/dev/null
        echo "$d"
        return 0
    done

    for base in /data/media/0 /sdcard /storage/emulated/0; do
        [ -d "$base" ] || continue
        d="$base/x663-logs"
        mkdir -p "$d" 2>/dev/null || continue
        : > "$d/.x663-write-test" 2>/dev/null || continue
        rm -f "$d/.x663-write-test" 2>/dev/null
        echo "$d"
        return 0
    done

    return 1
}

rm -rf "$DST" 2>/dev/null
mkdir -p "$DST" 2>/dev/null
chmod 0777 "$DST" 2>/dev/null

cp -af "$SRC"/. "$DST"/ 2>/dev/null

cp -af /data/tombstones "$DST"/tombstones 2>/dev/null
cp -af /data/anr "$DST"/anr 2>/dev/null

/system/bin/logcat -b all -d -v threadtime > "$DST/logcat-bootcompleted.txt" 2>&1
dmesg > "$DST/dmesg-bootcompleted.txt" 2>&1
getprop > "$DST/getprop-bootcompleted.txt" 2>&1
ps -A -T -Z > "$DST/ps-bootcompleted.txt" 2>&1
cat /proc/bootprof > "$DST/bootprof-bootcompleted.txt" 2>&1
mount > "$DST/mount-bootcompleted.txt" 2>&1
df -h > "$DST/df-bootcompleted.txt" 2>&1
timeout 30 dumpsys activity activities > "$DST/dumpsys-activity.txt" 2>&1
timeout 30 dumpsys window windows > "$DST/dumpsys-window.txt" 2>&1

restorecon -R "$DST" 2>/dev/null
chmod -R 0777 "$DST" 2>/dev/null

settings put global development_settings_enabled 1 2>/dev/null
settings put global adb_enabled 1 2>/dev/null

date > "$SRC/boot_completed" 2>/dev/null

EXT="$(find_ext)"
if [ -n "$EXT" ]; then
    mkdir -p "$EXT/report" "$EXT/metadata" 2>/dev/null
    cp -af "$DST"/. "$EXT/report"/ 2>/dev/null
    cp -af "$SRC"/. "$EXT/metadata"/ 2>/dev/null
    date > "$EXT/boot_completed" 2>/dev/null
    restorecon -R "$EXT" 2>/dev/null
    chmod -R 0777 "$EXT" 2>/dev/null
    sync
fi
