---
layer: tests
type: validation-protocol
priority: high
read_order: 1
version: 1.0.0
tags:
  - validation
  - gates
  - checklist
---

# Validation

## Gates

```
Gate 1 → Gate 2 → Gate 3 → Gate 4
Pre-Exec  RealTime  Post-Exec  Quality
```

## Gate 1: Pre-Execution

| Check | Pass If |
|-------|---------|
| Scope defined | ≤ 3 files |
| No new deps | 0 new |
| Plan minimal | Minimal solution |
| Constraints clear | Listed |

## Gate 2: Real-Time

| Check | Pass If |
|-------|---------|
| Scope maintained | No expansion |
| Complexity | ≤ 10% increase |
| Files created | ≤ 2 |
| Patterns followed | > 80% |

## Gate 3: Post-Execution

| Check | Pass If |
|-------|---------|
| Simpler than before | Yes |
| No new risk | Yes |
| Tests pass | 100% |
| Lint passes | 0 errors |

## Gate 4: Quality

| Check | Pass If |
|-------|---------|
| Complexity | < 10% increase |
| Coverage | > 70% |
| Security | 0 issues |
| Documentation | Updated |

## Validation Checklist

```
[ ] Gate 1: Plan validated
[ ] Gate 2: Changes minimal
[ ] Gate 3: Quality checks pass
[ ] Gate 4: Production ready
```

## Failure Response

| Gate | Fail Action |
|------|-------------|
| 1 | Reject plan |
| 2 | Stop, revert |
| 3 | Rollback |
| 4 | Reject |

## Related

- [[knowledge/md/tests/Automation]]
- [[knowledge/md/control/SelfCheck]]
- [[bin/SCRIPTS]]
