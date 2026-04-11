---
title: CORE — Map of Content
title_pt: CORE — Mapa de Conteúdo
layer: meta
type: index
version: 1.0.0
tags:
  - CORE
  - Index
  - MOC
description: Top-level navigation hub for the entire CORE vault. Entry point for AI reasoning and human exploration.
description_pt: Hub de navegação de nível superior para todo o vault CORE. Ponto de entrada para raciocínio de IA e exploração humana.
---

# CORE — Map of Content

## Overview

CORE is a structured AI Engineering reasoning dataset covering software engineering fundamentals through advanced architecture, security, testing, and operations.

## Domains

### [[Foundations MOC|Foundations]]
CS theory, algorithms, data structures, complexity, systems thinking — the bedrock of engineering reasoning.

### [[Principles MOC|Principles]]
SOLID, DRY, KISS, YAGNI, Fail Fast, Idempotency, Determinism, Separation of Concerns — guiding principles for engineering decisions.

### [[Architecture MOC|Architecture]]
Microservices, monoliths, distributed systems, CQRS, event sourcing, serverless, hexagonal, DDD, modularity, coupling, cohesion, layering, rate limiting, cloud, edge, IoT, real-time, GraphQL, consensus, consistency, distributed transactions, backpressure.

### [[Design MOC|Design]]
Design patterns, anti-patterns, code smells, GRASP, domain modeling, API design, contracts, OOP, refactoring, invariants, UML, interface design.

### [[Programming MOC|Programming]]
Concurrency, TypeScript, JavaScript, Kotlin, Swift — language-specific reasoning and concurrent programming.

### [[Testing MOC|Testing]]
TDD, BDD, unit, integration, E2E, contract, mutation, property, acceptance, regression, snapshot, fuzzing, mocks, test architecture, test coverage, visual regression.

### [[Quality MOC|Quality]]
Code quality, metrics, linting, formatting, static analysis, cyclomatic complexity, quality gates, technical debt.

### [[Security MOC|Security]]
Authentication, authorization, OAuth2, OIDC, JWT, OWASP Top 10, XSS, SQL injection, CSRF, cryptography, threat modeling, IAM, zero trust, memory safety, input validation, secrets management, secure coding, security audit, vulnerability assessment, penetration testing, supply chain security, security headers, TLS/SSL.

### [[DevOps MOC|DevOps]]
CI/CD, Docker, Kubernetes, container orchestration, infrastructure as code, GitOps, monitoring, observability, logging, alerting, chaos engineering, incident management, service mesh.

### [[Databases MOC|Databases]]
SQL, NoSQL, caching, database optimization.

### [[Network MOC|Network]]
HTTP, HTTPS, REST, WebSockets, DNS, firewall, VPN, network security.

### [[Performance MOC|Performance]]
Performance profiling, optimization, load testing, caching, connection pooling, memory management, latency optimization.

### [[ShellEngineering MOC|Shell Engineering]]
Bash best practices, POSIX shell, pipelines, text processing, awk/sed/grep, environment variables, exit status, job control.

### [[Mobile MOC|Mobile]]
Android, iOS, React Native, cross-platform, Jetpack Compose, SwiftUI, mobile architecture, mobile testing.

### [[AIEngineering MOC|AI Engineering]]
Prompt engineering, AI code review, AI validation, hallucination detection, human verification, AI-augmented development.

## Cross-Domain Reasoning Paths

- **Build a system:** [[Foundations MOC]] → [[Principles MOC]] → [[Architecture MOC]] → [[Design MOC]] → [[Programming MOC]] → [[Testing MOC]] → [[DevOps MOC]]
- **Secure a system:** [[Security MOC]] → [[Network MOC]] → [[Architecture MOC]] → [[DevOps MOC]] → [[Testing MOC]]
- **Scale a system:** [[Architecture MOC]] → [[Databases MOC]] → [[Partitioning]] → [[Performance MOC]] → [[DevOps MOC]] → [[Network MOC]]
- **Ship reliably:** [[DevOps MOC]] → [[Testing MOC]] → [[Quality MOC]] → [[ShellEngineering MOC]]
- **AI-assisted workflow:** [[AI Engineering MOC]] → [[Testing MOC]] → [[Quality MOC]] → [[Programming MOC]]
- **Distributed coordination:** [[StateMachines]] → [[LeaderElection]] → [[Consensus]] → [[ClockSkew]] → [[Consistency]]
- **Data at scale:** [[Partitioning]] → [[MemoryModels]] → [[DistributedTransactions]] → [[SagaPattern]]

## Cross-Domain Topics

- [[CapacityPlanning]] — load modeling, scaling decisions
- [[SchemaEvolution]] — migrations, backward/forward compatibility
- [[Backpressure]] — flow control, reactive streams
- [[MessageQueues]] — pub/sub, Kafka, RabbitMQ
- [[SRE]] — SLO/SLI, error budgets, burn rates
- [[CircuitBreaker]] — circuit breaker, bulkhead, retry patterns
- [[SagaPattern]] — distributed transactions, choreography vs orchestration
- [[ApiGateway]] — routing, rate limiting, authentication offloading
- [[DisasterRecovery]] — RTO/RPO, backup strategies, failover
- [[Consensus]] — Raft, Paxos, distributed agreement
- [[Consistency]] — CAP, eventual, strong consistency
- [[DistributedTransactions]] — Saga deep dive
- [[Tracing]] — Distributed tracing, trace context, sampling
- [[StateMachines]] — Formal state modeling, transitions, workflows
- [[LeaderElection]] — Distributed coordination, primary selection
- [[Partitioning]] — Horizontal data distribution, sharding strategies
- [[MemoryModels]] — Thread memory visibility, happens-before, ordering
- [[ClockSkew]] — Time in distributed systems, logical clocks, causal ordering
