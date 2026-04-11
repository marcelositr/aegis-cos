---
title: Architecture MOC
title_pt: Arquitetura — Mapa de Conteúdo
layer: architecture
type: index
version: 1.0.0
tags:
  - Architecture
  - MOC
  - Index
description: Navigation hub for software architecture patterns, styles, and decision frameworks.
description_pt: Hub de navegação para padrões de arquitetura de software, estilos e frameworks de decisão.
---

# Architecture MOC

## Architectural Styles

- [[Monoliths]] — Single unified codebase, simple to start, hard to scale
- [[Microservices]] — Loosely coupled, independently deployable services
- [[Serverless]] — Event-driven, managed infrastructure, pay-per-use
- [[EdgeComputing]] — Processing closer to data sources
- [[IoTArchitecture]] — Sensor networks, constrained devices, edge-to-cloud
- [[CloudComputing]] — On-demand computing resources over the internet

## Architectural Patterns

- [[Layering]] — Organizing code into horizontal layers of responsibility
- [[Hexagonal]] — Ports and adapters, isolating core from infrastructure
- [[CQRS]] — Command Query Responsibility Segregation — separate read and write models
- [[EventSourcing]] — Persist state as a sequence of events
- [[EventArchitecture]] — Event-driven communication between components
- [[DistributedSystems]] — Multiple independent nodes coordinating over a network
- [[Modularity]] — Organizing code into cohesive, loosely coupled modules
- [[GraphQLArchitecture]] — Query language API with flexible data fetching
- [[RealTimeArchitecture]] — Low-latency, bidirectional communication patterns
- [[MessageQueues]] — Async communication via brokers (Kafka, RabbitMQ)
- [[CircuitBreaker]] — Preventing cascading failures with fast-fail patterns
- [[SagaPattern]] — Distributed transactions with compensating actions
- [[ApiGateway]] — Single entry point for routing, auth, rate limiting
- [[Backpressure]] — Flow control for producer-consumer pipelines

## Distributed Systems Concepts

- [[Consensus]] — Algorithms for reaching agreement (Raft, Paxos)
- [[Consistency]] — Consistency models (CAP, eventual, strong)
- [[DistributedTransactions]] — Saga pattern, distributed transactions
- [[DistributedSystems]] — Multiple independent nodes coordinating over a network

## Structural Concepts

- [[Cohesion]] — How closely related responsibilities are within a module
- [[Coupling]] — Degree of interdependence between modules
- [[RateLimiting]] — Controlling request throughput to protect systems
- [[DDD]] — Domain-Driven Design — aligning software with business domain

## Reasoning Path

1. Start simple with [[Monoliths]] → understand when to evolve
2. Apply [[Cohesion]] + [[Coupling]] → evaluate module quality
3. Choose style: [[Microservices]] vs [[Serverless]] vs [[Monoliths]]
4. Apply patterns: [[Layering]] → [[Hexagonal]] → [[DDD]]
5. Handle data flow: [[EventArchitecture]] → [[CQRS]] → [[EventSourcing]]
6. Scale: [[DistributedSystems]] → [[RateLimiting]] → [[CloudComputing]]
7. Specialize: [[RealTimeArchitecture]], [[EdgeComputing]], [[IoTArchitecture]], [[GraphQLArchitecture]]

## Cross-Domain Links

- [[Microservices]] → [[Docker]] → [[Kubernetes]] → [[CiCd]]
- [[DistributedSystems]] → [[Concurrency]] → [[Idempotency]]
- [[CQRS]] → [[EventSourcing]] → [[SQL]] → [[NoSQL]]
- [[DDD]] → [[DomainModeling]] → [[GRASP]]
- [[Hexagonal]] → [[DesignPatterns]] → [[UnitTest]]
- [[RateLimiting]] → [[APIDesign]] → [[SecurityHeaders]]
- [[Serverless]] → [[CloudComputing]] → [[Monitoring]]
- [[EventArchitecture]] → [[MessageQueues]] → [[Observability]]
- [[Modularity]] → [[SeparationOfConcerns]] → [[CodeQuality]]
