---
title: Metrics
title_pt: Métricas
layer: quality
type: concept
priority: high
version: 1.0.0
tags:
  - Quality
  - Metrics
description: Quantitative measures of code quality and software health.
description_pt: Medidas quantitativas de qualidade de código e saúde de software.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Metrics

## Description

Metrics provide quantitative measures of code quality and software health. Key metrics include:
- **Complexity**: How complicated is the code?
- **Coverage**: How much is tested?
- **Duplication**: How much is repeated?
- **Maintainability**: How easy to change?

## Purpose

**When metrics are valuable:**
- For tracking quality over time
- For identifying problem areas
- For making data-driven decisions
- For setting improvement goals

**When metrics may be misleading:**
- When tracked without action
- When gaming the numbers
- When measuring the wrong thing

**The key question:** What metrics help us improve, and can we act on them?

## Examples

### Measuring Code Quality

```python
class QualityMetrics:
    def measure(self, codebase):
        return {
            'complexity': measure_complexity(codebase),
            'coverage': measure_coverage(codebase),
            'duplication': measure_duplication(codebase),
        }
```

### Setting Quality Thresholds

```python
def check_quality(metrics):
    if metrics['complexity'] > 10:
        fail("Complexity too high")
    if metrics['coverage'] < 80:
        fail("Test coverage below threshold")
```

## Key Metrics

| Metric | Target | Description |
|--------|--------|-------------|
| Cyclomatic Complexity | < 10 | Decision points per function |
| Test Coverage | > 80% | Code covered by tests |
| Duplication | < 5% | Repeated code |
| Coupling | Low | Dependencies between modules |
| Cohesion | High | Relatedness within modules |

## Failure Modes

- **Gaming metrics instead of improving quality** → developers optimize for numbers, not actual quality → metrics become meaningless → use multiple metrics together and review trends, not absolute values
- **Coverage threshold creating false confidence** → 80% coverage but tests assert nothing → bugs slip through despite passing coverage gate → measure assertion quality, not just line coverage
- **Complexity thresholds blocking necessary code** → legitimate complex algorithms rejected by metrics → developers write worse code to pass checks → allow complexity exceptions with documented justification
- **Metrics without baseline or trends** → single measurement without context → cannot tell if quality is improving → track metrics over time and set improvement targets
- **Vanity metrics that look good but mean nothing** → measuring lines of code or commit count → incentivizes wrong behavior → measure outcomes like defect rate and mean time to recovery
- **Metric analysis paralysis** → too many metrics to act on → team ignores all metrics → focus on 3-5 actionable metrics and review them regularly
- **Automated metrics replacing human judgment** → SonarQube score used as sole quality gate → nuanced issues missed → combine automated metrics with code review and manual assessment

## Related Topics

- [[StaticAnalysis]]
- [[TestCoverage]]
- [[CyclomaticComplexity]]
- [[CodeQuality]]
- [[TechnicalDebt]]
- [[QualityGates]]
- [[PerformanceOptimization]]
- [[Refactoring]]

## Anti-Patterns

### 1. Gaming Metrics

**Bad:** Developers writing trivial tests to inflate coverage from 79% to 81%, or splitting functions to reduce cyclomatic complexity without improving clarity
**Why it's bad:** The numbers pass the gate but the code quality is unchanged or worse — you have false confidence and more code to maintain
**Good:** Review the actual code behind the numbers — use metrics to identify areas for discussion, not as automated pass/fail criteria

### 2. Coverage as a Quality Proxy

**Bad:** Assuming 80% test coverage means the code is well-tested, when tests assert nothing meaningful
**Why it's bad:** Lines are executed but behavior is not verified — bugs slip through despite the green coverage badge
**Good:** Measure mutation testing or assertion density alongside coverage — executing a line is not the same as testing it

### 3. Vanity Metrics

**Bad:** Tracking lines of code written, commit count, or number of PRs merged as quality indicators
**Why it's bad:** These metrics incentivize the wrong behavior — verbose code, small meaningless commits, and rubber-stamp reviews
**Good:** Measure outcomes — defect rate, mean time to recovery, lead time for changes, and customer-reported bugs

### 4. Analysis Paralysis

**Bad:** Tracking 20+ metrics on dashboards that nobody looks at or acts on
**Why it's bad:** Signal drowns in noise — the team ignores all metrics because there are too many to process
**Good:** Focus on 3-5 actionable metrics that drive decisions — review them regularly and retire metrics that do not lead to action

## Best Practices

1. **Track metrics over time** - Spot trends
2. **Set realistic targets** - Based on codebase state
3. **Use automation** - Measure in CI/CD
4. **Balance metrics** - Don't optimize single metric
5. **Review regularly** - Adjust thresholds as needed

## Key Takeaways

- Metrics provide quantitative measures of code quality and software health including complexity, coverage, duplication, and maintainability
- Valuable for tracking quality trends over time, identifying problem areas, making data-driven decisions, and setting improvement goals
- Misleading when tracked without action, when teams game the numbers, or when measuring the wrong thing entirely
- Tradeoff: objective visibility into codebase health versus risk of metric gaming and false confidence from superficial numbers
- Main failure mode: developers optimize for metric numbers rather than actual quality—writing trivial tests to inflate coverage or splitting functions to reduce complexity without improving clarity
- Best practice: focus on 3-5 actionable metrics that drive decisions, track trends not absolute values, combine automated metrics with human code review, and measure assertion quality not just line coverage
- Related: static analysis, test coverage, cyclomatic complexity, code quality, technical debt, quality gates, performance optimization
