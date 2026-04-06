---
layer: tests
type: hostile-environment
priority: high
read_order: 2
version: 1.0.0
tags:
  - tests
  - hostile
  - environment
---

# Hostile

## DO

| DO | Environment |
|----|-------------|
| Test in Alpine | musl libc |
| Test in Busybox | Minimal tools |
| Test as non-root | Permissions |
| Test with minimal PATH | No assumptions |
| Test with network disabled | Offline behavior |
| Test in Docker scratch | No shell |

## DON'T

| DON'T | Problem |
|-------|---------|
| Assume tools exist | May not |
| Assume root | Usually not |
| Assume full PATH | Often stripped |
| Assume network | May be offline |
| Assume bash | May be sh only |

## Test Checklist

```
Environment Tests:
[ ] Alpine Linux (musl)
[ ] Busybox
[ ] Debian Oldstable
[ ] Non-root user
[ ] Minimal PATH
[ ] Network disabled
[ ] Disk full scenario
[ ] Read-only filesystem
[ ] No bash
[ ] Docker scratch
```

## Docker Test Commands

```bash
# Alpine test
docker run --rm -v "$PWD:/app" alpine:latest /bin/sh -c "cd /app && ./test.sh"

# Busybox test
docker run --rm -v "$PWD:/app" busybox:latest /bin/sh -c "cd /app && ./test.sh"

# Non-root test
docker run --rm --user 1000:1000 -v "$PWD:/app" alpine:latest /bin/sh -c "cd /app && ./test.sh"

# Minimal PATH test
docker run --rm -v "$PWD:/app" alpine:latest /bin/sh -c "PATH=/bin:/usr/bin && cd /app && ./test.sh"
```

## Related

- [[knowledge/md/tests/Validation]]
- [[knowledge/md/knowledge/Environment]]
- [[bin/SCRIPTS]]
