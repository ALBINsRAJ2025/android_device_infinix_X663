#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
# X663 first-boot debug collector

LOG_DIR=/metadata/x663-logs
BOOT_ID_FILE="$LOG_DIR/boot_id"

mkdir -p "$LOG_DIR" 2>/dev/null
chmod 0755 "$LOG_DIR" 2>/dev/null

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
    case "$COUNT" in ''|*[!0-9]*) COUNT=0 ;; esac
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
                "$LOG_DIR"/last_kmsg-boot*.txt "$LOG_DIR"/kmsg-boot*.txt; do
            [ -f "$f" ] && mv -f "$f" "$ARCH"/ 2>/dev/null
        done
        for d in "$LOG_DIR"/pstore-boot*; do
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
    for f in $(ls -dt "$LOG_DIR"/failed-boot-* 2>/dev/null | tail -n +2); do
        rm -rf "$f"
    done
    for f in $(ls -dt "$LOG_DIR"/pstore-boot* 2>/dev/null | tail -n +2); do
        rm -rf "$f"
    done
fi

cat /proc/kmsg > "$LOG_DIR/kmsg-boot$COUNT.txt" 2>&1 &

exec /system/bin/logcat -b all -v threadtime \
    -f "$LOG_DIR/logcat" -r 512 -n 4
