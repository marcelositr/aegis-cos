---
title: Static Analysis
title_pt: Análise Estática
layer: quality
type: concept
priority: high
version: 1.0.0
tags:
  - Quality
  - StaticAnalysis
description: Analysis of software without executing it, finding defects and quality issues.
description_pt: Análise de software sem executá-lo, encontrando defeitos e problemas de qualidade.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Static Analysis

## Description

Static analysis examines code without executing it, identifying:
- Code smells
- Potential bugs
- Security vulnerabilities
- Style violations
- Complexity issues

## Purpose

**When static analysis is valuable:**
- For automated code review
- For catching bugs before runtime
- For enforcing coding standards
- For security scanning

**When it may not help:**
- For logic/business rule errors
- When tools are poorly configured
- When warnings are ignored

**The key question:** Can static analysis catch issues before they reach production?

## Examples

```python
# Bandit - Python security checker
# Install: pip install bandit
# Run: bandit -r mymodule/

# Example output
>> Issue: [B413:blacklist] Use of insecure MD5 hash
   Severity: Medium
   Confidence: High
   Location: mymodule.py:23
   More info: https://bandit.readthedocs.io/en/latest/plugins/b413_use_of_md5.html
   import hashlib
   hashlib.md5(data).hexdigest()
```

```python
# SonarQube - Comprehensive analysis
# Run: sonar-scanner

# Reports:
# - Bugs: 3
# - Vulnerabilities: 1
# - Code smells: 45
# - Coverage: 78%
# - Duplication: 5%
```

```python
# Type checking with mypy
def process_items(items: list[int]) -> int:
    return sum(items)

# Run: mypy mymodule.py
# mymodule.py:10: error: Argument 1 to "sum" has incompatible type "str"; expected "Iterable[int]"
```

## Anti-Patterns

### 1. False Positive Fatigue

**Bad:** Enabling every available rule and flooding developers with hundreds of warnings, most of which are spurious
**Why it's bad:** Developers learn to ignore all static analysis output — including the real bugs hidden in the noise
**Good:** Start with high-confidence rules only, gradually add more as the team builds trust — a tool that finds 5 real bugs is better than one that reports 500 warnings

### 2. Analysis Without Integration

**Bad:** Running static analysis locally where results are optional and easily ignored
**Why it's bad:** Developers under deadline pressure skip the analysis — issues reach production that the tool would have caught
**Good:** Make static analysis a blocking CI gate — code cannot merge until analysis passes with zero critical issues

### 3. Over-Reliance on Automated Analysis

**Bad:** Assuming that passing static analysis means the code is correct, and skipping manual code review
**Why it's bad:** Static analysis cannot catch logic errors, design flaws, or domain-specific issues — it only finds patterns it was programmed to detect
**Good:** Combine static analysis with human code review — tools catch mechanical issues, humans catch conceptual ones

### 4. Configuration Drift

**Bad:** Each developer and CI environment using different rule sets and tool versions
**Why it's bad:** Code passes analysis on one machine but fails on another — inconsistent quality enforcement and wasted debugging time
**Good:** Share analysis configuration in version control — pin tool versions and rule sets so every environment produces identical results

## Best Practices

### 1. Run in CI Pipeline

```yaml
- name: Static Analysis
  run: |
    mypy src/
    pylint src/
    bandit -r src/
    sonar-scanner
```

### 2. Set Quality Gates

```yaml
quality_gate:
  min_sonarqube_rating: A
  max_critical_bugs: 0
  max_security_issues: 0
  min_coverage: 80%
```

### 3. Fix Issues Regularly

```python
# Don't let issues accumulate
# Address warnings in PRs
# Make it part of workflow
```

## Failure Modes

- **False positive fatigue** → too many spurious warnings → developers ignore all static analysis output → tune rules to reduce noise and only enable high-confidence checks
- **Static analysis not integrated in CI** → analysis runs locally and results are ignored → issues reach production → make static analysis a blocking CI gate with clear pass criteria
- **Analysis configuration drift** → different team members use different rule sets → inconsistent quality enforcement → share analysis config in version control and enforce in CI
- **Security analysis missing custom rules** → generic rules miss application-specific vulnerabilities → false sense of security → add custom rules for application-specific security patterns
- **Analysis performance blocking development** → full analysis takes too long → developers skip it → use incremental analysis and run full analysis only in CI
- **Ignoring analysis results** → warnings accumulate over time → critical issues buried in noise → fix issues as they appear and maintain zero-warning policy
- **Over-reliance on automated analysis** → assuming tools catch all issues → manual review skipped → combine static analysis with code review and manual security assessment

## Related Topics

- [[Linting]]
- [[Metrics]]
- [[CodeQuality]]
- [[SecurityHeaders]]
- [[InputValidation]]
- [[QualityGates]]
- [[CiCd]]
- [[TypeScript]]

## Key Takeaways

- Static analysis examines code without executing it to find bugs, security vulnerabilities, style violations, and complexity issues before runtime
- Valuable for automated code review, catching bugs before runtime, enforcing coding standards, and security scanning
- Cannot catch logic/business rule errors, design flaws, or domain-specific issues; poorly configured tools produce noise
- Tradeoff: early defect detection and automated enforcement versus false positive fatigue and the risk of over-reliance replacing human judgment
- Main failure mode: enabling every available rule floods developers with hundreds of spurious warnings, causing them to ignore all static analysis output including real bugs
- Best practice: start with high-confidence rules only and gradually expand, make analysis a blocking CI gate with zero critical issues, share configuration in version control, and combine with human code review
- Related: linting, metrics, code quality, security headers, input validation, quality gates, CI/CD
