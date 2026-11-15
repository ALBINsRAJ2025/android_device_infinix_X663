# Fully permissive policy (ROM side)

`permissive.te` marks **every** type of the platform and the vendor policy as
permissive:

```
permissive <type>;
```

With every type permissive the kernel logs every denial and enforces nothing,
which is the ROM-side equivalent of a fully permissive system.  It is generated
by `generate.sh` from `sepolicy/aosp_provided_types.txt` (the AOSP 12.1
platform types) and `sepolicy/vendor.te` (the ported vendor types) — 2,952
types.

## It cannot replace the kernel side

The stock kernel **cannot** be made permissive, from either direction:

| Mechanism | Stock kernel | Why |
| --- | --- | --- |
| boot parameter `enforcing=0` / `selinux=0` | ignored | `CONFIG_SECURITY_SELINUX_BOOTPARAM is not set` |
| `/sys/fs/selinux/enforce` write | read-only | `security/selinux/selinuxfs.c` compiles `sel_write_enforce` out unless `CONFIG_SECURITY_SELINUX_DEVELOP` |
| `androidboot.selinux=permissive` (Android init) | no effect | init writes to `/sys/fs/selinux/enforce`, which has no handler |
| kernel default at boot | enforcing | `CONFIG_SECURITY_SELINUX_DEVELOP is not set`, so `selinux_enforcing_boot = 1` |

A kernel-side permissive build needs a kernel built with
`CONFIG_SECURITY_SELINUX_DEVELOP=y`, which needs the kernel source — not part
of the delivered firmware (see `PENDING.md`, kernel-source task).

## Enabling

`BoardConfig.mk`:

```make
X663_SELINUX_PERMISSIVE ?= false
```

Set it to `true` for a fully permissive build.  AOSP 12 refuses a `user` build
when a policy contains permissive domains (`system/sepolicy/Android.mk` runs
`sepolicy-analyze permissive` and errors out), so keep this to
userdebug/eng.

Combine it with `X663_SEPOLICY_PORT := true` when the ported vendor policy
exists; the permissive list then also covers the ported types.

## What to expect

* every denial appears in `logcat`/`dmesg` as `avc: denied ... permissive=1`;
* nothing is enforced, so HALs and services start even when their policy is
  incomplete — this is the intended debugging state;
* **do not ship this**: it removes all SELinux protection.
