---
title: Code Quality Handbook
title_pt: Guia de Qualidade de Código
layer: quality
type: handbook
priority: high
version: 1.0.0
tags:
  - Quality
  - CodeQuality
  - Metrics
  - Linting
  - StaticAnalysis
  - TechnicalDebt
description: Consolidated guide covering code quality dimensions, metrics, tooling, and debt management.
description_pt: Guia consolidado cobrindo dimensões de qualidade de código, métricas, ferramentas e gerenciamento de dívida técnica.
prerequisites: []
estimated_read_time: 20 min
difficulty: intermediate
---

# Code Quality Handbook

## Quality Dimensions

Code quality is multi-dimensional. High-quality code excels across all dimensions:

- **Maintainability** — Easy to change and extend
- **Readability** — Easy to understand and review
- **Testability** — Easy to verify correctness
- **Efficiency** — Good performance characteristics
- **Security** — Free from vulnerabilities
- **Reliability** — Handles errors gracefully

## Metrics That Matter

### Cyclomatic Complexity

Measures independent paths through code. Each `if`, `for`, `while`, `case` adds 1.

| Score | Meaning | Action |
|-------|---------|--------|
| 1-10 | Low | Good, keep it |
| 11-20 | Moderate | Review, consider simplifying |
| 21-50 | High | Refactor needed |
| 50+ | Critical | Must refactor immediately |

```python
# High complexity (CC = 10+) — needs refactoring
def complex_function(data):
    result = 0
    for item in data:
        if item.active:
            if item.value > 100:
                if item.category == "A":
                    result += item.value * 0.9
                elif item.category == "B":
                    result += item.value * 0.8
            elif item.value > 50:
                result += item.value * 0.95
    return result

# Refactored (CC = 3)
DISCOUNT_RATES = {
    ("A", "high"): 0.9,
    ("B", "high"): 0.8,
    ("default", "medium"): 0.95,
}

def get_discount(category, value):
    tier = "high" if value > 100 else "medium" if value > 50 else "low"
    return DISCOUNT_RATES.get((category, tier), 1.0)

def calculate_total(data):
    return sum(item.value * get_discount(item.category, item.value) for item in data if item.active)
```

### Key Quality Thresholds

| Metric | Target | Why |
|--------|--------|-----|
| Cyclomatic Complexity | < 10 per function | Testable, understandable |
| Test Coverage | > 80% | Catch regressions |
| Code Duplication | < 5% | DRY, maintainable |
| Function Length | < 30 lines | Single responsibility |
| File Length | < 300 lines | Cohesive module |
| Nesting Depth | < 4 levels | Readable logic |

## Tooling Stack

### Linting — Style and Pattern Enforcement

```yaml
# Python: ruff (fast, comprehensive)
# pip install ruff
# ruff check src/

# JavaScript/TypeScript: ESLint + Prettier
# npm install --save-dev eslint prettier
# npx eslint src/ && npx prettier --check src/

# Run in CI
- name: Lint
  run: |
    ruff check src/
    eslint src/
    prettier --check src/
```

### Static Analysis — Bug and Vulnerability Detection

```python
# Python: mypy (type checking)
# mypy src/ --strict

# Python: bandit (security)
# bandit -r src/

# Python: pylint (comprehensive)
# pylint src/ --fail-under=8

# Multi-language: SonarQube
# sonar-scanner
# Reports: bugs, vulnerabilities, code smells, coverage, duplication
```

### Quality Gates — Automated Enforcement

```yaml
# GitHub Actions quality gate
- name: Quality Gate
  if: always()
  run: |
    # All checks must pass
    ruff check src/ --fail-under=8
    coverage report --fail-under=80
    mypy src/ --strict
    bandit -r src/ --exit-zero  # Log but don't block on security warnings
```

## Technical Debt Management

### Types of Debt

- **Intentional** — Conscious shortcuts: "we'll fix this after launch"
- **Unintentional** — Accidental poor choices due to lack of knowledge
- **Code** — Duplicated code, long methods, magic numbers
- **Architecture** — Tight coupling, wrong abstractions
- **Test** — Missing or brittle tests

### Debt Repayment Strategy

```
20% of each sprint on technical debt
- Fix high-complexity functions first
- Eliminate duplication hotspots
- Add tests for critical untested paths
- Update documentation for confusing areas
```

### Tracking Debt

```python
# Use TODO comments with context
# TODO(refactor): Extract payment logic into separate service — Est: 4h — Priority: High
# TODO(test): Add tests for edge cases in order validation — Est: 2h

# Track in project management tool
# Link code TODOs to backlog items
# Review debt list in sprint planning
```

## Failure Modes

- **Perfectionism** → endless refactoring → no features shipped
- **No standards** → inconsistent codebase → high cognitive load
- **Tool obsession** → optimizing metrics → ignoring real quality
- **Review bottlenecks** → too strict PR process → slow delivery
- **Quality debt ignored** → compounding complexity → velocity drops
- **Coverage obsession** → 100% coverage with shallow assertions → false confidence
- **Metric gaming** → writing tests to hit numbers, not to verify behavior

## Anti-Patterns

### 1. Quality Handbook as Shelfware

**Bad:** Writing a comprehensive quality handbook that nobody reads or references in daily work
**Why it's bad:** The handbook becomes a document that exists only for audits — developers continue making the same quality mistakes because the guidance is not embedded in their workflow
**Good:** Embed handbook principles into automated tooling (linters, CI gates, PR templates) so quality enforcement happens without requiring anyone to read a document

### 2. One-Size-Fits-All Thresholds

**Bad:** Applying the same complexity thresholds, coverage requirements, and lint rules to every project regardless of context
**Why it's bad:** A throwaway prototype and a financial system have vastly different quality needs — uniform thresholds either over-constrain simple projects or under-constrain critical ones
**Good:** Calibrate quality thresholds to project risk, lifespan, and team size — use the handbook as a menu, not a mandate

### 3. Debt Repayment Without Prioritization

**Bad:** Addressing technical debt in the order it was discovered rather than by impact
**Why it's bad:** You spend sprint capacity fixing cosmetic issues while critical architectural debt continues to slow down every feature
**Good:** Prioritize debt by impact on velocity, risk of failure, and frequency of modification — fix the debt that hurts most first

### 4. Metrics Dashboard Without Action

**Bad:** Maintaining elaborate quality dashboards that are never reviewed in sprint planning or retrospectives
**Why it's bad:** Data without action is noise — the team cannot tell if quality is improving or degrading, and stakeholders lose trust in the metrics
**Good:** Review quality metrics in every sprint — set improvement targets, celebrate progress, and adjust thresholds based on trends

## Best Practices

1. **Automate quality checks in CI** — don't rely on human review alone
2. **Set realistic thresholds** — based on current codebase state, not ideal
3. **Track trends, not absolutes** — is quality improving or degrading?
4. **Address debt regularly** — 20% of sprint capacity
5. **Review code with quality lens** — not just "does it work" but "is it maintainable"
6. **Use linters aggressively** — catch style issues automatically
7. **Type-check everything** — catch errors before runtime
8. **Keep functions small** — single responsibility, easy to test

## Related Topics

- [[Refactoring]] — Improving code structure without changing behavior
- [[TDD]] — Test-driven development for quality by design
- [[SOLID]] — Design principles for maintainable code
- [[CodeSmells]] — Surface indicators of deeper problems
- [[DesignPatterns]] — Reusable solutions to common problems
- [[CiCd]] — Automating quality enforcement
- [[TestCoverage]] — Measuring what code is tested
- [[MutationTesting]] — Evaluating test quality
- [[StaticAnalysis]] — Finding bugs without executing code
- [[Linting]] — Enforcing style and pattern rules
- [[TechnicalDebt]] — Managing accumulated quality shortcuts
- [[QualityGates]] — Automated quality checkpoints

## Key Takeaways

- Code quality spans multiple dimensions: maintainability, readability, testability, efficiency, security, and reliability — all must be balanced.
- Use continuously across all projects to catch regressions early, manage technical debt, and maintain team velocity over time.
- Do NOT optimize for metrics alone (coverage obsession, cyclomatic complexity thresholds) at the expense of real code quality and feature delivery.
- Key tradeoff: investing in quality practices (linting, testing, type-checking) vs. short-term feature delivery speed that compounds into long-term slowdown.
- Main failure mode: perfectionism leading to endless refactoring with no features shipped, or ignoring quality debt until velocity drops to near zero.
- Best practice: automate quality checks in CI, set realistic thresholds based on current state, dedicate 20% of sprint capacity to debt repayment, and track trends not absolutes.
- Related concepts: Cyclomatic Complexity, Technical Debt, Static Analysis, Linting, TDD, Refactoring, SOLID, CI/CD Quality Gates.
