---
layer: knowledge
type: shell-rules
priority: critical
read_order: 2
version: 1.0.0
tags:
  - shell
  - safety
  - checklist
---

# Shell Safety

## DO

| DO | Command | Example |
|----|---------|---------|
| Enable error handling | `set -eu` | Top of every script |
| Quote variables | `"$var"` | Always |
| Use mktemp | `tmp="$(mktemp)"` | For temp files |
| Use trap | `trap cleanup EXIT` | Cleanup always |
| Check errors | `|| exit 1` | After critical commands |
| Validate input | `[ -n "$1" ]` | Before use |
| Use command -v | `command -v tool` | Detect availability |
| Check exit status | `if command; then` | Before using output |

## DON'T

| DON'T | Problem | Fix |
|-------|---------|-----|
| `echo $var` | Splits on spaces | `echo "$var"` |
| `rm $file` | Breaks on spaces | `rm "$file"` |
| `[ $var = x ]` | Error if empty | `[ "$var" = x ]` |
| `rm *.tmp` | Glob may fail | `set -f; rm *.tmp` |
| `tmp=/tmp/file$$` | Race condition | `mktemp` |
| `cd $dir` | No error check | `cd "$dir" || exit` |
| `cat file \| grep` | Useless cat | `grep pattern file` |
| `command > file` | No error check | `command > file || exit` |

## Checklist

```
[ ] set -eu at top
[ ] All variables quoted
[ ] trap cleanup EXIT
[ ] mktemp for temp files
[ ] Error handling on critical commands
[ ] Input validation
[ ] No dangerous operations
```

## Patterns

### Essential Header
```sh
#!/bin/sh
set -eu

tmpfile="$(mktemp)"
trap 'rm -f "$tmpfile"' EXIT
```

### Safe Variables
```sh
# DO
name="${1:-}"
if [ -z "$name" ]; then
    echo "Usage: $0 <name>" >&2
    exit 1
fi

# DON'T
name=$1
echo $name
```

### Safe Globbing
```sh
# DO
set -f
for f in *.tmp; do
    [ -f "$f" ] && rm "$f"
done
set +f

# OR check first
ls *.tmp >/dev/null 2>&1 && rm *.tmp
```

### Safe Conditionals
```sh
# DO
if [ "$count" -gt 0 ] && [ "$count" -lt 100 ]; then

# DON'T
if [ $count -gt 0 ]; then
```

## Common Failures

| Failure | Cause | Prevention |
|---------|-------|------------|
| File not found | Space in path | Quote variables |
| Syntax error | Empty variable | Use `${var:-}` |
| Loop fails | Word splitting | Quote variables |
| Permissions | No check | Test before use |
| Disk full | No check | Verify space |

## Portuguese

### Propósito

Define práticas de segurança para scripts shell, prevenindo falhas comuns.

## Links

- [[knowledge/md/knowledge/Portable]]
- [[knowledge/md/knowledge/FeatureDetection]]