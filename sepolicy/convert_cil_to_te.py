#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0

import argparse
import os
import re
import sys

def parse_cil(text):
    """Return the list of top-level s-expressions as nested lists."""
    stack = []
    top = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c == ';':
            j = text.find('\n', i)
            i = n if j < 0 else j + 1
            continue
        if c == '(':
            expr = []
            if stack:
                stack[-1].append(expr)
            else:
                top.append(expr)
            stack.append(expr)
        elif c == ')':
            if not stack:
                raise ValueError('unbalanced ) at %d' % i)
            stack.pop()
        elif c.isspace():
            pass
        else:
            j = i
            while j < n and not text[j].isspace() and text[j] not in '()':
                j += 1
            tok = text[i:j]
            if stack:
                stack[-1].append(tok)
            i = j
            continue
        i += 1
    if stack:
        raise ValueError('unbalanced ( in input')
    return top

def head(expr):
    return expr[0] if expr and isinstance(expr[0], str) else ''

def atoms(expr):
    return [x for x in expr[1:] if isinstance(x, str)]

def class_perms(expr, kind='allow'):
    """Extract (class, [perms], [xperms]) from a CIL rule body.

    allow / dontaudit / neverallow:
        (class (perm perm ...))
    allowx:
        (class perm perm ... (xperm xperm ...))
    """
    cls = None
    perms = []
    xperms = []
    for item in expr[1:]:
        if not isinstance(item, list):
            continue
        strings = [s for s in item if isinstance(s, str)]
        lists = [l for l in item if isinstance(l, list)]
        if not strings and not lists:
            continue
        if cls is None:
            cls = strings[0] if strings else None
            rest = strings[1:]
            if kind == 'allowx':
                perms = rest
                if lists:
                    xperms = [s for s in lists[0] if isinstance(s, str)]
            else:
                if lists:
                    perms = [s for s in lists[0] if isinstance(s, str)]
                else:
                    perms = rest
            continue
        for l in lists:
            vals = [s for s in l if isinstance(s, str)]
            if not perms:
                perms = vals
            elif not xperms:
                xperms = vals
    return cls, perms, xperms

def fmt_perms(perms):
    if not perms:
        return ''
    return ' { %s }' % ' '.join(perms)

def fmt_xperms(xperms):
    if not xperms:
        return ''
    return ' { %s }' % ' '.join(xperms)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('cil')
    ap.add_argument('out')
    ap.add_argument('--types', default=None,
                    help='file with AOSP-provided type names, one per line')
    ap.add_argument('--attrs', default=None,
                    help='file with AOSP-provided attribute names, one per line')
    ap.add_argument('--keep-neverallow', action='store_true')
    args = ap.parse_args()

    aosp_types = set()
    aosp_attrs = set()
    for path, target in ((args.types, aosp_types), (args.attrs, aosp_attrs)):
        if path and os.path.exists(path):
            with open(path) as fh:
                for line in fh:
                    line = line.strip()
                    if line and not line.startswith('#'):
                        target.add(line)

    with open(args.cil, errors='replace') as fh:
        stmts = parse_cil(fh.read())

    counts = {}
    aliases = {}
    out = []
    skipped_types = []
    skipped_attrs = []

    def note(key):
        counts[key] = counts.get(key, 0) + 1

    for e in stmts:
        if head(e) == 'typealiasactual':
            a = atoms(e)
            if len(a) >= 2:
                aliases[a[0]] = a[1]

    def expand(name):
        return aliases.get(name, name)

    for e in stmts:
        kind = head(e)
        if kind == 'type':
            a = atoms(e)
            if not a:
                continue
            name = expand(a[0])
            if name in aosp_types:
                note('type:already-in-AOSP')
                skipped_types.append(name)
                continue
            out.append('type %s;' % name)
            note('type')
        elif kind == 'typeattribute':
            a = atoms(e)
            if not a:
                continue
            name = expand(a[0])
            if name in aosp_attrs or name in aosp_types:
                note('typeattribute:already-in-AOSP')
                skipped_attrs.append(name)
                continue
            out.append('typeattribute %s;' % name)
            note('typeattribute')
        elif kind == 'typeattributeset':
            a = atoms(e)
            if not a:
                continue
            attr = expand(a[0])
            members = []
            for item in e[1:]:
                if isinstance(item, list):
                    members.extend(expand(s) for s in item if isinstance(s, str))
            for m in members:
                if m in aosp_types or m in aosp_attrs:
                    if attr in aosp_attrs or attr in aosp_types:
                        note('typeattributeset:already-in-AOSP')
                        continue
                out.append('typeattribute %s %s;' % (m, attr))
                note('typeattribute-membership')
        elif kind == 'roletype':
            note('roletype:dropped')
        elif kind == 'neverallow':
            if args.keep_neverallow:
                a = atoms(e)
                cls, perms, _ = class_perms(e, kind)
                if len(a) >= 2 and cls:
                    out.append('neverallow %s %s:%s%s;' %
                               (expand(a[0]), expand(a[1]), cls, fmt_perms(perms)))
                    note('neverallow')
            else:
                note('neverallow:dropped')
        elif kind in ('allow', 'dontaudit', 'auditallow'):
            a = atoms(e)
            cls, perms, _ = class_perms(e, kind)
            if len(a) < 2 or not cls:
                note(kind + ':unparsed')
                continue
            out.append('%s %s %s:%s%s;' %
                       (kind, expand(a[0]), expand(a[1]), cls, fmt_perms(perms)))
            note(kind)
        elif kind == 'allowx':
            a = atoms(e)
            cls, perms, xperms = class_perms(e, kind)
            if len(a) < 2 or not cls:
                note('allowx:unparsed')
                continue
            out.append('allowx %s %s:%s%s%s;' %
                       (expand(a[0]), expand(a[1]), cls,
                        fmt_perms(perms), fmt_xperms(xperms)))
            note('allowx')
        elif kind == 'typetransition':
            a = atoms(e)
            if len(a) < 4:
                note('typetransition:unparsed')
                continue
            out.append('type_transition %s %s:%s %s;' %
                       (expand(a[0]), expand(a[1]), a[2], expand(a[3])))
            note('type_transition')
        elif kind == 'genfscon':
            a = atoms(e)
            ctx = None
            for item in e[1:]:
                if isinstance(item, list) and item:
                    vals = [x for x in item if isinstance(x, str)]
                    if len(vals) >= 3 and vals[0] == 'u':
                        user, role, typ = vals[0], vals[1], expand(vals[2])
                        rng = None
                        for sub in item:
                            if isinstance(sub, list) and len(sub) >= 2:
                                rng = [x for x in sub if isinstance(x, str)]
                        sens = ''
                        if rng:
                            lo, hi = rng[0], rng[-1]
                            if lo == hi:
                                sens = lo
                            else:
                                sens = '%s-%s' % (lo, hi)
                        ctx = '%s:%s:%s' % (user, role, typ)
                        if sens:
                            ctx = '%s:%s' % (ctx, sens)
            if len(a) < 2 or ctx is None:
                note('genfscon:unparsed')
                continue
            out.append('genfscon %s %s %s;' % (a[0], a[1], ctx))
            note('genfscon')
        elif kind == 'typealias':
            note('typealias:expanded')
        elif kind == 'typealiasactual':
            note('typealiasactual:expanded')
        else:
            note(kind + ':unsupported')

    header = ['# SPDX-License-Identifier: Apache-2.0', '']

    with open(args.out, 'w') as fh:
        fh.write('\n'.join(header))
        fh.write('\n'.join(out))
        fh.write('\n')

    print('wrote %s: %d lines' % (args.out, len(out)))
    for k in sorted(counts):
        print('  %-38s %d' % (k, counts[k]))
    print('  types already in AOSP: %d, attributes already in AOSP: %d' %
          (len(skipped_types), len(skipped_attrs)))
    return 0

if __name__ == '__main__':
    sys.exit(main())
