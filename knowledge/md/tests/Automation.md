---
layer: tests
type: automation
priority: high
read_order: 3
version: 1.0.0
tags:
  - automation
  - ci-cd
  - pipeline
---

# Automation

## CI Pipeline

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Validation Gates
        run: ./SCRIPTS/Validation_Gates.sh .
        
      - name: ShellCheck
        run: shellcheck scripts/*.sh
        
  hostile-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Alpine Test
        run: docker run --rm -v $PWD:/app alpine:latest /bin/sh -c "cd /app && ./test.sh"
        
      - name: Busybox Test
        run: docker run --rm -v $PWD:/app busybox:latest /bin/sh -c "cd /app && ./test.sh"
```

## Pre-Commit Setup

```bash
# Install hook
ln -s ../../SCRIPTS/PreCommit_Hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Validation Scripts

| Script | Purpose |
|--------|---------|
| `Validation_Gates.sh` | Full validation |
| `Hostile_Env_Test.sh` | Environment test |
| `Dependency_Check.sh` | Dep validation |
| `PreCommit_Hook.sh` | Git hook |

## Automation Levels

| Level | Method | When |
|-------|--------|-------|
| 1 | Manual review | Optional |
| 2 | Script validation | Required |
| 3 | CI pipeline | Every push |
| 4 | Pre-commit hook | Every commit |

## Checklist

```
[ ] Validation script installed
[ ] Pre-commit hook configured
[ ] CI pipeline configured
[ ] Hostile env tests configured
[ ] Scripts are executable
```

## Related

- [[knowledge/md/tests/Validation]]
- [[knowledge/md/tests/Hostile]]
- [[bin/SCRIPTS]]
