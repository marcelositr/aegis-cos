---
title: Quality MOC
title_pt: Qualidade — Mapa de Conteúdo
layer: quality
type: index
version: 1.0.0
tags:
  - Quality
  - MOC
  - Index
description: Navigation hub for code quality metrics, tooling, and quality gates.
description_pt: Hub de navegação para métricas de qualidade de código, ferramentas e gates de qualidade.
---

# Quality MOC

## Quality Attributes

- [[CodeQuality]] — Characteristics that make code maintainable, readable, and robust
- [[TechnicalDebt]] — Future cost of choosing easy solutions now over better approaches

## Metrics & Analysis

- [[Metrics]] — Quantitative measures of code quality and team performance
- [[CyclomaticComplexity]] — Measuring code complexity through decision paths
- [[StaticAnalysis]] — Analyzing code without executing it to find defects
- [[Linting]] — Enforcing style and pattern rules automatically
- [[Formatting]] — Consistent code style across a codebase

## Quality Enforcement

- [[QualityGates]] — Automated checks that must pass before code is merged or deployed

## Reasoning Path

1. Define quality: [[CodeQuality]] → [[Metrics]]
2. Measure: [[CyclomaticComplexity]] → [[StaticAnalysis]] → [[Linting]] → [[Formatting]]
3. Track debt: [[TechnicalDebt]]
4. Enforce: [[QualityGates]]

## Cross-Domain Links

- [[CodeQuality]] → [[Refactoring]] → [[TDD]]
- [[Metrics]] → [[TestCoverage]] → [[MutationTesting]]
- [[CyclomaticComplexity]] → [[Algorithms]] → [[Complexity]]
- [[StaticAnalysis]] → [[SecurityAudit]] → [[SecureCoding]]
- [[Linting]] + [[Formatting]] → [[CiCd]] → [[QualityGates]]
- [[QualityGates]] → [[CiCd]] → [[Monitoring]]
- [[TechnicalDebt]] → [[Refactoring]] → [[YAGNI]] → [[KISS]]
