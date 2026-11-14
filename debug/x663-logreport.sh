#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
#
# X663 first-boot debug report (see debug-bootloop.mk).
# Started by init at sys.boot_completed=1 as root in the su domain.
# Copies the persistent /metadata log set to /data/local/tmp/x663-logs,
# where it can be pulled without root.

SRC=/metadata/x663-logs
DST=/data/local/tmp/x663-logs

# Keep only this boot's report in /data/local/tmp.  The authoritative copy
# stays in /metadata.
rm -rf "$DST" 2>/dev/null
mkdir -p "$DST" 2>/dev/null
chmod 0777 "$DST" 2>/dev/null

# Copy the persistent early-boot set first: logcat rotations, dmesg/getprop
# snapshots, pstore/last_kmsg copies and failed-boot archives.  This is the
# part that matters most if a later dumpsys hangs.
cp -af "$SRC"/. "$DST"/ 2>/dev/null

# Crash data normally collected by the framework.
cp -af /data/tombstones "$DST"/tombstones 2>/dev/null
cp -af /data/anr "$DST"/anr 2>/dev/null

# State at the home screen: buffers still hold early boot and crash data.
/system/bin/logcat -b all -d -v threadtime > "$DST/logcat-bootcompleted.txt" 2>&1
dmesg > "$DST/dmesg-bootcompleted.txt" 2>&1
getprop > "$DST/getprop-bootcompleted.txt" 2>&1
ps -A > "$DST/ps-bootcompleted.txt" 2>&1
mount > "$DST/mount-bootcompleted.txt" 2>&1
df -h > "$DST/df-bootcompleted.txt" 2>&1
timeout 30 dumpsys activity activities > "$DST/dumpsys-activity.txt" 2>&1
timeout 30 dumpsys window windows > "$DST/dumpsys-window.txt" 2>&1

# Files created by the su domain need the normal /data/local/tmp label so a
# non-root "adb pull" can read them.
restorecon -R "$DST" 2>/dev/null
chmod -R 0777 "$DST" 2>/dev/null

# Developer options / USB debugging UI.  AdbService derives the real adb
# state from persist.sys.usb.config (forced to adb above), so this only makes
# the Settings toggle reflect that state.
settings put global development_settings_enabled 1 2>/dev/null
settings put global adb_enabled 1 2>/dev/null

# Mark this boot as complete only after the report succeeded.  The next boot
# uses the marker's presence to decide whether to keep a failed-boot archive.
date > "$SRC/boot_completed" 2>/dev/null
