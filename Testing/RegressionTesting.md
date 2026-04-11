---
title: Regression Testing
title_pt: Testes de Regressão
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - RegressionTesting
description: Testing to ensure new changes don't break existing functionality.
description_pt: Testando para garantir que novas mudanças não quebram funcionalidade existente.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Regression Testing

## Description

Regression tests ensure new changes don't break existing functionality. They run after every change to catch unintended side effects.

Types of regression testing:
- **Full regression** — entire test suite, run before releases
- **Targeted regression** — tests affected by the change, run on every PR
- **Automated regression** — CI pipeline catches regressions early
- **Manual regression** — exploratory testing for areas hard to automate

## Purpose

**When regression testing is critical:**
- Before every production release
- After refactoring or architectural changes
- When fixing bugs (add test to prevent recurrence)
- In systems with complex interdependencies
- For compliance and safety-critical systems

**When regression testing may be lighter:**
- For isolated changes with clear blast radius
- In early-stage prototypes
- When change is purely cosmetic (formatting, comments)

**The key question:** What existing functionality could this change break?

## Test Selection Strategies

### Impact-Based Selection

```python
# Run tests that touch changed modules
# Tools: pytest-testmon, Bazel test selection
# Analyzes which tests exercise changed code
```

### Risk-Based Selection

```
High risk → Full regression
- Database schema changes
- API contract changes
- Authentication/authorization changes

Medium risk → Targeted regression
- Business logic changes
- New feature additions

Low risk → Quick smoke tests
- UI text changes
- Configuration updates
```

## Best Practices

### 1. Automate in CI

```yaml
# CI runs regression tests on every PR
- name: Quick Regression (Unit Tests)
  run: pytest tests/unit/ -q --tb=short

- name: Full Regression (Before Release)
  run: pytest tests/ -q --tb=short --cov=src --cov-report=xml
```

### 2. Categorize by Speed

```python
# Fast: unit tests (< 1 min)
pytest tests/unit/ -q

# Medium: integration tests (< 5 min)
pytest tests/integration/ -q

# Slow: full regression (< 30 min)
pytest tests/ -q
```

### 3. Guard Against Flaky Tests

```python
# Flaky tests destroy regression confidence
# Use: pytest-rerunfailures, quarantine flaky tests
# Fix root cause: timing issues, shared state, external dependencies
```

## Failure Modes

- **Flaky tests** → false positives → team ignores failures → regressions slip through
- **Slow regression suite** → developers skip running locally → late detection
- **No test for bug fix** → same bug recurs → wasted debugging time
- **Test environment drift** → tests pass in CI but fail in production → false confidence

## Anti-Patterns

### 1. Flaky Tests Destroying Regression Confidence

**Bad:** Regression tests that sometimes pass and sometimes fail for reasons unrelated to the code change
**Why it's bad:** The team learns to ignore test failures — real regressions slip through because every failure is assumed to be "just another flaky test"
**Good:** Quarantine flaky tests immediately, fix the root cause (timing issues, shared state, external dependencies), and never merge code that introduces flakiness

### 2. No Test for Bug Fixes

**Bad:** Fixing a production bug without adding a regression test to prevent recurrence
**Why it's bad:** The same bug returns weeks or months later — someone changes related code and the bug reappears, requiring the same debugging effort all over again
**Good:** Every bug fix must include a regression test — the test should fail before the fix and pass after it, proving the fix actually works

### 3. Slow Regression Suite

**Bad:** A full regression test that takes 30+ minutes to run, causing developers to skip it
**Why it's bad:** Regressions are detected late — after merge, after deployment, or worse, in production — when the cost of fixing is highest
**Good:** Categorize tests by speed — fast unit tests run on every commit, medium integration tests run on PR, and full regression runs before release

### 4. Test Environment Drift

**Bad:** Regression tests pass in CI but fail in production because the test environment does not match production
**Why it's bad:** False confidence — the regression suite gives a green signal but the system still breaks in production because the tests never exercised the real environment
**Good:** Use containerized test environments that mirror production configuration — same OS, same dependencies, same network topology

## Related Topics

- [[UnitTesting]] — Foundation of regression suites
- [[IntegrationTesting]] — Catching integration regressions
- [[CiCd]] — Automating regression execution
- [[TestArchitecture]] — Organizing regression suites
- [[MutationTesting]] — Verifying regression test quality
- [[E2ETesting]] — End-to-end regression validation
- [[VisualRegressionTesting]] — UI regression detection
- [[TestCoverage]] — Measuring regression suite coverage
