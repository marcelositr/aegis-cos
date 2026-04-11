---
title: Design MOC
title_pt: Design — Mapa de Conteúdo
layer: design
type: index
version: 1.0.0
tags:
  - Design
  - MOC
  - Index
description: Navigation hub for software design patterns, principles, and modeling techniques.
description_pt: Hub de navegação para padrões de design de software, princípios e técnicas de modelagem.
---

# Design MOC

## Patterns & Anti-Patterns

- [[DesignPatterns]] — Reusable solutions to common design problems (Creational, Structural, Behavioral)
- [[AntiPatterns]] — Common responses to recurring problems that are ineffective and risky
- [[CodeSmells]] — Surface indicators that usually correspond to a deeper problem in the system

## Design Principles

- [[GRASP]] — General Responsibility Assignment Software Patterns
- [[Contracts]] — Preconditions, postconditions, and invariants that define component agreements
- [[Invariants]] — Conditions that must always be true during execution
- [[InterfaceDesign]] — Designing clean, stable, and minimal interfaces

## Modeling & Structure

- [[DomainModeling]] — Creating abstract models of the problem domain
- [[OOP]] — Designing systems using objects, classes, and their interactions
- [[UMLBasics]] — Unified Modeling Language for visual system design
- [[Refactoring]] — Improving internal structure without changing external behavior
- [[APIDesign]] — Designing clean, consistent, and usable APIs

## Reasoning Path

1. Model the problem: [[DomainModeling]] → [[UMLBasics]]
2. Assign responsibilities: [[GRASP]] → [[OOP]]
3. Define agreements: [[Contracts]] → [[Invariants]] → [[InterfaceDesign]]
4. Apply patterns: [[DesignPatterns]] → avoid [[AntiPatterns]] → detect [[CodeSmells]]
5. Expose cleanly: [[APIDesign]]
6. Improve continuously: [[Refactoring]]

## Cross-Domain Links

- [[DesignPatterns]] → [[SOLID]] → [[OOP]]
- [[AntiPatterns]] → [[CodeSmells]] → [[Refactoring]] → [[CodeQuality]]
- [[GRASP]] → [[DDD]] → [[DomainModeling]]
- [[Contracts]] → [[ContractTesting]] → [[IntegrationTesting]]
- [[APIDesign]] → [[REST]] → [[GraphQLArchitecture]]
- [[InterfaceDesign]] → [[Hexagonal]] → [[Modularity]]
- [[DomainModeling]] → [[DDD]] → [[Microservices]] (bounded contexts)
- [[Refactoring]] → [[TDD]] → [[CiCd]]
