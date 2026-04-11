---
title: Testing MOC
title_pt: Testes — Mapa de Conteúdo
layer: testing
type: index
version: 1.0.0
tags:
  - Testing
  - MOC
  - Index
description: Navigation hub for testing methodologies, strategies, and quality assurance.
description_pt: Hub de navegação para metodologias de teste, estratégias e garantia de qualidade.
---

# Testing MOC

## Methodologies

- [[UnitTest]] — Fundamentals of software testing, types, and strategies
- [[TDD]] — Test-Driven Development: write tests before implementation
- [[BDD]] — Behavior-Driven Development: tests as executable specifications

## Test Levels

- [[UnitTest]] — Testing individual components in isolation
- [[IntegrationTesting]] — Testing interactions between components
- [[AcceptanceTesting]] — Testing system behavior against business requirements
- [[E2ETesting]] — End-to-end testing of complete user workflows
- [[ContractTesting]] — Verifying service interfaces match expectations
- [[RegressionTesting]] — Ensuring changes don't break existing functionality
- [[VisualRegressionTesting]] — Detecting unintended visual changes

## Advanced Techniques

- [[MutationTesting]] — Evaluating test quality by injecting faults
- [[PropertyTesting]] — Testing general properties with randomized inputs
- [[Fuzzing]] — Automated testing with random/malformed inputs
- [[SnapshotTesting]] — Capturing and comparing output snapshots
- [[TestDoubles]] — Test replacements for isolating dependencies

## Test Infrastructure

- [[TestArchitecture]] — Organizing and structuring test suites
- [[TestCoverage]] — Measuring how much code is exercised by tests

## Reasoning Path

1. Start with fundamentals: [[UnitTest]]
2. Adopt methodology: [[TDD]] or [[BDD]]
3. Expand coverage: [[IntegrationTesting]] → [[ContractTesting]] → [[E2ETesting]]
4. Validate quality: [[MutationTesting]] → [[PropertyTesting]] → [[Fuzzing]]
5. Maintain over time: [[RegressionTesting]] → [[SnapshotTesting]] → [[VisualRegressionTesting]]
6. Manage infrastructure: [[TestArchitecture]] → [[TestCoverage]]
7. Isolate dependencies: [[TestDoubles]]

## Cross-Domain Links

- [[TDD]] → [[Refactoring]] → [[SOLID]] → [[CodeQuality]]
- [[BDD]] → [[DomainModeling]] → [[AcceptanceTesting]]
- [[UnitTest]] → [[TestDoubles]] → [[MobileArchitecture]]
- [[IntegrationTesting]] → [[Microservices]] → [[ContractTesting]]
- [[E2ETesting]] → [[Docker]] → [[CiCd]]
- [[MutationTesting]] → [[TestCoverage]] → [[QualityGates]]
- [[Fuzzing]] → [[SecureCoding]] → [[OWASPTop10]] → [[InputValidation]]
- [[RegressionTesting]] → [[CiCd]] → [[Monitoring]]
- [[TestArchitecture]] → [[CiCd]] → [[Observability]]
