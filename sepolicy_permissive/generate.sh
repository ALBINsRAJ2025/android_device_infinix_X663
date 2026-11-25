#!/usr/bin/env bash
set -euo pipefail
cd "\./.."
python3 - <<"PY"
import re
domains = set()
for line in open("sepolicy/vendor.te"):
    m = re.match(r"^typeattribute\s+(\S+)\s+domain;", line.strip())
    if m:
        domains.add(m.group(1))
    m2 = re.match(r"^type\s+(\S+).*domain.*", line.strip())
    if m2:
        domains.add(m2.group(1))
with open("sepolicy_permissive/permissive.te", "w") as fh:
    fh.write("# SPDX-License-Identifier: Apache-2.0
# Permissive domains

")
    for d in sorted(domains):
        fh.write(f"permissive {d};
")
print(f"permissive.te: {len(domains)} domains")
PY
