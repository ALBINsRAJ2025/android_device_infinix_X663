# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
# Filtered stock init scripts

LOCAL_PATH := $(call my-dir)

X663_INIT_SRC := $(TOPDIR)vendor/infinix/X663/proprietary/etc/init/hw

$(X663_INIT_OUT)/%.rc: $(X663_INIT_SRC)/%.rc
	$(hide) mkdir -p $(dir $@)
	$(hide) sed -e '/^on property:persist\.vendor\.tran\.wipedata=/ {N; d;}' \
	              -e '/^on property:sys\.powerctl=\*/ {N; d;}' $< > $@
	$(hide) if grep -Eq '^[[:space:]]*(tran_factory_reset|powerctl)([[:space:]]|$$)' $@; then \
	          echo "X663 init: $@ still carries a command that init does not know"; \
	          rm -f $@; exit 1; fi
