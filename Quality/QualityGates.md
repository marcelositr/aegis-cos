---
title: Quality Gates
title_pt: Portões de Qualidade
layer: quality
type: concept
priority: high
version: 1.0.0
tags:
  - Quality
  - QualityGates
description: Checkpoints that must be passed before code can proceed in the delivery pipeline.
description_pt: Pontos de verificação que devem ser passados antes do código poder avançar no pipeline de entrega.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Quality Gates

## Description

Quality gates are automated checkpoints in CI/CD that enforce quality standards before code can proceed. They ensure:
- Minimum test coverage
- No critical bugs
- Passing linting
- Security scan passes

## Purpose

**When quality gates are valuable:**
- For enforcing standards automatically
- For preventing bad code from reaching production
- For maintaining consistency across team
- For compliance requirements

**When gates may cause friction:**
- When too strict or slow
- When false positives are common
- When blocking hotfixes

**The key question:** What quality standards must be met before deploying?

## Examples

```yaml
# GitHub Actions quality gate
- name: Quality Checks
  run: |
    pylint src/ --fail-under=8
    coverage run -m pytest
    coverage report --fail-under=80
    bandit -r src/

- name: Quality Gate Check
  if: always()
  run: |
    if [ "${{ steps.tests.outputs.failed }}" -eq 1 ]; then
      echo "Tests failed"
      exit 1
    fi
    if [ "${{ steps.coverage.outputs.percentage }}" -lt 80 ]; then
      echo "Coverage below threshold"
      exit 1
    fi
```

## Standard Gates

| Gate | Threshold |
|------|------------|
| Test Coverage | > 80% |
| Code Review | Approved |
| Security Scan | 0 Critical |
| Linting | Pass |
| Complexity | < 15 per function |

## Anti-Patterns

### 1. Gates Too Strict Blocking Delivery

**Bad:** Setting impossible thresholds (100% coverage, zero warnings) that no PR can pass
**Why it's bad:** Developers bypass the gates entirely or the gates are disabled under pressure — the gates become meaningless and trust in quality processes erodes
**Good:** Set achievable thresholds based on the current codebase state and tighten them gradually — gates should be challenging but passable

### 2. Hotfix Bypass Becoming the Norm

**Bad:** Using emergency bypass procedures for regular deployments because "the gate is blocking us"
**Why it's bad:** The bypass becomes the standard path — quality gates exist on paper but are never enforced in practice
**Good:** Define strict, auditable criteria for bypass — require post-deployment gate compliance and track bypass frequency as a quality metric itself

### 3. Gates Without Clear Remediation

**Bad:** A quality gate fails with a cryptic error message and no guidance on how to fix it
**Why it's bad:** Developers are blocked but do not know what to do — they waste hours investigating instead of fixing
**Good:** Provide actionable error messages with specific remediation steps — tell developers exactly what failed and how to fix it

### 4. Gates Only at the End of the Pipeline

**Bad:** Running all quality checks only at the pre-deployment stage, after hours of build and test time
**Why it's bad:** Issues are discovered late when fixes are most expensive — a lint failure should not require waiting for a full deployment pipeline
**Good:** Add quality gates at multiple stages — fast checks (linting, formatting) in pre-commit, medium checks (tests, coverage) in PR, and comprehensive checks (security, performance) in pre-deployment

## Best Practices

### 1. Define Early

```yaml
# Define in project setup
# Everyone knows expectations
```

### 2. Make Blocking

```yaml
# Don't let failures pass silently
# Block deployment on failure
```

### 3. Start Strict

```yaml
# Can always relax
# Hard to tighten later
```

## Failure Modes

- **Quality gates too strict blocking delivery** → impossible thresholds prevent any deployment → gates become ignored or bypassed → set achievable thresholds and tighten gradually over time
- **Quality gates too lenient providing no value** → thresholds so low everything passes → gates do not prevent quality degradation → set meaningful thresholds based on historical baselines
- **Gates without clear failure remediation** → build fails but no guidance on how to fix → developers blocked without direction → provide actionable error messages and remediation steps
- **Gate configuration drift** → different branches have different gate rules → inconsistent quality enforcement → share gate configuration in version control
- **Hotfix bypass becoming norm** → emergency bypasses used for regular deployments → gate effectiveness erodes → define strict criteria for bypass and require post-deployment gate compliance
- **False positives in security gates** → security scanner flags legitimate code → developers disable security checks → tune security rules and maintain allowlist with documented justification
- **Quality gates only at end of pipeline** → issues discovered late in deployment process → expensive fixes and delayed releases → add quality gates at multiple stages: pre-commit, PR, and pre-deployment

## Related Topics

- [[CiCd]]
- [[StaticAnalysis]]
- [[Linting]]
- [[TestCoverage]]
- [[Metrics]]
- [[CodeQuality]]
- [[SecurityHeaders]]
- [[Monitoring]]

## Key Takeaways

- Quality gates are automated checkpoints in CI/CD that enforce quality standards like test coverage, linting, and security scans before code proceeds
- Valuable for enforcing standards automatically, preventing bad code from reaching production, and meeting compliance requirements
- Causes friction when too strict, when false positives are common, or when blocking emergency hotfixes
- Tradeoff: consistent quality enforcement versus risk of blocking delivery and creating bypass culture
- Main failure mode: setting impossible thresholds (100% coverage, zero warnings) causes developers to bypass gates entirely, eroding trust in quality processes
- Best practice: set achievable thresholds based on current codebase state and tighten gradually, add gates at multiple stages (pre-commit, PR, pre-deployment), provide actionable error messages with remediation steps, and define strict auditable criteria for bypass
- Related: CI/CD, static analysis, linting, test coverage, metrics, code quality, security headers
