---
title: Principles MOC
title_pt: Princípios — Mapa de Conteúdo
layer: principles
type: index
version: 1.0.0
tags:
  - Principles
  - MOC
  - Index
description: Navigation hub for software engineering principles that guide design decisions.
description_pt: Hub de navegação para princípios de engenharia de software que guiam decisões de design.
---

# Principles MOC

## Core Principles

- [[SOLID]] — Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- [[DRY]] — Don't Repeat Yourself — eliminate duplication
- [[KISS]] — Keep It Simple, Stupid — prefer simplicity over complexity
- [[YAGNI]] — You Aren't Gonna Need It — avoid over-engineering
- [[FailFast]] — Detect and surface errors early
- [[Idempotency]] — Operations that produce the same result regardless of how many times they're executed
- [[Determinism]] — Same input always produces same output
- [[SeparationOfConcerns]] — Divide system into distinct sections with minimal overlap

## Reasoning Path

1. Start with [[KISS]] + [[YAGNI]] — simplicity first
2. Apply [[DRY]] — eliminate duplication
3. Structure with [[SOLID]] + [[SeparationOfConcerns]] — clean architecture
4. Build resilience with [[FailFast]] + [[Idempotency]] — handle failure
5. Ensure predictability with [[Determinism]] — reproducible behavior

## Cross-Domain Links

- [[SOLID]] → [[DesignPatterns]] → [[OOP]]
- [[DRY]] → [[Refactoring]] → [[CodeQuality]]
- [[KISS]] + [[YAGNI]] → [[Monoliths]] → [[Microservices]] (when to split)
- [[Idempotency]] → [[DistributedSystems]] → [[APIDesign]]
- [[FailFast]] → [[Testing]] → [[Monitoring]]
- [[Determinism]] → [[Testing]] → [[CiCd]]
- [[SeparationOfConcerns]] → [[Layering]] → [[Hexagonal]]
