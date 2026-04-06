---
layer: knowledge
type: dependency-rules
priority: high
read_order: 4
version: 1.0.0
tags:
  - dependencies
  - discipline
  - minimalism
---

# Dependency

## DO

| DO | Reason |
|----|--------|
| Declare all deps | Explicit is safe |
| Verify before use | Detect missing |
| Minimize count | Less is more |
| Prefer built-ins | No external |
| Document requirements | Clear contract |

## DON'T

| DON'T | Problem |
|-------|---------|
| Add deps for convenience | Liability |
| Hide deps | Latent bugs |
| Use latest versions | Compatibility |
| Trust external | Security risk |
| Assume availability | Environments vary |

## Dependency Hierarchy

```
1. No dependency (built-in/shell)
2. Standard library only
3. Single proven dependency
4. Multiple deps (avoid)
```

## Checklist

```
[ ] No external dependencies (if possible)
[ ] All dependencies declared
[ ] Dependencies verified at runtime
[ ] Fallback provided
[ ] Minimal count (< 5)
[ ] No heavy frameworks
```

## DO Examples

### Shell Built-ins
```sh
# DO - use built-in
[ "${#string}" -gt 0 ]

# DON'T - external command
echo "$string" | wc -l
```

### Fallback Pattern
```sh
# DO - with fallback
if command -v jq >/dev/null 2>&1; then
    parse_json() { jq -r "$1" "$2"; }
elif command -v python3 >/dev/null 2>&1; then
    parse_json() { python3 -c "import json,sys; print(json.load(sys.stdin)$1)"; }
else
    parse_json() { echo "Error: jq or python3 required" >&2; exit 1; }
fi
```

## Forbidden Dependencies

| Dependency | Reason | Alternative |
|------------|--------|-------------|
| Boost | Heavy | Standard library |
| jQuery | Browser only | Vanilla JS |
| Lodash | Large | Native methods |
| Moment.js | Heavy | Native Date |
| curl | External | Built-in (if available) |

## Decision Tree

```
Need functionality?
    │
    ├── Can shell built-in do it?
    │       └── YES: Use built-in
    │
    ├── Can POSIX tool do it?
    │       └── YES: Use POSIX tool
    │
    ├── Single simple tool?
    │       └── YES: Add dependency
    │
    └── Multiple tools/complex?
            └── NO: Redesign solution
```

## Portuguese

### Propósito

Define disciplina de dependências. Toda dependência é um risco.

## Links

- [[knowledge/md/knowledge/Environment]]
- [[knowledge/md/knowledge/FeatureDetection]]