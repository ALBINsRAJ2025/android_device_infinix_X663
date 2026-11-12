#!/bin/bash
# Wrapper used from device/infinix/X663.
exec "$(cd "$(dirname "$0")" && pwd)/../../../vendor/infinix/X663/extract-files.sh" "$@"
