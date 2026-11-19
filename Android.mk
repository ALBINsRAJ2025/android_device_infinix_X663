# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
# Filtered stock init scripts

LOCAL_PATH := $(call my-dir)

X663_INIT_SRC := $(TOPDIR)vendor/infinix/X663/proprietary/etc/init/hw
X663_INIT_RC := init.mt6768.rc factory_init.rc meta_init.rc

define x663-filter-init-rc
$(X663_INIT_OUT)/$(1): $(X663_INIT_SRC)/$(1)
	@mkdir -p $$(dir $$@)
	@sed -e '/^on property:persist\.vendor\.tran\.wipedata=/ {N; d;}' \
	     -e '/^on property:sys\.powerctl=\*/ {N; d;}' $$< > $$@
	@if grep -Eq '^[[:space:]]*(tran_factory_reset|powerctl)' $$@; then \
	  echo "X663 init: $$@ still carries a command that init does not know"; \
	  rm -f $$@; exit 1; fi
endef

$(foreach rc,$(X663_INIT_RC),$(eval $(call x663-filter-init-rc,$(rc))))

include $(call all-subdir-makefiles)
