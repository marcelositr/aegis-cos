---
layer: knowledge
type: portability-rules
priority: critical
read_order: 1
version: 1.0.0
tags:
  - portability
  - posix
  - shell
---

# Portable Code

## DO

### Shell Scripts

| DO | Reason |
|----|--------|
| Use `#!/bin/sh` | POSIX guaranteed |
| Use `[ ]` for tests | POSIX standard |
| Use `printf '%s\n'` | Portable output |
| Use `command -v` | POSIX command detection |
| Quote variables `"$var"` | Handle spaces |
| Check return values | Detect failures |
| Use `set -eu` | Fail safely |

### C Code

| DO | Reason |
|----|--------|
| Use `<stdlib.h>` | Always available |
| Use `<string.h>` | Standard string ops |
| Use `<stdio.h>` | Standard I/O |
| Check `malloc` return | Handle OOM |
| Use `snprintf` | Prevent overflow |
| Use `fgets` for lines | Safe line reading |

## DON'T

### Shell Scripts

| DON'T | Why |
|-------|-----|
| Use `#!/bin/bash` | Not POSIX |
| Use `[[ ]]` | Bash-ism |
| Use `echo -e` | Non-portable |
| Use `grep -P` | Perl regex, GNU only |
| Use `sed -i` | GNU extension |
| Use `which` | Not POSIX |
| Use `$var` unquoted | Breaks on spaces |
| Use `cat file \| grep` | Useless use of cat |

### C Code

| DON'T | Why |
|-------|-----|
| Include `<features.h>` | GNU-specific |
| Include `<bsd/string.h>` | BSD-only |
| Use `strdup()` | GNU extension |
| Use `asprintf()` | GNU extension |
| Use `getline()` | GNU extension |
| Use `strlcpy()` | BSD-only |
| Assume `long long` | May not exist |
| Assume `wchar_t` | Not portable |

## Checklist

```
[ ] Uses #!/bin/sh
[ ] No bash-isms ([[ ]], $(( )), etc)
[ ] Variables quoted
[ ] Error handling (set -eu)
[ ] No GNU-only commands
[ ] POSIX compliant (sh -n passes)
```

## Patterns

### Command Detection
```sh
# DO
if command -v curl >/dev/null 2>&1; then

# DON'T
if which curl >/dev/null 2>&1; then
```

### Safe Echo
```sh
# DO
printf '%s\n' "$message"

# DON'T
echo -e "$message"
```

### Fallback Chain
```sh
# DO
if command -v curl >/dev/null 2>&1; then
    FETCH="curl -L"
elif command -v wget >/dev/null 2>&1; then
    FETCH="wget -O -"
else
    echo "Error: No download tool" >&2
    exit 1
fi
```

## Portuguese

### Propósito

Define regras para código shell portável usando apenas ferramentas POSIX.

## Links

- [[knowledge/md/knowledge/ShellSafety]]
- [[knowledge/md/knowledge/FeatureDetection]]