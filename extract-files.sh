#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2026 ALBINsRAJ2025
# Wrapper used from device/infinix/X663.
exec "$(cd "$(dirname "$0")" && pwd)/../../../vendor/infinix/X663/extract-files.sh" "$@"
