#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
# External log mirror

SRC=/metadata/x663-logs
POLL=5
SYNC_EVERY=6

find_ext() {
    if [ -d /mnt/sdcard_debug/x663-logs ]; then
        echo "/mnt/sdcard_debug/x663-logs"
        return 0
    fi

    for dev in /dev/block/mmcblk1p1 /dev/block/mmcblk1; do
        if [ -b "$dev" ]; then
            mkdir -p /mnt/sdcard_debug 2>/dev/null
            mount -t vfat -o rw,noatime,nodiratime,fmask=0000,dmask=0000 "$dev" /mnt/sdcard_debug 2>/dev/null || \
            mount -t exfat -o rw,noatime,nodiratime "$dev" /mnt/sdcard_debug 2>/dev/null || \
            mount -t ext4 -o rw,noatime "$dev" /mnt/sdcard_debug 2>/dev/null
            if [ $? -eq 0 ]; then
                mkdir -p /mnt/sdcard_debug/x663-logs 2>/dev/null
                chmod 0777 /mnt/sdcard_debug/x663-logs 2>/dev/null
                echo "/mnt/sdcard_debug/x663-logs"
                return 0
            fi
        fi
    done

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

sync_metadata() {
    dst="$1"
    [ -d "$SRC" ] || return 1
    mkdir -p "$dst/metadata" 2>/dev/null || return 1
    cp -af "$SRC"/. "$dst/metadata"/ 2>/dev/null
}

write_readme() {
    dst="$1"
    [ -f "$dst/README.txt" ] && return
    {
        echo "X663 debug logs"
        echo "metadata/       mirror of /metadata/x663-logs"
        echo "logcat-external direct logcat follower"
        echo "report/         boot-completed report, if boot reached the home screen"
    } > "$dst/README.txt" 2>/dev/null
}

DST=""
while true; do
    NEW="$(find_ext)"
    if [ -z "$NEW" ]; then
        sleep "$POLL"
        continue
    fi

    if [ "$NEW" != "$DST" ]; then
        DST="$NEW"
        write_readme "$DST"
        chmod 0777 "$DST" 2>/dev/null
        restorecon -R "$DST" 2>/dev/null
    fi

    sync_metadata "$DST"

    /system/bin/logcat -b all -v threadtime \
        -f "$DST/logcat-external" -r 512 -n 4 &
    LPID=$!

    i=0
    while kill -0 "$LPID" 2>/dev/null; do
        sleep "$POLL"

        CUR="$(find_ext)"
        if [ "$CUR" != "$DST" ]; then
            kill "$LPID" 2>/dev/null
            break
        fi

        sync_metadata "$DST"
        i=$((i + 1))
        if [ "$i" -ge "$SYNC_EVERY" ]; then
            sync
            i=0
        fi
    done

    wait "$LPID" 2>/dev/null
    sleep 1
done
