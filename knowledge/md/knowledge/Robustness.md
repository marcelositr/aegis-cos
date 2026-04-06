---
layer: knowledge
type: robustness-rules
priority: critical
read_order: 3
version: 1.0.0
tags:
  - robustness
  - fail-fast
  - defensive
---

# Robustness

## DO

| DO | When |
|----|------|
| Fail immediately | Error detected |
| Validate input | Always |
| Check return values | Every call |
| Handle edge cases | Null, empty, overflow |
| Log errors | With context |
| Clean up | On exit/error |

## DON'T

| DON'T | Problem |
|-------|---------|
| Continue on error | Cascading failure |
| Assume input valid | User/environment hostile |
| Ignore return values | Silent bugs |
| Leak resources | Memory/files/handles |
| Swallow exceptions | Hidden failures |

## Error Handling Checklist

```
[ ] Input validated
[ ] Return values checked
[ ] Errors logged
[ ] Resources cleaned
[ ] Fail-fast enabled (set -eu)
[ ] Edge cases handled
[ ] Timeout configured
```

## Patterns

### Fail Fast
```sh
# DO - fail immediately
validate_input() {
    [ -z "$1" ] && return 1
    [ ${#1} -gt 100 ] && return 1
    return 0
}

if ! validate_input "$input"; then
    echo "Error: Invalid input" >&2
    exit 1
fi

# DON'T - continue silently
if [ -z "$input" ]; then
    : # Do nothing
fi
```

### Input Validation
```sh
# DO - validate everything
[ -z "${1:-}" ] && exit 1      # Required
[ -n "${1:-}" ] || exit 1       # Not empty
[ "${#1}" -le 100 ] || exit 1   # Length
[ -f "$1" ] || exit 1            # File exists
[ -r "$1" ] || exit 1           # Readable
```

### Resource Cleanup
```sh
# DO
tmpfile="$(mktemp)"
tmpdir="$(mktemp -d)"

cleanup() {
    rm -f "$tmpfile"
    rm -rf "$tmpdir"
}
trap cleanup EXIT INT TERM

# DON'T - no cleanup
tmpfile="/tmp/myapp_$$"
# Will leak on error
```

### Error Recovery
```sh
# DO - specific handling
case $? in
    1) echo "Invalid input" ;;
    2) echo "File not found" ;;
    3) echo "Permission denied" ;;
    *) echo "Unknown error" ;;
esac

# DON'T - generic
if [ $? -ne 0 ]; then
    echo "Error"  # What error?
fi
```

## Error Levels

| Level | Action | Exit Code |
|-------|--------|-----------|
| FATAL | Exit immediately | 1 |
| ERROR | Return error | > 0 |
| WARN | Log and continue | 0 |
| INFO | Log only | 0 |

## Portuguese

### Propósito

Define práticas para código robusto que falha rapidamente e limpa recursos.

## Links

- [[knowledge/md/knowledge/ShellSafety]]
- [[knowledge/md/knowledge/FeatureDetection]]