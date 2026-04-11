---
title: Technical Debt
title_pt: Dívida Técnica
layer: quality
type: concept
priority: high
version: 1.0.0
tags:
  - Quality
  - TechnicalDebt
description: Implied cost of additional rework caused by choosing quick solutions over better approaches.
description_pt: Custo implícito de retrabalho adicional causado por escolher soluções rápidas ao invés de abordagens melhores.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Technical Debt

## Description

Technical debt is the cost of future rework caused by taking shortcuts now. Like financial debt, it accumulates interest over time.

Types:
- **Intentional**: Known shortcuts taken consciously
- **Unintentional**: Accidental poor choices
- **Code**: Poor code quality
- **Architecture**: Design-level issues

## Purpose

**When technical debt tracking matters:**
- For long-term project health
- When velocity decreases over time
- When refactoring is frequently needed
- For making debt visible to stakeholders

**When it may not be a priority:**
- For short-lived projects
- When speed is critical
- When debt is low

**The key question:** Is this shortcut worth its future cost?

## Examples

```python
# Example: Hardcoded values instead of config
# Now: Works, but config changes require code changes
API_KEY = "secret-key"

# Better: Load from config
API_KEY = os.getenv("API_KEY")
```

### Types of Debt

- **Intentional**: Known shortcuts taken consciously — "we'll fix this after launch"
- **Unintentional**: Accidental poor choices due to lack of knowledge
- **Code**: Poor code quality — duplicated code, long methods, magic numbers
- **Architecture**: Design-level issues — tight coupling, wrong abstractions
- **Test**: Missing or brittle tests that don't catch regressions

Managing debt:
- Track it in your backlog
- Pay it down regularly (20% of each sprint)
- Don't let it compound — interest grows exponentially

## Tracking

```python
# Track technical debt
# TODO comments are one approach
# TODO: Refactor this to use proper database connection pool
# Debt: 2 hours estimated

# Use debt tracking tools
# SonarQube, CodeClimate, etc.
```

## Anti-Patterns

### 1. Intentional Debt Becoming Permanent

**Bad:** Taking a shortcut with the promise "we'll fix this after launch" — and never revisiting it
**Why it's bad:** The temporary hack becomes the foundation that other code is built on — fixing it later requires a massive refactor that nobody has time for
**Good:** Set explicit review dates for every intentional debt item and enforce follow-through — treat debt repayment as a commitment, not a wish

### 2. Paying the Wrong Debt First

**Bad:** Addressing low-impact cosmetic debt while critical architectural debt continues to slow down every feature
**Why it's bad:** The team feels productive fixing easy items, but velocity does not improve because the real bottlenecks remain
**Good:** Prioritize debt by impact on velocity, risk of failure, and frequency of modification — fix the debt that hurts most first

### 3. Debt Competing with Features

**Bad:** Leaving debt repayment to compete with feature work in the same backlog — features always win
**Why it's bad:** Debt compounds silently while stakeholders celebrate feature delivery — eventually the system becomes unmaintainable
**Good:** Allocate a fixed percentage of each sprint (e.g., 20%) to debt repayment — make it non-negotiable, not optional

### 4. Underestimating Debt Interest

**Bad:** Treating technical debt as a one-time cost rather than a compounding liability
**Why it's bad:** Every new feature built on top of debt makes the debt harder to fix — the cost grows exponentially, not linearly
**Good:** Factor in future maintenance cost when evaluating whether to take on debt — a shortcut that saves 1 hour today may cost 10 hours next month

## Best Practices

### 1. Address Regularly

```python
# Schedule debt repayment
# 20% of sprint on tech debt
# Pay down debt incrementally
# Track with TODOs, issue tracker, or SonarQube
```

### 2. Document Debt

```python
# Add comments explaining debt
# Use TODO markers with estimates
# Add to project debt log
```

## Failure Modes

- **Technical debt never tracked or measured** → debt accumulates invisibly → velocity drops without understanding why → track debt in backlog with estimates and review regularly
- **Debt repayment competing with features** → business always prioritizes new features → debt compounds until system is unmaintainable → allocate fixed percentage of each sprint to debt repayment
- **Underestimating debt interest** → assuming debt is static cost → debt compounds exponentially as more code builds on it → factor in future maintenance cost when evaluating debt trade-offs
- **Paying wrong debt first** → addressing low-impact debt while critical debt remains → wasted effort with no velocity improvement → prioritize debt by impact on velocity, risk, and frequency of modification
- **Debt documentation becoming stale** → TODO comments never addressed → documentation loses credibility → link debt items to backlog tickets and review in sprint planning
- **Intentional debt becoming permanent** → planned shortcuts never revisited → temporary hacks become permanent architecture → set explicit review dates for intentional debt and enforce follow-through
- **Not communicating debt to stakeholders** → business unaware of quality impact → unrealistic feature expectations → visualize debt impact on velocity and present business case for repayment

## Related Topics

- [[Refactoring]]
- [[CodeQuality]]
- [[Metrics]]
- [[CyclomaticComplexity]]
- [[StaticAnalysis]]
- [[QualityGates]]
- [[CiCd]]
- [[SOLID]]

## Key Takeaways

- Technical debt is the cost of future rework caused by taking shortcuts now, accumulating interest like financial debt
- Tracking matters for long-term project health, when velocity decreases, or when refactoring is frequently needed
- Not a priority for short-lived projects, speed-critical situations, or when debt is genuinely low
- Tradeoff: short-term delivery speed versus compounding long-term maintenance costs that slow future development
- Main failure mode: debt never tracked or measured accumulates invisibly until velocity drops without understanding why
- Best practice: allocate fixed percentage of each sprint (20%) to debt repayment, prioritize by impact on velocity and risk, set explicit review dates for intentional debt, and visualize debt impact to stakeholders
- Related: refactoring, code quality, metrics, cyclomatic complexity, static analysis, quality gates, CI/CD
