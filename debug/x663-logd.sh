#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Log paths and setup

LOG_DIR=/metadata/x663-logs
BOOT_ID_FILE="$LOG_DIR/boot_id"

mkdir -p "$LOG_DIR" 2>/dev/null
chmod 0755 "$LOG_DIR" 2>/dev/null

mount_sdcard() {
    [ -d /mnt/sdcard_debug/x663-logs ] && return 0
    for dev in /dev/block/mmcblk1p1 /dev/block/mmcblk1; do
        if [ -b "$dev" ]; then
            mkdir -p /mnt/sdcard_debug 2>/dev/null
            mount -t vfat -o rw,noatime,nodiratime,fmask=0000,dmask=0000 "$dev" /mnt/sdcard_debug 2>/dev/null || \
            mount -t exfat -o rw,noatime,nodiratime "$dev" /mnt/sdcard_debug 2>/dev/null || \
            mount -t ext4 -o rw,noatime "$dev" /mnt/sdcard_debug 2>/dev/null
            if [ $? -eq 0 ]; then
                mkdir -p /mnt/sdcard_debug/x663-logs 2>/dev/null
                chmod 0777 /mnt/sdcard_debug/x663-logs 2>/dev/null
                return 0
            fi
        fi
    done
    return 1
}

mount_sdcard

BOOT_ID="$(cat /proc/sys/kernel/random/boot_id 2>/dev/null)"
FIRST_RUN=0
if [ -n "$BOOT_ID" ] && [ -f "$BOOT_ID_FILE" ] && \
        [ "$(cat "$BOOT_ID_FILE" 2>/dev/null)" = "$BOOT_ID" ]; then
    FIRST_RUN=0
else
    FIRST_RUN=1
    [ -n "$BOOT_ID" ] && echo "$BOOT_ID" > "$BOOT_ID_FILE"
fi

if [ "$FIRST_RUN" = "1" ]; then
    COUNT=0
    [ -f "$LOG_DIR/boot_count" ] && COUNT="$(cat "$LOG_DIR/boot_count" 2>/dev/null)"
        case "$COUNT" in ""|*[!0-9]*) COUNT=0 ;; esac
    COUNT=$((COUNT + 1))
    echo "$COUNT" > "$LOG_DIR/boot_count"

    PREV_DONE=0
    [ -f "$LOG_DIR/boot_completed" ] && PREV_DONE=1
    rm -f "$LOG_DIR/boot_completed"
    if [ "$PREV_DONE" = "0" ] && [ "$COUNT" -gt 1 ]; then
        ARCH="$LOG_DIR/failed-boot-$((COUNT - 1))"
        mkdir -p "$ARCH" 2>/dev/null
        for f in "$LOG_DIR"/logcat "$LOG_DIR"/logcat.* "$LOG_DIR"/boot-*.txt \
                "$LOG_DIR"/dmesg-boot*.txt "$LOG_DIR"/getprop-boot*.txt \
                "$LOG_DIR"/last_kmsg-boot*.txt "$LOG_DIR"/kmsg-boot*.txt \
                "$LOG_DIR"/ps-boot*.txt "$LOG_DIR"/bootprof-boot*.txt \
                "$LOG_DIR"/mounts-boot*.txt "$LOG_DIR"/df-boot*.txt \
                "$LOG_DIR"/avc-boot*.txt "$LOG_DIR"/binder-*.txt; do
            [ -f "$f" ] && mv -f "$f" "$ARCH"/ 2>/dev/null
        done
        for d in "$LOG_DIR"/pstore-boot* "$LOG_DIR"/periodic; do
            [ -d "$d" ] && mv -f "$d" "$ARCH"/ 2>/dev/null
        done
    fi

    PS_DIR="$LOG_DIR/pstore-boot$COUNT"
    mkdir -p "$PS_DIR" 2>/dev/null
    for f in /sys/fs/pstore/*; do
        [ -f "$f" ] && cp -f "$f" "$PS_DIR/$(basename "$f")" 2>/dev/null
    done
    if [ -f /proc/last_kmsg ]; then
        cat /proc/last_kmsg > "$LOG_DIR/last_kmsg-boot$COUNT.txt" 2>&1
    fi

    dmesg > "$LOG_DIR/dmesg-boot$COUNT.txt" 2>&1
    /system/bin/logcat -b all -d -v threadtime > "$LOG_DIR/boot-$COUNT.txt" 2>&1
    getprop > "$LOG_DIR/getprop-boot$COUNT.txt" 2>&1
    ps -A -T -Z > "$LOG_DIR/ps-boot$COUNT.txt" 2>&1
    cat /proc/bootprof > "$LOG_DIR/bootprof-boot$COUNT.txt" 2>&1
    cat /proc/mounts > "$LOG_DIR/mounts-boot$COUNT.txt" 2>&1
    df -h > "$LOG_DIR/df-boot$COUNT.txt" 2>&1
    dmesg | grep 'avc: ' > "$LOG_DIR/avc-boot$COUNT.txt" 2>&1

    cat /dev/binderfs/binder_logs/failed_transaction_log > "$LOG_DIR/binder-failed-tx-boot$COUNT.txt" 2>/dev/null
    cat /dev/binderfs/binder_logs/transaction_log > "$LOG_DIR/binder-tx-boot$COUNT.txt" 2>/dev/null

    {
        echo "boot=$COUNT"
        echo "boot_id=$BOOT_ID"
        echo "date=$(date 2>/dev/null)"
        echo "uptime=$(cat /proc/uptime 2>/dev/null)"
        echo "bootreason=$(getprop ro.boot.bootreason)"
        echo "verifiedbootstate=$(getprop ro.boot.verifiedbootstate)"
        echo "veritymode=$(getprop ro.boot.veritymode)"
    } >> "$LOG_DIR/boots.txt" 2>&1

    for f in $(ls -t "$LOG_DIR"/boot-*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/dmesg-boot*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/getprop-boot*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/last_kmsg-boot*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/kmsg-boot*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/ps-boot*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/bootprof-boot*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/mounts-boot*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/df-boot*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/avc-boot*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for f in $(ls -t "$LOG_DIR"/binder-*.txt 2>/dev/null | tail -n +2); do
        rm -f "$f"
    done
    for d in $(ls -dt "$LOG_DIR"/failed-boot-* 2>/dev/null | tail -n +2); do
        rm -rf "$d"
    done
    for d in $(ls -dt "$LOG_DIR"/pstore-boot* 2>/dev/null | tail -n +2); do
        rm -rf "$d"
    done

    if [ -d /mnt/sdcard_debug/x663-logs ]; then
        cp -af "$LOG_DIR"/. /mnt/sdcard_debug/x663-logs/ 2>/dev/null
        sync
    fi
fi

cat /proc/kmsg > "$LOG_DIR/kmsg-boot$COUNT.txt" 2>&1 &

flight_recorder() {
    snap_dir="$LOG_DIR/periodic"
    mkdir -p "$snap_dir" 2>/dev/null
    for t in 5 15 30 60 120 300; do
        sleep "$t" 2>/dev/null || break
        [ -f "$LOG_DIR/boot_completed" ] && break

        cur_dir="$snap_dir/t${t}s"
        mkdir -p "$cur_dir" 2>/dev/null
        getprop > "$cur_dir/getprop.txt" 2>&1
        ps -A -T -Z > "$cur_dir/ps.txt" 2>&1
        cat /proc/bootprof > "$cur_dir/bootprof.txt" 2>&1
        dmesg > "$cur_dir/dmesg.txt" 2>&1
        dmesg | grep 'avc: ' > "$cur_dir/avc.txt" 2>&1
        cat /proc/mounts > "$cur_dir/mounts.txt" 2>&1
        df -h > "$cur_dir/df.txt" 2>&1

        mount_sdcard
        if [ -d /mnt/sdcard_debug/x663-logs ]; then
            cp -af "$LOG_DIR"/. /mnt/sdcard_debug/x663-logs/ 2>/dev/null
            sync
        fi
    done
}

flight_recorder &

exec /system/bin/logcat -b all -v threadtime \
    -f "$LOG_DIR/logcat" -r 512 -n 4
