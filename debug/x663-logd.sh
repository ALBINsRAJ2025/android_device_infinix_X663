#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
#
# X663 first-boot debug collector (see debug-bootloop.mk).
# Started by init at "on init" as root in the su domain (userdebug/eng only).
# logd is started earlier in the same "on init" trigger by AOSP init.rc and,
# because ro.logd.kernel=true, has been forwarding /proc/kmsg into its kernel
# buffer.
#
# Everything is written to /metadata because it is a first_stage_mount,
# unencrypted, and survives a reboot that never gets as far as /data or the
# home screen.  x663-logmirror.sh mirrors the set to external storage as soon
# as vold mounts it, and x663-logreport.sh copies it to /data/local/tmp for
# "adb pull" at boot completion.

LOG_DIR=/metadata/x663-logs
BOOT_ID_FILE="$LOG_DIR/boot_id"

# /metadata is first_stage_mounted, but retry briefly in case init starts us
# while the mount is still being set up.
i=0
while [ "$i" -lt 20 ]; do
    mkdir -p "$LOG_DIR" 2>/dev/null && [ -d "$LOG_DIR" ] && break
    i=$((i + 1))
    sleep 1
done
mkdir -p "$LOG_DIR" 2>/dev/null || exit 1
chmod 0755 "$LOG_DIR" 2>/dev/null

# logd normally wins this race (it starts in "on init"), but wait for its
# sockets so the one-shot snapshot below is not empty and so we do not rely on
# an init restart storm.
i=0
while [ "$i" -lt 20 ]; do
    /system/bin/logcat -b all -d -v threadtime >/dev/null 2>&1 && break
    i=$((i + 1))
    sleep 1
done

BOOT_ID="$(cat /proc/sys/kernel/random/boot_id 2>/dev/null)"
FIRST_RUN=0
if [ -n "$BOOT_ID" ] && [ -f "$BOOT_ID_FILE" ] && \
        [ "$(cat "$BOOT_ID_FILE" 2>/dev/null)" = "$BOOT_ID" ]; then
    # init restarted logcat within the same boot: do not count this as a
    # new boot and do not overwrite the first snapshot.
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

    # If the previous boot never reached sys.boot_completed=1, move its
    # rotated logcat and dmesg snapshots into a failed-boot directory before
    # the new follower starts rotating them away.  Keep only the newest one
    # to bound /metadata usage.
    PREV_DONE=0
    [ -f "$LOG_DIR/boot_completed" ] && PREV_DONE=1
    rm -f "$LOG_DIR/boot_completed"
    if [ "$PREV_DONE" = "0" ] && [ "$COUNT" -gt 1 ]; then
        ARCH="$LOG_DIR/failed-boot-$((COUNT - 1))"
        mkdir -p "$ARCH" 2>/dev/null
        for f in "$LOG_DIR"/logcat "$LOG_DIR"/logcat.* "$LOG_DIR"/boot-*.txt \
                "$LOG_DIR"/dmesg-boot*.txt "$LOG_DIR"/getprop-boot*.txt \
                "$LOG_DIR"/last_kmsg-boot*.txt; do
            [ -f "$f" ] && mv -f "$f" "$ARCH"/ 2>/dev/null
        done
        for d in "$LOG_DIR"/pstore-boot*; do
            [ -d "$d" ] && mv -f "$d" "$ARCH"/ 2>/dev/null
        done
    fi

    # Previous-boot panic/oops residue.  The stock 4.19 kernel has pstore
    # enabled but the stock DTB has no ramoops reserved-memory node, so this
    # is best-effort and can legitimately be empty.  /proc/last_kmsg is also
    # optional and may not exist at all.
    PS_DIR="$LOG_DIR/pstore-boot$COUNT"
    mkdir -p "$PS_DIR" 2>/dev/null
    for f in /sys/fs/pstore/*; do
        [ -f "$f" ] && cp -f "$f" "$PS_DIR/$(basename "$f")" 2>/dev/null
    done
    if [ -f /proc/last_kmsg ]; then
        cat /proc/last_kmsg > "$LOG_DIR/last_kmsg-boot$COUNT.txt" 2>&1
    fi

    # First userspace snapshot.  dmesg contains the whole kernel ring buffer;
    # logcat (below) replays logd's buffers from "on init".
    dmesg > "$LOG_DIR/dmesg-boot$COUNT.txt" 2>&1
    # One-shot dump of everything logd has buffered since "on init".  This is
    # kept as a plain file so the follower's rotation cannot overwrite the
    # earliest userspace messages.
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

    # Bound /metadata usage: one current boot/dmesg/getprop/last_kmsg set,
    # one failed-boot archive, and the newest pstore copy.
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
    for f in $(ls -dt "$LOG_DIR"/failed-boot-* 2>/dev/null | tail -n +2); do
        rm -rf "$f"
    done
    for f in $(ls -dt "$LOG_DIR"/pstore-boot* 2>/dev/null | tail -n +2); do
        rm -rf "$f"
    done
fi

# Follow all buffers, including kernel (ro.logd.kernel=true), and rotate in
# /metadata: 4 * 512 KiB = ~2 MiB maximum.  init restarts this service if
# logcat dies; the boot_id check above keeps the boot counter stable.
exec /system/bin/logcat -b all -v threadtime \
    -f "$LOG_DIR/logcat" -r 512 -n 4
