---
layer: knowledge
type: feature-detection
priority: high
read_order: 8
version: 1.0.0
tags:
  - detection
  - feature
  - discovery
---

# Feature Detection

## DO

| DO | Command | Use |
|----|---------|-----|
| Detect before use | `command -v tool` | Check availability |
| Provide fallback | `if; then ... elif; then` | Chain alternatives |
| Exit on missing critical | `exit 1` | If required |
| Use POSIX detection | `command -v` | Not `which` |

## DON'T

| DON'T | Problem | Fix |
|-------|---------|-----|
| Assume tool exists | May fail | Always detect |
| Use `which` | Not POSIX | Use `command -v` |
| Use single fallback | May not exist | Provide alternatives |
| Continue on missing | Cascading failures | Exit early |

## Detection Checklist

```
[ ] Command availability checked
[ ] Fallback chain provided
[ ] Critical tools required (exit 1)
[ ] Optional tools warned
[ ] OS detected
[ ] Architecture detected
```

## Patterns

### Command Detection
```sh
# DO - with fallback
if command -v curl >/dev/null 2>&1; then
    FETCH="curl -L -s"
elif command -v wget >/dev/null 2>&1; then
    FETCH="wget -q -O -"
elif command -v fetch >/dev/null 2>&1; then
    FETCH="fetch -o -"
else
    echo "Error: No download tool found" >&2
    exit 1
fi

# DON'T - no fallback
curl -L https://example.com
```

### OS Detection
```sh
# DO
OS="$(uname -s 2>/dev/null)"
case "$OS" in
    Linux*)   echo "linux" ;;
    Darwin*)  echo "macos" ;;
    FreeBSD*) echo "freebsd" ;;
    *)        echo "unknown" ;;
esac

# DON'T
echo "Detecting OS..."
# Assume Linux
```

### Required Tool
```sh
# DO - fail fast
require_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: $1 is required" >&2
        exit 1
    fi
}

require_tool curl
require_tool grep

# DON'T - silent failure
curl https://example.com  # Fails without message
```

### Architecture Detection
```sh
# DO
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)  ARCH=x64 ;;
    aarch64) ARCH=arm64 ;;
    armv7*)  ARCH=arm32 ;;
    *)       ARCH=unknown ;;
esac
```

## Detection Matrix

| Feature | Command | Fallback |
|---------|---------|----------|
| Download | `curl` | `wget`, `fetch` |
| JSON parse | `jq` | `awk` (simple) |
| HTTPS | `curl` | `wget` |
| grep -P | N/A | `grep` basic |
| sha256 | `sha256sum` | `sha256` |

## Portuguese

### Propósito

Define padrões para detecção de recursos e ferramentas antes do uso.

## Links

- [[knowledge/md/knowledge/Portable]]
- [[knowledge/md/knowledge/ShellSafety]]