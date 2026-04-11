---
title: Test Coverage
title_pt: Cobertura de Testes
layer: testing
type: concept
priority: high
version: 1.0.0
tags:
  - Testing
  - TestCoverage
description: Measuring what percentage of code is tested.
description_pt: Medindo qual porcentagem do código é testada.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Test Coverage

## Description

Test coverage measures how much code is executed by tests:
- **Line coverage**: Lines executed
- **Branch coverage**: Branches taken
- **Function coverage**: Functions called

## Purpose

**When test coverage is useful:**
- For identifying untested code
- For setting quality baselines
- For regression detection
- For ensuring minimum quality

**When coverage may be misleading:**
- 100% coverage doesn't mean bug-free
- For creative/business logic
- When testing the wrong thing

**The key question:** What percentage of code is tested, and is it the right code?

## Examples

```bash
# Python with coverage.py
# pip install coverage
coverage run -m pytest
coverage report

# Output
# Name              Stmts   Miss  Cover   Missing
# ------------------------------------------------
# mymodule             20      1    95%     15, 20
```

## Coverage Reports

```bash
# HTML report
coverage html

# XML for CI
coverage xml -o coverage.xml

# Minimum coverage
coverage report --fail-under=80
```

## Best Practices

### 1. Aim High but Not 100%

```python
# 80% is good target
# 100% often means testing trivial code
```

### 2. Cover Important Paths

```python
# Focus on critical code paths
# Business logic first
# Boilerplate later
```

## Coverage Types

### Line Coverage
Percentage of source code lines executed by tests.
- **Pros:** Easy to understand, widely supported
- **Cons:** Doesn't verify correctness, can be gamed

### Branch Coverage
Percentage of decision branches (if/else, switch cases) taken.
- **Pros:** More thorough than line coverage
- **Cons:** Harder to achieve, may test impossible branches

### Function/Method Coverage
Percentage of functions/methods called by tests.
- **Pros:** Ensures all functions are exercised
- **Cons:** Doesn't verify all paths within functions

### Statement Coverage
Percentage of executable statements executed.
- **Pros:** Granular measurement
- **Cons:** Similar limitations to line coverage

### Path Coverage
Percentage of all possible execution paths tested.
- **Pros:** Most thorough coverage type
- **Cons:** Often impractical (exponential paths)

## Coverage vs Quality

**Coverage tells you what was executed, not what was verified.**

```python
# 100% line coverage, 0% quality
def divide(a, b):
    return a / b  # Covered by test

def test_divide():
    divide(10, 2)  # Doesn't test divide(10, 0)!
```

**Good coverage focuses on:**
- Business logic paths
- Error handling branches
- Edge cases (empty, null, boundary values)
- Integration points between components

## Failure Modes

- **Coverage obsession** → writing tests to hit numbers, not to verify behavior
- **Ignoring untested code** → critical paths may be uncovered
- **False confidence** → 90% coverage with shallow assertions
- **Coverage regression** → new code lowers coverage without anyone noticing
- **Gaming the metric** → tests that call functions without asserting anything

## Anti-Patterns

### 1. Coverage Obsession

**Bad:** Writing tests solely to hit a coverage percentage target, with assertions that verify nothing meaningful
**Why it's bad:** 90% coverage with shallow assertions gives false confidence — the code is "covered" but bugs slip through because the tests do not actually verify behavior
**Good:** Focus on assertion quality, not just line execution — a test that executes 5 lines and verifies the result is better than one that executes 100 lines and asserts nothing

### 2. Gaming the Metric

**Bad:** Calling functions from tests without asserting anything, or writing trivial tests for boilerplate code to inflate coverage numbers
**Why it's bad:** The coverage report looks green but the critical business logic is untested — you have optimized for the metric, not for quality
**Good:** Use mutation testing alongside coverage — if a test suite cannot detect intentionally introduced bugs, the coverage number is meaningless

### 3. Ignoring Untested Code

**Bad:** Focusing on increasing overall coverage while critical paths (error handling, edge cases, security checks) remain untested
**Why it's bad:** The overall number looks good but the most dangerous code paths have zero test coverage — production bugs cluster in the untested areas
**Good:** Use coverage reports to identify untested critical paths — prioritize testing error handling, boundary conditions, and security-sensitive code over boilerplate

### 4. Coverage Regression Without Detection

**Bad:** New code lowers overall coverage but nobody notices because there is no threshold enforcement
**Why it's bad:** Coverage drifts downward over time — each PR adds a few untested lines, and within months the codebase has significant untested areas
**Good:** Enforce minimum coverage thresholds in CI (`--fail-under=80`) and track coverage trends over time — reject PRs that lower coverage below the threshold

## Related Topics

- [[UnitTesting]]
- [[QualityGates]]
- [[MutationTesting]]
- [[StaticAnalysis]]
- [[Metrics]]
- [[CiCd]]
- [[CodeQuality]]
- [[IntegrationTesting]]
